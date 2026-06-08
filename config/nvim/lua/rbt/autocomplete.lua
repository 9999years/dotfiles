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

      -- `<CR>` accepts the currently-selected item (preselected or
      -- explicitly chosen) whenever the menu is open; otherwise inserts a
      -- literal newline. To insert a newline while the menu is up, dismiss
      -- it first with `<C-l>` / `<C-z>`.
      --
      -- This is VS Code style and *more aggressive* than my old nvim-cmp
      -- setup, which only accepted on `<CR>` when the LSP server flagged
      -- an item as preselect (since blink's `preselect = true` always
      -- preselects item 1, while nvim-cmp's `PreselectMode.Item` only
      -- preselected server-flagged items). Going with this because the
      -- "only accept after explicit Tab" variant felt unnatural — I kept
      -- hitting Enter expecting it to accept.
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

      -- `<Tab>` tentatively selects the next completion item — it does NOT
      -- accept (so e.g. snippet items don't expand until I explicitly
      -- confirm with `<CR>`). With `auto_insert = true`, the selected item's
      -- text appears in the buffer as a preview as I tab through.
      --
      -- The wrinkle: blink opens the menu with item 1 already preselected
      -- but with `is_explicitly_selected = false`, and `select_next` reads
      -- the current index and advances — so the first `<Tab>` would skip
      -- past item 1 to item 2. Instead, on first press we *re-select* item
      -- 1 with `is_explicit_selection = true`, which applies the auto_insert
      -- preview and arms `<CR>` for accept. Subsequent presses advance.
      --
      -- Uses internal API (`is_explicitly_selected`, `list.select`); see
      -- comment on the `<CR>` mapping above.
      ["<Tab>"] = {
        function(cmp)
          if not cmp.is_menu_visible() then return end
          local list = require("blink.cmp.completion.list")
          if list.is_explicitly_selected then
            return cmp.select_next()
          end
          -- Wrap in `vim.schedule` because `list.select` ultimately applies a
          -- text edit (the auto_insert preview), and direct buffer mutation
          -- isn't allowed from a keymap callback (nvim's textlock). All of
          -- blink's public API actions schedule for the same reason.
          vim.schedule(function()
            list.select(list.selected_item_idx or 1, { is_explicit_selection = true })
          end)
          return true
        end,
        "snippet_forward",
        "fallback",
      },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },

    completion = {
      list = {
        selection = {
          -- Preselect the LSP-preferred item visually, and use blink's
          -- `auto_insert` mode so navigating with `<Tab>`/`<C-n>` writes a
          -- *preview* of the selected item into the buffer (gives concrete
          -- feedback while I'm browsing the menu). For snippet items the
          -- preview is just the prefix before any placeholder — full snippet
          -- expansion only happens at `accept` time, on `<CR>`.
          --
          -- This is different from my old nvim-cmp setup, which used
          -- `SelectBehavior.Select` (highlight-only, no buffer change).
          preselect = true,
          auto_insert = true,
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
      -- Use the built-in `cmdline` preset, whose `<Tab>` is
      -- `{ "show_and_insert_or_accept_single", "select_next" }`:
      --
      -- - With the menu hidden, `<Tab>` shows it with item 1 selected
      --   (auto_insert puts a preview of item 1 in the cmdline).
      -- - With the menu visible, the show call no-ops and falls through to
      --   `select_next`, so subsequent `<Tab>`s cycle through items.
      -- - `<S-Tab>` is symmetric (shows with the last item selected, then
      --   `select_prev` on later presses).
      --
      -- That matches the vanilla / old nvim-cmp feel: `<Tab>` navigates the
      -- menu while leaving it open. The preset has no `<CR>` mapping, so
      -- `<CR>` falls through to vim's default cmdline submit -- it executes
      -- whatever text is currently in the cmdline (including any previewed
      -- selection from `<Tab>`), rather than "accepting" a menu item without
      -- executing.
      --
      -- This file previously overrode `<Tab>` to `select_and_accept` to get
      -- VS Code style accept-on-tab. That made an auto-shown menu hard to
      -- navigate because the first `<Tab>` would accept and close it before
      -- it could be used to cycle.
      keymap = {
        preset = "cmdline",

        -- The default preset routes `<Right>`/`<Left>` through
        -- `select_next`/`select_prev`. In the cmdline I want those keys to
        -- just move the cursor -- let them fall through to vim's default.
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
