-- Version guard check, run by `scripts/smoke --expect-guard` with a Neovim older than the
-- config supports (0.11.x): init.lua must stop with exactly one ERROR, before lazy.nvim
-- loads, so the old Neovim never installs plugins or rewrites lazy-lock.json.
-- Prints one line per problem and exits 1, or prints the PASS line and exits 0.

local want = "config requires Neovim 0.12.6, see docs/UPGRADE-0.12.md"
local problems = {}

local messages = vim.split(vim.fn.execute("messages"), "\n", { trimempty = true })
if #messages ~= 1 or messages[1] ~= want then
  table.insert(problems, ("messages are %s, want exactly { %q }"):format(vim.inspect(messages), want))
end
if package.loaded["lazy"] then
  table.insert(problems, "lazy.nvim was loaded")
end

local function read(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end
local orig = read((vim.env.SMOKE_REPO or "") .. "/lazy-lock.json")
local copy = read(vim.fn.stdpath("config") .. "/lazy-lock.json")
if not orig or orig ~= copy then
  table.insert(problems, "lazy-lock.json in the copied config differs from the repository's")
end

local version = tostring(vim.version())
if #problems == 0 then
  io.stdout:write(("SMOKE GUARD PASS: Neovim %s stopped at the version guard: %s\n"):format(version, want))
  vim.cmd("qall!")
else
  for _, p in ipairs(problems) do
    io.stdout:write("FAIL  [guard] " .. p .. "\n")
  end
  io.stdout:write(("SMOKE GUARD FAIL: Neovim %s, %d problems\n"):format(version, #problems))
  vim.cmd("cquit 1")
end
