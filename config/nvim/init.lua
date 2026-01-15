-- See: `:h lua`
-- I like to format this file with `stylua` (`cargo install stylua`).
-- https://github.com/JohnnyMorganz/StyLua

-- Bootstrap lazy.nvim: https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
  {
    "tpope/vim-repeat",
    config = function()
      -- Force `vim-repeat` to load by wrapping a no-op command. If
      -- `vim-repeat` doesn't load, then the undo mapping points to a
      -- non-existent command and does nothing. Ugh!
      --
      -- This is the closest thing I can find to a no-op command. `::` seems to
      -- work but it's not documented?
      vim.fn["repeat#wrap"]('execute ""', 0)
    end,
  },

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

  {
    "folke/which-key.nvim",
    opts = {
      plugins = {
        -- When attempting to display register values over SSH, this causes
        -- Neovim to emit an OSC-52 sequence to get the keyboard from the SSH
        -- host. Wezterm doesn't support this, so it stalls forever, making the
        -- attempted paste or yank fail.
        --
        -- See: https://github.com/wezterm/wezterm/issues/2050
        --
        -- It would be nice if we could only toggle displaying system clipboard
        -- registers and keep the internal registers displayed, but alas.
        --
        -- I'm not going to report this upstream because folke insta-closes
        -- most issues with no resolution and generally does not seem to view
        -- issue trackers as a place to track issues.
        --
        -- See: https://github.com/folke/lazy.nvim/issues/2084
        registers = false,
      },
    },
  },

  -- Fuzzy finder
  require("rbt.telescope"),

  -- Broot integration
  require("rbt.broot"),

  -- GitHub integration / view in browser.
  {
    "9999years/open-browser-git.nvim",
    config = function()
      require("open_browser_git").setup {
        commands = {
          open = "Browse",
          copy = "Copy",
        },
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
      -- Line numbers are too dark.
      vim.cmd("highlight! link LineNr StatusLineNC")
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
        filename = {
          ["flake.lock"] = "json.flake",
        },
      }

      local lint = require("lint")

      -- It's literally always Bash.
      local shellcheck = require("lint").linters.shellcheck
      table.insert(shellcheck.args, "--shell=bash")

      -- Display `lastModified` timestamps in `flake.lock` files as human-readable dates.
      lint.linters.flake_lock_unix_timestamps =
        require("rbt.flake_lock_unix_timestamps")

      lint.linters_by_ft = {
        sh = { "shellcheck" },
        ghaction = { "actionlint" },
        flake = { "flake_lock_unix_timestamps" },
      }

      -- Lint when opening or writing a file.
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })

      -- Display human-readable `flake.lock` timestamps in virtual text,
      -- without needing to jump to the lint explicitly.
      local flakeunixtime_namespace =
        require("lint").get_namespace("flake_lock_unix_timestamps")
      vim.diagnostic.config({ virtual_text = true }, flakeunixtime_namespace)
    end,
  },

  {
    "wesQ3/vim-windowswap",
    init = function()
      vim.g.windowswap_map_keys = 0
    end,
    config = function()
      require("batteries").map {
        {
          "<C-w>y",
          function()
            vim.fn["WindowSwap#MarkWindowSwap"]()
          end,
          "Yank window",
        },
        {
          "<C-w>p",
          function()
            vim.fn["WindowSwap#DoWindowSwap"]()
          end,
          "Paste window",
        },
        {
          "<C-w>e",
          function()
            vim.fn["WindowSwap#EasyWindowSwap"]()
          end,
          "Easy swap window",
        },
      }
    end,
  },

  require("rbt.session"),

  -- Yesod Haskell web framework syntax highlighting.
  { "alx741/yesod.vim" },
  -- `:BuckOpen`, `:BuckTarget`.
  {
    "lf-/buck2.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

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
-- There's no way to get the `wildmenu` to show dotfiles by default.
-- https://github.com/neovim/neovim/issues/35111
vim.opt.wildoptions:append { "fuzzy" } -- Fuzzy completion in command line
vim.opt.wildignorecase = true
vim.opt.sessionoptions:append {
  -- We use `vim.g.format_after_save` to toggle autoformatting, but Vim only
  -- saves "global variables that start with an uppercase letter and contain at
  -- least one lowercase letter" (???) so maybe we need to change the name...?
  "globals",
  "localoptions",
  -- Includes key mappings.
  "options",
  -- Don't save the `runtimepath` or `packpath` options; these seem to confuse
  -- `lazy.nvim` and cause strange errors:
  --
  --     Error executing vim.schedule lua callback: ...ovim-unwrapped-0.11.5/share/nvim/runtime/lua/vim/lsp.lua:258: module 'vim.
  --     lsp.client' not found:
  --             no field package.preload['vim.lsp.client']
  --             cache_loader: module 'vim.lsp.client' not found
  --             cache_loader_lib: module 'vim.lsp.client' not found
  "skiprtp",
}

-- See: `:h netrw-variables`
vim.g.netrw_banner = false
-- Show a tree-style listing.
vim.g.netrw_liststyle = 3

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
    if not filetype then
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
    vim.cmd([[/\v^(\<{7}|\|{7}|\={7}|\>{7}|\+{7}|\%{7}|-{7})]])
  end,
  "Search for Git merge conflict markers",
}

batteries.cmd {
  complete = "file",
  nargs = "?", -- 0 or 1.
  range = true, -- Default current line.
  "CopyContext",
  function(args)
    require("rbt.context").copy_range_context(args)
  end,
  "Copy a reference to the file as context for an LLM",
}

batteries.cmd {
  complete = "file",
  nargs = "?", -- 0 or 1.
  range = true, -- Default current line.
  "CopyContextAbsolute",
  function(args)
    require("rbt.context").copy_range_context_absolute(args)
  end,
  "Copy a reference to the file as context for an LLM",
}

vim.filetype.add {
  extension = {
    -- See: https://buck2.build/docs/bxl/
    bxl = "bzl.bxl",
  },
  filename = {
    ["gitconfig"] = "gitconfig",
    ["BUCK"] = "bzl.build",
    ["PACKAGE"] = "bzl.build",
  },
  pattern = {
    -- NB: Lua patterns!
    ["%.buckconfig.*"] = "ini",
  },
}
