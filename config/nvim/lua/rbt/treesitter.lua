--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
}

M.dependencies = {
  "nvim-treesitter/playground",

  "nvim-treesitter/nvim-treesitter-textobjects",
  "RRethy/nvim-treesitter-textsubjects",

  -- Show "context" at the top of the window.
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      -- TODO: This doesn't work with the treesitter 'module' system?
      require("treesitter-context").setup {
        -- Only show a couple lines.
        max_lines = "10%",
        -- Don't show context on small windows.
        min_window_height = 5,
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
  -- See: https://github.com/nvim-treesitter/nvim-treesitter#available-modules
  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup {
    matchup = {
      enable = true,
      disable = {},
    },
    ensure_installed = { "diff", "git_rebase" },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = {
        "markdown",
        "gitcommit",
        "make",
      },
    },
    indent = {
      -- maybe this sucks? (2025-06-20)
      enable = false,
      disable = {
        "markdown",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
          ["ic"] = "@class.inner",
          ["ac"] = "@class.outer",
          ["if"] = "@function.inner",
          ["af"] = "@function.outer",
          ["as"] = {
            query = "@local.scope",
            query_group = "locals",
            desc = "Select language scope",
          },
        },
      },
    },
    -- Visual mappings for selecting.
    textsubjects = {
      enable = true,
      -- All only in visual mode!
      prev_selection = ",",
      keymaps = {
        -- `v.` Select "the current thing".
        -- `.`  Select "more".
        ["."] = "textsubjects-smart",
        -- Select the "outer" container.
        [";"] = "textsubjects-container-outer",
        -- Select the "inner" container.
        ["i;"] = "textsubjects-container-inner",
      },
    },
  }

  -- https://neovim.discourse.group/t/git-diff-highlighting-are-not-working-anymore-in-gitcommit-filetype/3547/5
  vim.cmd([[
    highlight def link @text.diff.add DiffAdded
    highlight def link @text.diff.delete DiffRemoved
  ]])
end

return M
