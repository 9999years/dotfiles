local M = {}

--- Run a command in a new `:split`.
---
--- @param callback fun()
--- @return fun()
function M.split_then(callback)
  return function()
    vim.cmd("split")
    callback()
  end
end

--- Run a command in a new `:vsplit`.
---
--- @param callback fun()
--- @return fun()
function M.vsplit_then(callback)
  return function()
    vim.cmd("vsplit")
    callback()
  end
end

return M
