#!/usr/bin/env luajit

-- Hyprland Pinch-to-Zoom Script
-- Monitors libinput gestures and controls screen zoom via hyprctl
local LOCK_FILE = "/tmp/hyprland_zoom.lock"

-- Configuration
local config = {
	zoom_sensitivity = 1.5, -- How responsive zoom is to pinch gestures (1.0=normal, 2.0=more sensitive)
	zoom_acceleration = 0.8, -- Additional scaling for faster gestures (0.5=conservative, 1.5=aggressive)

	-- ZOOM LIMITS
	zoom_min = 1.0, -- Minimum zoom level (normal)
	zoom_max = 3.0, -- Maximum zoom level

	gesture_threshold = 0.01, -- Min gesture to trigger zoom (browser-like sensitivity)
	smoothing_factor = 1.0, -- Gesture smoothing (higher = smoother, browser-like)
	deadzone = 0.05, -- Ignore very small scale changes (reduces jitter)

	continuous_zoom = true, -- Enable continuous zoom updates during gesture
	zoom_momentum = 0, -- Slight momentum effect after gesture ends
	scale_damping = 0.92, -- Damping factor for scale changes (more browser-like)

	-- ROBUSTNESS
	restart_delay = 2.0, -- Seconds to wait before restarting libinput on failure
	max_restarts = 5, -- Maximum restart attempts before giving up
	heartbeat_interval = 30, -- Seconds between heartbeat checks

	-- DEBUG
	debug = false, -- Enable debug output
}

-- Global state
local state = {
	current_zoom = 1.0,
	target_zoom = 1.0,
	gesture_active = false,
	gesture_start_zoom = 1.0,
	base_scale = 1.0,
	last_scale = 1.0,
	accumulated_scale = 1.0,
	scale_velocity = 0.0,
	should_exit = false,
	restart_count = 0,
	last_heartbeat = os.time(),
	libinput_handle = nil,
}

-- Utility functions
local function debug_print(msg, ...)
	if config.debug then
		local timestamp = os.date("%H:%M:%S")
		print(string.format("[%s DEBUG] %s", timestamp, string.format(msg, ...)))
	end
end

local function log_print(msg, ...)
	local timestamp = os.date("%H:%M:%S")
	print(string.format("[%s]", timestamp), msg, ...)
end

local function clamp(value, min_val, max_val)
	return math.max(min_val, math.min(max_val, value))
end

-- Smooth interpolation function (browser-like)
local function smooth_step(current, target, factor)
	return current + (target - current) * factor
end

-- Check if Hyprland is running
local function is_hyprland_running()
	local handle = io.popen("pgrep -x Hyprland >/dev/null 2>&1")
	local result = handle:close()
	return result == true or result == 0
end

-- Execute hyprctl command with error handling
local function execute_hyprctl(cmd)
	if not is_hyprland_running() then
		debug_print("Hyprland not running, exiting...")
		state.should_exit = true
		return nil
	end

	local full_cmd = "hyprctl " .. cmd .. " 2>/dev/null"
	debug_print("Executing: %s", full_cmd)

	local handle = io.popen(full_cmd)
	if not handle then
		debug_print("Failed to execute hyprctl command")
		return nil
	end

	local result = handle:read("*a")
	local success = handle:close()

	if not success then
		debug_print("hyprctl command failed")
		return nil
	end

	return result
end

-- Set zoom level with validation and smoothing
local function set_zoom(zoom_level, immediate)
	zoom_level = clamp(zoom_level, config.zoom_min, config.zoom_max)

	if immediate then
		state.target_zoom = zoom_level
		state.current_zoom = zoom_level
	else
		state.target_zoom = zoom_level
		-- Smooth transition to target (browser-like)
		state.current_zoom = smooth_step(state.current_zoom, state.target_zoom, config.smoothing_factor)
	end

	-- Only update if there's a significant change
	if
		state.last_applied_zoom
		and math.abs(state.current_zoom - state.last_applied_zoom) < config.gesture_threshold
	then
		debug_print("No significant zoom change detected (%.2f -> %.2f)", state.last_applied_zoom, state.current_zoom)
		return false
	end

	local cmd
	if state.current_zoom <= 1.01 then
		cmd = "keyword cursor:zoom_factor 1"
		debug_print("Zoom disabled")
	else
		cmd = string.format("keyword cursor:zoom_factor %.2f", state.current_zoom)
		debug_print("Zoom set to %.2f (target: %.2f)", state.current_zoom, state.target_zoom)
	end

	local result = execute_hyprctl(cmd)
	if result ~= nil then
		state.last_applied_zoom = state.current_zoom
		return true
	end

	return false
