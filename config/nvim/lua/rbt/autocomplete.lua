--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "saghen/blink.cmp",
  -- Pin to a release tag; lazy.nvim will fetch the matching prebuilt Rust
  -- fuzzy-matcher binary so we don't need a local Rust toolchain.
  version = "1.*",
  dependencies = {
    "LuaSnip",
    -- `lazydev` provides its own blink.cmp source via
    -- `lazydev.integrations.blink`, but the dependency is already declared in
    -- `rbt.lsp`.
  },
}

function M.config()
  require("blink.cmp").setup {
    -- Start from the built-in `default` preset (`<C-Space>` show, `<C-e>` hide,
    -- `<C-y>` accept, `<C-n>`/`<C-p>` select next/prev, `<C-b>`/`<C-f>` scroll
    -- docs, `<Tab>`/`<S-Tab>` snippet jump) and override individual keys to
    -- match my previous nvim-cmp setup.
    keymap = {
      preset = "default",

      -- nvim-cmp had `<C-a>` scroll up and `<C-e>` scroll down. blink's
      -- `default` preset uses `<C-b>`/`<C-f>` for scrolling and `<C-e>` for
      -- hiding the menu, so override both.
      ["<C-a>"] = { "scroll_documentation_up", "fallback" },
      ["<C-e>"] = { "scroll_documentation_down", "fallback" },

      -- Hide the menu. (blink's default already maps `<C-e>` to hide, but we
      -- repurposed that key above, so route hide through `<C-l>` and `<C-z>`.)
      ["<C-l>"] = { "hide", "fallback" },
      ["<C-z>"] = { "hide", "fallback" },

      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },

      -- Confirm with `<CR>` only if there is an explicitly selected item;
      -- otherwise insert a literal newline. This preserves my old "don't eat
      -- my newline if I haven't picked anything" behaviour.
      ["<CR>"] = {
        function(cmp)
          if cmp.get_selected_item() ~= nil then
            return cmp.accept()
          end
        end,
        "fallback",
      },

      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },

      -- Snippet placeholder jumps.
      ["<A-n>"] = { "snippet_forward", "fallback" },
      ["<A-p>"] = { "snippet_backward", "fallback" },

      -- CHANGED: nvim-cmp `<Tab>` used to auto-confirm when exactly one entry
      -- was visible, otherwise select the next item. blink.cmp doesn't expose
      -- an entry count in its public API, so this falls back to the standard
      -- "select next item, or jump to next snippet placeholder, else fallthrough"
      -- behaviour.
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    completion = {
      list = {
        selection = {
          -- nvim-cmp had `preselect = cmp.PreselectMode.Item` (respect the
          -- server's `preselect` flag) together with `SelectBehavior.Select`
          -- on `<C-n>`/`<C-p>` (don't write the highlighted entry into the
          -- buffer until I confirm). The blink equivalent is `preselect = true,
          -- auto_insert = false`. blink's default is `auto_insert = true`,
          -- which would write text into the buffer just from navigating —
          -- override that.
          preselect = true,
          auto_insert = false,
        },
      },
      menu = {
        auto_show = true,
      },
      documentation = {
        -- Equivalent to `view.docs.auto_open = true` in nvim-cmp.
        auto_show = true,
      },
      -- Equivalent to `experimental.ghost_text = true` in nvim-cmp.
      ghost_text = {
        enabled = true,
      },
    },

    snippets = {
      -- Built-in LuaSnip integration; replaces the `cmp_luasnip` source.
      preset = "luasnip",
    },

    sources = {
      -- CHANGED: nvim-cmp grouped sources so that, on Lua files, `lazydev`
      -- entries completely suppressed `nvim_lsp`+`luasnip` results, and those
      -- in turn suppressed `path`+`buffer`. blink.cmp doesn't have grouped
      -- sources — every source competes on score in a single flat list — so
      -- the closest approximation is a large `score_offset` on `lazydev`
      -- to keep its entries at the top. LSP/snippet/path/buffer entries
      -- will still show alongside lazydev's, rather than being hidden.
      default = { "lsp", "snippets", "path", "buffer", "lazydev" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
      -- Note: `cmp-async-path` is replaced by blink's built-in `path` source,
      -- which is already async. `cmp-nvim-lsp-signature-help` (inline sig
      -- help in the completion menu) has no direct blink equivalent; blink
      -- offers a separate floating signature window via `signature.enabled`,
      -- but I already have `<C-k>` bound to `vim.lsp.buf.signature_help` in
      -- `rbt.lsp`, so leaving that off.
    },

    fuzzy = {
      -- Use the prebuilt Rust matcher shipped with the tagged release.
      implementation = "prefer_rust_with_warning",
    },
  }

  vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(
      require("lsp-status").capabilities
    ),
  })
end

return M
