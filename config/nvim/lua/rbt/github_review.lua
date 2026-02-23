local M = {}

M.namespace = vim.api.nvim_create_namespace("github_review")
M.comments_by_path = {}
M.git_root = nil
M.augroup = vim.api.nvim_create_augroup("rbt.github_review", { clear = true })

vim.diagnostic.config(
  { virtual_text = true, signs = false, underline = false },
  M.namespace
)

function M.define_cmd()
  require("batteries").cmd {
    nargs = "?",
    "GitHubReview",
    function(opts)
      local pr_number = opts.fargs[1]
      if pr_number then
        M.fetch(pr_number)
      else
        M.clear()
      end
    end,
    "Show GitHub PR review comments as diagnostics",
  }
end

function M.clear()
  vim.diagnostic.reset(M.namespace)
  M.comments_by_path = {}
  vim.api.nvim_clear_autocmds { group = M.augroup }
end

local function format_comment(comment)
  local author = comment.user and comment.user.login or "unknown"
  local body = comment.body:gsub("\r", "")
  return "@" .. author .. ": " .. body
end

function M.apply_to_buffer(bufnr)
  if not M.git_root then
    return
  end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return
  end
  local relative_path = vim.fs.relpath(M.git_root, bufname)
  if not relative_path then
    return
  end
  local comments = M.comments_by_path[relative_path]
  if not comments then
    return
  end
  local diagnostics = {}
  for _, comment in ipairs(comments) do
    if comment.line then
      local diag = {
        lnum = (comment.start_line or comment.line) - 1,
        end_lnum = comment.start_line and (comment.line - 1) or nil,
        col = 0,
        severity = vim.diagnostic.severity.INFO,
        message = format_comment(comment),
        source = "gh-review",
      }
      table.insert(diagnostics, diag)
    end
  end
  vim.diagnostic.set(M.namespace, bufnr, diagnostics)
end

function M.apply_to_all_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.apply_to_buffer(bufnr)
    end
  end
end

-- stylua: ignore
local GRAPHQL_QUERY = [[
query($owner: String!, $repo: String!, $pr: Int!, $endCursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          isResolved
          comments(first: 100) {
            nodes { body path line startLine author { login } }
          }
        }
      }
    }
  }
}]]

--- Parse GraphQL response into a flat list of unresolved review comments.
local function parse_comments(stdout)
  local data = vim.json.decode(stdout, { luanil = { object = true, array = true } })
  local threads = data.data.repository.pullRequest.reviewThreads.nodes
  local comments = {}
  for _, thread in ipairs(threads) do
    if not thread.isResolved then
      for _, comment in ipairs(thread.comments.nodes) do
        table.insert(comments, {
          path = comment.path,
          line = comment.line,
          start_line = comment.startLine,
          body = comment.body,
          user = comment.author and { login = comment.author.login },
        })
      end
    end
  end
  return comments
end

--- Group comments by their file path.
local function group_by_path(comments)
  local by_path = {}
  for _, comment in ipairs(comments) do
    local path = comment.path
    if path then
      if not by_path[path] then
        by_path[path] = {}
      end
      table.insert(by_path[path], comment)
    end
  end
  return by_path
end

function M.fetch(pr_number)
  if not tonumber(pr_number) then
    vim.notify("PR number must be numeric", vim.log.levels.ERROR)
    return
  end

  M.clear()

  local git_root = vim.fs.root(0, ".git")
  if not git_root then
    vim.notify("not in a git repository", vim.log.levels.ERROR)
    return
  end
  M.git_root = git_root

  local repo_result = vim.system(
    { "gh", "repo", "view", "--json", "owner,name" },
    { cwd = git_root, text = true }
  ):wait()
  if repo_result.code ~= 0 then
    vim.notify("failed to get repo info: " .. (repo_result.stderr or ""), vim.log.levels.ERROR)
    return
  end
  local repo = vim.json.decode(repo_result.stdout)

  vim.system(
    {
      "gh", "api", "graphql", "--paginate",
      "-F", "owner=" .. repo.owner.login,
      "-F", "repo=" .. repo.name,
      "-F", "pr=" .. pr_number,
      "-f", "query=" .. GRAPHQL_QUERY,
    },
    { cwd = git_root, text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(
            "gh api failed: " .. (result.stderr or ""),
            vim.log.levels.ERROR
          )
          return
        end

        local ok, comments = pcall(parse_comments, result.stdout)
        if not ok then
          vim.notify(
            "failed to parse JSON: " .. tostring(comments),
            vim.log.levels.ERROR
          )
          return
        end

        M.comments_by_path = group_by_path(comments)
        M.apply_to_all_buffers()

        vim.api.nvim_create_autocmd("BufRead", {
          group = M.augroup,
          callback = function(args)
            M.apply_to_buffer(args.buf)
          end,
        })

        vim.notify(
          "Loaded " .. #comments .. " review comments for PR #" .. pr_number
        )
      end)
    end
  )
end

return M