end

-- Reset zoom to normal
local function reset_zoom()
	debug_print("Resetting zoom to 1.0")
	return set_zoom(1.0, true)
end

-- Parse libinput gesture event
---@param line string|nil
---@return "begin"|"end"|"update"|nil, number|nil
local function parse_gesture_event(line)
	if not line then
		return nil
	end

	-- Update heartbeat
	state.last_heartbeat = os.time()

	-- Look for pinch gesture events
	if line:match("GESTURE_PINCH_BEGIN") then
		state.gesture_active = true
		state.gesture_start_zoom = state.current_zoom
		state.base_scale = nil
		state.accumulated_scale = 1.0
		state.scale_velocity = 0.0
		debug_print("Pinch gesture started, current zoom: %.2f", state.current_zoom)
		return "begin"
	elseif line:match("GESTURE_PINCH_END") then
		state.gesture_active = false
		debug_print("Pinch gesture ended, final zoom: %.2f", state.current_zoom)

		-- Apply momentum if enabled
		if config.zoom_momentum > 0 and math.abs(state.scale_velocity) > 0.01 then
			local momentum_zoom = state.current_zoom * (1 + state.scale_velocity * config.zoom_momentum)
			debug_print("Applying momentum: %.3f -> %.2f", state.current_zoom, momentum_zoom)
			set_zoom(momentum_zoom)
		end

		return "end"
	elseif line:match("GESTURE_PINCH_UPDATE") then
		local scale_str = line:match("([%-%.%d]+)%s+@")
		local scale = tonumber(scale_str)
		if scale and state.gesture_active then
			return "update", scale
		end
	end

	return nil
end

-- Process gesture update (browser-like behavior)
local function process_gesture_update(scale)
	if not state.gesture_active then
		return
	end

	-- Set base scale on first update
	if not state.base_scale then
		state.base_scale = scale
		state.last_scale = scale
		debug_print("Base scale set to: %.3f", scale)
		return
	end

	-- Calculate scale change from last update (more responsive)
	local scale_delta = scale - state.last_scale
	local scale_change = scale_delta * config.scale_damping

	-- Apply deadzone to reduce jitter
	if math.abs(scale_change) < config.deadzone then
		return
	end

	-- Update velocity for momentum calculation
	state.scale_velocity = state.scale_velocity * 0.8 + scale_change * 0.2

	-- Calculate relative scale factor (browser-like)
	local relative_scale = scale / state.base_scale

	-- Apply browser-like scaling with sensitivity
	local zoom_factor
	if relative_scale > 1.0 then
		-- Zooming in
		zoom_factor = 1.0 + (relative_scale - 1.0) * config.zoom_sensitivity
	else
		-- Zooming out
		zoom_factor = 1.0 - (1.0 - relative_scale) * config.zoom_sensitivity
	end

	-- Apply acceleration for larger gestures (more browser-like)
	local gesture_magnitude = math.abs(relative_scale - 1.0)
	local acceleration = 1.0 + gesture_magnitude * config.zoom_acceleration
	zoom_factor = 1.0 + (zoom_factor - 1.0) * acceleration

	-- Calculate new zoom level
	local new_zoom = state.gesture_start_zoom * zoom_factor

	debug_print(
		"Scale: %.3f->%.3f, Delta: %.3f, Relative: %.3f, Factor: %.3f, New zoom: %.2f",
		state.last_scale,
		scale,
		scale_delta,
		relative_scale,
		zoom_factor,
		new_zoom
	)

	-- Apply zoom with smoothing
	if config.continuous_zoom then
		set_zoom(new_zoom, false) -- Smooth transition
	else
		set_zoom(new_zoom, true) -- Immediate
	end

	state.last_scale = scale
end

-- Cleanup function
local function cleanup()
	log_print("Cleaning up...")

	-- Close libinput handle if open
	if state.libinput_handle then
		debug_print("Closing libinput handle")
		state.libinput_handle:close()
		state.libinput_handle = nil
	end

	local lock_handle = io.open(LOCK_FILE, "w")
	if lock_handle then
		lock_handle:close()
		os.remove(LOCK_FILE)
		debug_print("Lock file removed: %s", LOCK_FILE)
	else
		debug_print("Failed to remove lock file: %s", LOCK_FILE)
	end
	-- Reset zoom
	reset_zoom()

	-- Kill any linger libinput processes
	local cmd = "pkill -f 'libinput-debug-events' 2>/dev/null"
	local result = os.execute(cmd)
	if result then
		debug_print("Killed lingering libinput processes")
	else
		debug_print("No lingering libinput processes found")
	end

	log_print("Cleanup complete")
