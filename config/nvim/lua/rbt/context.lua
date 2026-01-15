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

--- @class FormatRangeContextOpts
--- @field normalize_path? boolean

--- Format a range for the given path and lines.
---
--- Returns (e.g.) `@puppy.lua:112-113`
---
---@param path string
---@param line1 number?
---@param line2 number?
---@param options FormatRangeContextOpts?
--- @return string
function M.format_range_context(path, line1, line2, options)
  options = vim.tbl_extend("keep", options or {}, {
    normalize_path = true,
  })

  if options.normalize_path then
    path = M.normalize_path(path)
  end

  local ret = "@" .. path
  if line1 ~= nil and line2 ~= nil then
    ret = ret .. "#L"
    if line1 == line2 then
      ret = ret .. line1
    else
      ret = ret .. line1 .. "-" .. line2
    end
  end
  return ret
end

--- @class FormatRangeContextArgs
--- @field path string
--- @field line1 number?
--- @field line2 number?

--- @param args vim.api.keyset.create_user_command.command_args
--- @return FormatRangeContextArgs
local function get_format_range_context_args(args)
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

  return {
    path = path,
    line1 = line1,
    line2 = line2,
  }
end

--- Copy a context reference for the current file and range to the system
--- clipboard.
---
--- Copies (e.g.) `@puppy.lua:112-113`
---
---@param args vim.api.keyset.create_user_command.command_args
---@param opts FormatRangeContextOpts?
function M.copy_range_context_inner(args, opts)
  local context_args = get_format_range_context_args(args)

  local ret = M.format_range_context(
    context_args.path,
    context_args.line1,
    context_args.line2,
    opts
  )
  vim.notify(ret)
  vim.fn.setreg("+", ret)
end

--- Copy a context reference for the current file and range to the system
--- clipboard.
---
--- Copies (e.g.) `@puppy.lua:112-113`
---
---@param args vim.api.keyset.create_user_command.command_args
function M.copy_range_context(args)
  M.copy_range_context_inner(args, { normalize_path = true })
end

--- Like `copy_range_context` but copies an absolute path.
---
---@param args vim.api.keyset.create_user_command.command_args
function M.copy_range_context_absolute(args)
  M.copy_range_context_inner(args, { normalize_path = false })
end

return M
