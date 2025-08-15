--- @type LazyPluginSpec
local M = {
  "neovim/nvim-lspconfig",
}

M.dependencies = {
  "batteries.nvim",

  -- Autoformat on save.
  require("rbt.autoformat"),

  -- Status/diagnostic information
  {
    "nvim-lua/lsp-status.nvim",
    config = function()
      require("lsp-status").register_progress()
    end,
  },

  -- Rust inlay hints and extras.
  --
  -- Archived, replaced with: https://github.com/mrcjkb/rustaceanvim
  "simrat39/rust-tools.nvim",

  -- Needed to handle the `omnisharp` LSP's nonsense `$metadata` paths
  -- correctly.
  "Hoffs/omnisharp-extended-lsp.nvim",

  -- Neovim Lua setup.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    config = function()
      -- Monkeypatch in a PR to remove a call to the deprecated `client.notify`
      -- function.
      --
      -- See: https://github.com/folke/lazydev.nvim/pull/106
      local config = require("lazydev.config")
      config.have_0_11 = vim.fn.has("nvim-0.11") == 1

      local lsp = require("lazydev.lsp")
      lsp.update = function(client)
        lsp.assert(client)
        if config.have_0_11 then
          client:notify("workspace/didChangeConfiguration", {
            settings = { Lua = {} },
          })
        else
          client.notify("workspace/didChangeConfiguration", {
            settings = { Lua = {} },
          })
        end
      end

      require("lazydev").setup {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      }
    end,
  },
}

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
-- LSP client will reset these options _after_ calling `lsp_attach`.
--
-- See: https://github.com/neovim/neovim/issues/31430
local function reset_defaults(_client, bufnr)
  -- *Don't* set `formatexpr` to `v:lua.vim.lsp.formatexpr()` because I like
  -- Vim's default word-wrapping for comments and such. Anyways I have
  -- `:Format` and format-on-save. See `conform.nvim`.
  vim.api.nvim_set_option_value("formatexpr", "", { buf = bufnr })
end

local function list_workspace_folders()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

local split_then = require("split-then").split_then
local vsplit_then = require("split-then").vsplit_then

--- @arg opts vim.diagnostic.JumpOpts
local function jump_most_severe(opts)
  --- @arg severity vim.diagnostic.Severity
  local function opts_for_severity(severity)
    return vim.tbl_extend("keep", {
      severity = severity,
    }, opts)
  end

  local diagnostic =
    vim.diagnostic.jump(opts_for_severity(vim.diagnostic.severity.ERROR))
  if diagnostic ~= nil then
    return
  end

  diagnostic = vim.diagnostic.jump(opts_for_severity(vim.diagnostic.severity.WARN))
  if diagnostic ~= nil then
    return
  end

  vim.diagnostic.jump(opts)
end

-- Use an `LspAttach` function to only create LSP-related key bindings after
-- the language server attaches to the buffer.
--
--- @param args vim.api.keyset.create_autocmd.callback_args
local function lsp_attach(args)
  --- @type vim.lsp.Client
  local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

  --- @type integer
  local bufnr = args.buf

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_set_option_value(
    "omnifunc",
    "v:lua.vim.lsp.omnifunc",
    { buf = bufnr }
  )

  local function get_line_diagnostics()
    vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") })
  end

  local function format()
    require("conform").format { bufnr = bufnr }
  end

  reset_defaults(client, bufnr)

  local definition = vim.lsp.buf.definition
  local type_definition = vim.lsp.buf.type_definition
  local references = vim.lsp.buf.references
  local implementation = vim.lsp.buf.implementation

  if vim.bo["filetype"] == "cs" then
    local omnisharp = require("omnisharp_extended")
    definition = omnisharp.lsp_definition
    type_definition = omnisharp.lsp_type_definition
    references = omnisharp.lsp_references
    implementation = omnisharp.lsp_implementation
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  require("batteries").map {
    buffer = bufnr,
    { "gD", vim.lsp.buf.declaration, "Go to declaration" },
    { "gd", definition, "Go to definition" },
    { "gi", implementation, "Go to implementation" },
    { "gt", type_definition, "Go to symbol's type" },

    { "grr", references, "Go to references" },
    { "gri", implementation, "Go to implementation" },
    { "grt", type_definition, "Go to type definition" },

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
    { "<space>e", get_line_diagnostics, "Get diagnostics" },
    { "<space>q", vim.diagnostic.setqflist, "Set qflist to diagnostics" },
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

    {
      "[D",
      function()
        jump_most_severe {
          count = -1,
        }
      end,
      "Go to next severe diagnostic",
    },
    {
      "]D",
      function()
        jump_most_severe {
          count = 1,
        }
      end,
      "Go to next severe diagnostic",
    },
  }

  -- Setup progress/status info
  require("lsp-status").on_attach(client)
  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

function M.config()
  -- Language server / autocomplete configuration

  -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

  -- https://github.com/neovim/neovim/issues/16807#issuecomment-1001618856
  vim.lsp.log.set_format_func(vim.inspect)

  -- When jumping to diagnostics, open floating windows by default.
  vim.diagnostic.config {
    jump = {
      float = true,
    },
  }

  -- See: `:h lsp-attach`
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("rbt.lsp", {}),
    callback = lsp_attach,
  })

  -- Gross!!!!!
  -- See: https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
  local nvim_lsp = require("lspconfig")

  -- See: vim.lsp.ClientConfig
  local lsp_options = {
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

      -- See: https://rust-analyzer.github.io/book/configuration
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
    omnisharp = {
      cmd = {
        "OmniSharp",
        "--zero-based-indices",
        "DotNet:enablePackageRestore=false",
        "--encoding",
        "utf-8",
        "--languageserver",
      },
    },
  }

  if vim.fn.executable("static-ls") == 1 then
    lsp_server_options.hls = { cmd = { "static-ls" } }
  end

  local function lsp_server_options_for(server)
    return vim.tbl_extend("keep", lsp_server_options[server] or {}, lsp_options)
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
    "omnisharp", -- C# https://github.com/dotnet/roslyn
  }

  for _, lsp in ipairs(lsp_servers) do
    nvim_lsp[lsp].setup(lsp_server_options_for(lsp))
  end
end

return M
