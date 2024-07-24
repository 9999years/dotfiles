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
          disable = {
            -- https://github.com/andymass/vim-matchup/issues/347
            "haskell",
          },
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
            "vimdoc",
            "haskell",
          },
        },
        indent = {
          enable = true,
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
          "Edit file with Broot",
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
        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "async_path" },
          { name = "buffer" },
        }),

        ---@diagnostic disable-next-line: missing-fields
        matching = {
          disallow_partial_fuzzy_matching = false,
        },
      }
    end,
  },

  { "lukas-reineke/indent-blankline.nvim" }, -- Indentation guides
  { "tpope/vim-fugitive" }, -- Git wrapper
  {
    "lewis6991/gitsigns.nvim", -- Git gutter
    opts = {
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
                gs.next_hunk()
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
                gs.prev_hunk()
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
          { "<Leader>hu", gs.undo_stage_hunk, "Undo stage hunk" },
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
    end,
  },

  -- Show a lightbulb to indicate code actions
  {
    "kosayoda/nvim-lightbulb",
    opts = {
      autocmd = { enabled = true },
    },
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
        "lukas-reineke/lsp-format.nvim",
        config = function()
          require("lsp-format").setup {
            exclude = {},
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
      -- Diagnostic injection, etc.
      {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = "nvim-lua/plenary.nvim",
      },
      -- Rust inlay hints and extras.
      "simrat39/rust-tools.nvim",
      -- Neovim Lua setup.
      {
        "folke/neodev.nvim",
        opts = {
          lspconfig = false,
        },
      },
    },

    config = function()
      -- Language server / autocomplete configuration

      -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

      -- https://github.com/neovim/neovim/issues/16807#issuecomment-1001618856
      require("vim.lsp.log").set_format_func(vim.inspect)

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local function lsp_on_attach(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- *Don't* set `formatexpr` to `v:lua.vim.lsp.formatexpr()` because I like
        -- Vim's default word-wrapping for comments and such. Anyways I have
        -- `:Format` and format-on-save. See `lsp-format`.
        vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")

        local function get_line_diagnostics()
          vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") })
        end

        local function list_workspace_folders()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end

        local function format()
          vim.lsp.buf.format { async = true }
        end

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        require("batteries").map {
          buffer = bufnr,
          { "gD", vim.lsp.buf.declaration, "Go to declaration" },
          { "gd", vim.lsp.buf.definition, "Go to definition" },
          { "gi", vim.lsp.buf.implementation, "Go to implementation" },
          {
            "<C-k>",
            vim.lsp.buf.signature_help,
            "Open signature help",
            mode = { "i", "n" },
          },
          { "gt", vim.lsp.buf.type_definition, "Go to symbol's type" },
          { "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
          { "<space>ca", vim.lsp.buf.code_action, "Code actions" },
          { "<M-.>", vim.lsp.buf.code_action, "Code actions", mode = { "i", "n" } },
          { "gr", vim.lsp.buf.references, "Go to references" },
          { "<space>e", get_line_diagnostics, "Get diagnostics" },
          { "[d", vim.diagnostic.goto_prev, "Prev diagnostic" },
          { "]d", vim.diagnostic.goto_next, "Next diagnostic" },
          { "<space>q", vim.diagnostic.setloclist, "Set loclist to diagnostics" },
          { "<space>f", format, "Format buffer" },
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

        -- Autoformat on save
        require("lsp-format").on_attach(client)
        -- Setup progress/status info
        require("lsp-status").on_attach(client)
      end

      -- null-ls allows Lua and external commands to inject diagnostics as though
      -- they were a full-fledged language server.
      -- Among other things this is a really neat way to support format-on-save; I
      -- have a plugin that handles that for LSPs, so null-ls bridges the gap by
      -- letting me use any old formatter.
      -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
      local null_ls = require("null-ls")

      local python_formatter = null_ls.builtins.formatting.black

      if vim.fn.executable("ruff") == 1 then
        local null_ls_helpers = require("null-ls.helpers")
        python_formatter = null_ls_helpers.make_builtin {
          name = "ruff",
          meta = {
            url = "https://github.com/charliermarsh/ruff/",
            description = "An extremely fast Python linter, written in Rust.",
          },
          method = require("null-ls.methods").internal.FORMATTING,
          filetypes = { "python" },
          generator_opts = {
            command = "ruff",
            args = { "format", "--stdin-filename", "$FILENAME", "-" },
            to_stdin = true,
          },
          factory = null_ls_helpers.formatter_factory,
        }
      end

      null_ls.setup {
        on_attach = lsp_on_attach,
        sources = {
          null_ls.builtins.code_actions.shellcheck,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.actionlint,
          null_ls.builtins.diagnostics.fish,
          null_ls.builtins.formatting.fish_indent,
          null_ls.builtins.formatting.jq,
          null_ls.builtins.formatting.alejandra,
          null_ls.builtins.formatting.stylua,
          python_formatter,
        },
      }

      -- Gross!!!!!
      -- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
      local nvim_lsp = require("lspconfig")

      local lsp_options = {
        before_init = require("neodev.lsp").before_init,
        on_attach = lsp_on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(
          require("lsp-status").capabilities
        ),
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
          },

          ["nil"] = {
            formatting = {
              command = { "nixpkgs-fmt" },
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

      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      local lsp_servers = {
        "pyright",
        "racket_langserver",
        "rust_analyzer",
        "tsserver",
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

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --line-number $*"
end

local batteries = require("batteries")
batteries.map {
  -- Make j and k operate on screen lines.
  -- Text selection still operates on file lines; these are normal-mode
  -- mappings only.
  { "j", "gj", "Cursor down one screen line" },
  { "k", "gk", "Cursor up one screen line" },
  { "gj", "j", "Cursor down one file line" },
  { "gk", "k", "Cursor up one file line" },

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
