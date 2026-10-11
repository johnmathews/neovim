-- Fixture helper, run with `nvim --clean -l test/smoke/fixture.lua <command> ...`.
--
--   apply <fixture.lua> <config dir>   break the copied config the way the fixture says
--   info  <fixture.lua>                print "<expect id or ->\t<expect exit>\t<extra smoke args>"
--   check <report.json> <check id>     exit 0 if the report lists that check ID as a failure
--
-- A fixture file returns:
--   {
--     description = "what it simulates",
--     expect = "python:settings",   -- check ID that must fail (or nil with expect_exit)
--     expect_exit = 1,              -- smoke exit code, default 1
--     args = { "--only", "python" },  -- extra scripts/smoke arguments for the self-test
--     write = { ["path/in/config"] = "content" },   -- create or replace files
--     append = { ["path/in/config"] = "content" },  -- append to existing files
--   }

local command, fixture_path, config_dir = arg[1], arg[2], arg[3]

local function die(msg)
  io.stderr:write("fixture: " .. msg .. "\n")
  os.exit(2)
end

if not fixture_path then
  die("usage: fixture.lua apply <fixture> <config dir> | info <fixture> | check <report> <id>")
end

if command == "check" then
  local report_path, want_id = arg[2], arg[3]
  local f = io.open(report_path, "r")
  if not f then
    die("no report at " .. report_path)
  end
  local report = vim.json.decode(f:read("*a"))
  f:close()
  local ids = {}
  for _, failure in ipairs(report.failures or {}) do
    if failure.id == want_id then
      os.exit(0)
    end
    table.insert(ids, failure.id)
  end
  io.stderr:write("fixture: failures were {" .. table.concat(ids, ", ") .. "}\n")
  os.exit(1)
end
local ok, fixture = pcall(dofile, fixture_path)
if not ok or type(fixture) ~= "table" then
  die("cannot load " .. fixture_path .. ": " .. tostring(fixture))
end

if command == "info" then
  io.stdout:write(
    ("%s\t%d\t%s\n"):format(fixture.expect or "-", fixture.expect_exit or 1, table.concat(fixture.args or {}, " "))
  )
  os.exit(0)
end

if command ~= "apply" or not config_dir then
  die("unknown command " .. tostring(command))
end

local function write(rel, content, mode)
  local path = config_dir .. "/" .. rel
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  if mode == "a" and vim.fn.filereadable(path) == 0 then
    die("append target does not exist: " .. rel)
  end
  local f = assert(io.open(path, mode))
  f:write(mode == "a" and ("\n" .. content .. "\n") or content)
  f:close()
end

for rel, content in pairs(fixture.write or {}) do
  write(rel, content, "w")
end
for rel, content in pairs(fixture.append or {}) do
  write(rel, content, "a")
end
os.exit(0)
