---@meta

-- Type definitions for Niri IPC Protocol
-- Based on: https://yalter.github.io/niri/niri_ipc/

---@alias EventVariant
---|"WorkspacesChanged"|"WorkspaceUrgencyChanged"|"WorkspaceActivated"|"WorkspaceActiveWindowChanged"|
---|"WindowsChanged"|"WindowOpenedOrChanged"|"WindowClosed"|"WindowFocusChanged"|
---|"WindowFocusTimestampChanged"|"WindowUrgencyChanged"|"WindowLayoutsChanged"|"KeyboardLayoutsChanged"|
---|"KeyboardLayoutSwitched"|"OverviewOpenedOrClosed"|"ConfigLoaded"|"ScreenshotCaptured"

---@alias RequestType
---|"Version"|"Outputs"|"Workspaces"|"Windows"|"Layers"|"KeyboardLayouts"|
---|"FocusedOutput"|"FocusedWindow"|"PickWindow"|"PickColor"|"Action"|
---|"Output"|"EventStream"|"ReturnError"|"OverviewState"

---@alias ColumnDisplay
---|"stack"|"tabbed"|"stacked"

---@alias LayoutSwitchTarget
---|"prev"|"next"

---@alias SizeChange
---|"SetExact"|"Adjust"|"SetAuto"

---@alias WorkspaceReferenceArg
---{index: integer}|--as workspace index
---{name: string}|--as workspace name

---@class EventData
---@field event_type EventVariant
---@field data table

---@class WorkspaceEvent
---@field workspaces table[]

---@class WorkspaceUrgencyEvent
---@field id number
---@field urgent boolean

---@class WorkspaceActivatedEvent
---@field id number
---@field focused boolean

---@class WorkspaceActiveWindowEvent
---@field workspace_id number
---@field active_window_id number|nil

---@class WindowEvent
---@field windows table[]

---@class WindowEvent
---@field window table

---@class WindowFocusEvent
---@field id number|nil

---@class WindowFocusTimestampEvent
---@field id number
---@field focus_timestamp table|nil

---@class WindowUrgencyEvent
---@field id number
---@field urgent boolean

---@class WindowLayoutChangeEvent
---@field changes table[] -- Array of {window_id, layout} pairs

---@class KeyboardLayoutsEvent
---@field keyboard_layouts table

---@class KeyboardLayoutSwitchedEvent
---@field idx number

---@class OverviewEvent
---@field is_open boolean

---@class ConfigLoadedEvent
---@field failed boolean

---@class ScreenshotCapturedEvent
---@field path string|nil

---@class ActionResult
--- Actions are fire-and-forget, most return simple success indication
---@field success boolean|nil
---@field message string|nil

---@class ResponseData
--- Command response data - runtime type is always table, structure varies by command
--- This is documented type info for IDE support, not runtime enforcement
---@field version string|nil -- from "Version" command
---@field outputs table|nil -- from "Outputs" command
---@field workspaces table|nil -- from "Workspaces" command
---@field windows table|nil -- from "Windows" command
---@field layers table|nil -- from "Layers" command
---@field keyboard_layouts table|nil -- from "KeyboardLayouts" command
---@field output table|nil -- from "Output" and "FocusedOutput" commands
---@field window table|nil -- from "FocusedWindow" and "PickWindow" commands
---@field color table|nil -- from "PickColor" command
---@field overview table|nil -- from "OverviewState" command
---@field error string|nil -- from error responses

---@class WindowData
---@field id number
---@field title string|nil
---@field app_id string|nil
---@field is_focused boolean
---@field workspace_id number|nil
---@field fullscreen boolean
---@field floating boolean

---@class WorkspaceData
---@field id number
---@field idx number|nil
---@field name string|nil
---@field output string|nil

---@class OutputData
---@field name string
---@field width number
---@field height number
---@field scale number|nil

