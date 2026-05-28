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

      -- Confirm with `<CR>` only if I have *explicitly* selected an item
      -- (i.e. navigated to it with `<Tab>`/`<C-n>`); otherwise insert a
      -- literal newline. Just having an item *preselected* by the LSP
      -- shouldn't eat my newline — that matches nvim-cmp's old behaviour,
      -- where `cmp.get_selected_entry()` returned nil until you navigated,
      -- even with `PreselectMode.Item`.
      --
      -- blink's public API only exposes `cmp.get_selected_item()`, which
      -- returns the preselected item too — so we reach into the internal
      -- `is_explicitly_selected` flag on the completion list module to
      -- distinguish "highlighted by preselect" from "user picked this".
      ["<CR>"] = {
        function(cmp)
          if require("blink.cmp.completion.list").is_explicitly_selected then
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

      -- `<Tab>` accepts the currently-selected item (which is item 1 by
      -- default, thanks to `preselect = true`). VS-Code-style; also matches
      -- what the cmdline keymap does below. Falls back to snippet-forward
      -- when the menu isn't open, and then to the default `<Tab>` (indent).
      --
      -- Note: this means `<Tab>` can no longer be used to navigate within
      -- the menu — use `<C-n>` / `<C-p>` (or `<Down>` / `<Up>`) for that.
      ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
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

    cmdline = {
      -- Start from the built-in `cmdline` preset and override the few keys
      -- whose default behaviour is awkward when the first item is already
      -- preselected.
      keymap = {
        preset = "cmdline",

        -- The default cmdline preset maps `<Tab>` to
        -- `show_and_insert_or_accept_single` → `select_next`. With item 1
        -- already preselected by `auto_insert = true`, that means `<Tab>`
        -- *advances past* the visually-highlighted item instead of accepting
        -- it — VS Code's `<Tab>` accepts. Make `<Tab>` accept whatever is
        -- selected (first item, by default), falling back to the preset's
        -- show/accept-single behaviour if the menu isn't up yet.
        ["<Tab>"] = {
          "select_and_accept",
          "show_and_insert_or_accept_single",
          "fallback",
        },

        -- The default preset also routes `<Right>`/`<Left>` through
        -- `select_next`/`select_prev`. In the cmdline I want those keys to
        -- just move the cursor — let them fall through to vim's default.
        ["<Right>"] = {},
        ["<Left>"] = {},
      },
    },
  }

  vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(
      require("lsp-status").capabilities
    ),
  })
end

return M
