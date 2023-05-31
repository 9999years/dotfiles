-- See: `:h lua`
-- I like to format this file with `stylua` (`cargo install stylua`).
-- https://github.com/JohnnyMorganz/StyLua

-- Bootstrap packer: https://github.com/wbthomason/packer.nvim#bootstrapping
local packer_install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  packer_bootstrap = vim.fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    packer_install_path,
  }
end

-- Package manager & plugin configuration.
require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  -- Better repeated mappings with plugins.
  use("tpope/vim-repeat")

  -- Mapping/command utils.
  use("9999years/batteries.nvim")

  -- Comment toggling.
  use {
    "scrooloose/nerdcommenter",
    setup = function()
      vim.g.NERDSpaceDelims = 1
    end,
  }

  -- Text table alignment
  use("godlygeek/tabular")

  -- Pairs of mappings
  use("tpope/vim-unimpaired")

  -- `:Move`, `:Rename`, `:Mkdir`, etc.
  use("tpope/vim-eunuch")

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = { "nvim-treesitter/playground" },
    config = function()
      -- See: https://github.com/nvim-treesitter/nvim-treesitter#available-modules
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      }

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.markdown = {
        install_info = {
          url = "https://github.com/MDeiml/tree-sitter-markdown.git",
          files = { "src/parser.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "md",
      }
    end,
  }

  -- Create directories when saving files.
  use("jghauser/mkdir.nvim")

  -- Status line (mostly for LSP progress)
  use("nvim-lualine/lualine.nvim")

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end,
  }

  -- Fuzzy finder
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("batteries").map {
        { prefix = "<Leader>t", name = "+telescope" },
        { "<Leader>tt", "<cmd>Telescope builtin include_extensions=true<CR>", "Telescope" },
        { "<Leader>tf", "<cmd>Telescope find_files hidden=true<CR>", "Find files" },
        { "<Leader>f", "<cmd>Telescope find_files hidden=true<CR>", "Find files" },
        { "<Leader>tb", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>b", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>g", "<cmd>Telescope live_grep<CR>", "Grep" },
        { "<Leader>th", "<cmd>Telescope oldfiles<CR>", "Recently opened" },
      }
      function max_height(self, max_columns, max_lines)
        return max_lines
      end
      function max_width(self, max_columns, max_lines)
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
      require("telescope").load_extension("packer")
      require("telescope").load_extension("ctags_plus")
    end,
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
      -- "nvim-telescope/telescope-ui-select.nvim",
      { "9999years/telescope-ui-select.nvim", branch = "fix-newlines-in-prompt-bug" },
      "nvim-telescope/telescope-github.nvim",
      "nvim-telescope/telescope-packer.nvim",
      "gnfisher/nvim-telescope-ctags-plus",
    },
  }

  -- GitHub integration / view in browser.
  use {
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
  }

  -- LSP configuration
  use("neovim/nvim-lspconfig")
  -- Autoformat on save:
  use("lukas-reineke/lsp-format.nvim")
  use {
    "ms-jpq/coq_nvim",
    run = "python3 -m coq deps",
    branch = "coq",
    requires = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
      { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
  }
  -- Status/diagnostic information
  use("nvim-lua/lsp-status.nvim")
  -- Diagnostic injection, etc.
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = "nvim-lua/plenary.nvim",
  }

  use("lukas-reineke/indent-blankline.nvim") -- Indentation guides
  use("tpope/vim-fugitive") -- Git wrapper
  use {
    "lewis6991/gitsigns.nvim", -- Git gutter
    config = function()
      require("gitsigns").setup {
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
      }
    end,
  }

  -- Color scheme
  use {
    "Shatur/neovim-ayu",
    config = function()
      vim.cmd("colorscheme ayu")
    end,
  }

  -- Show a lightbulb to indicate code actions
  use {
    "kosayoda/nvim-lightbulb",
    config = function()
      require("nvim-lightbulb").setup {
        autocmd = { enabled = true },
      }
    end,
  }

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
  use {
    "sheerun/vim-polyglot",
    setup = function()
      vim.g.polyglot_disabled = { "rust", "latex", "java" }
    end,
  }

  -- Yesod Haskell web framework syntax highlighting.
  use("alx741/yesod.vim")

  use("rust-lang/rust.vim")
  use("simrat39/rust-tools.nvim")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)

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

  function get_line_diagnostics()
    vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") })
  end

  function list_workspace_folders()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end

  function format()
    vim.lsp.buf.format { async = true }
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- stylua: ignore start
  batteries.map {
    buffer = bufnr,
    { "gD",        vim.lsp.buf.declaration, "Go to declaration" },
    { "gd",        vim.lsp.buf.definition, "Go to definition" },
    { "K",         vim.lsp.buf.hover, "Hover docs" },
    { "gi",        vim.lsp.buf.implementation, "Go to implementation" },
    { "<C-k>",     vim.lsp.buf.signature_help, "Open signature help" },
    { "<space>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
    { "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
    { "<space>wl", list_workspace_folders, "List workspace folders" },
    { "gt",        vim.lsp.buf.type_definition, "Go to symbol's type" },
    { "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
    { "<space>ca", vim.lsp.buf.code_action, "Code actions" },
    { "<M-.>",     vim.lsp.buf.code_action, "Code actions", mode = { "i", "n" } },
    { "gr",        vim.lsp.buf.references, "Go to references" },
    { "<space>e",  get_line_diagnostics, "Get diagnostics" },
    { "[d",        vim.diagnostic.goto_prev, "Prev diagnostic" },
    { "]d",        vim.diagnostic.goto_next, "Next diagnostic" },
    { "<space>q",  vim.diagnostic.setloclist, "Set loclist to diagnostics" },
    { "<space>f",  format, "Format buffer" },
  }
  -- stylua: ignore end
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

-- Automatically start coq
vim.g.coq_settings = {
  auto_start = "shut-up",
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
    lualine_a = { "filename" },
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
  on_attach = lsp_on_attach,
  capabilities = lsp_status.capabilities,
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
    },

    ["nil"] = {
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
}

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
  server = lsp_options,
}
require("rust-tools").inlay_hints.enable()

local lsp_server_options = {
  ["nil"] = {
    formatting = {
      command = { "alejandra" },
    },
  },
}

if vim.fn.executable("static-ls") == 1 then
  lsp_server_options.hls = { cmd = { "static-ls" } }
end

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
}

for _, lsp in ipairs(lsp_servers) do
  nvim_lsp[lsp].setup(
    require("coq").lsp_ensure_capabilities(vim.tbl_extend("keep", lsp_server_options[lsp] or {}, lsp_options))
  )
end
