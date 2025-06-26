--- @type LazyPluginSpec
local M = {
  "stevearc/conform.nvim",
}

function M.config()
  vim.g.format_after_save = true

  require("conform").setup {
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      json = { "jq" },
      lua = { "stylua" },
      nix = { "nixfmt" },
      python = {
        "ruff",
        "ruff_format",
        "isort",
      },
      haskell = {
        lsp_format = "never",
      },
    },
    notify_no_formatters = false,
    format_after_save = function(bufnr)
      if not vim.g.format_after_save then
        return
      end
      local buf_format_after_save = vim.b[bufnr].format_after_save
      if buf_format_after_save ~= nil and not buf_format_after_save then
        return
      end
      return {}
    end,
  }

  local batteries = require("batteries")
  batteries.cmd {
    "Format",
    function(_opts)
      require("conform").format()
    end,
    "Format the current buffer with conform",
  }
  batteries.cmd {
    "FormatDisable",
    function(opts)
      if opts.bang then
        vim.b.format_after_save = false
      else
        vim.g.format_after_save = false
      end
    end,
    "Disable formatting on save",
    bang = true,
  }
  batteries.cmd {
    "FormatEnable",
    function(opts)
      if opts.bang then
        vim.b.format_after_save = true
      else
        vim.g.format_after_save = true
      end
    end,
    "Enable formatting on save",
    bang = true,
  }
end

return M
