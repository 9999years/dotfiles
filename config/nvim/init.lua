-- See: `:h lua`
-- I like to format this file with `stylua` (`cargo install stylua`).
-- https://github.com/JohnnyMorganz/StyLua

-- Bootstrap lazy.nvim: https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Package manager & plugin configuration.
require("lazy").setup {
  -- Better repeated mappings with plugins.
  { "tpope/vim-repeat" },

  -- Mapping/command utils.
  { "9999years/batteries.nvim" },

  -- Comment toggling.
  {
    "scrooloose/nerdcommenter",
    init = function()
      vim.g.NERDSpaceDelims = 1
    end,
  },

  -- Text table alignment
  { "godlygeek/tabular" },

  -- Pairs of mappings
  { "tpope/vim-unimpaired" },

  -- `:Move`, `:Rename`, `:Mkdir`, etc.
  { "tpope/vim-eunuch" },

  -- `%` (matchit) delimiter matching but with treesitter support.
  { "andymass/vim-matchup" },

  -- Better parsing for syntax highlighting and other goodies.
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/playground",
      -- Matching
      "vim-matchup",
      -- Folding!
      {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async", "batteries.nvim" },
        config = function()
          vim.opt.foldcolumn = "0"
          vim.opt.foldlevel = 99
          vim.opt.foldlevelstart = 99
          vim.opt.foldenable = true

          local more_msg_highlight = vim.api.nvim_get_hl_id_by_name("MoreMsg")
          local non_text_highlight = vim.api.nvim_get_hl_id_by_name("NonText")

          ---@diagnostic disable-next-line: missing-fields
          require("ufo").setup {
            provider_selector = function(_bufnr, _filetype, _buftype)
              return { "treesitter", "indent" }
            end,
            preview = {
              win_config = {
                winblend = 0,
              },
            },
            fold_virt_text_handler = function(
              -- The start_line's text.
              virtual_text_chunks,
              -- Start and end lines of fold.
              start_line,
              end_line,
              -- Total text width.
              text_width,
              -- fun(str: string, width: number): string Trunctation function.
              truncate,
              -- Context for the fold.
              ctx
            )
              local line_delta = (" 󰁂 %d"):format(end_line - start_line)
              local remaining_width = text_width
                - vim.fn.strdisplaywidth(ctx.text)
                - vim.fn.strdisplaywidth(line_delta)
              table.insert(virtual_text_chunks, { line_delta, more_msg_highlight })
              local line = start_line
              while remaining_width > 0 and line < end_line do
                line = line + 1
                local line_text =
                  vim.api.nvim_buf_get_lines(ctx.bufnr, line, line + 1, true)[1]
                line_text = " " .. vim.trim(line_text)
                local line_text_width = vim.fn.strdisplaywidth(line_text)
                if line_text_width <= remaining_width - 2 then
                  remaining_width = remaining_width - line_text_width
                else
                  line_text = truncate(line_text, remaining_width - 2) .. "…"
                  remaining_width = remaining_width
                    - vim.fn.strdisplaywidth(line_text)
                end
                table.insert(virtual_text_chunks, { line_text, non_text_highlight })
              end
              return virtual_text_chunks
            end,
          }

          require("batteries").map {
            { "zR", require("ufo").openAllFolds, "Open all folds" },
            { "zM", require("ufo").closeAllFolds, "Close all folds" },
            {
              "K",
              function()
                local window_id = require("ufo").peekFoldedLinesUnderCursor()
                if not window_id then
                  vim.lsp.buf.hover()
                end
              end,
              "Hover fold or documentation",
              mode = { "n", "v" },
            },
          }
        end,
      },
    },

    config = function()
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
          enable = true,
          disable = {
            "markdown",
          },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn", -- set to `false` to disable one of the mappings
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      }

      -- https://neovim.discourse.group/t/git-diff-highlighting-are-not-working-anymore-in-gitcommit-filetype/3547/5
      vim.cmd([[
        highlight def link @text.diff.add DiffAdded
        highlight def link @text.diff.delete DiffRemoved
      ]])
    end,
  },

  -- Create directories when saving files.
  { "jghauser/mkdir.nvim" },

  -- Status line (mostly for LSP progress)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "lsp-status.nvim",
    },
    config = function()
      require("lualine").setup {
        options = {
          theme = "ayu",
          section_separators = { left = "", right = "" },
          component_separators = { left = "│", right = "│" },
        },
        sections = {
          lualine_a = { { "filename", path = 1 } },
          lualine_b = { "diff", "diagnostics" },
          lualine_c = {},
          lualine_x = { "encoding", "filetype" },
          lualine_y = {
            "progress",
            require("lsp-status").status_progress,
          },
        },
        inactive_sections = {
          lualine_a = { { "filename", path = 1 } },
          lualine_b = { "diff", "diagnostics" },
          lualine_c = {},
          lualine_x = { "location" },
          lualine_y = {},
        },
      }
    end,
  },

  { "folke/which-key.nvim", config = true },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("batteries").map {
        { prefix = "<Leader>t", group = "telescope" },
        {
          "<Leader>tt",
          "<cmd>Telescope builtin include_extensions=true<CR>",
          "Telescope",
        },
        { "<Leader>tf", "<cmd>Telescope find_files hidden=true<CR>", "Find files" },
        { "<Leader>tb", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>b", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>to", "<cmd>Telescope oldfiles<CR>", "Recently opened" },
        {
          "<Leader>t*",
          "<cmd>Telescope grep_string<CR>",
          "Grep identifier under cursor",
        },
      }
      local function max_height(_self, _max_columns, max_lines)
        return max_lines
      end

      local function max_width(_self, max_columns, _max_lines)
        return max_columns
      end

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
    end,
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-github.nvim",
      "gnfisher/nvim-telescope-ctags-plus",
    },
  },

  -- Broot integration
  {
    "9999years/broot.nvim",
    config = function()
      require("broot").setup {
        default_directory = require("broot.default_directory").git_root,
        create_user_commands = true,
      }
      local batteries = require("batteries")
      batteries.map {
        "<leader>f",
        function()
          require("broot").broot()
        end,
        "Edit file with Broot",
      }
      batteries.map {
        {
          "<leader>g",
          function()
            require("broot").broot {
              extra_args = { "--cmd", "/" },
            }
          end,
          "Grep with Broot",
        },
        {
          "<leader>*",
          function()
            local identifier = vim.fn.expand("<cword>")
            require("broot").broot {
              extra_args = { "--cmd", "/" .. identifier },
            }
          end,
          "Grep identifier under cursor Broot",
        },
        {
          "<leader>tc",
          function()
            require("broot").broot {
              directory = vim.fn.getcwd(),
            }
          end,
          "Broot (current directory)",
        },
        {
          "<leader>th",
          function()
            require("broot").broot {
              directory = require("broot.default_directory").current_file(),
            }
          end,
          "Broot (directory of current file)",
        },
      }
    end,
  },

  -- GitHub integration / view in browser.
  {
    "9999years/open-browser-git.nvim",
    config = function()
      require("open_browser_git").setup {
        command_prefix = "Browse",
        flavor_patterns = {
          forgejo = {
            "git.lix.systems",
          },
        },
      }
      local batteries = require("batteries")
      batteries.map {
        "<leader>og",
        "<cmd>Browse<CR>",
        "Open file on GitHub",
      }
    end,
  },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
      "honza/vim-snippets",
    },
    config = function()
      local luasnip = require("luasnip")
      -- require("luasnip.util.log").set_loglevel("info")
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
                  config_path
                    .. "/"
                    .. dirname
                    .. "/"
                    .. filetype
                    .. "."
                    .. extension,
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
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip",
      "LuaSnip",
      {
        "zbirenbaum/copilot-cmp",
        dependencies = {
          {
            "zbirenbaum/copilot.lua",
            config = function()
              require("copilot").setup {
                suggestion = { enabled = false },
                panel = { enabled = false },
              }
            end,
          },
        },
        config = function()
          require("copilot_cmp").setup()
        end,
      },
    },
    config = function()
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
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = function(fallback)
            if cmp.get_selected_entry() ~= nil then
              -- If we have a completion selected, confirm it.
              cmp.confirm { select = true }
            else
              fallback()
            end
          end,
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local entries = cmp.get_entries()
              if #entries == 1 then
                cmp.confirm { select = true }
              else
                cmp.select_next_item()
              end
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
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
          { name = "copilot", group_index = 2 },
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
    end,
  },

  { "lukas-reineke/indent-blankline.nvim" }, -- Indentation guides
  { "tpope/vim-fugitive" }, -- Git wrapper
  {
    "lewis6991/gitsigns.nvim", -- Git gutter
    opts = {
      diff_opts = {
        ignore_whitespace = false,
      },

      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local batteries = require("batteries")

        batteries.map {
          buffer = bufnr,

          -- Navigation
          {
            "]c",
            function()
              if vim.wo.diff then
                return "]c"
              end
              vim.schedule(function()
                gs.nav_hunk("next")
              end)
              return "<Ignore>"
            end,
            "Next diff hunk",
            expr = true,
          },
          {
            "[c",
            function()
              if vim.wo.diff then
                return "[c"
              end
              vim.schedule(function()
                gs.nav_hunk("prev")
              end)
              return "<Ignore>"
            end,
            "Prev diff hunk",
            expr = true,
          },

          -- Text object
          { "ih", "<Cmd>Gitsigns select_hunk<CR>", "Hunk", mode = { "o", "x" } },

          -- Actions
          { prefix = "<Leader>h", group = "hunk" },
          {
            "<Leader>hs",
            "<Cmd>Gitsigns stage_hunk<CR>",
            "Stage hunk",
            mode = { "n", "v" },
          },
          {
            "<Leader>hr",
            "<Cmd>Gitsigns reset_hunk<CR>",
            "Reset (unstage) hunk",
            mode = { "n", "v" },
          },
          { "<Leader>hS", gs.stage_buffer, "Stage buffer" },
          { "<Leader>hR", gs.reset_buffer, "Reset buffer" },
          { "<Leader>hp", gs.preview_hunk, "Preview hunk" },
          {
            "<Leader>hb",
            function()
              gs.blame_line { full = true }
            end,
            "Blame line",
          },
          {
            "<Leader>hd",
            function()
              gs.diffthis("~")
            end,
            "Diff",
          },
        }
      end,
    },
  },

  -- `diff3` conflict highlighting
  -- `:Conflict3Highlight` and similar
  { "mkotha/conflict3" },

  -- Color scheme
  {
    "Shatur/neovim-ayu",
    config = function()
      vim.cmd("colorscheme ayu")
      -- The colors for inlay hints are too dark, use the comment colors instead.
      vim.cmd("highlight link LspInlayHint Comment")
      vim.cmd("highlight link LspCodeLens Comment")
    end,
  },

  -- Show a lightbulb to indicate code actions
  {
    "kosayoda/nvim-lightbulb",
    opts = {
      autocmd = { enabled = true },
    },
  },

  {
    "mfussenegger/nvim-lint",
    config = function()
      -- See: https://github.com/mfussenegger/nvim-lint/issues/660
      vim.filetype.add {
        pattern = {
          [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
          [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
        },
      }

      local lint = require("lint")

      lint.linters_by_ft = {
        sh = { "shellcheck" },
        ghaction = { "actionlint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Language-specific plugins
  -- vim-polyglot includes (among many others):
  --   - rust-lang/rust.vim
  --   - cespare/vim-toml
  --   - wavded/vim-stylus
  --   - typescript
  --   - isobit/vim-caddyfile
  --   - dag/vim-fish
  --   - idris-hackers/idris-vim
  --   - pangloss/vim-javascript
  {
    "sheerun/vim-polyglot",
    init = function()
      vim.g.polyglot_disabled = { "rust", "latex", "java", "markdown" }
    end,
  },

  -- Yesod Haskell web framework syntax highlighting.
  { "alx741/yesod.vim" },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",

    dependencies = {
      "batteries.nvim",
      -- Autoformat on save.
      {
        "stevearc/conform.nvim",
        config = function()
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
        end,
      },
      -- Status/diagnostic information
      {
        "nvim-lua/lsp-status.nvim",
        config = function()
          require("lsp-status").register_progress()
        end,
      },
      -- Rust inlay hints and extras.
      "simrat39/rust-tools.nvim",
      -- Neovim Lua setup.
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },

    config = function()
      -- Language server / autocomplete configuration

      -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

      -- https://github.com/neovim/neovim/issues/16807#issuecomment-1001618856
      require("vim.lsp.log").set_format_func(vim.inspect)

      --- @param ctx lsp.HandlerContext
      --- @param callback function(client: vim.lsp.Client, bufnr: number)
      local function for_all_attached_buffers(ctx, callback)
        -- See: https://github.com/neovim/neovim/blob/49d6cd1da86cab49c7a5a8c79e59d48d016975fa/runtime/lua/vim/lsp/handlers.lua#L122-L131
        local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
        for bufnr, _ in pairs(client.attached_buffers) do
          callback(client, bufnr)
        end
      end

      -- Reset options back to what I want. This is needed because the Neovim
      -- LSP client will reset these options _after_ calling `on_attach`.
      --
      -- See: https://github.com/neovim/neovim/issues/31430
      local function reset_defaults(_client, bufnr)
        -- *Don't* set `formatexpr` to `v:lua.vim.lsp.formatexpr()` because I like
        -- Vim's default word-wrapping for comments and such. Anyways I have
        -- `:Format` and format-on-save. See `conform.nvim`.
        vim.api.nvim_set_option_value("formatexpr", "", { buf = bufnr })
      end

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local function lsp_on_attach(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_set_option_value(
          "omnifunc",
          "v:lua.vim.lsp.omnifunc",
          { buf = bufnr }
        )

        reset_defaults(client, bufnr)

        local function get_line_diagnostics()
          vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") })
        end

        local function list_workspace_folders()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end

        local function format()
          require("conform").format { bufnr = bufnr }
        end

        local split_then = require("split_then").split_then
        local vsplit_then = require("split_then").vsplit_then

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        require("batteries").map {
          buffer = bufnr,
          { "gD", vim.lsp.buf.declaration, "Go to declaration" },
          { "gd", vim.lsp.buf.definition, "Go to definition" },
          { "gi", vim.lsp.buf.implementation, "Go to implementation" },
          { "gt", vim.lsp.buf.type_definition, "Go to symbol's type" },

          {
            "gsD",
            split_then(vim.lsp.buf.declaration),
            "Go to declaration in split",
          },
          { "gsd", split_then(vim.lsp.buf.definition), "Go to definition in split" },
          {
            "gsi",
            split_then(vim.lsp.buf.implementation),
            "Go to implementation in split",
          },
          {
            "gst",
            split_then(vim.lsp.buf.type_definition),
            "Go to symbol's type in split",
          },

          {
            "gvD",
            vsplit_then(vim.lsp.buf.declaration),
            "Go to declaration in vsplit",
          },
          {
            "gvd",
            vsplit_then(vim.lsp.buf.definition),
            "Go to definition in vsplit",
          },
          {
            "gvi",
            vsplit_then(vim.lsp.buf.implementation),
            "Go to implementation in vsplit",
          },
          {
            "gvt",
            vsplit_then(vim.lsp.buf.type_definition),
            "Go to symbol's type in vsplit",
          },

          {
            "<C-k>",
            vim.lsp.buf.signature_help,
            "Open signature help",
            mode = { "i", "n" },
          },

          { "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
          {
            "<space>ca",
            vim.lsp.buf.code_action,
            "Code action",
            mode = { "n", "v" },
          },
          { "<M-.>", vim.lsp.buf.code_action, "Code actions", mode = { "i", "n" } },
          { "gr", vim.lsp.buf.references, "Go to references" },
          { "<space>e", get_line_diagnostics, "Get diagnostics" },
          {
            "[d",
            function()
              vim.diagnostic.jump { count = -1, float = true }
            end,
            "Prev diagnostic",
          },
          {
            "]d",
            function()
              vim.diagnostic.jump { count = 1, float = true }
            end,
            "Next diagnostic",
          },
          { "<space>q", vim.diagnostic.setloclist, "Set loclist to diagnostics" },
          { "<space>f", format, "Format buffer" },
          { "<space>f", format, "Format range", mode = "v" },
          {
            prefix = "<space>w",
            group = "workspace folders",
          },
          { "<space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
          {
            "<space>wr",
            vim.lsp.buf.remove_workspace_folder,
            "Remove workspace folder",
          },
          { "<space>wl", list_workspace_folders, "List workspace folders" },
        }

        -- Setup progress/status info
        require("lsp-status").on_attach(client)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end

      -- Gross!!!!!
      -- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
      local nvim_lsp = require("lspconfig")
      local nvim_lsp_util = require("lspconfig.util")

      -- See: vim.lsp.ClientConfig
      local lsp_options = {
        on_attach = lsp_on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(
          require("lsp-status").capabilities
        ),
        handlers = {
          -- See: https://github.com/neovim/neovim/issues/31430
          ["client/registerCapability"] = function(err, result, ctx, config)
            local default_result =
              vim.lsp.handlers["client/registerCapability"](err, result, ctx, config)
            for_all_attached_buffers(ctx, reset_defaults)
            return default_result
          end,
        },
        flags = {
          debounce_text_changes = 150,
        },
        settings = {

          haskell = {
            formattingProvider = "fourmolu",
          },

          json = {
            validate = {
              enable = true,
            },
          },

          -- The yaml-language-server actually crashes if I do this with nested
          -- tables instead of writing the property name with dots. Incredible.
          -- Anyways this gets me autocomplete for things like GitHub Actions files.
          -- Essential.
          -- https://github.com/redhat-developer/yaml-language-server
          ["yaml.schemaStore.enable"] = true,

          ["rust-analyzer"] = {
            -- Meanwhile, `rust-analyzer` won't recognize `imports.granularity.group`
            -- unless it's formatted *with* nested tables.
            imports = {
              granularity = {
                -- Reformat imports.
                enforce = true,
                -- Create a new `use` statement for each import when using the
                -- auto-import functionality.
                -- https://rust-analyzer.github.io/manual.html#auto-import
                group = "item",
              },
            },
            inlayHints = {
              bindingModeHints = {
                enable = true,
              },
              closureReturnTypeHints = {
                enable = "always",
              },
              expressionAdjustmentHints = {
                enable = "always",
              },
            },
            checkOnSave = {
              -- Get clippy lints
              command = "clippy",
            },
            files = {
              excludeDirs = {
                -- Don't scan nixpkgs on startup -_-
                -- https://github.com/rust-lang/rust-analyzer/issues/12613#issuecomment-1174418175
                ".direnv",
              },
            },
            cargo = {
              features = "all",
            },
          },

          ["nil"] = {
            formatting = {
              command = { "nixfmt" },
            },
          },

          Lua = {
            runtime = {
              -- For neovim
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
              unusedLocalExclude = { "_*" },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            format = {
              enable = false,
            },
          },
        },
      }

      local lsp_server_options = {
        ["nil"] = {
          formatting = {
            command = { "alejandra" },
          },
          nix = {
            autoArchive = true,
            autoEvalInputs = true,
          },
        },
        denols = {
          -- Removing `.git` here so it won't conflict with `ts_ls`.
          root_dir = nvim_lsp_util.root_pattern("deno.json", "deno.jsonc"),
        },
        ts_ls = {
          -- Removing `.git` here so it won't conflict with `deno`.
          root_dir = nvim_lsp_util.root_pattern(
            "tsconfig.json",
            "jsconfig.json",
            "package.json"
          ),
          single_file_support = false,
        },
      }

      local function lsp_server_options_for(server)
        return vim.tbl_extend("keep", lsp_server_options[server] or {}, lsp_options)
      end

      if vim.fn.executable("static-ls") == 1 then
        lsp_server_options.hls = { cmd = { "static-ls" } }
      end

      -- `rust-tools` initializes `lspconfig`'s `rust_analyzer` as well, so it has to
      -- go before...
      require("rust-tools").setup {
        tools = {
          inlay_hints = {
            auto = true,
            parameter_hints_prefix = "← ",
            other_hints_prefix = "⇒ ",
          },
        },
        server = lsp_server_options_for("rust_analyzer"),
      }
      require("rust-tools").inlay_hints.enable()

      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
      local lsp_servers = {
        "pyright",
        "racket_langserver",
        "rust_analyzer",
        "denols", -- https://docs.deno.com/runtime/reference/lsp_integration/
        "ts_ls",
        "hls",
        "jsonls",
        "yamlls",
        "html",
        "cssls",
        "texlab", -- LaTeX
        "nil_ls", -- Nix: https://github.com/oxalica/nil
        "lua_ls", -- https://github.com/LuaLS/lua-language-server
        "gopls", -- https://github.com/golang/tools/tree/master/gopls
        "clangd", -- https://clangd.llvm.org/
        "buck2", -- https://buck2.build/docs/users/commands/lsp/
      }

      for _, lsp in ipairs(lsp_servers) do
        nvim_lsp[lsp].setup(lsp_server_options_for(lsp))
      end
    end,
  },
}

vim.opt.number = true
vim.opt.hidden = true
vim.opt.scrolloff = 1
vim.opt.linebreak = true
vim.opt.splitright = true
vim.opt.confirm = true
vim.opt.joinspaces = false
vim.opt.conceallevel = 2 -- Concealed text is hidden unless it has a :syn-cchar
vim.opt.list = true -- Display tabs and trailing spaces; see listchars
vim.opt.listchars = { tab = "│ ", trail = "·", extends = "…", nbsp = "␣" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.breakindent = true
vim.opt.breakindentopt = { min = 30, shift = -1 }
vim.opt.showbreak = "↪" -- Show a cool arrow to indicate continued lines
vim.opt.diffopt:append { "vertical", "iwhiteall" }
vim.opt.shortmess = "aoOsWAfilt" -- Help avoid hit-enter prompts
if vim.fn.has("mouse") then
  vim.opt.mouse = "nvichar"
end
if vim.fn.has("termguicolors") then
  vim.opt.termguicolors = true
end
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.exrc = true -- Load `.nvim.lua` when trusted

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --line-number $*"
end

local split_then = require("split_then").split_then
local vsplit_then = require("split_then").vsplit_then

local batteries = require("batteries")
batteries.map {
  -- Make j and k operate on screen lines.
  -- Text selection still operates on file lines; these are normal-mode
  -- mappings only.
  { "j", "gj", "Cursor down one screen line" },
  { "k", "gk", "Cursor up one screen line" },
  { "gj", "j", "Cursor down one file line" },
  { "gk", "k", "Cursor up one file line" },

  { prefix = "gs", group = "Go to ... in split" },
  { prefix = "gv", group = "Go to ... in vsplit" },

  {
    "gsf",
    split_then(function()
      vim.cmd("normal gf")
    end),
    "Go to file in split",
  },

  {
    "gsF",
    split_then(function()
      vim.cmd("normal gF")
    end),
    "Go to file and line in split",
  },

  {
    "gvf",
    vsplit_then(function()
      vim.cmd("normal gf")
    end),
    "Go to file in vsplit",
  },

  {
    "gvF",
    vsplit_then(function()
      vim.cmd("normal gF")
    end),
    "Go to file and line in vsplit",
  },

  -- `\w` toggles line-wrapping
  { "<leader>w", "<cmd>set wrap!<CR>", "Toggle wrapping" },

  -- Quickfix bindings!
  { prefix = "<Leader>q", group = "quickfix" },
  {
    "<Leader>qn",
    "<cmd>:cnext<CR>",
    "Next item in qflist",
  },
  {
    "<Leader>qp",
    "<cmd>:cprevious<CR>",
    "Previous item in qflist",
  },
  {
    "<Leader>qa",
    "<cmd>:cafter<CR>",
    "Item in qflist *a*fter cursor",
  },
  {
    "<Leader>qb",
    "<cmd>:cbefore<CR>",
    "Item in qflist *b*efore cursor",
  },
  { prefix = "<Leader>qf", group = "file" },
  {
    "<Leader>qfn",
    "<cmd>:cnfile<CR>",
    "Next file in qflist",
  },
  {
    "<Leader>qfp",
    "<cmd>:cpfile<CR>",
    "Previous file in qflist",
  },
}

batteries.cmd {
  range = "%",
  nargs = 0,
  "StripWhitespace",
  function(opts)
    -- Save cursor position.
    local cursor = vim.fn.getcurpos()
    -- Strip trailing whitespace & display number of matches
    local cmd = opts.line1 .. "," .. opts.line2 .. " smagic/\\s\\+$//e"
    vim.cmd(cmd .. "n\n" .. "keepjumps " .. cmd .. "g\n" .. "nohlsearch\n")
    vim.fn.setpos(".", cursor)
  end,
  "Delete trailing whitespace in the current buffer",
}

batteries.cmd {
  nargs = "?",
  complete = "filetype",
  "EditFtplugin",
  function(opts)
    local filetype = opts.fargs[1]
    if filetype == "" then
      filetype = vim.opt.filetype:get()
    end
    vim.cmd(
      "split " .. vim.fn.stdpath("config") .. "/ftplugin/" .. filetype .. ".lua"
    )
  end,
  "Edit the ftplugin for a filetype",
}

batteries.cmd {
  "MergeConflicts",
  function()
    vim.cmd([[/\M^\(<\{7}\||\{7}\|=\{7}\|>\{7}\)]])
  end,
  "Search for Git merge conflict markers",
}
