--- @require "lint"

---@type lint.parse
local function parser(_output, bufnr, _linter_cwd)
  local lines = vim.api.nvim_buf_get_lines(
    bufnr,
    -- 0-indexed start line.
    0,
    -- Until end.
    -1,
    -- Strict indexing.
    false
  )

  local diagnostics = {}

  for line_number, line in ipairs(lines) do
    local unix_timestamp = line:match('"lastModified": *(%d+),')
    if unix_timestamp ~= nil then
      local date_formatted = os.date("%Y-%m-%d", tonumber(unix_timestamp))

      -- There's no way, as far as I can tell, to both get the contents of a
      -- capture group and its indices.
      local col, end_col = line:find(
        unix_timestamp,
        -- Start index.
        1,
        -- Disable pattern syntax.
        true
      )

      if col == nil then
        col = 0
        end_col = line:len() - 1
      else
        col = col - 1
      end

      table.insert(diagnostics, {
        bufnr = bufnr,
        lnum = line_number - 1,
        col = col,
        end_col = end_col,
        severity = vim.diagnostic.severity.INFO,
        message = date_formatted,
        source = "timestamp",
      })
    end
  end

  return diagnostics
end

-- A linter for `nvim-lint` which formats `lastModified` timestamps as
-- human-readable ISO-8601 dates in `flake.lock` files. This is extremely
-- useful when resolving merge conflicts.
--
-- See: <https://github.com/mfussenegger/nvim-lint>
--
--- @type lint.Linter
return {
  name = "flake_lock_unix_timestamps",
  -- NOTE: Using `/bin/true` doesn't work here, I guess it needs to write
  -- _some_ output to actually complete?
  cmd = "echo",
  stdin = false,
  append_fname = false,
  args = {},
  stream = "stdout",
  ignore_exitcode = true,
  env = nil,
  parser = parser,
}