---@class EventData
--- Event data from niri IPC - runtime type is always table, structure varies by event
--- Based on niri-ipc/src/lib.rs Event enum definitions
---@field windows table[]|nil -- WorkspacesChanged, WindowsChanged
---@field workspaces table[]|nil -- WorkspacesChanged
---@field id number|nil -- WorkspaceUrgencyChanged, WorkspaceActivated, WindowClosed, WindowFocusChanged, WindowFocusTimestampChanged, WindowUrgencyChanged, ToggleWindowUrgent
---@field urgent boolean|nil -- WorkspaceUrgencyChanged, WindowUrgencyChanged
---@field focused boolean|nil -- WorkspaceActivated
---@field workspace_id number|nil -- WorkspaceActiveWindowChanged
---@field active_window_id number|nil -- WorkspaceActiveWindowChanged
---@field window table|nil -- WindowOpenedOrChanged
---@field focus_timestamp table|nil -- WindowFocusTimestampChanged, Window (has focus_timestamp field)
---@field changes table[]|nil -- WindowLayoutsChanged - array of {window_id, layout}
---@field keyboard_layouts table|nil -- KeyboardLayoutsChanged
---@field idx number|nil -- KeyboardLayoutSwitched
---@field is_open boolean|nil -- OverviewOpenedOrClosed
---@field failed boolean|nil -- ConfigLoaded
---@field path string|nil -- ScreenshotCaptured

---@class EventWrapper
--- IPC event wrapper format from niri
--- Events arrive as [event_type, event_data] arrays
---@field [1] EventVariant -- event type identifier
---@field [2] table|nil -- event-specific data

---@class WindowData
--- Complete window data from Niri IPC
--- Based on niri-ipc/src/lib.rs Window struct (lines 1277-1317)
---@field id number -- u64
---@field title string|nil -- Option<String>
---@field app_id string|nil -- Option<String>
---@field pid number|nil -- Option<i32>
---@field workspace_id number|nil -- Option<u64>
---@field is_focused boolean -- bool
---@field is_floating boolean -- bool
---@field is_urgent boolean -- bool
---@field layout WindowLayoutData -- WindowLayout
---@field focus_timestamp TimestampData|nil -- Option<Timestamp>

---@class WindowLayoutData
--- Window layout information from Niri IPC
--- Based on niri-ipc/src/lib.rs WindowLayout struct (lines 1347-1360)
---@field tile_size SizeData|nil -- Option<Size>
---@field tile_pos PositionData|nil -- Option<Position>
---@field window_size SizeData|nil -- Option<Size>
---@field window_offset PositionData|nil -- Option<Position>
---@field fullscreen boolean -- bool

---@class SizeData
---@field width number
---@field height number

---@class PositionData
---@field x number
---@field y number

---@class TimestampData
---@field secs number -- i64
---@field nanos number -- u32

---@class WorkspaceData
--- Complete workspace data from Niri IPC
--- Based on niri-ipc/src/lib.rs Workspace struct (lines 1388-1415)
---@field id number -- u64
---@field idx number -- u8
---@field name string|nil -- Option<String>
---@field output string|nil -- Option<String>
---@field is_urgent boolean -- bool
---@field is_active boolean -- bool

---@class KeyboardLayoutData
---@field name string -- String
---@field variant string -- String
---@field bindings table -- HashMap<String, Key>

---@class KeyboardLayoutsData
---@field layouts KeyboardLayoutData[] -- Vec<KeyboardLayout>
---@field current_layout number -- u8

---@class Window
---@field id number
---@field title string|nil
---@field app_id string|nil
---@field is_focused boolean
---@field workspace_id number|nil
---@field fullscreen boolean
---@field floating boolean
---@field width number|nil
---@field height number|nil
---@field x number|nil
---@field y number|nil
---@field width_change number|nil
---@field height_change number|nil

---@class Workspace
---@field id number
---@field idx number|nil
---@field name string|nil
---@field output string|nil

---@class Layout
---@field width number
---@field height number

---@class Output
---@field name string
---@field make string|nil
---@field model string|nil
---@field serial string|nil
---@field width number
---@field height number
---@field refresh_rate number
---@field logical_width number
---@field logical_height number
---@field logical_x number
---@field logical_y number
---@field transform string|nil
---@field adaptive_sync boolean
---@field scale number

---@class KeyboardLayouts
---@field layouts table[]

---@class KeyboardLayout
---@field name string
---@field variant string
---@field bindings table

---@class ColumnDisplay
---@field display ColumnDisplay

---@class Timestamp
---@field secs number
---@field nanos number

---@class SizeChange
---@field size_change SizeChange

---@class PositionChange
---@field position_change PositionChange

---@class Action -- Complex action types with their specific fields
---@field action_type string

---@class SpawnAction
---@field action_type "Spawn"
---@field command string[]

---@class SpawnShAction
---@field action_type "SpawnSh"
---@field command string

