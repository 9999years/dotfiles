-- See: https://wezterm.org/config/files.html
local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- TODO: Fallbacks?
config.font = wezterm.font("PragmataPro Liga")
config.font_size = 16.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.scrollback_lines = 100000

config.leader = {
	key = "b",
	mods = "CTRL",
}

if wezterm.gui then
	local copy_mode = nil
	copy_mode = wezterm.gui.default_key_tables().copy_mode
	table.insert(copy_mode, { key = "[", action = act.ScrollToPrompt(-1) })
	table.insert(copy_mode, { key = "]", action = act.ScrollToPrompt(1) })

	-- table.insert(copy_mode, { key = "a", action = act.ScrollByLine(-1) })

	-- See: https://wezterm.org/config/key-tables.html
	config.key_tables = {
		copy_mode = copy_mode,
	}
end

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

	-- WezTerm-specific :)
	{
		key = "k",
		mods = "CMD",
		action = act.ActivateCommandPalette,
	},
}

return config
