--- Commands for LLM context.

local M = {}

--- Format a range for the given path and lines.
---
--- Returns (e.g.) "`puppy.lua` at lines 112-113".
---
---@param path string
---@param line1 number?
---@param line2 number?
function M.format_range_context(path, line1, line2)
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
