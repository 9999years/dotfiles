--- @type LazyPluginSpec
local M = {
  "9999years/broot.nvim",
}

function M.config()
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
end

return M
