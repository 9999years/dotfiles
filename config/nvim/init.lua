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
  -- This adds the `matchup` module to treesitter below.
  { "andymass/vim-matchup" },

  -- Better parsing for syntax highlighting and other goodies.
  require("rbt.treesitter"),

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
  require("rbt.telescope"),

  -- Broot integration
  require("rbt.broot"),

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
  require("rbt.snippet"),

  -- Autocompletion
  require("rbt.autocomplete"),

  { "lukas-reineke/indent-blankline.nvim" }, -- Indentation guides
  { "tpope/vim-fugitive" }, -- Git wrapper
  require("rbt.gitsigns"),

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
  --
  -- Deprecation warning: `vim.validate is deprecated. Feature will be removed in Nvim 1.0`
  -- See: https://github.com/kosayoda/nvim-lightbulb/pull/78
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

  -- Yesod Haskell web framework syntax highlighting.
  { "alx741/yesod.vim" },

  -- LSP configuration
  require("rbt.lsp"),
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

local split_then = require("split-then").split_then
local vsplit_then = require("split-then").vsplit_then

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
