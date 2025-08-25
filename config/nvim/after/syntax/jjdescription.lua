-- Parse the file from the start to avoid syntax highlighting breaking mid-way
-- through.
--
-- Unless it's >5000 lines long, in which case don't break the bank.
vim.cmd.syntax("sync", "minlines=5000")
