--- @type LazyPluginSpec
local M = {
  "hrsh7th/nvim-cmp",
}

M.dependencies = {
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "FelipeLema/cmp-async-path",
  "hrsh7th/cmp-nvim-lsp-signature-help",
  "saadparwaiz1/cmp_luasnip",
  "LuaSnip",
}

function M.config()
  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api
          .nvim_buf_get_lines(0, line - 1, line, true)[1]
          :sub(col, col)
          :match("%s")
        == nil
  end

  local cmp = require("cmp")
  local luasnip = require("luasnip")

  ---@diagnostic disable-next-line: missing-fields
  cmp.setup {
    experimental = {
      ghost_text = true,
    },

    preselect = cmp.PreselectMode.Item,

    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },

    mapping = cmp.mapping.preset.insert {
      ["<C-a>"] = cmp.mapping.scroll_docs(-4),
      ["<C-e>"] = cmp.mapping.scroll_docs(4),
      ["<C-l>"] = cmp.mapping.abort(),
      ["<C-z>"] = cmp.mapping.abort(),
      ["<C-Space>"] = cmp.mapping.complete(),

      ["<CR>"] = function(fallback)
        if cmp.get_selected_entry() ~= nil then
          -- If we have a completion selected, confirm it.
          cmp.confirm { select = true }
        else
          fallback()
        end
      end,

      ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item {
            behavior = cmp.SelectBehavior.Select,
          }
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item {
            behavior = cmp.SelectBehavior.Select,
          }
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<A-n>"] = function(_fallback)
        -- Direction parameter.
        luasnip.jump(1)
      end,

      ["<A-p>"] = function(_fallback)
        -- Direction parameter.
        luasnip.jump(-1)
      end,

      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          local entries = cmp.get_entries()
          if #entries == 1 then
            cmp.confirm { select = true }
          else
            cmp.select_next_item {
              behavior = cmp.SelectBehavior.Select,
            }
          end
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },

    -- Note: The two-level structure here groups completion items.
    -- If a completion source in the first group has matches, the second
    -- source isn't queried.
    sources = cmp.config.sources {
      { name = "lazydev", group_index = 1 },
      { name = "nvim_lsp", group_index = 2 },
      { name = "luasnip", group_index = 2 },
      { name = "async_path", group_index = 3 },
      { name = "buffer", group_index = 3 },
    },

    ---@diagnostic disable-next-line: missing-fields
    matching = {
      disallow_partial_fuzzy_matching = false,
    },

    view = {
      docs = {
        auto_open = true,
      },
    },
  }
end

return M
