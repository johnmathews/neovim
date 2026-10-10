-- Smoke gate, part 1: loaded with --cmd, so it runs BEFORE init.lua.
-- It records every vim.notify call (whoever replaces vim.notify later) and every
-- vim.deprecate call with the first caller outside the Nvim runtime. run.lua
-- reads the records from _G.__smoke after startup.

local S = {
  notifies = {}, -- { msg, level, case, deprecation }
  deprecations = {}, -- { name, alt, version, plugin, where, case }
  case = "startup", -- set by run.lua while a case runs, for attribution
  preinit = debug.getinfo(1, "S").source:sub(2),
}
_G.__smoke = S

local runtime = vim.fs.normalize(vim.env.VIMRUNTIME or "")

local function level_number(level)
  if type(level) == "number" then
    return level
  end
  if type(level) == "string" then
    return vim.log.levels[level:upper()] or vim.log.levels.INFO
  end
  return vim.log.levels.INFO
end

-- vim.notify is a plain field of the vim table. nvim-notify and noice assign their
-- own function to it after startup, which would bypass a simple wrapper. Instead,
-- remove the field and serve it through the metatable: every read returns the
-- recorder, and every assignment is pushed onto a chain the recorder calls into.
local chain = { rawget(vim, "notify") }
local depth = 0
local recorder

recorder = function(msg, level, opts)
  if depth == 0 then
    table.insert(S.notifies, {
      msg = tostring(msg),
      level = level_number(level),
      case = S.case,
      deprecation = S.in_deprecate == true,
    })
  end
  -- A replacement that saved the previous vim.notify (this recorder) and calls it
  -- as a fallback re-enters here one level deeper; serve it the previous function.
  local fn = chain[math.max(1, #chain - depth)]
  depth = depth + 1
  local ok, result = pcall(fn, msg, level, opts)
  depth = depth - 1
  if not ok then
    error(result, 0)
  end
  return result
end

rawset(vim, "notify", nil)
local mt = getmetatable(vim)
local old_index, old_newindex = mt.__index, mt.__newindex
mt.__index = function(t, k)
  if k == "notify" then
    return recorder
  end
  if type(old_index) == "function" then
    return old_index(t, k)
  elseif type(old_index) == "table" then
    return old_index[k]
  end
end
mt.__newindex = function(t, k, v)
  if k ~= "notify" then
    if old_newindex then
      return old_newindex(t, k, v)
    end
    return rawset(t, k, v)
  end
  if v == recorder then
    -- restoring a saved vim.notify: drop the most recent replacement
    if #chain > 1 then
      table.remove(chain)
    end
  else
    table.insert(chain, v)
  end
end

-- First stack frame that belongs to neither the Nvim runtime nor this harness.
local function origin()
  for level = 3, 60 do
    local info = debug.getinfo(level, "Sl")
    if not info then
      break
    end
    local src = info.source or ""
    -- "@vim/shared.lua" and "[string ...]" are runtime chunks compiled into Nvim
    if src:sub(1, 2) == "@/" then
      local path = vim.fs.normalize(src:sub(2))
      local in_runtime = runtime ~= "" and path:sub(1, #runtime) == runtime
      if not in_runtime and not path:find("/test/smoke/", 1, true) then
        return path .. ":" .. tostring(info.currentline)
      end
    end
  end
  return "?"
end

local orig_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
  table.insert(S.deprecations, {
    name = tostring(name),
    alt = alternative and tostring(alternative) or nil,
    version = version and tostring(version) or nil,
    plugin = plugin,
    where = origin(),
    case = S.case,
  })
  S.in_deprecate = true
  local ok, result = pcall(orig_deprecate, name, alternative, version, plugin, backtrace)
  S.in_deprecate = false
  if not ok then
    error(result, 0)
  end
  return result
end
