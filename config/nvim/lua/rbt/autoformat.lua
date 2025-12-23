--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "stevearc/conform.nvim",
}

--- Always format with these formatters, even if others are specified or an LSP
--- formatter is being used.
local always_formatters = {
  "keep-sorted",
  "treefmt",
}

local function has_lsp_format(bufnr)
  local lsp_format_clients = require("conform.lsp_format").get_format_clients {
    bufnr = bufnr,
  }
  return #lsp_format_clients > 0
end

--- What we want:
--- - Always format with `always_formatters`, e.g. `treefmt`, `keep-sorted`.
--- - Sometimes format with other formatters, e.g. `stylua` for Lua.
--- - Sometimes format with an LSP.
--- - If an LSP isn't available, sometimes use a backup formatter instead (e.g.
---   format with `rust-analyzer` by default or `rustfmt` if the LSP isn't
---   available).
---
--- If we set formatters for a filetype, `conform.nvim` won't use the
--- formatters for `*` (`treefmt`, `keep-sorted`). This function works around
--- that to return the correct set of formatters.
local function formatters(opts)
  local lsp_format = opts.lsp_format
  local lsp_format_fallback = opts.lsp_format_fallback

  -- This is a shallow copy.
  local other_formatters = vim.list_slice(opts)
  vim.list_extend(other_formatters, always_formatters)

  return function(bufnr)
    -- Note: We don't want to mutate `opts` so we make a shallow copy here.
    local ret = vim.list_slice(other_formatters)
    ret.lsp_format = lsp_format

    if not has_lsp_format(bufnr) then
      table.insert(ret, lsp_format_fallback)
    end

    return ret
  end
end

function M.config()
  vim.g.format_after_save = true

  require("conform").setup {
    default_format_opts = {
      lsp_format = "fallback",
    },

    formatters_by_ft = {
      ["bzl.build"] = formatters { "buildifier_build" },
      bzl = formatters { "buildifier" },
      ["bzl.bxl"] = formatters { "buildifier_bzl" },
      c = formatters { "clang-format" },
      cpp = formatters { "clang-format" },
      go = formatters { "gofmt" },
      json = formatters { "jq" },
      lua = formatters { "stylua" },
      nix = formatters { "nixfmt" },
      python = formatters {
        "ruff_format",
        "ruff_fix",
        lsp_format = "never",
      },
      haskell = formatters {
        lsp_format = "never",
      },
      rust = formatters {
        lsp_format_fallback = "rustfmt",
        lsp_format = "first",
      },
      ["*"] = formatters {},
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

    formatters = {

      buildifier_build = {
        command = "buildifier",
        args = {
          "-type",
          "build",
          "-path",
          "$FILENAME",
          "-",
        },
      },

      buildifier_bzl = {
        command = "buildifier",
        args = {
          "-type",
          "bzl",
          "-path",
          "$FILENAME",
          "-",
        },
      },
    },
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