---@class ScreenshotAction
---@field action_type "Screenshot"
---@field show_pointer boolean
---@field path string|nil

---@class ScreenshotScreenAction
---@field action_type "ScreenshotScreen"
---@field write_to_disk boolean
---@field show_pointer boolean
---@field path string|nil

---@class ScreenshotWindowAction
---@field action_type "ScreenshotWindow"
---@field id number|nil
---@field write_to_disk boolean
---@field show_pointer boolean
---@field path string|nil

---@class CloseWindowAction
---@field action_type "CloseWindow"
---@field id number|nil

---@class FullscreenWindowAction
---@field action_type "FullscreenWindow"
---@field id number|nil

---@class ToggleWindowedFullscreenAction
---@field action_type "ToggleWindowedFullscreen"
---@field id number|nil

---@class FocusWindowAction
---@field action_type "FocusWindow"
---@field id number

---@class FocusWindowInColumnAction
---@field action_type "FocusWindowInColumn"
---@field index number

---@class FocusColumnAction
---@field action_type "FocusColumn"
---@field index number

---@class SetColumnDisplayAction
---@field action_type "SetColumnDisplay"
---@field display ColumnDisplay

---@class CenterWindowAction
---@field action_type "CenterWindow"
---@field id number|nil

---@class SetWindowWidthAction
---@field action_type "SetWindowWidth"
---@field id number|nil
---@field change SizeChange

---@class SetWindowHeightAction
---@field action_type "SetWindowHeight"
---@field id number|nil
---@field change SizeChange

---@class ResetWindowHeightAction
---@field action_type "ResetWindowHeight"
---@field id number|nil

---@class MaximizeWindowToEdgesAction
---@field action_type "MaximizeWindowToEdges"
---@field id number|nil

---@class ToggleWindowFloatingAction
---@field action_type "ToggleWindowFloating"
---@field id number|nil

---@class MoveWindowToWorkspaceAction
---@field action_type "MoveWindowToWorkspace"
---@field window_id number|nil
---@field reference WorkspaceReferenceArg
---@field focus boolean

---@class SetWorkspaceNameAction
---@field action_type "SetWorkspaceName"
---@field name string
---@field workspace WorkspaceReferenceArg|nil

---@class UnsetWorkspaceNameAction
---@field action_type "UnsetWorkspaceName"
---@field reference WorkspaceReferenceArg|nil

---@class ToggleWindowUrgentAction
---@field action_type "ToggleWindowUrgent"
---@field id number

---@class SetWindowUrgentAction
---@field action_type "SetWindowUrgent"
---@field id number

---@class UnsetWindowUrgentAction
---@field action_type "UnsetWindowUrgent"
---@field id number

---@class OutputAction
---@field output string
---@field action OutputAction

---@class DoScreenTransitionAction
---@field action_type "DoScreenTransition"
---@field delay_ms number|nil

---@class QuitAction
---@field action_type "Quit"
---@field skip_confirmation boolean

---@class PowerOffMonitorsAction
---@field action_type "PowerOffMonitors"

---@class PowerOnMonitorsAction
---@field action_type "PowerOnMonitors"

---@class ToggleKeyboardShortcutsInhibitAction
---@field action_type "ToggleKeyboardShortcutsInhibit"

---@class LoadConfigFileAction
---@field action_type "LoadConfigFile"

---@class DebugToggleDamageAction
---@field action_type "DebugToggleDamage"

---@class DebugToggleOpaqueRegionsAction
---@field action_type "DebugToggleOpaqueRegions"

---@class ToggleDebugTintAction
---@field action_type "ToggleDebugTint"

---@class ShowHotkeyOverlayAction
---@field action_type "ShowHotkeyOverlay"

---@class OpenOverviewAction
---@field action_type "OpenOverview"

---@class CloseOverviewAction
---@field action_type "CloseOverview"

---@class ToggleOverviewAction
---@field action_type "ToggleOverview"

---@class CenterColumnAction
---@field action_type "CenterColumn"

---@class CenterVisibleColumnsAction
---@field action_type "CenterVisibleColumns"

---@class FocusColumnLeftAction
---@field action_type "FocusColumnLeft"

---@class FocusColumnRightAction
---@field action_type "FocusColumnRight"

---@class FocusColumnFirstAction
---@field action_type "FocusColumnFirst"

