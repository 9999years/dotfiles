-- See: https://wezterm.org/config/files.html
--
-- Wishlist:
-- - Drag to reorder tabs: https://github.com/wezterm/wezterm/issues/549
-- - Get entire key table stack: https://github.com/wezterm/wezterm/issues/3460
-- - Spawn tab next to current tab: https://github.com/wezterm/wezterm/issues/909
-- - Resize panes to equal sizes: https://github.com/wezterm/wezterm/issues/2972
-- - Switch pane layouts: https://github.com/wezterm/wezterm/issues/3516
-- - Inspect/mutate pane layouts from Lua: https://github.com/wezterm/wezterm/issues/7083
local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- Like `table.insert`, but adds multiple entries and only to the end of a
-- table.
local function insert_all(table_, entries)
  for _i, entry in ipairs(entries) do
    table.insert(table_, entry)
  end
end

-- Add a series of key bindings to a default key table.
--
-- See: https://wezterm.org/config/key-tables.html
-- See: https://wezterm.org/config/lua/wezterm.gui/default_key_tables.html
local function extend_key_table(name, entries)
  if wezterm.gui then
    local key_table = wezterm.gui.default_key_tables()[name]

    insert_all(key_table, entries)

    if config.key_tables == nil then
      config.key_tables = {}
    end

    config.key_tables[name] = key_table
  end
end

-- TODO: Fallbacks?
config.font = wezterm.font("PragmataPro Liga")
config.font_size = 16.0

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left = "0cell",
  right = "0cell",
  top = "0cell",
  bottom = "0cell",
}

config.scrollback_lines = 100000
config.bypass_mouse_reporting_modifiers = "CMD"

config.quick_select_patterns = {
  "sha256-[a-zA-Z0-9+/=]{44}",
  -- Hash part can't include a couple characters, name part can include almost
  -- anything.
  "/nix/store/[a-z0-9]{32}-[a-zA-Z0-9_.-]*",
}

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, _pane)
  local name = window:active_key_table()
  local status = name or ""

  if window:leader_is_active() then
    if status then
      status = "leader " .. status
    else
      status = "leader"
    end
  end

  window:set_right_status(status)
end)

config.leader = {
  key = "b",
  mods = "CTRL",
}

-- Search/copy mode is kinda janky.
-- See: https://github.com/wezterm/wezterm/issues/5952
extend_key_table("copy_mode", {
  {
    key = "Enter",
    action = act.Multiple {
      act.CopyTo("Clipboard"),
      act.CopyMode("Close"),
    },
  },
  {
    key = "?",
    action = act.Search("CurrentSelectionOrEmptyString"),
  },
  {
    key = "/",
    action = act.Search("CurrentSelectionOrEmptyString"),
  },

  { key = "n", action = act.CopyMode("NextMatch") },
  { key = "N", action = act.CopyMode("PriorMatch") },
  { key = "p", action = act.CopyMode("PriorMatch") },

  -- VERY hacky paragraph movement.
  -- See: https://github.com/wezterm/wezterm/issues/7079
  {
    key = "{",
    action = act.Multiple {
      act.Search {
        Regex = "^\\s*$",
      },
      act.CopyMode("PriorMatch"),
      act.CopyMode("AcceptPattern"),
      act.CopyMode("ClearSelectionMode"),
    },
  },
  {
    key = "}",
    action = act.Multiple {
      act.Search {
        Regex = "^\\s*$",
      },
      act.CopyMode("NextMatch"),
      act.CopyMode("AcceptPattern"),
      act.CopyMode("ClearSelectionMode"),
    },
  },
})

extend_key_table("search_mode", {
  {
    key = "Enter",
    action = act.CopyMode("AcceptPattern"),
  },
  {
    key = "Escape",
    action = act.Multiple {
      act.CopyMode("AcceptPattern"),
      act.CopyMode("ClearSelectionMode"),
    },
  },
})

-- See: https://wezterm.org/config/keys.html
-- See: https://wezterm.org/config/lua/keyassignment/
config.keys = {
  -- Split panes.
  {
    key = "|",
    mods = "LEADER",
    action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = '"',
    mods = "LEADER",
    action = act.SplitVertical { domain = "CurrentPaneDomain" },
  },

  -- Zoom pane.
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Switch pane.
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Rotate panes.
  { key = "o", mods = "LEADER|CTRL", action = act.RotatePanes("Clockwise") },
  { key = "r", mods = "LEADER|CTRL", action = act.RotatePanes("CounterClockwise") },

  -- TODO: Binding to swap panes.
  -- See: https://wezterm.org/config/lua/keyassignment/PaneSelect.html
  -- See: https://wezterm.org/config/lua/MuxTab/get_pane_direction.html

  -- Tabs.
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

  -- Copy mode.
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  {
    key = "?",
    mods = "LEADER",
    action = act.Search("CurrentSelectionOrEmptyString"),
  },

  -- WezTerm-specific :)
  { key = "k", mods = "CMD", action = act.ActivateCommandPalette },

  -- Don't encode `Delete` as `CTRL-h`.
  {
    key = "phys:Delete",
    action = act.SendKey {
      key = "Delete",
    },
  },
}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CMD",
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
  },
}

return config