end

-- Signal handler setup
local function setup_signal_handlers()
	-- Try to load posix.signal for proper signal handling
	local signal_ok, signal = pcall(require, "posix.signal")

	if signal_ok and signal then
		debug_print("Setting up POSIX signal handlers")

		local function signal_handler(signum)
			log_print("Received signal %d, exiting gracefully...", signum)
			state.should_exit = true
		end

		-- Handle common termination signals
		signal.signal(signal.SIGINT, signal_handler) -- Ctrl+C
		signal.signal(signal.SIGTERM, signal_handler) -- Termination request
		signal.signal(signal.SIGHUP, signal_handler) -- Hangup
		signal.signal(signal.SIGPIPE, signal_handler) -- Broken pipe

		return true
	else
		debug_print("POSIX signals not available, using basic signal handling")
		return false
	end
end

-- Check for libinput availability
local function check_libinput()
	local handle = io.popen("command -v libinput >/dev/null 2>&1")
	local result = handle:close()
	return result == true or result == 0
end

-- Start libinput monitoring with restart capability
local function start_libinput_monitor()
	if not check_libinput() then
		log_print("ERROR: libinput command not found")
		return false
	end

	while not state.should_exit and state.restart_count < config.max_restarts do
		log_print("Starting libinput monitoring (attempt %d/%d)", state.restart_count + 1, config.max_restarts)

		-- Start libinput debug-events with line buffering
		local cmd = "stdbuf -oL libinput debug-events 2>/dev/null"
		state.libinput_handle = io.popen(cmd)

		if not state.libinput_handle then
			log_print("ERROR: Failed to start libinput debug-events")
			log_print("Are you allowed to read input devices?")
			log_print("If not, add a udev rule to allow your user access.")
			log_print("udev rule file placed in /etc/udev/rules.d/99-input.rules:")
			log_print('KERNEL="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"')
			log_print("Reload udev rules with: sudo udevadm control --reload-rules && sudo udevadm trigger")
			log_print("Ensure your user is in the 'input' group: sudo usermod -aG input $USER")
			state.restart_count = state.restart_count + 1

			if state.restart_count < config.max_restarts then
				log_print("Retrying in %.1f seconds...", config.restart_delay)
				os.execute(string.format("sleep %.1f", config.restart_delay))
			end

			goto continue
		end

		log_print("Libinput monitoring started successfully")
		state.restart_count = 0 -- Reset restart counter on success

		-- Main event loop
		while not state.should_exit do
			local line = state.libinput_handle:read("*l")

			-- Check for EOF or read error
			if not line then
				debug_print("Libinput stream ended or error occurred")
				break
			end

			-- Process the line
			local event_type, scale = parse_gesture_event(line)

			if event_type == "update" and scale then
				process_gesture_update(scale)
			end

			-- Periodic checks
			local current_time = os.time()
			if current_time - state.last_heartbeat > config.heartbeat_interval then
				-- Check if Hyprland is still running
				if not is_hyprland_running() then
					log_print("Hyprland no longer running, exiting...")
					state.should_exit = true
					break
				end

				debug_print("Heartbeat: script still running")
				state.last_heartbeat = current_time
			end
		end

		-- Close handle
		if state.libinput_handle then
			state.libinput_handle:close()
			state.libinput_handle = nil
		end

		-- If we're not supposed to exit, this was an unexpected termination
		if not state.should_exit then
			log_print("Libinput monitoring stopped unexpectedly")
			state.restart_count = state.restart_count + 1

			if state.restart_count < config.max_restarts then
				log_print("Restarting in %.1f seconds...", config.restart_delay)
				os.execute(string.format("sleep %.1f", config.restart_delay))
			else
				log_print("Maximum restart attempts reached, giving up")
				break
			end
		end

		::continue::
	end

	return state.restart_count < config.max_restarts
end

-- Get touchpad device (informational)
local function get_touchpad_device()
	local handle = io.popen("libinput list-devices 2>/dev/null")
	if not handle then
		return nil
	end

	local output = handle:read("*a")
	handle:close()

	for device in output:gmatch("Device:%s*([^\n]+)") do
		if device:lower():match("touchpad") or device:lower():match("trackpad") then
			debug_print("Found touchpad: %s", device)
			return device
		end
	end

	return nil
