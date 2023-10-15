---@diagnostic disable: undefined-global

local function output_checked(command, opts)
  if type(command) ~= "table" or #command < 1 then
    error("Commands must be a table of arguments")
  end

  local prog = command[1]

  local stdout
  local stderr
  opts = vim.tbl_extend("force", opts or {}, {
    on_stdout = function(_channel, lines, _stream_name)
      if #lines > 0 then
        stdout = vim.trim(vim.fn.join(lines, "\n"))
      end
    end,
    on_stderr = function(_channel, lines, _stream_name)
      if #lines > 0 then
        stderr = vim.trim(vim.fn.join(lines, "\n"))
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_job_id, exit_code, _event)
      if exit_code ~= 0 then
        local message = prog .. " failed with code " .. exit_code
        if stdout ~= nil then
          message = message .. "\nStdout: " .. stdout
        end
        if stderr ~= nil then
          message = message .. "\nStderr: " .. stderr
        end
        error(message)
      end
    end,
  })

  local job_id = vim.fn.jobstart(command, opts)

  if job_id == 0 then
    error("Invalid job arguments for " .. program)
  elseif job_id == -1 then
    error(program .. " is not executable")
  end

  vim.fn.jobwait { job_id }

  return stdout
end

---@param name string
local function sanitize_filename(name)
  local sanitized, _substitution_count = name:gsub("[^a-zA-Z0-9%.-]", "_")
  return sanitized
end

local function is_valid_github_username(user)
  return (
    user
    and #user < 40
    and user:find("%-%-") == nil
    and user:find("^%-") == nil
    and user:find("%-$") == nil
    and user:find("^[a-zA-Z0-9-]+$") ~= nil
  )
end

local function is_valid_github_repo(name)
  return name:match("[a-zA-Z0-9.-]+") ~= nil
end

local function is_reasonable_version(version)
  return version ~= nil and #version > 0
end

local function nix_prefetch_url(opts)
  local hashType = opts.hashType or "sha256"

  local args = { "nix-prefetch-url", "--type", hashType }
  if opts.extra_args ~= nil then
    vim.list_extend(args, opts.extra_args)
  end
  if opts.url == nil then
    error("`url` is required")
  end
  table.insert(args, opts.url)

  local hash = output_checked(args)
  local base64_hash = "sha256-"
    .. output_checked {
      "nix-hash",
      "--to-base64",
      "--type",
      hashType,
      hash,
    }

  return base64_hash
end

local function github_nix_hash(opts)
  local owner = opts.owner
  local repo = opts.repo
  local rev = opts.rev
  if
    is_valid_github_username(owner)
    and is_valid_github_repo(repo)
    and is_reasonable_version(rev)
  then
    return nix_prefetch_url {
      url = "https://github.com/"
        .. owner
        .. "/"
        .. repo
        .. "/archive/"
        .. rev
        .. ".tar.gz",
      extra_args = {
        "--unpack",
        -- If the version number isn't a valid nix path name, the download might error.
        "--name",
        sanitize_filename(owner .. "-" .. repo .. "-" .. rev),
      },
    }
  else
    return ""
  end
end

s({ trig = "github", desc = "fetchFromGitHub" }, {
  t { "fetchFromGitHub {", '\towner = "' },
  i(1),
  t { '";', '\trepo = "' },
  i(2),
  t { '";', '\trev = "' },
  i(3),
  t { '";', '\thash = "' },
  f(function(args)
    -- Each element of `args` is a list of lines, so we need to index these.
    local owner, repo, rev = unpack(args)
    return github_nix_hash {
      owner = owner[1],
      repo = repo[1],
      rev = rev[1],
    }
  end, { 1, 2, 3 }),
  t { '";', "}" },
})
