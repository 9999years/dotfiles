local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.font = wezterm.font("PragmataProLiga Nerd Font")
config.font_size = 16.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.scrollback_lines = 100000

config.leader = {
	key = "b",
	mods = "CTRL",
}

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

	-- WezTerm-specific :)
	{
		key = "k",
		mods = "CMD",
		action = act.ActivateCommandPalette,
	},
}

return config