end

-- Main function
local function main()
	log_print("Hyprland Browser-Like Pinch-to-Zoom Script starting...")
	log_print("PID: %d", os.execute("echo $$") or "unknown")

	if config.debug then
		log_print("Debug mode enabled")
	end

	-- Check if Hyprland is running
	if not is_hyprland_running() then
		log_print("ERROR: Hyprland is not running")
		os.exit(1)
	end

	-- Setup signal handlers
	local has_posix_signals = setup_signal_handlers()
	if not has_posix_signals then
		log_print("WARNING: Limited signal handling available")
	end

	-- Get touchpad info
	local touchpad = get_touchpad_device()
	if touchpad then
		log_print("Detected touchpad: %s", touchpad)
	else
		log_print("WARNING: No touchpad detected, but continuing anyway...")
	end

	-- Ensure zoom starts at 1.0
	reset_zoom()

	log_print("Browser-like Configuration:")
	log_print("  Zoom sensitivity: %.2f", config.zoom_sensitivity)
	log_print("  Zoom acceleration: %.2f", config.zoom_acceleration)
	log_print("  Zoom range: %.1f - %.1f", config.zoom_min, config.zoom_max)
	log_print("  Gesture threshold: %.3f", config.gesture_threshold)
	log_print("  Smoothing factor: %.2f", config.smoothing_factor)
	log_print("  Continuous zoom: %s", config.continuous_zoom and "enabled" or "disabled")
	log_print("  Zoom momentum: %.2f", config.zoom_momentum)

	-- Start monitoring
	local success = start_libinput_monitor()

	if success then
		log_print("Exiting normally")
	else
		log_print("Exiting due to errors")
	end

	-- Cleanup
	cleanup()

	os.exit(success and 0 or 1)
end

-- Entry point
if arg and arg[0] then
	-- Parse command line arguments
	for i, v in ipairs(arg) do
		if v == "--debug" then
			config.debug = true
		elseif v == "--help" or v == "-h" then
			print("Hyprland Browser-Like Pinch-to-Zoom Script")
			print("Usage: " .. arg[0] .. " [--debug] [--help]")
			print("")
			print("Options:")
			print("  --debug    Enable debug output")
			print("  --help     Show this help")
			print("")
			print("This script monitors touchpad pinch gestures and controls")
			print("Hyprland's cursor zoom feature with browser-like behavior.")
			print("")
			print("The script will automatically exit when Hyprland stops running.")
			os.exit(0)
		end
	end

	-- Install cleanup handler for normal exit
	local original_exit = os.exit
	os.exit = function(code)
		cleanup()
		original_exit(code or 0)
	end

	local lock_handle = io.open(LOCK_FILE, "r")
	if lock_handle then
		log_print("Another instance is already running.")
		log_print("Killing the existing instance...")
		local pid = lock_handle:read("*l")

		if pid then
			local kill_cmd = string.format("kill -9 %s 2>/dev/null", pid)
			os.execute(kill_cmd)
			log_print("Killed existing instance with PID: %s", pid)
		else
			log_print("ERROR: Failed to read PID from lock file. Exiting.")
		end
		-- Remove stale lock file
		os.remove(LOCK_FILE)
		log_print("Lock file removed: %s", LOCK_FILE)
		lock_handle:close()
		os.exit(1)
	else
		lock_handle = io.open(LOCK_FILE, "w")
		if lock_handle then
			local pid
			-- Read /proc/self/stat to get the PID
			local stat_handle = io.open("/proc/self/stat", "r")
			if stat_handle then
				local stat_line = stat_handle:read("*l")
				stat_handle:close()
				pid = stat_line:match("^(%d+)")
			end
			if pid then
				lock_handle:write(pid)
				lock_handle:flush()
				log_print("Lock file created: %s (PID: %s)", LOCK_FILE, pid)
			else
				log_print("ERROR: Failed to get PID for lock file. Exiting.")
				lock_handle:close()
				os.exit(1)
			end
			lock_handle:close()
		else
			log_print("ERROR: Failed to create lock file. Exiting.")
			os.exit(1)
		end
	end

	-- Run main function with error handling
	local success, err = pcall(main)
	if not success then
		log_print("ERROR: %s", err)
		cleanup()
		os.exit(1)
	end
end
