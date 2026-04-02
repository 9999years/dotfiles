--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
}

M.dependencies = {
  -- Disabled until updated for nvim-treesitter main (0.12) API:
  -- "nvim-treesitter/nvim-treesitter-textobjects",
  -- "RRethy/nvim-treesitter-textsubjects",

  -- Show "context" at the top of the window.
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        -- Only show a couple lines.
        max_lines = "10%",
        -- Don't show context on small windows.
        min_window_height = 5,
        -- Show context on non-focused windows.
        multiwindow = true,
        patterns = {
          nix = {
            "binding",
          },
        },
      }
    end,
  },

  -- Matching
  "vim-matchup",

  require("rbt.fold"),
}

function M.config()
  -- NB: Auto-install was removed.

  -- Text objects: re-enable when nvim-treesitter-textobjects supports the new API.
  -- Restore dependency: "nvim-treesitter/nvim-treesitter-textobjects"
  --
  -- require("nvim-treesitter-textobjects").setup {
  --   select = {
  --     enable = true,
  --     lookahead = true,
  --     keymaps = {
  --       ["ia"] = "@parameter.inner",
  --       ["aa"] = "@parameter.outer",
  --       ["ic"] = "@class.inner",
  --       ["ac"] = "@class.outer",
  --       ["if"] = "@function.inner",
  --       ["af"] = "@function.outer",
  --       ["as"] = {
  --         query = "@local.scope",
  --         query_group = "locals",
  --         desc = "Select language scope",
  --       },
  --     },
  --   },
  -- }

  -- Text subjects: re-enable when nvim-treesitter-textsubjects supports the new API.
  -- Restore dependency: "RRethy/nvim-treesitter-textsubjects"
  --
  -- require("nvim-treesitter-textsubjects").configure {
  --   -- All only in visual mode!
  --   prev_selection = ",",
  --   keymaps = {
  --     -- `v.` Select "the current thing".
  --     -- `.`  Select "more".
  --     ["."] = "textsubjects-smart",
  --     -- Select the "outer" container.
  --     [";"] = "textsubjects-container-outer",
  --     -- Select the "inner" container.
  --     ["i;"] = "textsubjects-container-inner",
  --   },
  -- }

  -- https://neovim.discourse.group/t/git-diff-highlighting-are-not-working-anymore-in-gitcommit-filetype/3547/5
  vim.cmd([[
    highlight def link @text.diff.add DiffAdded
    highlight def link @text.diff.delete DiffRemoved
  ]])
end

return M
