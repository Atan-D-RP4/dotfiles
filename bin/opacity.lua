#!/usr/bin/env luajit

-- Increment/decrement the active window's opacity in Hyprland.
-- Dependencies: dkjson (install via luarocks or pacman)

local json = require("dkjson")

local MEM_FILE = "/tmp/hypr_alpha_memory.json"
local STEP = 0.1
local MIN_OPACITY, MAX_OPACITY = 0.1, 1.0

local function die(msg, code)
	io.stderr:write("Error: " .. msg .. "\n")
	os.exit(code or 1)
end

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	else
		return false
	end
end

local function read_json(path)
	if not file_exists(path) then
		return {}
	end
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()
	if content == "" then
		return {}
	end
	local data, _, err = json.decode(content)
	if err then
		die("Failed to parse JSON: " .. err)
	end
	return data
end

local function write_json(path, tbl)
	local tmp = path .. ".tmp"
	local f = io.open(tmp, "w")
	if not f then
		die("Cannot write to temp file: " .. tmp)
	end
	f:write(json.encode(tbl, { indent = false }))
	f:close()
	os.rename(tmp, path)
end

local function run(cmd)
	local f = io.popen(cmd)
	if not f then
		die("Command failed: " .. cmd)
	end
	local output = f:read("*a")
	f:close()
	return output
end

local function get_active_window_address()
	local output = run("hyprctl activewindow -j")
	return output:match([["address"%s*:%s*"([^"]+)"]])
end

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local function main()
	local direction = arg[1]
	if direction ~= "--increase" and direction ~= "--decrease" then
		die("Usage: " .. arg[0] .. " --increase | --decrease")
	end

	local addr = get_active_window_address()
	if not addr then
		die("No active window found")
	end

	local state = read_json(MEM_FILE)
	local current = state[addr] or 1.0
	local delta = (direction == "--increase") and STEP or -STEP
	local new_alpha = clamp(current + delta, MIN_OPACITY, MAX_OPACITY)

	-- Apply to active window
	os.execute(string.format("hyprctl dispatch setprop address:%s alphaoverride 1", addr))
	os.execute(string.format("hyprctl dispatch setprop address:%s alpha %.3f", addr, new_alpha))

	-- Save to file
	state[addr] = new_alpha
	write_json(MEM_FILE, state)

	-- Optional feedback
	os.execute(string.format('notify-send "Opacity set to %.2f" "Window %s"', new_alpha, addr))
end

main()
