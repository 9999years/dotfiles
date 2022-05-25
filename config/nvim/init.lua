-- Bootstrap packer: https://github.com/wbthomason/packer.nvim#bootstrapping
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim',
    packer_install_path
  })
end

-- Package manager & plugin configuration.
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Better repeated mappings with plugins.
  use "tpope/vim-repeat"

  -- Comment toggling.
  use {
    "scrooloose/nerdcommenter",
    setup = function() vim.g.NERDSpaceDelims = 1 end,
  }

  -- Text table alignment
  use "godlygeek/tabular"

  -- Pairs of mappings
  use "tpope/vim-unimpaired"

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
          files = {"src/parser.c"},
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "md",
      }
    end,
  }

  -- Fuzzy finder
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      vim.cmd [[
        nnoremap <leader>t :<C-u>Telescope<CR>
        nnoremap <leader>f :<C-u>Telescope find_files<CR>
        nnoremap <leader>b :<C-u>Telescope buffers<CR>
        nnoremap <leader>g :<C-u>Telescope live_grep<CR>
        nnoremap <leader>h :<C-u>Telescope oldfiles<CR>
      ]]
    end,
    requires = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
  }

  use {
    "nvim-telescope/telescope-ui-select.nvim",
    requires = "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").setup{}
      require("telescope").load_extension("ui-select")
    end,
  }

  -- GitHub integration / view in browser.
  use {
    "tyru/open-browser-github.vim",
    requires = { "tyru/open-browser.vim" },
    config = function()
      vim.cmd [[
        command! -range -nargs=0 Browse <line1>,<line2>OpenGithubFile
        nnoremap <leader>og :Browse<CR>
      ]]
    end,
  }

  -- LSP configuration
  use "neovim/nvim-lspconfig"
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

  use "lukas-reineke/indent-blankline.nvim" -- Indentation guides
  use "tpope/vim-fugitive"                  -- Git wrapper
  use {
    "lewis6991/gitsigns.nvim",              -- Git gutter
    config = function() require("gitsigns").setup() end,
  }

  -- Color scheme
  use {
    "Shatur/neovim-ayu",
    config = function() vim.cmd("colorscheme ayu") end,
  }

  -- Show a lightbulb to indicate code actions
  use {
    "kosayoda/nvim-lightbulb",
    config = function()
      vim.cmd [[
        autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()
      ]]
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
    setup = function() vim.g.polyglot_disabled = { "rust", "latex", "java" } end
  }

  -- Yesod Haskell web framework syntax highlighting.
  use "alx741/yesod.vim"

  use "rust-lang/rust.vim"
  use "simrat39/rust-tools.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

vim.opt.number = true
vim.opt.hidden = true
vim.opt.scrolloff = 1
vim.opt.linebreak = true
vim.opt.splitright = true
vim.opt.confirm = true
vim.opt.joinspaces = false
vim.opt.conceallevel = 2  -- Concealed text is hidden unless it has a :syn-cchar
vim.opt.list = true       -- Display tabs and trailing spaces; see listchars
vim.opt.listchars = { tab = "│ ", trail = "·", extends = "…", nbsp = "␣" }
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.breakindent = true
vim.opt.breakindentopt = { min = 30, shift = -1 }
vim.opt.showbreak = "↪"  -- Show a cool arrow to indicate continued lines
vim.opt.diffopt:append { "vertical", "iwhiteall" }
vim.opt.shortmess = "aoOsWAfil"  -- Help avoid hit-enter prompts
if vim.fn["has"] "mouse" then
  vim.opt.mouse = "nvichar"
end
if vim.fn["has"] "termguicolors" then
  vim.opt.termguicolors = true
end
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Make j and k operate on screen lines.
-- Text selection still operates on file lines; these are normal-mode mappings
-- only.
vim.cmd [[
  nnoremap j gj
  nnoremap k gk
  nnoremap gj j
  nnoremap gk k
]]

vim.cmd("command! -range=% -nargs=0 StripWhitespace"
  .. " call misc#StripWhitespace(<line1>, <line2>)")
vim.cmd("command! -nargs=? -complete=filetype EditFtplugin"
  .. " call misc#EditFtplugin(<f-args>)")
vim.cmd("command! -nargs=? -complete=filetype EditAfterFtplugin"
  .. " call misc#EditAfterFtplugin(<f-args>)")
vim.cmd("command! -nargs=? -complete=filetype EditUltiSnips"
  .. " call misc#EditUltiSnips(<f-args>)")

-- Language server / autocomplete configuration

-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local lsp_on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap("n", "gD",        "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd",        "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K",         "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi",        "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<C-k>",     "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D",  "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr",        "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<space>e",  "<cmd>lua vim.diagnostic.get(" .. bufnr .. ", { lnum = vim.fn.line('.') })<CR>", opts)
  buf_set_keymap("n", "[d",        "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d",        "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q",  "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  buf_set_keymap("n", "<space>f",  "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

end

-- Automatically start coq
vim.g.coq_settings = {
  auto_start = "shut-up",
}

-- Gross!!!!!
-- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
local nvim_lsp = require "lspconfig"

local lsp_options = {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    haskell = {
      formattingProvider = "fourmolu",
    },
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
if vim.fn.executable("halfsp") == 1 then
  lsp_hls_config = {
    cmd = { "halfsp" }
  }
end

local lsp_server_options = {
  hls = lsp_hls_config,
}

local lsp_servers = {
  "pyright",
  "rust_analyzer",
  "tsserver",
  "hls",
}

for _, lsp in ipairs(lsp_servers) do
  nvim_lsp[lsp].setup(
    require("coq").lsp_ensure_capabilities(
      vim.tbl_extend(
        "keep",
        lsp_server_options[lsp] or {},
        lsp_options
      )
    )
  )
end