---@class FocusColumnLastAction
---@field action_type "FocusColumnLast"

---@class FocusColumnRightOrFirstAction
---@field action_type "FocusColumnRightOrFirst"

---@class FocusColumnLeftOrLastAction
---@field action_type "FocusColumnLeftOrLast"

---@class MoveColumnLeftAction
---@field action_type "MoveColumnLeft"

---@class MoveColumnRightAction
---@field action_type "MoveColumnRight"

---@class MoveColumnToFirstAction
---@field action_type "MoveColumnToFirst"

---@class MoveColumnToLastAction
---@field action_type "MoveColumnToLast"

---@class MoveColumnToIndexAction
---@field action_type "MoveColumnToIndex"
---@field index number

---@class MoveColumnLeftOrToMonitorLeftAction
---@field action_type "MoveColumnLeftOrToMonitorLeft"

---@class MoveColumnRightOrToMonitorRightAction
---@field action_type "MoveColumnRightOrToMonitorRight"

---@class MoveColumnToMonitorAction
---@field action_type "MoveColumnToMonitor"
---@field output string

---@class FocusWindowOrMonitorUpAction
---@field action_type "FocusWindowOrMonitorUp"

---@class FocusWindowOrMonitorDownAction
---@field action_type "FocusWindowOrMonitorDown"

---@class FocusColumnOrMonitorLeftAction
---@field action_type "FocusColumnOrMonitorLeft"

---@class FocusColumnOrMonitorRightAction
---@field action_type "FocusColumnOrMonitorRight"

---@class MoveWindowDownAction
---@field action_type "MoveWindowDown"

---@class MoveWindowUpAction
---@field action_type "MoveWindowUp"

---@class MoveWindowDownOrColumnLeftAction
---@field action_type "MoveWindowDownOrColumnLeft"

---@class MoveWindowDownOrColumnRightAction
---@field action_type "MoveWindowDownOrColumnRight"

---@class MoveWindowUpOrColumnLeftAction
---@field action_type "MoveWindowUpOrColumnLeft"

---@class MoveWindowUpOrColumnRightAction
---@field action_type "MoveWindowUpOrColumnRight"

---@class FocusWindowOrWorkspaceDownAction
---@field action_type "FocusWindowOrWorkspaceDown"

---@class FocusWindowOrWorkspaceUpAction
---@field action_type "FocusWindowOrWorkspaceUp"

---@class FocusWindowTopAction
---@field action_type "FocusWindowTop"

---@class FocusWindowBottomAction
---@field action_type "FocusWindowBottom"

---@class FocusWindowDownOrTopAction
---@field action_type "FocusWindowDownOrTop"

---@class FocusWindowUpOrBottomAction
---@field action_type "FocusWindowUpOrBottom"

---@class MoveWindowToWorkspaceDownAction
---@field action_type "MoveWindowToWorkspaceDown"
---@field focus boolean

---@class MoveWindowToWorkspaceUpAction
---@field action_type "MoveWindowToWorkspaceUp"
---@field focus boolean

---@class MoveWindowToFloatingAction
---@field action_type "MoveWindowToFloating"
---@field id number|nil

---@class MoveWindowToTilingAction
---@field action_type "MoveWindowToTiling"
---@field id number|nil

---@class FocusFloatingAction
---@field action_type "FocusFloating"

---@class FocusTilingAction
---@field action_type "FocusTiling"

---@class SwitchFocusBetweenFloatingAndTilingAction
---@field action_type "SwitchFocusBetweenFloatingAndTiling"

---@class MoveFloatingWindowAction
---@field action_type "MoveFloatingWindow"
---@field id number|nil
---@field x PositionChange|nil
---@field y PositionChange|nil

---@class ToggleWindowRuleOpacityAction
---@field action_type "ToggleWindowRuleOpacity"
---@field id number|nil

---@class SetDynamicCastWindowAction
---@field action_type "SetDynamicCastWindow"
---@field id number|nil

---@class SetDynamicCastMonitorAction
---@field action_type "SetDynamicCastMonitor"
---@field output string|nil

---@class ClearDynamicCastTargetAction
---@field action_type "ClearDynamicCastTarget"

---@class FocusWorkspaceDownAction
---@field action_type "FocusWorkspaceDown"

---@class FocusWorkspaceUpAction
---@field action_type "FocusWorkspaceUp"

---@class FocusWorkspaceAction
---@field action_type "FocusWorkspace"
---@field reference WorkspaceReferenceArg

