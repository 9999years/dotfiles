--- @require "lazy"
--- @type LazyPluginSpec
local M = {
  "olimorris/persisted.nvim",
}

function M.init()
  -- ??? The examples reference this variable, but as far as I can tell no
  -- public plugin has ever set it?
  -- See: https://github.com/olimorris/persisted.nvim/issues/180
  if vim.g.started_with_stdin == nil then
    vim.g.started_with_stdin = false
  end

  vim.api.nvim_create_autocmd("StdinReadPre", {
    callback = function()
      vim.g.started_with_stdin = true
    end,
  })
end

--- This is our session-loading logic, which we use instead of the default
--- `require("persisted").autoload()` implementation.
---
--- This creates a new session if there's no session for the current
--- directory, even if files were specified as command-line arguments.
local function maybe_load_session()
  local persisted = require("persisted")
  if not persisted.allowed_dir() then
    return
  end

  if vim.g.started_with_stdin then
    return
  end

  local argv = vim.fn.argv()
  --- @cast argv -string

  local maybe_session = persisted.current()
  if vim.fn.filereadable(maybe_session) == 0 then
    -- No session for this directory; start one.
    persisted.start()
  elseif #argv == 0 then
    -- There's already a session for this directory; load it if there's no CLI
    -- arguments.
    persisted.load {
      session = maybe_session,
    }
    persisted.start()
  end
end

function M.config()
  vim.api.nvim_create_autocmd("VimEnter", {
    nested = true,
    callback = maybe_load_session,
  })

  require("persisted").setup {
    autostart = false,
  }
end

return M
