--- @type LazyPluginSpec
return {
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
}
