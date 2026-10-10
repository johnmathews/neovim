-- Smoke gate, part 2: the engine. scripts/smoke runs it with `-c "luafile ..."`
-- after preinit.lua (`--cmd`). It waits for startup, opens one buffer per case in
-- cases.lua, asserts on runtime state, applies xfail.lua, writes the report, and
-- exits through `qall!` (pass) or `cquit N` (1 failed, 2 harness error, 3 timeout).

local S = _G.__smoke
local env = vim.env
local cfg = vim.fn.stdpath("config")
local smoke_dir = cfg .. "/test/smoke"
local version = vim.version()
local nvim_version = ("%d.%d.%d"):format(version.major, version.minor, version.patch)

local R = { failures = {}, warnings = {}, xfailed = {}, cases = {}, scopes = {} }

-- assertion helpers -----------------------------------------------------------

local function first_line(s)
  return (tostring(s):match("^[^\n]*") or ""):sub(1, 400)
end

local function fail(id, msg)
  msg = first_line(msg)
  for _, f in ipairs(R.failures) do
    if f.id == id and f.msg == msg then
      return
    end
  end
  table.insert(R.failures, { id = id, msg = msg })
end

local function warn(msg)
  if not vim.tbl_contains(R.warnings, msg) then
    table.insert(R.warnings, msg)
  end
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local s = f:read("*a")
  f:close()
  return s
end

local function write_file(path, s)
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

local function load_data(name)
  local ok, data = pcall(dofile, smoke_dir .. "/" .. name)
  if not ok then
    error("cannot load test/smoke/" .. name .. ": " .. tostring(data), 0)
  end
  return data
end

local function now()
  return vim.uv.now()
end

