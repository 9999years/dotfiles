-- See: https://wezterm.org/config/files.html
local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- TODO: Fallbacks?
config.font = wezterm.font("PragmataPro Liga")
config.font_size = 16.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.scrollback_lines = 100000

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, _pane)
	local name = window:active_key_table()
	window:set_right_status(name or "")
end)

config.leader = {
	key = "b",
	mods = "CTRL",
}

-- See: https://wezterm.org/config/keys.html
-- See: https://wezterm.org/config/lua/keyassignment/
config.keys = {
	-- Split panes.
	{
		key = "|",
		mods = "LEADER",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = '"',
		mods = "LEADER",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Zoom pane.
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},

	-- Switch pane.
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},

	-- Rotate panes.
	{
		key = "o",
		mods = "LEADER|CTRL",
		action = act.RotatePanes("Clockwise"),
	},
	{
		key = "r",
		mods = "LEADER|CTRL",
		action = act.RotatePanes("CounterClockwise"),
	},

	-- Tabs.
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "n",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},

	-- Copy mode.
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},

	-- WezTerm-specific :)
	{
		key = "k",
		mods = "CMD",
		action = act.ActivateCommandPalette,
	},
}

return config