---@class FocusWorkspacePreviousAction
---@field action_type "FocusWorkspacePrevious"

---@class MaximizeColumnAction
---@field action_type "MaximizeColumn"

---@class ExpandColumnToAvailableWidthAction
---@field action_type "ExpandColumnToAvailableWidth"

---@class SwitchLayoutAction
---@field action_type "SwitchLayout"
---@field layout LayoutSwitchTarget

---@class SwitchPresetColumnWidthAction
---@field action_type "SwitchPresetColumnWidth"

---@class SwitchPresetColumnWidthBackAction
---@field action_type "SwitchPresetColumnWidthBack"

---@class SwitchPresetWindowWidthAction
---@field action_type "SwitchPresetWindowWidth"
---@field id number|nil

---@class SwitchPresetWindowWidthBackAction
---@field action_type "SwitchPresetWindowWidthBack"
---@field id number|nil

---@class SwitchPresetWindowHeightAction
---@field action_type "SwitchPresetWindowHeight"
---@field id number|nil

---@class SwitchPresetWindowHeightBackAction
---@field action_type "SwitchPresetWindowHeightBack"
---@field id number|nil

---@class ConsumeOrExpelWindowLeftAction
---@field action_type "ConsumeOrExpelWindowLeft"
---@field id number|nil

---@class ConsumeOrExpelWindowRightAction
---@field action_type "ConsumeOrExpelWindowRight"
---@field id number|nil

---@class ConsumeWindowIntoColumnAction
---@field action_type "ConsumeWindowIntoColumn"

---@class ExpelWindowFromColumnAction
---@field action_type "ExpelWindowFromColumn"

---@class SwapWindowRightAction
---@field action_type "SwapWindowRight"

---@class SwapWindowLeftAction
---@field action_type "SwapWindowLeft"

---@class ToggleColumnTabbedDisplayAction
---@field action_type "ToggleColumnTabbedDisplay"

---@class SetColumnWidthAction
---@field action_type "SetColumnWidth"
---@field change SizeChange

---@class MoveWorkspaceDownAction
---@field action_type "MoveWorkspaceDown"

---@class MoveWorkspaceUpAction
---@field action_type "MoveWorkspaceUp"

---@class MoveWorkspaceToIndexAction
---@field action_type "MoveWorkspaceToIndex"
---@field index number
---@field reference WorkspaceReferenceArg|nil

---@class MoveWorkspaceToMonitorAction
---@field action_type "MoveWorkspaceToMonitor"
---@field output string
---@field reference WorkspaceReferenceArg|nil

---@class MoveWorkspaceToMonitorLeftAction
---@field action_type "MoveWorkspaceToMonitorLeft"

---@class MoveWorkspaceToMonitorRightAction
---@field action_type "MoveWorkspaceToMonitorRight"

---@class MoveWorkspaceToMonitorDownAction
---@field action_type "MoveWorkspaceToMonitorDown"

---@class MoveWorkspaceToMonitorUpAction
---@field action_type "MoveWorkspaceToMonitorUp"

---@class MoveWorkspaceToMonitorPreviousAction
---@field action_type "MoveWorkspaceToMonitorPrevious"

---@class MoveWorkspaceToMonitorNextAction
---@field action_type "MoveWorkspaceToMonitorNext"

---@class MoveColumnToWorkspaceAction
---@field action_type "MoveColumnToWorkspace"
---@field reference WorkspaceReferenceArg
---@field focus boolean

---@class MoveColumnToWorkspaceDownAction
---@field action_type "MoveColumnToWorkspaceDown"
---@field focus boolean

---@class MoveColumnToWorkspaceUpAction
---@field action_type "MoveColumnToWorkspaceUp"
---@field focus boolean

---@class FocusMonitorLeftAction
---@field action_type "FocusMonitorLeft"

---@class FocusMonitorRightAction
---@field action_type "FocusMonitorRight"

---@class FocusMonitorDownAction
---@field action_type "FocusMonitorDown"

---@class FocusMonitorUpAction
---@field action_type "FocusMonitorUp"

---@class FocusMonitorPreviousAction
---@field action_type "FocusMonitorPrevious"

---@class FocusMonitorNextAction
---@field action_type "FocusMonitorNext"

---@class FocusMonitorAction
---@field action_type "FocusMonitor"
---@field output string

