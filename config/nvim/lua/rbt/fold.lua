--- @type LazyPluginSpec
local M = {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async", "batteries.nvim" },
}

function M.config()
  vim.opt.foldcolumn = "0"
  vim.opt.foldlevel = 99
  vim.opt.foldlevelstart = 99
  vim.opt.foldenable = true

  local more_msg_highlight = vim.api.nvim_get_hl_id_by_name("MoreMsg")
  local non_text_highlight = vim.api.nvim_get_hl_id_by_name("NonText")

  ---@diagnostic disable-next-line: missing-fields
  require("ufo").setup {
    provider_selector = function(_bufnr, _filetype, _buftype)
      return { "treesitter", "indent" }
    end,
    preview = {
      win_config = {
        winblend = 0,
      },
    },
    fold_virt_text_handler = function(
      -- The start_line's text.
      virtual_text_chunks,
      -- Start and end lines of fold.
      start_line,
      end_line,
      -- Total text width.
      text_width,
      -- fun(str: string, width: number): string Trunctation function.
      truncate,
      -- Context for the fold.
      ctx
    )
      local line_delta = (" 󰁂 %d"):format(end_line - start_line)
      local remaining_width = text_width
        - vim.fn.strdisplaywidth(ctx.text)
        - vim.fn.strdisplaywidth(line_delta)
      table.insert(virtual_text_chunks, { line_delta, more_msg_highlight })
      local line = start_line
      while remaining_width > 0 and line < end_line do
        line = line + 1
        local line_text =
          vim.api.nvim_buf_get_lines(ctx.bufnr, line, line + 1, true)[1]
        line_text = " " .. vim.trim(line_text)
        local line_text_width = vim.fn.strdisplaywidth(line_text)
        if line_text_width <= remaining_width - 2 then
          remaining_width = remaining_width - line_text_width
        else
          line_text = truncate(line_text, remaining_width - 2) .. "…"
          remaining_width = remaining_width - vim.fn.strdisplaywidth(line_text)
        end
        table.insert(virtual_text_chunks, { line_text, non_text_highlight })
      end
      return virtual_text_chunks
    end,
  }

  require("batteries").map {
    { "zR", require("ufo").openAllFolds, "Open all folds" },
    { "zM", require("ufo").closeAllFolds, "Close all folds" },
    {
      "K",
      function()
        local window_id = require("ufo").peekFoldedLinesUnderCursor()
        if not window_id then
          vim.lsp.buf.hover()
        end
      end,
      "Hover fold or documentation",
      mode = { "n", "v" },
    },
  }
end

return M
