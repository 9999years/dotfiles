--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  -- Upstream: https://github.com/lewis6991/gitsigns.nvim
  --
  -- `actions.blame`: add `BlameOpts` parameter
  --
  -- See: https://github.com/lewis6991/gitsigns.nvim/pull/1399
  "9999years/gitsigns.nvim", -- Git gutter
  branch = "push-zykuprrtwxwt",
}

M.opts = {
  diff_opts = {
    ignore_whitespace = false,
  },
}

-- NB: This is lifted outside of the `on_attach` function so that we can share
-- the state between every buffer.
local diff_against_working_copy = true

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
    -- Keep committed work navigable without leaving the live buffer. All
    -- buffers toggle together; HEAD^ includes the last commit plus staged
    -- and unstaged edits. For merge commits, it means the first parent.
    {
      "<Leader>hc",
      function()
        diff_against_working_copy = not diff_against_working_copy
        if diff_against_working_copy then
          gitsigns.reset_base(true)
          vim.notify("gitsigns: working copy")
        else
          gitsigns.change_base("HEAD^", true)
          vim.notify("gitsigns: parent commit + working copy")
        end
      end,
      "Toggle last commit hunks",
    },
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
      function()
        gitsigns.blame {
          ignore_whitespace = true,
          extra_opts = {
            -- Look for moved or copied lines when blaming.
            "-M", -- Look within one file.
            "-C", -- Look at other files modified in the same commit.
            "-C", -- Look at other files present in the same commit.
            "-C", -- Look at other files in any commit.
          },
        }
      end,
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
