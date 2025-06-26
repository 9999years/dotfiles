--- @type LazyPluginSpec
local M = {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "honza/vim-snippets",
  },
}

function M.config()
  local luasnip = require("luasnip")
  luasnip.setup {
    -- This `snip_env` is used as globals when loading snippets from `.lua`
    -- files.
    --
    -- We use `getfenv` to get the environment of the thing that _calls_
    -- the function, because that's where LuaSnip injects the
    -- `ls_file_snippets` global.
    --
    -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua
    snip_env = {
      s = function(...)
        local snip = luasnip.s(...)
        -- we can't just access the global `ls_file_snippets`, since it will be
        -- resolved in the environment of the scope in which it was defined.
        table.insert(getfenv(2).ls_file_snippets, snip)
      end,
    },
  }
  -- Load `.snippets` files.
  require("luasnip.loaders.from_snipmate").lazy_load()
  -- Load `.lua` snippet files.
  require("luasnip.loaders.from_lua").lazy_load()
  -- Treat `_.snippets` as `all`.
  luasnip.filetype_extend("all", { "_" })

  local batteries = require("batteries")
  batteries.map {
    {
      "<C-j>",
      function()
        luasnip.jump(1)
      end,
      "Expand a snippet or jump to the next placeholder",
      mode = { "i", "v" },
    },
    {
      "<C-k>",
      function()
        luasnip.jump(-1)
      end,
      "Jump to the previous snippet placeholder",
      mode = { "i", "v" },
    },
    {
      "<C-S-j>",
      function()
        luasnip.change_choice(1)
      end,
      "Cycle to the next snippet choice",
      mode = "i",
    },
    {
      "<C-S-k>",
      function()
        luasnip.change_choice(-1)
      end,
      "Cycle to the previous snippet choice",
      mode = "i",
    },
  }

  batteries.cmd {
    nargs = "?",
    complete = "filetype",
    "EditSnippets",
    function()
      -- TODO: No way to override when user types a filetype?
      require("luasnip.loaders").edit_snippet_files {
        edit = function(file)
          vim.cmd("split " .. file)
        end,
        ft_filter = function(filetype)
          return #filetype > 0 and filetype ~= "_"
        end,
        format = function(_file, _source_name)
          -- We only want to edit the snippets from `extend`, which are in
          -- `./snippets/`.
          return nil
        end,
        extend = function(filetype, _paths)
          local config_path = vim.fn.stdpath("config")
          local function path(dirname, extension)
            return {
              "$CONFIG/" .. dirname .. "/" .. filetype .. "." .. extension,
              config_path .. "/" .. dirname .. "/" .. filetype .. "." .. extension,
            }
          end
          return {
            path("snippets", "snippets"),
            path("luasnippets", "lua"),
          }
        end,
      }
    end,
    "Edit the snippets file for this filetype",
  }
end

return M
