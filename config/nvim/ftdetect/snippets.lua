-- Having trouble with `vim.filetype.add`: https://github.com/neovim/neovim/issues/23522
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.snippets",
  command = "setfiletype snippets",
})
