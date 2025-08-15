--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "lewis6991/gitsigns.nvim", -- Git gutter
}

M.opts = {
  diff_opts = {
    ignore_whitespace = false,
  },
}

function M.opts.on_attach(bufnr)
  local gitsigns = require("gitsigns")
  local batteries = require("batteries")

  batteries.map {
    buffer = bufnr,

    -- Navigation
    {
      "]c",
      function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          gitsigns.nav_hunk("next")
        end
      end,
      "Next diff hunk",
    },
    {
      "[c",
      function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          gitsigns.nav_hunk("prev")
        end
      end,
      "Prev diff hunk",
    },

    -- Text object
    {
      "ih",
      function()
        gitsigns.select_hunk()
      end,
      "Hunk",
      mode = { "o", "x" },
    },

    -- Actions
    { prefix = "<Leader>h", group = "hunk" },
    {
      "<Leader>hs",
      function()
        gitsigns.stage_hunk()
      end,
      "Stage hunk",
      mode = { "n", "v" },
    },
    {
      "<Leader>hr",
      function()
        gitsigns.reset_hunk()
      end,
      "Reset (unstage) hunk",
      mode = { "n", "v" },
    },
    { "<Leader>hS", gitsigns.stage_buffer, "Stage buffer" },
    { "<Leader>hR", gitsigns.reset_buffer, "Reset buffer" },
    { "<Leader>hp", gitsigns.preview_hunk, "Preview hunk" },
    {
      "<Leader>hb",
      function()
        gitsigns.blame_line { full = true }
      end,
      "Blame line",
    },
    {
      "<Leader>hB",
      gitsigns.blame,
      "Blame file",
    },
    {
      "<Leader>hd",
      gitsigns.diffthis,
      "Diff",
    },
    {
      "<Leader>hq",
      gitsigns.setqflist,
      "File hunks -> qflist",
    },
    {
      "<Leader>hQ",
      function()
        gitsigns.setqflist("all")
      end,
      "All file hunks -> qflist",
    },
  }
end

return M