---@class MoveWindowToMonitorAction
---@field action_type "MoveWindowToMonitor"
---@field id number|nil
---@field output string

---@class MoveWindowToMonitorLeftAction
---@field action_type "MoveWindowToMonitorLeft"

---@class MoveWindowToMonitorRightAction
---@field action_type "MoveWindowToMonitorRight"

---@class MoveWindowToMonitorDownAction
---@field action_type "MoveWindowToMonitorDown"

---@class MoveWindowToMonitorUpAction
---@field action_type "MoveWindowToMonitorUp"

---@class MoveWindowToMonitorPreviousAction
---@field action_type "MoveWindowToMonitorPrevious"

---@class MoveWindowToMonitorNextAction
---@field action_type "MoveWindowToMonitorNext"

---@class MoveColumnToMonitorLeftAction
---@field action_type "MoveColumnToMonitorLeft"

---@class MoveColumnToMonitorRightAction
---@field action_type "MoveColumnToMonitorRight"

---@class MoveColumnToMonitorDownAction
---@field action_type "MoveColumnToMonitorDown"

---@class MoveColumnToMonitorUpAction
---@field action_type "MoveColumnToMonitorUp"

---@class MoveColumnToMonitorPreviousAction
---@field action_type "MoveColumnToMonitorPrevious"

---@class MoveColumnToMonitorNextAction
---@field action_type "MoveColumnToMonitorNext"

---@class MoveColumnToMonitorAction
---@field action_type "MoveColumnToMonitor"
---@field output string

---@class ToggleWindowUrgentAction
---@field action_type "ToggleWindowUrgent"
---@field id number

-- Utility functions for type checking and validation

---@param command string|table
---@return RequestType|boolean
local function get_request_type(command)
	if type(command) ~= "string" and type(command) ~= "table" then
		return false, "Invalid command type"
	end

	-- Check if command is a Request enum variant
	local requestTypes = {
		Version = true,
		Outputs = true,
		Workspaces = true,
		Windows = true,
		Layers = true,
		KeyboardLayouts = true,
		FocusedOutput = true,
		FocusedWindow = true,
		PickWindow = true,
		PickColor = true,
		Output = true,
		EventStream = true,
		ReturnError = true,
		OverviewState = true,
	}

	if requestTypes[command] then
		return command, true
	end

	-- Check if command is an Action wrapper
	if type(command) == "table" and command.Action then
		return "Action", true
	end

	return false, "Unknown command type"
end

---@param action table
---@return ActionResult|boolean
local function get_action_result(action)
	if type(action) ~= "table" or not action.action_type then
		return false, "Invalid action format"
	end

	-- Most actions return simple success/failure
	return {
		success = true,
		message = nil,
	}, true
end

-- Event type mapping for dispatcher
---@param event table
---@return EventData|boolean
local function classify_event(event)
	if type(event) ~= "table" or not event[1] then
		return false, "Invalid event format"
	end

	local event_type = event[1]
	local data = event[2] or {}

	return {
		event_type = event_type,
		data = data,
	}, true
end

return {
	-- Request types (actual Lua tables for runtime use)
	RequestType = {
		"Version", "Outputs", "Workspaces", "Windows", "Layers", "KeyboardLayouts",
		"FocusedOutput", "FocusedWindow", "PickWindow", "PickColor", "Action",
		"Output", "EventStream", "ReturnError", "OverviewState"
	},

	-- Event variants (actual Lua table for runtime use)
	EventVariant = {
		"WorkspacesChanged", "WorkspaceUrgencyChanged", "WorkspaceActivated", "WorkspaceActiveWindowChanged",
		"WindowsChanged", "WindowOpenedOrChanged", "WindowClosed", "WindowFocusChanged",
		"WindowFocusTimestampChanged", "WindowUrgencyChanged", "WindowLayoutsChanged", "KeyboardLayoutsChanged",
		"KeyboardLayoutSwitched", "OverviewOpenedOrClosed", "ConfigLoaded", "ScreenshotCaptured"
	},

	-- Type aliases for reference
	ColumnDisplay = { "stack", "tabbed", "stacked" },
	LayoutSwitchTarget = { "prev", "next" },
	SizeChange = { "SetExact", "Adjust", "SetAuto" },
	
	-- Utility functions
	get_request_type = get_request_type,
	get_action_result = get_action_result,
	classify_event = classify_event,
}

