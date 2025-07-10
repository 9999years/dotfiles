--- @type LazyPluginSpec
local M = {
  "nvim-telescope/telescope.nvim",

  dependencies = {
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-github.nvim",
    "gnfisher/nvim-telescope-ctags-plus",
  },
}

local function max_height(_self, _max_columns, max_lines)
  return max_lines
end

local function max_width(_self, max_columns, _max_lines)
  return max_columns
end

function M.config()
  local builtin = require("telescope.builtin")
  require("batteries").map {
    { prefix = "<Leader>t", group = "telescope" },
    {
      "<Leader>tt",
      function()
        return builtin.builtin { include_extensions = true }
      end,
      "Telescope",
    },
    {
      "<Leader>tr",
      builtin.resume,
      "Resume",
    },
    {
      "<Leader>tf",
      function()
        return builtin.find_files { hidden = true }
      end,
      "Find files",
    },
    {
      "<Leader>tg",
      function()
        return builtin.live_grep()
      end,
      "Grep",
    },
    { "<Leader>b", builtin.buffers, "Find buffers" },
    {
      "<Leader>t*",
      builtin.grep_string,
      "Grep identifier under cursor",
    },
  }

  local actions = require("telescope.actions")
  require("telescope").setup {
    extensions = {
      ["ui-select"] = {
        -- Defined here: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/themes.lua
        require("telescope.themes").get_dropdown {
          layout_strategy = "cursor",
        },
      },
    },
    defaults = {
      mappings = {
        i = {
          ["<Tab>"] = actions.move_selection_next,
          ["<S-Tab>"] = actions.move_selection_previous,
        },
      },
      -- See: `:h telescope.resolve`
      layout_config = {
        horizontal = {
          height = max_height,
          width = max_width,
        },
        vertical = {
          height = max_height,
          width = max_width,
        },
        cursor = {
          height = { 0.25, min = 3 },
          width = { 0.5, min = 40 },
        },
      },
    },
  }

  require("telescope").load_extension("fzy_native")
  require("telescope").load_extension("ui-select") -- telescope-ui-select.nvim
  require("telescope").load_extension("gh") -- telescope-github.nvim
  require("telescope").load_extension("ctags_plus")
end

return M
