--- Commands for LLM context.

local M = {}

--- Normalize a path to be relative to the current working directory.
---
---@param path string
---@return string
function M.normalize_path(path)
  -- TODO: Should we look for like `vim.fs.root(path, ".git")` or something?
  local relativized = vim.fs.relpath(vim.fn.getcwd(), path)
  if relativized ~= nil then
    -- `cwd` is not an ancestor of `path`.
    return relativized
  else
    return path
  end
end

--- Format a range for the given path and lines.
---
--- Returns (e.g.) "`puppy.lua` at lines 112-113".
---
---@param path string
---@param line1 number?
---@param line2 number?
--- @return string
function M.format_range_context(path, line1, line2)
  path = M.normalize_path(path)
  local ret = "`" .. path .. "`"
  if line1 ~= nil and line2 ~= nil then
    if line1 == line2 then
      ret = ret .. " at line " .. line1
    else
      ret = ret .. " at lines " .. line1 .. "-" .. line2
    end
  end
  return ret
end

--- Copy a range for the current file and options.
---
--- Copies (e.g.) "`puppy.lua` at lines 112-113".
---
---@param args vim.api.keyset.create_user_command.command_args
function M.copy_range_context(args)
  local line1 = nil
  local line2 = nil
  if args.range > 0 then
    line1 = args.line1
    line2 = args.line2
  end

  local path = nil
  if args.args == nil or args.args == "" then
    path = vim.fn.expand("%")
  else
    path = args.args
  end

  local ret = M.format_range_context(path, line1, line2)
  vim.notify(ret)
  vim.fn.setreg("+", ret)
end

return M
