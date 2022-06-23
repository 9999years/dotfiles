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

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {}
    end,
  }

  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }

  -- Fuzzy finder
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("batteries").map {
        { prefix = "<Leader>t", name = "+telescope" },
        { "<Leader>tt", "<cmd>Telescope builtin include_extensions=true<CR>", "Telescope" },
        { "<Leader>tf", "<cmd>Telescope find_files<CR>", "Find files" },
        { "<Leader>f", "<cmd>Telescope find_files<CR>", "Find files" },
        { "<Leader>tb", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>b", "<cmd>Telescope buffers<CR>", "Find buffers" },
        { "<Leader>tg", "<cmd>Telescope live_grep<CR>", "Grep" },
        { "<Leader>th", "<cmd>Telescope oldfiles<CR>", "Recently opened" },
        { "<Space>fb", "<cmd>Telescope file_browser<CR>", "File browser" },
      }
      local trouble = require("trouble.providers.telescope")
      function max_height(self, max_columns, max_lines)
        return max_lines
      end
      function max_width(self, max_columns, max_lines)
        return max_columns
      end
      require("telescope").setup {
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
          },
          -- See: `:h telescope.resolve`
          layout_config = {
            horizontal = {
              height = max_height,
              width  = max_width,
            },
            vertical = {
              height = max_height,
              width  = max_width,
            }
          },
        }
      }
      require("telescope").load_extension("fzy_native")
      require("telescope").load_extension("ui-select") -- telescope-ui-select.nvim
      require("telescope").load_extension("gh") -- telescope-github.nvim
      require("telescope").load_extension("file_browser") -- telescope-file-browser.nvim
      require("telescope").load_extension("packer")
    end,
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-github.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-packer.nvim",
    },
  }

  -- GitHub integration / view in browser.
  use {
    "tyru/open-browser-github.vim",
    requires = { "tyru/open-browser.vim" },
    config = function()
      local batteries = require("batteries")
      batteries.cmd {
        range = true,
        nargs = 0,
        "Browse",
        "<line1>,<line2>OpenGithubFile",
      }

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
  -- vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
  use {
    "ms-jpq/coq_nvim",
    run = "python3 -m coq deps",
    branch = "coq",
    requires = {
      { "ms-jpq/coq.artifacts", branch = "artifacts" },
      { "ms-jpq/coq.thirdparty", branch = "3p" },
    },
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
                vim.schedule(function() gs.next_hunk() end)
                return "<Ignore>"
              end,
              "Next diff hunk",
              expr = true
            },
            {
              "[c",
              function()
                if vim.wo.diff then
                  return "[c"
                end
                vim.schedule(function() gs.prev_hunk() end)
                return "<Ignore>"
              end,
              "Prev diff hunk",
              expr = true
            },

            -- Text object
            { "ih", "<Cmd>Gitsigns select_hunk<CR>", "Hunk", mode = {"o", "x"} },

            -- Actions
            { prefix = "<Leader>h", name = "+hunk" },
            { "<Leader>hs", "<Cmd>Gitsigns stage_hunk<CR>", "Stage hunk", mode = {"n", "v"} },
            { "<Leader>hr", "<Cmd>Gitsigns reset_hunk<CR>", "Reset (unstage) hunk", mode = {"n", "v"} },
            { "<Leader>hS", gs.stage_buffer, "Stage buffer" },
            { "<Leader>hu", gs.undo_stage_hunk, "Undo stage hunk" },
            { "<Leader>hR", gs.reset_buffer, "Reset buffer" },
            { "<Leader>hp", gs.preview_hunk, "Preview hunk" },
            { "<Leader>hb", function() gs.blame_line { full = true } end, "Blame line" },
            { "<Leader>hD", function() gs.diffthis("~") end, "Diff" },
          }
        end
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
      vim.cmd([[
        autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()
      ]])
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
  use("b0o/schemastore.nvim")

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
    vim.cmd(
      cmd .. "n\n"
      .. "keepjumps " .. cmd .. "g\n"
      .. "nohlsearch\n"
    )
    vim.fn.setpos(".", cursor)
  end,
  "Delete trailing whitespace in the current buffer"
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
  "Edit the ftplugin for a filetype"
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
  "Edit the after/ftplugin for a filetype"
}

-- Language server / autocomplete configuration

-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local lsp_on_attach = function(client, bufnr)
  --Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  function get_line_diagnostics()
    vim.diagnostic.get(bufnr, { lnum = vim.fn.line('.') })
  end

  function list_workspace_folders()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
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
    { "<space>D",  vim.lsp.buf.type_definition, "Go to symbol's type" },
    { "<space>rn", vim.lsp.buf.rename, "Rename symbol" },
    { "<space>ca", vim.lsp.buf.code_action, "Code actions" },
    { "<M-.>",     vim.lsp.buf.code_action, "Code actions", mode = "i" },
    { "gr",        vim.lsp.buf.references, "Go to references" },
    { "<space>e",  get_line_diagnostics, "Get diagnostics" },
    { "[d",        vim.diagnostic.goto_prev, "Prev diagnostic" },
    { "]d",        vim.diagnostic.goto_next, "Next diagnostic" },
    { "<space>q",  vim.diagnostic.setloclist, "Set loclist to diagnostics" },
    { "<space>f",  vim.lsp.buf.formatting, "Format buffer" },
  }
  -- stylua: ignore end
  batteries.map {
    prefix = "<space>w",
    name = "+workspace folders",
  }
end

-- Automatically start coq
vim.g.coq_settings = {
  auto_start = "shut-up",
}

-- Gross!!!!!
-- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local nvim_lsp = require("lspconfig")

local lsp_options = {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    haskell = {
      formattingProvider = "fourmolu",
    },
    json = {
      schemas = require("schemastore").json.schemas(),
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
  },
}

-- `rust-tools` initializes `lspconfig`'s `rust_analyzer` as well, so it has to
-- go before...
require("rust-tools").setup {
  tools = {
    inlay_hints = {
      parameter_hints_prefix = "← ",
      other_hints_prefix = "⇒ ",
    },
  },
  server = lsp_options,
}

local lsp_hls_config = {}

-- Only use `halfsp` if it's in `$PATH`.
-- if vim.fn.executable("halfsp") == 1 then
  -- lsp_hls_config = {
    -- cmd = { "halfsp" },
  -- }
-- end

local lsp_server_options = {
  hls = lsp_hls_config,
}

local lsp_servers = {
  "pyright",
  "rust_analyzer",
  "tsserver",
  "hls",
  "jsonls",
  "yamlls",
}

for _, lsp in ipairs(lsp_servers) do
  nvim_lsp[lsp].setup(
    require("coq").lsp_ensure_capabilities(vim.tbl_extend("keep", lsp_server_options[lsp] or {}, lsp_options))
  )
end
