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

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/playground" },
    config = function()
      -- See: https://github.com/nvim-treesitter/nvim-treesitter#available-modules
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "diff", "git_rebase" },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
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
  { "nvim-lualine/lualine.nvim" },

  { "folke/which-key.nvim", config = true },

  {
    "folke/trouble.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = {
      action_keys = {
        jump = "<tab>",
        jump_close = "<cr>",
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("batteries").map {
        { prefix = "<Leader>t", name = "+telescope" },
        { "<Leader>tt", "<cmd>Telescope builtin include_extensions=true<CR>", "Telescope" },
        { "<Leader>tf", "<cmd>Telescope find_files hidden=true<CR>", "Find files" },
        { "<Leader>tb", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>b", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>th", "<cmd>Telescope oldfiles<CR>", "Recently opened" },
      }
      local trouble = require("trouble.providers.telescope")
      local function max_height(_self, _max_columns, max_lines)
        return max_lines
      end

      local function max_width(_self, max_columns, _max_lines)
        return max_columns
      end

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
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
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
        default_directory = require("broot.default_directory").current_file,
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
        "<leader>g",
        function()
          require("broot").broot {
            extra_args = { "--cmd", "/" },
          }
        end,
        "Edit file with Broot",
      }
    end,
  },

  -- GitHub integration / view in browser.
  {
    "9999years/open-browser-git.nvim",
    config = function()
      require("open_browser_git").setup {
        command_prefix = "Browse",
      }
      local batteries = require("batteries")
      batteries.map {
        "<leader>og",
        "<cmd>Browse<CR>",
        "Open file on GitHub",
      }
    end,
  },

  -- LSP configuration
  { "neovim/nvim-lspconfig" },
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "mtoohey31/cmp-fish",
      "hrsh7th/cmp-nvim-lua",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      {
        "petertriho/cmp-git",
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
      },
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-a>"] = cmp.mapping.scroll_docs(-4),
          ["<C-e>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
        },
        sources = cmp.config.sources {
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "async_path" },
          { name = "buffer" },
          { name = "git" },
          { name = "fish" },
          { name = "nvim_lua" },
        },
      }
    end,
  },
  -- Autoformat on save:
  { "lukas-reineke/lsp-format.nvim" },
  -- Status/diagnostic information
  { "nvim-lua/lsp-status.nvim" },
  -- Diagnostic injection, etc.
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = "nvim-lua/plenary.nvim",
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
          { prefix = "<Leader>h", name = "+hunk" },
          { "<Leader>hs", "<Cmd>Gitsigns stage_hunk<CR>", "Stage hunk", mode = { "n", "v" } },
          { "<Leader>hr", "<Cmd>Gitsigns reset_hunk<CR>", "Reset (unstage) hunk", mode = { "n", "v" } },
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
      vim.g.polyglot_disabled = { "rust", "latex", "java" }
    end,
  },

  -- Yesod Haskell web framework syntax highlighting.
  { "alx741/yesod.vim" },

  -- Neovim Lua setup.
  {
    "folke/neodev.nvim",
    opts = {
      lspconfig = false,
    },
  },

  { "rust-lang/rust.vim" },
  { "simrat39/rust-tools.nvim" },
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
vim.opt.shortmess = "aoOsWAfil" -- Help avoid hit-enter prompts
if vim.fn.has("mouse") then
  vim.opt.mouse = "nvichar"
end
if vim.fn.has("termguicolors") then
  vim.opt.termguicolors = true
end
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

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
    local ft = opts.fargs[1]
    if ft == "" then
      ft = vim.opt.ft:get()
    end
    vim.cmd("split " .. vim.fn.stdpath("config") .. "/ftplugin/" .. ft .. ".vim")
  end,
  "Edit the ftplugin for a filetype",
}
batteries.cmd {
  nargs = "?",
  complete = "filetype",
  "EditAfterFtplugin",
  function(opts)
    local ft = opts.fargs[1]
    if ft == "" then
      ft = vim.opt.ft:get()
    end
    vim.cmd("split " .. vim.fn.stdpath("config") .. "/after/ftplugin/" .. ft .. ".vim")
  end,
  "Edit the after/ftplugin for a filetype",
}

-- Language server / autocomplete configuration

-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- https://github.com/neovim/neovim/issues/16807#issuecomment-1001618856
require("vim.lsp.log").set_format_func(vim.inspect)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local lsp_on_attach = function(client, bufnr)
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

  local function lsp_references()
    require("trouble").open("lsp_references")
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  batteries.map {
    buffer = bufnr,
    { "gD", vim.lsp.buf.declaration, "Go to declaration" },
    { "gd", vim.lsp.buf.definition, "Go to definition" },
    { "K", vim.lsp.buf.hover, "Hover docs" },
    { "gi", vim.lsp.buf.implementation, "Go to implementation" },
    { "<C-k>", vim.lsp.buf.signature_help, "Open signature help" },
    { "<space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
    { "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
    { "<space>wl", list_workspace_folders, "List workspace folders" },
    { "gt", vim.lsp.buf.type_definition, "Go to symbol's type" },
    { "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
    { "<space>ca", vim.lsp.buf.code_action, "Code actions" },
    { "<M-.>", vim.lsp.buf.code_action, "Code actions", mode = { "i", "n" } },
    { "gr", lsp_references, "Go to references" },
    { "<space>e", get_line_diagnostics, "Get diagnostics" },
    { "[d", vim.diagnostic.goto_prev, "Prev diagnostic" },
    { "]d", vim.diagnostic.goto_next, "Next diagnostic" },
    { "<space>q", vim.diagnostic.setloclist, "Set loclist to diagnostics" },
    { "<space>f", format, "Format buffer" },
  }
  batteries.map {
    prefix = "<space>w",
    name = "+workspace folders",
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
null_ls.setup {
  on_attach = lsp_on_attach,
  sources = {
    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.actionlint,
    null_ls.builtins.diagnostics.fish,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.fish_indent,
    null_ls.builtins.formatting.jq,
    null_ls.builtins.formatting.alejandra,
    null_ls.builtins.formatting.stylua,
  },
}

-- Gross!!!!!
-- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local nvim_lsp = require("lspconfig")

-- Progress information / diagnostics
local lsp_status = require("lsp-status")
lsp_status.register_progress()

require("lualine").setup {
  options = {
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
      lsp_status.status_progress,
    },
  },
}

local lsp_options = {
  before_init = require("neodev.lsp").before_init,
  on_attach = lsp_on_attach,
  capabilities = require("cmp_nvim_lsp").default_capabilities(lsp_status.capabilities),
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

require("lsp-format").setup {
  exclude = {},
}

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
}

for _, lsp in ipairs(lsp_servers) do
  nvim_lsp[lsp].setup(lsp_server_options_for(lsp))
end