local function version_matches(spec)
  if spec == nil then
    return true
  end
  for _, prefix in ipairs(type(spec) == "table" and spec or { spec }) do
    if nvim_version == prefix or nvim_version:sub(1, #prefix + 1) == prefix .. "." then
      return true
    end
  end
  return false
end

-- message capture ---------------------------------------------------------------
-- Messages reach three places, and which one depends on the Nvim version and on
-- whether noice has attached: `:messages` (empty on 0.11 once noice attaches),
-- stderr (headless writes them there until noice attaches on 0.12), and noice's
-- own history. The gate reads all three and requires every line to be explained.

local function messages_text()
  local ok, res = pcall(vim.api.nvim_exec2, "messages", { output = true })
  return ok and res.output or ""
end

local function stderr_text()
  return env.SMOKE_STDERR and read_file(env.SMOKE_STDERR) or ""
end

local skip_kinds = { search_count = true, return_prompt = true }
local function noice_messages()
  local out = {}
  if not package.loaded["noice"] then
    return out
  end
  local ok, manager = pcall(require, "noice.message.manager")
  if not ok then
    return out
  end
  local got, list = pcall(manager.get, {}, { history = true })
  if not got then
    return out
  end
  for _, m in ipairs(list) do
    if m.event == "msg_show" and not skip_kinds[m.kind or ""] then
      local cok, text = pcall(m.content, m)
      if cok and text then
        table.insert(out, text)
      end
    end
  end
  return out
end

local function snapshot()
  return { messages = #messages_text(), stderr = #stderr_text(), noice = #noice_messages() }
end

-- Text that appeared in any source since the snapshot `from`.
local function new_text(from)
  local parts = {}
  local m = messages_text()
  -- :messages is a capped history; if it shrank, take all of it.
  table.insert(parts, #m >= from.messages and m:sub(from.messages + 1) or m)
  table.insert(parts, stderr_text():sub(from.stderr + 1))
  local nm = noice_messages()
  for i = from.noice + 1, #nm do
    table.insert(parts, nm[i])
  end
  return table.concat(parts, "\n")
end

local allow = {}

local function remove_plain(text, needle)
  if needle == "" then
    return text
  end
  local out, start = {}, 1
  while true do
    local i, j = text:find(needle, start, true)
    if not i then
      break
    end
    table.insert(out, text:sub(start, i - 1))
    start = j + 1
  end
  table.insert(out, text:sub(start))
  return table.concat(out, "\n")
end

local function allowed(line)
  for _, a in ipairs(allow) do
    if version_matches(a.nvim) and line:find(a.match, 1, true) then
      return true
    end
  end
  return false
end

-- Remove everything the gate can account for: recorded notifies (judged by
-- level elsewhere), Nvim deprecation notices (judged by origin elsewhere), and
-- allow.lua entries. Whatever is left is unexplained.
local function unexplained(text)
  local needles = {}
  for _, n in ipairs(S.notifies) do
    table.insert(needles, n.msg)
    for line in n.msg:gmatch("[^\n]+") do
      table.insert(needles, line)
    end
  end
  table.sort(needles, function(a, b)
    return #a > #b
  end)
  for _, needle in ipairs(needles) do
    text = remove_plain(text, needle)
  end
  -- only notices for deprecations the recorder saw, so every one is judged by origin
  for _, d in ipairs(S.deprecations) do
    text = remove_plain(text, d.name .. ' is deprecated. Run ":checkhealth vim.deprecated" for more information')
  end

  local blocks, current = {}, nil
  local pending_header = nil
  for raw in text:gmatch("[^\n]+") do
    local line = raw:gsub("%s+$", "")
    if line:match("^%s") or line == "stack traceback:" then
      -- traceback frames and indented continuation belong to the previous block
      if current then
        current.context = current.context + 1
      end
    elseif line ~= "" and not allowed(line) then
      if line:match(":$") and not pending_header then
        pending_header = line -- e.g. 'Error in FileType Autocommands for "*":'
      else
        local head = pending_header and (pending_header .. " " .. line) or line
        pending_header = nil
        current = { head = head:sub(1, 400), context = 0 }
        table.insert(blocks, current)
      end
    end
  end
  if pending_header then
    table.insert(blocks, { head = pending_header, context = 0 })
  end
  return blocks
end

local function check_messages(scope, from)
  for _, b in ipairs(unexplained(new_text(from))) do
    fail(scope .. ":messages", "unexplained message: " .. b.head)
  end
end

-- buffer probes -----------------------------------------------------------------

local function client_names(buf)
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    table.insert(names, c.name)
  end
  table.sort(names)
  return names
end

-- LSP namespaces are named like vim.lsp.<client>.<id>[.<identifier>]; nvim-lint
-- namespaces carry the linter name.
local function diag_key(d)
  local ns = vim.diagnostic.get_namespace(d.namespace)
  local name = ns and ns.name or "?"
  local client = name:match("^n?vim%.lsp%.([^.]+)%.%d+")
  return client and ("lsp:" .. client) or name
end

local function diag_summary(buf)
  local by = {}
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    local k = diag_key(d)
    by[k] = (by[k] or 0) + 1
  end
  return by
end

local function fmt_summary(by)
  local keys = vim.tbl_keys(by)
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    table.insert(parts, k .. "=" .. by[k])
  end
  return "{" .. table.concat(parts, ", ") .. "}"
end

local function map_info(lhs, mode)
  local m = vim.fn.maparg(lhs, mode, false, true)
  if type(m) ~= "table" or m.lhs == nil then
    return nil
  end
  return m
end

local function supports(buf, method)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if c:supports_method(method, buf) then
      return true
    end
  end
  return false
end

local function wait_for_clients(buf, want)
  vim.wait(20000, function()
    local have = client_names(buf)
    for _, name in ipairs(want) do
      if not vim.tbl_contains(have, name) then
        return false
      end
    end
    return true
  end, 200)
end

-- Wait until diagnostics stop changing. Expected keys that are still missing keep
-- the wait going until a cap, so slow linters get time to report.
local function wait_for_diagnostics(buf, expected)
  local start, last, since = now(), nil, now()
  local settle = tonumber(env.SMOKE_SETTLE or "2500")
  vim.wait(45000, function()
    local sig = fmt_summary(diag_summary(buf))
    if sig ~= last then
      last, since = sig, now()
    end
    if now() - since < settle then
      return false
    end
    local by = diag_summary(buf)
    for key, want in pairs(expected or {}) do
      if want ~= false and want ~= 0 and (by[key] or 0) == 0 and now() - start < 30000 then
        return false
      end
    end
    return true
  end, 250)
end

local function lsp_request(buf, method, params)
  local results = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if c:supports_method(method, buf) then
      local resp = c:request_sync(method, params, 10000, buf)
      if resp and resp.result ~= nil and resp.result ~= vim.NIL then
        table.insert(results, { client = c.name, result = resp.result })
      end
    end
  end
  return results
end

local function non_empty(result)
  if type(result) ~= "table" then
    return result ~= nil and result ~= vim.NIL
  end
  return next(result) ~= nil
end

local function location_lines(result)
  local lines = {}
  local list = (result.uri or result.targetUri) and { result } or result
  for _, loc in ipairs(list) do
    local range = loc.targetSelectionRange or loc.targetRange or loc.range
    if range then
      table.insert(lines, range.start.line + 1)
    end
  end
  return lines
end

local function run_requests(c, buf)
  local uri = vim.uri_from_bufnr(buf)
  for _, rq in ipairs(c.requests or {}) do
    local params = {
      textDocument = { uri = uri },
      position = { line = rq.line - 1, character = rq.col },
    }
    if rq.method == "textDocument/codeAction" then
      local diags = {}
      for _, d in ipairs(vim.diagnostic.get(buf, { lnum = rq.line - 1 })) do
        local lsp_diag = vim.tbl_get(d, "user_data", "lsp")
        if lsp_diag then
          table.insert(diags, lsp_diag)
        end
      end
      params = {
        textDocument = { uri = uri },
        range = { start = params.position, ["end"] = { line = rq.line - 1, character = rq.col + 1 } },
        context = { diagnostics = diags },
      }
    end
    local where = ("%s at %d:%d"):format(rq.method, rq.line, rq.col)
    local good, wrong = false, nil
    for _, r in ipairs(lsp_request(buf, rq.method, params)) do
      if non_empty(r.result) then
        local lines = rq.expect_line and location_lines(r.result) or nil
        if not lines or vim.tbl_contains(lines, rq.expect_line) then
          good = true
        else
          wrong = ("%s from %s points at lines {%s}, want %d"):format(
            where,
            r.client,
            table.concat(lines, ","),
            rq.expect_line
          )
        end
      end
    end
    if not good then
      fail(c.name .. ":requests", wrong or (where .. " returned nothing from any client"))
    end
  end
end

local function check_settings(c, buf)
  for client_name, settings in pairs(c.settings or {}) do
    local client = vim.lsp.get_clients({ bufnr = buf, name = client_name })[1]
    if client then
      for path, want in pairs(settings) do
        local got = vim.tbl_get(client.config.settings or {}, unpack(vim.split(path, ".", { plain = true })))
        if not vim.deep_equal(got, want) then
          fail(
            c.name .. ":settings",
            ("%s setting %s=%s, want %s"):format(client_name, path, vim.inspect(got), vim.inspect(want))
          )
        end
      end
    end
  end
end

local function check_diagnostics(c, buf, by)
  for key, want in pairs(c.diags or {}) do
    local got = by[key] or 0
    local ok
    if want == true then
      ok = got > 0
    elseif want == false then
      ok = got == 0
    else
      ok = got == want
    end
    if not ok then
      local want_s = want == true and ">0" or (want == false and "0" or tostring(want))
      fail(c.name .. ":diags", ("diagnostics %s=%d, want %s (all: %s)"):format(key, got, want_s, fmt_summary(by)))
    end
  end
  -- The same finding reported by two tools means two owners for one job.
  local seen = {}
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    local k = ("%d:%d:%s"):format(d.lnum + 1, d.col, tostring(d.code or d.message))
    seen[k] = seen[k] or {}
    seen[k][diag_key(d)] = true
  end
  for k, owners in pairs(seen) do
    if vim.tbl_count(owners) > 1 then
      local names = vim.tbl_keys(owners)
      table.sort(names)
      fail(c.name .. ":duplicates", ("same diagnostic %s from %s"):format(k, table.concat(names, " and ")))
    end
  end
end

-- Paths of every leaf in `want` that `have` lacks or holds a different value for.
local function missing_leaves(want, have, prefix, out)
  for k, v in pairs(want) do
    local path = prefix and (prefix .. "." .. tostring(k)) or tostring(k)
    local h = nil -- not `have[k] or nil`: that would turn a false leaf into a missing one
    if type(have) == "table" then
      h = have[k]
    end
    if type(v) == "table" and not vim.islist(v) then
      missing_leaves(v, h, path, out)
    elseif not vim.deep_equal(v, h) then
      table.insert(out, path)
    end
  end
  return out
end

local function check_lsp_buffer_setup(c, buf)
  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then
    return
  end
  local okc, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  local cmp_caps = okc and cmp_lsp.default_capabilities({}) or nil
  for _, client in ipairs(clients) do
    if not cmp_caps then
      fail(c.name .. ":capabilities", "cmp_nvim_lsp cannot be loaded")
      break
    end
    local missing = missing_leaves(cmp_caps, client.capabilities or {}, nil, {})
    if #missing > 0 then
      table.sort(missing)
      fail(
        c.name .. ":capabilities",
        ("%s did not receive the cmp-nvim-lsp completion capabilities (missing %s)"):format(
          client.name,
          table.concat(vim.list_slice(missing, 1, 3), ", ")
        )
      )
    end
  end
  if supports(buf, "textDocument/inlayHint") then
    local m = map_info("<leader>li", "n")
    if not (m and m.buffer == 1) then
      fail(c.name .. ":keymaps", "<leader>li (inlay hints) is not buffer-mapped")
    end
  end
  if supports(buf, "textDocument/documentSymbol") and vim.b[buf].navic_client_id == nil then
    fail(c.name .. ":navic", "nvim-navic is not attached")
  end
end

local function check_treesitter(c, buf)
  vim.cmd("redraw!")
  local hl = vim.treesitter.highlighter.active[buf]
  local lang = hl and hl.tree and hl.tree:lang() or nil
  if c.lang then
    if not hl then
      fail(c.name .. ":treesitter", ("treesitter highlighter not active (want parser %s)"):format(c.lang))
    elseif lang ~= c.lang then
      fail(c.name .. ":treesitter", ("treesitter parser %s, want %s"):format(tostring(lang), c.lang))
    end
  end
  if c.textobjects then
    for _, mm in ipairs({ { "af", "o" }, { "if", "o" }, { "af", "x" }, { "if", "x" } }) do
      if not map_info(mm[1], mm[2]) then
        fail(c.name .. ":textobjects", ("textobject %s is not mapped in mode %s"):format(mm[1], mm[2]))
      end
    end
  end
  if c.folds then
    -- folds are computed from the parse tree, which may still be parsing on a busy machine
    local folded = 0
    vim.wait(5000, function()
      vim.cmd("normal! zx")
      folded = 0
      for l = 1, vim.api.nvim_buf_line_count(buf) do
        if vim.fn.foldlevel(l) > 0 then
          folded = folded + 1
        end
      end
      return folded > 0
    end, 250)
    if folded == 0 then
      fail(
        c.name .. ":folds",
        ("no folds computed (foldmethod=%s foldexpr=%s)"):format(vim.wo.foldmethod, vim.wo.foldexpr)
      )
    end
  end
  return lang
end

-- helpers handed to a case's own check(buf, t) function
local T = {
  fail = fail,
  map_info = map_info,
  diag_summary = diag_summary,
  -- mark a scope as run, for a check that only runs on some machines: xfail entries
  -- for that scope are judged stale only when it ran
  scope = function(name)
    R.scopes[name] = true
  end,
}

local function run_case(c)
  S.case = c.name
  R.scopes[c.name] = true
  local from = snapshot()
  local path = cfg .. "/" .. c.file
  local ok, err = pcall(vim.cmd, "silent edit " .. vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  if not ok then
    -- an autocmd error aborts :edit after the buffer loaded; keep checking it then
    fail(c.name .. ":open", "error while opening " .. c.file .. ": " .. first_line(err))
    if vim.fn.resolve(vim.api.nvim_buf_get_name(buf)) ~= vim.fn.resolve(path) then
      return
    end
  end
  wait_for_clients(buf, c.clients or {})
  wait_for_diagnostics(buf, c.diags)

  local have = client_names(buf)
  local want = vim.deepcopy(c.clients or {})
  table.sort(want)
  if table.concat(have, ",") ~= table.concat(want, ",") then
    fail(
      c.name .. ":clients",
      ("LSP clients {%s}, want exactly {%s}"):format(table.concat(have, ","), table.concat(want, ","))
    )
  end
  check_settings(c, buf)
  local by = diag_summary(buf)
  check_diagnostics(c, buf, by)
  check_lsp_buffer_setup(c, buf)
  local lang = check_treesitter(c, buf)
  run_requests(c, buf)
  if c.check then
    T.case = c.name
    local cok, cerr = pcall(c.check, buf, T)
    if not cok then
      fail(c.name .. ":check", "check raised: " .. first_line(cerr))
    end
  end
  check_messages(c.name, from)
  R.cases[c.name] = { clients = have, lang = lang, diags = by, filetype = vim.bo[buf].filetype }
end

-- once-per-run checks -----------------------------------------------------------

local function check_init()
  local init = read_file(cfg .. "/init.lua") or ""
  for mod in init:gmatch('\nrequire%("([^"]+)"%)') do
    if package.loaded[mod] == nil then
      fail("startup:modules", ("module %s never loaded: init.lua stopped before it"):format(mod))
    end
  end
end

-- The enabled LSP configs must be exactly cases.enabled_servers, so the set that can
-- start is the same on every machine (F13). Nvim 0.11 and 0.12 keep it in
-- vim.lsp._enabled_configs; there is no public listing API.
local function check_enabled(want)
  if not want then
    return
  end
  local have = vim.tbl_keys(vim.lsp._enabled_configs or {})
  table.sort(have)
  local sorted = vim.deepcopy(want)
  table.sort(sorted)
  if table.concat(have, ",") ~= table.concat(sorted, ",") then
    fail(
      "startup:enabled",
      ("enabled LSP configs {%s}, want exactly {%s}"):format(table.concat(have, ","), table.concat(sorted, ","))
    )
  end
end

local function check_tools()
  local okc, conform = pcall(require, "conform")
  if okc then
    for ft, list in pairs(conform.formatters_by_ft or {}) do
      if type(list) == "table" then
        for _, name in ipairs(list) do
          if type(name) == "string" then
            local info = conform.get_formatter_info(name, 0)
            if not info.available then
              fail("tools:formatters", ("conform formatter %s (%s): %s"):format(name, ft, tostring(info.available_msg)))
            end
          end
        end
      end
    end
  else
    fail("tools:formatters", "conform.nvim did not load")
  end
  local okl, lint = pcall(require, "lint")
  if okl then
    for ft, names in pairs(lint.linters_by_ft or {}) do
      for _, name in ipairs(names) do
        local linter = lint.linters[name]
        if type(linter) == "function" then
          local lok, l = pcall(linter)
          linter = lok and l or nil
        end
        if type(linter) ~= "table" then
          fail("tools:linters", ("nvim-lint linter %s (%s) is not defined"):format(name, ft))
        else
          local cmd = linter.cmd
          if type(cmd) == "function" then
            local cok, value = pcall(cmd)
            cmd = cok and value or nil
          end
          if type(cmd) ~= "string" or vim.fn.executable(cmd) ~= 1 then
            fail("tools:linters", ("nvim-lint linter %s (%s): %s is not executable"):format(name, ft, tostring(cmd)))
          end
        end
      end
    end
  else
    fail("tools:linters", "nvim-lint did not load")
  end
end

-- Deprecated or private APIs the config's own files must not use (F15). A text
-- scan, so it also covers code paths no case exercises. Lua patterns.
local deprecated_apis = {
  { api = "vim.loop", pattern = "vim%.loop", use = "vim.uv" },
  { api = "vim.lsp.set_log_level", pattern = "vim%.lsp%.set_log_level", use = "vim.lsp.log.set_level" },
  { api = "nvim_out_write", pattern = "nvim_out_write", use = "vim.api.nvim_echo" },
  { api = "_make_floating_popup_size", pattern = "_make_floating_popup_size", use = "a size computed in the config" },
  {
    api = "open_floating_preview override",
    pattern = "function%s+vim%.lsp%.util%.open_floating_preview",
    use = "the winborder option",
  },
  { api = 'require("lspconfig")', pattern = "require[%s%(,]*[\"']lspconfig[\"']", use = "vim.lsp.config" },
  { api = "lspconfig.util", pattern = "lspconfig%.util", use = "vim.fs.root and root_markers" },
  { api = "find_git_ancestor", pattern = "find_git_ancestor", use = "vim.fs.root" },
  { api = "vim.lsp.buf_get_clients", pattern = "buf_get_clients", use = "vim.lsp.get_clients" },
  { api = "vim.lsp.get_active_clients", pattern = "get_active_clients", use = "vim.lsp.get_clients" },
  { api = "conform lsp_fallback", pattern = "lsp_fallback", use = 'lsp_format = "fallback"' },
  { api = "vim.tbl_islist", pattern = "tbl_islist", use = "vim.islist" },
  { api = "vim.tbl_flatten", pattern = "tbl_flatten", use = "vim.iter(t):flatten():totable()" },
}

local function check_deprecated_scan()
  local files = { "init.lua" }
  for _, dir in ipairs({ "lua", "after", "ftplugin" }) do
    if vim.fn.isdirectory(cfg .. "/" .. dir) == 1 then
      for name, kind in vim.fs.dir(cfg .. "/" .. dir, { depth = 20 }) do
        if kind == "file" and (name:match("%.lua$") or name:match("%.vim$")) then
          table.insert(files, dir .. "/" .. name)
        end
      end
    end
  end
  table.sort(files)
  for _, rel in ipairs(files) do
    local lnum = 0
    for line in ((read_file(cfg .. "/" .. rel) or "") .. "\n"):gmatch("([^\n]*)\n") do
      lnum = lnum + 1
      for _, d in ipairs(deprecated_apis) do
        if line:find(d.pattern) then
          fail("scan:deprecated", ("%s: %s (use %s) at line %d"):format(rel, d.api, d.use, lnum))
        end
      end
    end
  end
end

local function check_lockfile()
  local orig = read_file((env.SMOKE_REPO or "") .. "/lazy-lock.json")
  local copy = read_file(cfg .. "/lazy-lock.json")
  if not orig or not copy or orig == copy then
    return
  end
  local okd, a = pcall(vim.json.decode, orig)
  local oke, b = pcall(vim.json.decode, copy)
  local changed = {}
  if okd and oke then
    for name, entry in pairs(b) do
      if not vim.deep_equal(a[name], entry) then
        table.insert(changed, name)
      end
    end
    for name in pairs(a) do
      if b[name] == nil then
        table.insert(changed, name .. " (removed)")
      end
    end
    table.sort(changed)
  end
  fail(
    "startup:lockfile",
    ("lazy-lock.json was rewritten during the run: %d entries changed (%s) [F8]"):format(
      #changed,
      table.concat(vim.list_slice(changed, 1, 5), ", ")
    )
  )
end

local function check_deprecations()
  local config_root = vim.fn.resolve(cfg)
  local lazy_root = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy")
  local seen = {}
  for _, d in ipairs(S.deprecations) do
    local key = d.name .. "@" .. d.where
    if not seen[key] then
      seen[key] = true
      local where = vim.fn.resolve((d.where:gsub(":%d+$", ""))) .. (d.where:match(":%d+$") or "")
      if where:sub(1, #config_root + 1) == config_root .. "/" then
        fail(
          d.case .. ":deprecated",
          ("%s (use %s) called from config %s"):format(d.name, tostring(d.alt), where:sub(#config_root + 2))
        )
      elseif where:sub(1, #lazy_root + 1) == lazy_root .. "/" then
        local msg = ("%s called from plugin %s"):format(d.name, where:sub(#lazy_root + 2))
        if env.SMOKE_STRICT == "1" then
          fail(d.case .. ":deprecated-plugin", msg)
        else
          warn("deprecated " .. msg)
        end
      else
        warn(("deprecated %s called from %s"):format(d.name, where))
      end
    end
  end
end

local function check_notifies()
  for _, n in ipairs(S.notifies) do
    if n.level >= vim.log.levels.WARN and not n.deprecation and not allowed(n.msg) then
      local label = n.level >= vim.log.levels.ERROR and "ERROR" or "WARN"
      fail(n.case .. ":notify", ("%s notify: %s"):format(label, first_line(n.msg)))
    end
  end
end

-- xfail and report ----------------------------------------------------------------

-- An entry matches a failure with the same check ID (or "*:<check>" for any scope)
-- whose message contains `match`. With --no-xfail the entries only label failures.
local function xfail_matches(x, f)
  if not version_matches(x.nvim) or not f.msg:find(x.match, 1, true) then
    return false
  end
  local scope, check = x.id:match("^([^:]+):(.+)$")
  return x.id == f.id or (scope == "*" and f.id:match(":(.+)$") == check)
end

local function apply_xfail(xfail)
  local remaining = {}
  local used, needed = {}, {}
  for _, f in ipairs(R.failures) do
    local hits = {}
    for i, x in ipairs(xfail) do
      if xfail_matches(x, f) then
        table.insert(hits, i)
        used[i] = true
      end
    end
    if #hits == 1 then
      needed[hits[1]] = true
    end
    if #hits > 0 then
      f.finding = xfail[hits[1]].finding
      table.insert(R.xfailed, { id = f.id, msg = f.msg, finding = f.finding })
    end
    if #hits == 0 or env.SMOKE_NO_XFAIL == "1" then
      table.insert(remaining, f)
    end
  end
  R.failures = remaining
  if env.SMOKE_NO_XFAIL == "1" then
    R.xfailed = {}
    return
  end
  -- Deleting any one entry must turn the run red: an entry whose failures are all
  -- covered by other entries could be deleted without anyone noticing.
  for i, x in ipairs(xfail) do
    if used[i] and not needed[i] then
      fail(
        "xfail:redundant",
        ("%s '%s' (%s) only matches failures other entries match"):format(x.id, x.match, x.finding)
      )
    end
  end
  for i, x in ipairs(xfail) do
    local scope = x.id:match("^([^:]+)")
    -- a wildcard entry can only be judged stale when every case ran
    local judged = scope == "*" and R.full_run or R.scopes[scope]
    if not used[i] and version_matches(x.nvim) and judged then
      fail(
        "xfail:stale",
        ("%s '%s' (%s) no longer fails on %s: delete the entry"):format(x.id, x.match, x.finding or "?", nvim_version)
      )
    end
  end
end

local function write_report(code, engine_error)
  local lines = {
    ("smoke: nvim %s  home=%s%s"):format(
      nvim_version,
      env.SMOKE_HOME or "?",
      (env.SMOKE_FIXTURE or "") ~= "" and ("  fixture=" .. env.SMOKE_FIXTURE) or ""
    ),
  }
  local names = vim.tbl_keys(R.cases)
  table.sort(names)
  for _, name in ipairs(names) do
    local c = R.cases[name]
    table.insert(
      lines,
      ("%-11s clients={%s} ts=%s diags=%s"):format(
        name,
        table.concat(c.clients, ","),
        tostring(c.lang),
        fmt_summary(c.diags)
      )
    )
  end
  for _, w in ipairs(R.warnings) do
    table.insert(lines, "WARN  " .. w)
  end
  for _, x in ipairs(R.xfailed) do
    table.insert(lines, ("XFAIL [%s] %s (%s)"):format(x.id, x.msg, x.finding or "?"))
  end
  for _, f in ipairs(R.failures) do
    local known = f.finding and ("  (known: " .. f.finding .. ")") or ""
    table.insert(lines, ("FAIL  [%s] %s%s"):format(f.id, f.msg, known))
  end
  if engine_error then
    table.insert(lines, "ENGINE ERROR " .. engine_error)
  end
  table.insert(
    lines,
    ("SMOKE %s: %d failed, %d xfailed, %d warnings"):format(
      code == 0 and "PASS" or (code == 1 and "FAIL" or "ERROR"),
      #R.failures,
      #R.xfailed,
      #R.warnings
    )
  )
  if env.SMOKE_SUMMARY then
    write_file(env.SMOKE_SUMMARY, table.concat(lines, "\n") .. "\n")
  end
  if env.SMOKE_REPORT then
    write_file(
      env.SMOKE_REPORT,
      vim.json.encode({
        nvim = nvim_version,
        pass = code == 0,
        exit = code,
        fixture = env.SMOKE_FIXTURE,
        failures = R.failures,
        xfailed = R.xfailed,
        warnings = R.warnings,
        cases = R.cases,
        engine_error = engine_error,
      })
    )
  end
end

local function finish(code, engine_error)
  pcall(write_report, code, engine_error)
  if code == 0 then
    vim.cmd("qall!")
  else
    vim.cmd("cquit " .. code)
  end
end

-- main ------------------------------------------------------------------------------

local function main()
  allow = load_data("allow.lua")
  local cases = load_data("cases.lua")
  local xfail = load_data("xfail.lua")

  -- Headless Nvim never fires UIEnter, so lazy.nvim would never fire VeryLazy and
  -- every VeryLazy plugin (noice, notify, lualine, navic, ...) would go untested.
  if not vim.g.did_very_lazy then
    vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
  end
  vim.wait(10000, function()
    return vim.g.did_very_lazy == true
  end, 50)
  vim.wait(tonumber(env.SMOKE_STARTWAIT or "1500"))

  R.scopes.startup, R.scopes.tools = true, true
  check_init()
  check_messages("startup", { messages = 0, stderr = 0, noice = 0 })

  -- the dashboard is what a bare `nvim` shows first
  S.case = "dashboard"
  R.scopes.dashboard = true
  local from = snapshot()
  if vim.fn.exists(":Alpha") == 2 and vim.bo.filetype ~= "alpha" then
    pcall(vim.cmd, "silent Alpha")
  end
  vim.wait(1000)
  vim.cmd("redraw!")
  check_messages("dashboard", from)

  check_enabled(cases.enabled_servers)

  S.case = "tools"
  check_tools()
  R.scopes.scan = true
  check_deprecated_scan()

  if env.SMOKE_STARTUP_ONLY ~= "1" then
    local only = (env.SMOKE_ONLY or "") ~= "" and vim.split(env.SMOKE_ONLY, ",", { trimempty = true }) or nil
    R.full_run = only == nil
    if only then
      for _, name in ipairs(only) do
        local known = vim.tbl_contains(
          vim.tbl_map(function(c)
            return c.name
          end, cases),
          name
        )
        if not known then
          error("--only: no case named " .. name .. " in test/smoke/cases.lua", 0)
        end
      end
    end
    for _, c in ipairs(cases) do
      if not only or vim.tbl_contains(only, c.name) then
        run_case(c)
      end
    end
  end

  S.case = "startup"
  check_lockfile()
  check_deprecations()
  check_notifies()
  apply_xfail(xfail)
  finish(#R.failures == 0 and 0 or 1)
end

local function start()
  vim.defer_fn(function()
    finish(3, "engine watchdog: run exceeded SMOKE_TIMEOUT_MS")
  end, math.max(10000, tonumber(env.SMOKE_TIMEOUT_MS or "300000") - 5000))
  local ok, err = xpcall(main, debug.traceback)
  if not ok then
    finish(2, tostring(err))
  end
end

if vim.v.vim_did_enter == 1 then
  vim.schedule(start)
else
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(start)
    end,
  })
end
