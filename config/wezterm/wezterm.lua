-- See: https://wezterm.org/config/files.html
--
-- Wishlist:
-- - Drag to reorder tabs: https://github.com/wezterm/wezterm/issues/549
--   - PR: https://github.com/wezterm/wezterm/pull/6527
-- - Get entire key table stack: https://github.com/wezterm/wezterm/issues/3460
-- - Spawn tab next to current tab: https://github.com/wezterm/wezterm/issues/909
--   - Workaround: https://github.com/wezterm/wezterm/issues/909#issuecomment-2481926947
-- - Resize panes to equal sizes: https://github.com/wezterm/wezterm/issues/2972
-- - Switch pane layouts: https://github.com/wezterm/wezterm/issues/3516
-- - Inspect/mutate pane layouts from Lua: https://github.com/wezterm/wezterm/issues/7083
-- - It's too easy to accidentally drag the window while selecting tabs:
--   https://github.com/wezterm/wezterm/issues/7116
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

-- Filter a table according to a predicate.
local function tbl_filter(tbl, predicate)
  local ret = {}
  for _, item in ipairs(tbl) do
    if predicate(item) then
      table.insert(ret, item)
    end
  end
  return ret
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

config.font = wezterm.font_with_fallback {
  "PragmataPro Liga",
  -- Support for Symbols for Legacy Computing Supplement and Appendix.
  -- Thank you Rebecca Bettencourt!!
  -- See: <https://www.kreativekorp.com/software/fonts/ksquare/>
  "Kreative Square",
  {
    family = "Apple Color Emoji",
    assume_emoji_presentation = true,
  },
  -- This gets me decent CJK coverage, but I'm not sure if it makes the
  -- terminal lag out.
  "LiHei Pro",
  "Yuanti TC",
}
config.font_size = 16.0

-- I would prefer to check `wezterm.gui.screens().main.effective_dpi >= 144`,
-- but just calling that function from the config crashes wezterm.
if wezterm.hostname() == "grandiflora" then
  config.font_size = 18.0
end

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left = "0cell",
  right = "0cell",
  top = "0cell",
  bottom = "0cell",
}

config.scrollback_lines = 2000000 -- 2 million
config.bypass_mouse_reporting_modifiers = "CMD"

config.quick_select_remove_styling = true
config.quick_select_patterns = {
  -- Nix SRI hash syntax, seen in Nix build hash mismatch outputs.
  "sha256-[a-zA-Z0-9+/=]{44}",

  -- Jujutsu chanage IDs.
  --
  -- > A change ID is a unique identifier for a change. [...] These are
  -- > actually hexadecimal numbers that use "digits" z-k instead of 0-9a-f.
  --
  -- See: https://jj-vcs.github.io/jj/latest/glossary/#change-id
  "[k-z]{8,32}",

  -- ISO 8601 dates.
  --
  -- Examples of accepted formats:
  -- - 2025-04
  -- - 2025-04-30
  -- - 2025-04-30 01:50
  -- - 2025-04-30T01:50:08
  -- - 2025-04-30T01:50:08Z
  -- - 2025-04-30T01:50:08+01:00
  "[12][0-9]{3}-[0-9]{2}(?:-[0-9]{2}(?:[ T][0-9]{2}:[0-9]{2}(?::[0-9]{2}(?:Z|[+-][0-9]{2}:[0-9]{2})?)?)?)?",

  -- Clock times.
  "[12]?[0-9]:[0-9]{2}(?::[0-9]{2})? ?(:?[aApP][mM])?",

  -- Buck2 target label.
  -- Note: `bxl` targets can have multiple `:name` components at the end, e.g.
  -- `//haskell:module_target_map.bxl:best_effort`.
  "@?[A-Za-z0-9._-]*//[A-Za-z0-9/._-]*(?::[A-Za-z0-9_/.=,@~+-]+)*",

  -- Haskell module name.
  "[A-Z][a-zA-Z0-9_']*(?:\\.[A-Z][a-zA-Z0-9_']*)+",
}

config.hyperlink_rules = tbl_filter(wezterm.default_hyperlink_rules(), function(item)
  return item.format ~= "mailto:$0"
end)

config.mux_enable_ssh_agent = false

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

config.colors = {
  compose_cursor = "orange",
}

-- Like `act.SpawnTab`, but next to the current tab.
--
-- See: https://github.com/wezterm/wezterm/issues/909
-- Via: https://github.com/wezterm/wezterm/issues/909#issuecomment-2481926947
local spawn_tab_adjacent = wezterm.action_callback(function(win, pane)
  local mux_win = win:mux_window()
  for _, item in ipairs(mux_win:tabs_with_info()) do
    if item.is_active then
      mux_win:spawn_tab {}
      win:perform_action(wezterm.action.MoveTab(item.index + 1), pane)
      return
    end
  end
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

  -- No paragraph movements upstream yet.
  -- See: https://github.com/wezterm/wezterm/issues/7079
  {
    key = "{",
    action = act.CopyMode("MoveBackwardSemanticZone"),
  },
  {
    key = "}",
    action = act.CopyMode("MoveForwardSemanticZone"),
  },

  {
    key = "[",
    action = act.CopyMode("MoveBackwardSemanticZone"),
  },
  {
    key = "]",
    action = act.CopyMode("MoveForwardSemanticZone"),
  },

  {
    key = ".",
    action = act.CopyMode { SetSelectionMode = "SemanticZone" },
  },

  {
    key = "e",
    mods = "CTRL",
    action = act.ScrollByLine(1),
  },
  {
    key = "y",
    mods = "CTRL",
    action = act.ScrollByLine(-1),
  },
})

-- We have feature detection at home.
-- See: https://github.com/wezterm/wezterm/issues/7450
-- We have feature detection at home.
-- See: https://github.com/wezterm/wezterm/issues/7450
if pcall(act.CopyMode, { MoveToBlankLine = "Up" }) then
  -- `MoveToBlankLine` requires a PR I wrote.
  -- See: https://github.com/wezterm/wezterm/issues/7079
  -- See: https://github.com/wezterm/wezterm/pull/7140
  extend_key_table("copy_mode", {
    {
      key = "{",
      action = act.CopyMode { MoveToBlankLine = "Up" },
    },
    {
      key = "}",
      action = act.CopyMode { MoveToBlankLine = "Down" },
    },
  })
end

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
  { key = "c", mods = "LEADER", action = spawn_tab_adjacent },
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

  -- `CTRL-b CTRL-b` = `CTRL-b`.
  {
    key = "b",
    mods = "CTRL|LEADER",
    action = act.SendKey {
      key = "b",
      mods = "CTRL",
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
