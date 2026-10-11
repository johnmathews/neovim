-- Smoke gate cases: one real buffer per daily language, and what must be true
-- once it has opened. run.lua opens each file and checks every field below.
-- Write the expectation for the config as it should be. Known failures go in
-- xfail.lua with their finding ID, never into a weakened expectation here.
--
-- Fields:
--   name         case name, used in check IDs (`python:clients`) and by --only
--   file         path relative to the config root
--   clients      the exact set of LSP clients that must attach
--   lang         treesitter language the highlighter must use (nil: no expectation)
--   textobjects  af/if must be mapped in operator-pending and visual mode
--   folds        `normal! zx` must produce at least one fold
--   settings     { client = { ["dotted.path"] = value } } read from client.config.settings
--   diags        { key = n | true | false }: exact count, at least one, or none.
--                Keys: "lsp:<client>" for LSP diagnostics, the linter name for nvim-lint.
--   requests     LSP requests that must return a result (lines 1-based, columns 0-based)
--   check        function(buf, t) for anything else; report with t.fail(id, msg). A check
--                that only runs on some machines reports under its own scope and calls
--                t.scope(name) when it runs, so xfail entries for it are judged only then.
--
-- Every case also gets the generic checks in run.lua: no duplicate diagnostic from
-- two owners, cmp capabilities on every client, a buffer-local <leader>li where a
-- client supports inlay hints, navic where a client supports document symbols,
-- and no unexplained message while the case ran.

---@class SmokeCase
---@field name string
---@field file string
---@field clients string[]
---@field lang string|nil
---@field textobjects boolean|nil
---@field folds boolean|nil
---@field settings table<string, table<string, any>>|nil
---@field diags table<string, integer|boolean>|nil
---@field requests table[]|nil
---@field check fun(buf: integer, t: table)|nil

-- Project root and session picker (F14): entering a file buffer moves cwd to its root
-- marker, and the session picker replaces project.nvim's.
local function project_checks(buf, t)
  local root = vim.fn.resolve(vim.fn.stdpath("config"))
  vim.cmd.cd(vim.fn.fnameescape(vim.fn.stdpath("cache")))
  vim.cmd("enew")
  local scratch = vim.api.nvim_get_current_buf()
  vim.cmd("silent buffer " .. buf)
  vim.api.nvim_buf_delete(scratch, { force = true })
  local cwd = vim.fn.resolve(vim.fn.getcwd())
  if cwd ~= root then
    t.fail("project:cwd", ("entering %s left cwd at %s, want %s"):format(vim.fn.expand("%:t"), cwd, root))
  end
  vim.cmd.cd(vim.fn.fnameescape(root))

  for _, lhs in ipairs({ "<Tab>p", "<localleader>fs" }) do
    local rhs = vim.fn.maparg(lhs, "n")
    if not rhs:find("AutoSession search", 1, true) then
      t.fail("project:pickers", ("%s maps to %q, want :AutoSession search"):format(lhs, rhs))
    end
  end
  if package.loaded["project_nvim"] then
    t.fail("project:plugin", "project.nvim is loaded; vim.fs.root in lua/autocmd.lua replaces it")
  end
end

-- Native commenting (F18): `gcc` on line `lnum` must turn it into `want`, a Lua pattern
-- matched against the trimmed line. The change is undone afterwards.
local function comment_check(t, lnum, want)
  vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  local ok, err = pcall(vim.cmd, "normal gcc")
  local got = vim.trim(vim.api.nvim_get_current_line())
  vim.cmd("silent! undo")
  if not ok then
    t.fail(t.case .. ":comment", ("gcc on line %d raised: %s"):format(lnum, tostring(err)))
  elseif not got:match(want) then
    t.fail(t.case .. ":comment", ("gcc on line %d gave %q, want %s"):format(lnum, got, want))
  end
end

-- The built-in comment and selection mappings, with Comment.nvim and vim-numbers gone.
local function builtin_map_checks(t)
  local gcc = vim.fn.maparg("gcc", "n", false, true)
  if gcc.desc ~= "Toggle comment line" then
    t.fail("comment:builtin", ("gcc is %s, want the built-in 'Toggle comment line'"):format(vim.inspect(gcc.desc)))
  end
  if package.loaded["Comment"] then
    t.fail("comment:builtin", "Comment.nvim is loaded; native gc replaces it")
  end
  -- 0.12 maps visual and operator-pending an/in to treesitter node selection
  local an = vim.fn.maparg("an", "x", false, true)
  local want = vim.fn.has("nvim-0.12") == 1 and "Select parent (outer) node" or nil
  if an.desc ~= want then
    t.fail("comment:builtin", ("visual an is %s, want %s"):format(vim.inspect(an.desc), vim.inspect(want)))
  end
end

-- Keys that used to shadow Neovim's defaults (F16): gr and gi are the built-ins again,
-- grr and gri open the Telescope pickers, and <leader>cl stays "Run lint".
local function keymap_checks(t)
  for _, lhs in ipairs({ "gr", "gi" }) do
    local rhs = vim.fn.maparg(lhs, "n")
    if rhs ~= "" then
      t.fail("keymaps:defaults", ("%s is mapped to %q; it must stay Vim's default"):format(lhs, rhs))
    end
  end
  for lhs, want in pairs({ grr = "Telescope lsp_references", gri = "Telescope lsp_implementations" }) do
    local rhs = vim.fn.maparg(lhs, "n")
    if not rhs:find(want, 1, true) then
      t.fail("keymaps:defaults", ("%s maps to %q, want %s"):format(lhs, rhs, want))
    end
  end
  for lhs, want in pairs({ ["<leader>cl"] = "Run lint", ["<leader>cL"] = "Trouble" }) do
    local desc = vim.fn.maparg(lhs, "n", false, true).desc or ""
    if not desc:find(want, 1, true) then
      t.fail("keymaps:defaults", ("%s is %q, want %s"):format(lhs, desc, want))
    end
  end
end

-- Inert or broken global config (F25, F27): a new buffer gets no filetype, the statusline
-- never prints "nil", and noice alone shows LSP progress.
local function inert_checks(t)
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("enew")
  local ft = vim.bo.filetype
  local scratch = vim.api.nvim_get_current_buf()
  vim.cmd("silent buffer " .. buf)
  vim.api.nvim_buf_delete(scratch, { force = true })
  if ft ~= "" then
    t.fail("config:filetype", (":enew gave filetype %q, want none"):format(ft))
  end
  -- 'filetype' is buffer-local: setting it in options.lua tags whatever buffer is current
  -- at startup, which is the empty buffer a bare `nvim` shows the dashboard over
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].filetype == "on" then
      t.fail("config:filetype", ("buffer %d (%q) has filetype 'on'"):format(b, vim.api.nvim_buf_get_name(b)))
    end
  end
  local line = vim.api.nvim_eval_statusline(vim.o.statusline, { winid = 0 }).str
  if line:find("%f[%w]nil%f[%W]") then
    t.fail("config:statusline", ("statusline contains nil: %q"):format(line))
  end
  if package.loaded["fidget"] then
    t.fail("config:progress", "fidget.nvim is loaded; noice shows LSP progress")
  end
  local ok, noice_config = pcall(require, "noice.config")
  if not ok or not vim.tbl_get(noice_config.options or {}, "lsp", "progress", "enabled") then
    t.fail("config:progress", "noice's lsp.progress is not enabled")
  end
end

-- nvim-treesitter `main` (F2, F3, F24): textobject maps are buffer-local, folds use the
-- native foldexpr, and the master-era maps are gone, so the built-in motions come back.
local function treesitter_checks(t)
  local m = vim.fn.maparg("]m", "n", false, true)
  if m.buffer ~= 1 or not m.callback then
    t.fail("python:textobjects", ("]m is %s, want a buffer-local textobjects mapping"):format(vim.inspect(m)))
  end
  if vim.wo.foldexpr ~= "v:lua.vim.treesitter.foldexpr()" then
    t.fail("python:folds", ("foldexpr=%s, want v:lua.vim.treesitter.foldexpr()"):format(vim.wo.foldexpr))
  end
  for lhs, want in pairs({ ["<leader>tc"] = "Inspect<CR>", ["<leader>tp"] = "InspectTree<CR>" }) do
    local rhs = vim.fn.maparg(lhs, "n")
    if not rhs:find(want, 1, true) then
      t.fail("treesitter:keymaps", ("%s maps to %q, want :%s"):format(lhs, rhs, want))
    end
  end
  for _, lhs in ipairs({ "<leader>df", "<leader>dF" }) do
    local rhs = vim.fn.maparg(lhs, "n")
    if rhs ~= "" then
      t.fail("treesitter:keymaps", ("%s maps to %q; it was removed"):format(lhs, rhs))
    end
  end
  -- ]o stays vim-unimpaired's option toggle; ]s and ]z are Vim's spell and fold motions
  for _, lhs in ipairs({ "]o", "]s", "]z" }) do
    if vim.fn.maparg(lhs, "n", false, true).buffer == 1 then
      t.fail("treesitter:keymaps", ("%s has a buffer-local mapping; the textobjects move was removed"):format(lhs))
    end
  end
  for _, lhs in ipairs({ "]d", "[d" }) do
    local desc = vim.fn.maparg(lhs, "n", false, true).desc or ""
    if not desc:find("diagnostic", 1, true) then
      t.fail("treesitter:keymaps", ("%s is %q, want the built-in diagnostic jump"):format(lhs, desc))
    end
  end
end

-- Plugin pins (F4, F18): aerial outlines the buffer on 0.12, and vim.ui.select is Telescope's
-- (telescope-ui-select replaced dressing.nvim).
local function plugin_checks(buf, t)
  local okA, aerial = pcall(require, "aerial")
  if not okA then
    t.fail("python:aerial", "aerial.nvim is not available: " .. tostring(aerial))
  else
    local symbols = 0
    vim.wait(10000, function()
      symbols = #(require("aerial.data").get_or_create(buf).items or {})
      return symbols > 0
    end, 200)
    if symbols == 0 then
      t.fail("python:aerial", "aerial found no symbols in test_sample.py")
    end
  end

  -- `gra` on the unused `import os` (ruff offers fixes); dressing sent code actions to its own window
  vim.api.nvim_win_set_cursor(0, { 6, 7 })
  pcall(vim.api.nvim_feedkeys, "gra", "mx", false)
  local opened = vim.wait(10000, function()
    return vim.bo.filetype == "TelescopePrompt"
  end, 50)
  if opened then
    -- close it as a user does. Telescope enters insert mode by feeding "A", which waits in
    -- the typeahead; closing any other way leaves it for the next case's keys to trigger.
    pcall(vim.api.nvim_feedkeys, vim.keycode("<Esc><Esc>"), "mx", false)
  else
    t.fail("python:ui-select", ("gra opened filetype %q, want a Telescope picker"):format(vim.bo.filetype))
    vim.cmd("stopinsert")
    vim.cmd("silent! close")
  end
  if package.loaded["dressing"] then
    t.fail("python:ui-select", "dressing.nvim is loaded; telescope-ui-select replaces it")
  end
  -- Telescope's history database lives in this Neovim's data dir (F35): a hard-coded
  -- ~/.local/share path breaks fresh machines and escapes the gate's sandbox
  local history = vim.tbl_get(require("telescope.config").values, "history", "path") or ""
  local data = vim.fn.stdpath("data")
  if vim.fn.fnamemodify(history, ":p"):sub(1, #data) ~= data then
    t.fail("python:telescope", ("history.path is %s, want a file under %s"):format(history, data))
  end
  vim.wait(1000, function()
    return vim.bo.filetype == "python"
  end, 50)
  vim.cmd("stopinsert")
  vim.cmd("silent buffer " .. buf)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

-- Keymap docs against the running config (F20, F16, #7). docs/KEYMAPS.md is written by hand;
-- this keeps it honest in both directions: every documented key resolves with maparg in its
-- documented modes, and every mapping with a desc under the main prefixes is documented.
-- Runs in the Python buffer, so buffer-local maps (LSP, textobjects, gitsigns) are there.

-- Documented keys that are Vim commands rather than mappings
local doc_builtins = { ["<C-o>"] = true }

local doc_modes = { normal = "n", insert = "i", visual = "x", pending = "o", operator = "o", terminal = "t" }

---Raw bytes of a documented key, with <Leader> and <LocalLeader> expanded.
---@param key string
---@return string
local function key_raw(key)
  local k = key:gsub("<[Ll]eader>", vim.g.mapleader or "\\")
  k = k:gsub("<[Ll]ocal[Ll]eader>", vim.g.maplocalleader or "\\")
  return vim.keycode(k)
end

---Rows of every Key | Mode | ... table in docs/KEYMAPS.md:
---{ keys = {...}, modes = {...}, line = n, section = "<## heading>" }
local function doc_rows()
  local rows = {}
  local path = vim.fn.stdpath("config") .. "/docs/KEYMAPS.md"
  local in_table = false
  local section = ""
  for lnum, line in ipairs(vim.fn.readfile(path)) do
    local cells = vim.split(line, "|", { plain = true })
    section = line:match("^## (.+)") or section
    if line:match("^|%s*Key%s*|%s*Mode%s*|") then
      in_table = true
    elseif not line:match("^|") then
      in_table = false
    elseif in_table and not line:match("^|%s*%-") then
      local keys = {}
      -- code spans: `x` or `` x `` (for keys that contain a backtick)
      for span in (cells[2] or ""):gmatch("``(.-)``") do
        table.insert(keys, vim.trim(span))
      end
      if #keys == 0 then
        for span in (cells[2] or ""):gmatch("`([^`]+)`") do
          table.insert(keys, span)
        end
      end
      local modes = {}
      for word in (cells[3] or ""):lower():gmatch("%a+") do
        if doc_modes[word] then
          table.insert(modes, doc_modes[word])
        end
      end
      table.insert(rows, { keys = keys, modes = modes, line = lnum, section = section })
    end
  end
  return rows
end

---@param buf integer
---@param t table
---@param markdown boolean true in the Markdown buffer: check the doc's Markdown section and
---  the buffer's own maps; false in the Python buffer: everything else, and the global maps
local function keymap_doc_checks(buf, t, markdown)
  if not markdown then
    -- gitsigns attaches asynchronously; its maps are part of what the doc lists
    vim.wait(10000, function()
      return vim.fn.maparg("<Leader>shp", "n") ~= ""
    end, 100)

    -- #7: the hunk actions call gitsigns instead of typing keys into the buffer
    for _, mode in ipairs({ "n", "x" }) do
      for _, lhs in ipairs({ "<Leader>shs", "<Leader>shr" }) do
        local m = vim.fn.maparg(lhs, mode, false, true)
        if not m.callback then
          t.fail("keymaps:gitsigns", ("%s (%s) maps to %s, want a gitsigns call"):format(lhs, mode, vim.inspect(m.rhs)))
        end
      end
    end
  end

  local documented = {}
  for _, row in ipairs(doc_rows()) do
    for _, key in ipairs(row.keys) do
      if not key:find("{", 1, true) then
        documented[key_raw(key)] = true
        if not doc_builtins[key] and (row.section == "Markdown") == markdown then
          for _, mode in ipairs(row.modes) do
            if vim.fn.maparg(key, mode) == "" then
              t.fail(
                "keymaps:documented",
                ("KEYMAPS.md:%d documents %s in mode %s, but it is not mapped"):format(row.line, key, mode)
              )
            end
          end
        end
      end
    end
  end

  local leader, localleader = vim.g.mapleader or "\\", vim.g.maplocalleader or "\\"
  local function prefixed(raw)
    if raw == leader or raw == localleader then
      return false -- the leader key itself, which the doc's header names
    end
    local name = vim.fn.keytrans(raw)
    return raw:sub(1, #leader) == leader
      or raw:sub(1, #localleader) == localleader
      or raw:sub(1, 1) == "\t"
      or raw:sub(1, 1) == "g"
      or name:match("^<F%d+>") ~= nil
  end
  local seen = {}
  for _, mode in ipairs({ "n", "x" }) do
    local maps = vim.api.nvim_buf_get_keymap(buf, mode)
    if not markdown then
      maps = vim.list_extend(maps, vim.api.nvim_get_keymap(mode))
    end
    for _, m in ipairs(maps) do
      local raw = m.lhsraw or vim.keycode(m.lhs)
      local name = vim.fn.keytrans(raw)
      local trigger = (m.desc or ""):find("^which%-key%-trigger") ~= nil
      if m.desc and not trigger and prefixed(raw) and not documented[raw] and not seen[name] then
        seen[name] = true
        t.fail("keymaps:undocumented", ("%s (%s, %q) is mapped but not in KEYMAPS.md"):format(name, mode, m.desc))
      end
    end
  end
  if markdown then
    return
  end

  -- which-key labels (lua/plugins/whichkey.lua) name real mappings
  local wk = vim.fn.readfile(vim.fn.stdpath("config") .. "/lua/plugins/whichkey.lua")
  for lnum, line in ipairs(wk) do
    local lhs = line:match('^%s*{%s*"([^"]+)",%s*desc%s*=')
    if lhs and not doc_builtins[lhs] then
      local mapped = false
      for _, mode in ipairs({ "n", "x", "o" }) do
        mapped = mapped or vim.fn.maparg(lhs, mode) ~= ""
      end
      if not mapped then
        t.fail("keymaps:whichkey", ("whichkey.lua:%d labels %s, which is not mapped"):format(lnum, lhs))
      end
    end
  end
end

---@type SmokeCase[]
local cases = {
  {
    name = "python",
    file = "test/python/test_sample.py",
    clients = { "basedpyright", "ruff" },
    lang = "python",
    textobjects = true,
    folds = true,
    settings = { basedpyright = { ["basedpyright.analysis.typeCheckingMode"] = "basic" } },
    -- ruff runs as an LSP server only, so there is no nvim-lint "ruff" namespace. Its count
    -- is not pinned: ruff's default rules grow between releases (0.17 adds PIE790, giving 5),
    -- and python:duplicates already catches a second owner.
    diags = { ["lsp:basedpyright"] = 4, ["lsp:ruff"] = true, ruff = false },
    requests = {
      { method = "textDocument/definition", line = 35, col = 13, expect_line = 10 },
      { method = "textDocument/hover", line = 35, col = 13 },
      { method = "textDocument/prepareRename", line = 35, col = 13 },
      { method = "textDocument/codeAction", line = 6, col = 7 },
    },
    check = function(buf, t)
      project_checks(buf, t)

      -- grr runs Telescope lsp_references. calculate_sum has two references; Telescope drops
      -- the one on the cursor line and jumps to the other (line 10) instead of opening a
      -- picker. The built-in grr would open the quickfix list.
      vim.api.nvim_win_set_cursor(0, { 35, 13 })
      pcall(vim.api.nvim_feedkeys, "grr", "mx", false)
      vim.wait(10000, function()
        return vim.api.nvim_win_get_cursor(0)[1] == 10 or vim.bo.filetype ~= "python"
      end, 100)
      local ft, lnum = vim.bo.filetype, vim.api.nvim_win_get_cursor(0)[1]
      if ft ~= "python" then
        vim.cmd("stopinsert")
        vim.cmd("silent! close")
        vim.cmd("silent buffer " .. buf)
      end
      if ft ~= "python" or lnum ~= 10 then
        t.fail("python:grr", ("grr left filetype %q at line %d, want Telescope's jump to line 10"):format(ft, lnum))
      end
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- basedpyright must push diagnostics. Pulled, on 0.12 it registers twice and can answer
      -- a pull with an empty report, so a buffer opens with none of its diagnostics.
      for _, ns in pairs(vim.diagnostic.get_namespaces()) do
        if ns.name:match("lsp%.basedpyright%.%d+%.") then
          t.fail("python:pull", ("basedpyright diagnostics are pulled (namespace %s), want pushed"):format(ns.name))
        end
      end

      -- vaf on the comment inside calculate_sum selects the whole function
      vim.api.nvim_win_set_cursor(0, { 12, 4 })
      local ok, err = pcall(vim.cmd, "normal vaf")
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      vim.cmd("normal! \27")
      if not ok or s ~= 10 or e ~= 13 then
        t.fail("python:textobjects", ("vaf from line 12 selected %d-%d, want 10-13 (%s)"):format(s, e, tostring(err)))
      end
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      treesitter_checks(t)
      plugin_checks(buf, t)
      keymap_doc_checks(buf, t, false)

      -- a restarted server must get the same settings as the first start
      local before = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })[1]
      if before and vim.fn.exists(":LspRestart") == 2 then
        vim.cmd("silent LspRestart basedpyright")
        vim.wait(20000, function()
          local after = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })[1]
          return after ~= nil and after.id ~= before.id and after.initialized
        end, 200)
        local after = vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" })[1]
        local mode = after and vim.tbl_get(after.config.settings or {}, "basedpyright", "analysis", "typeCheckingMode")
        if not after or after.id == before.id then
          t.fail("python:restart", ":LspRestart did not start a new basedpyright client")
        elseif mode ~= "basic" then
          t.fail("python:restart", ("after :LspRestart typeCheckingMode=%s, want basic"):format(tostring(mode)))
        end
      end

      -- providers: uv's pynvim tool when it is installed, never a guessed path, and no node host (F22)
      local data = vim.env.XDG_DATA_HOME or (vim.env.HOME .. "/.local/share")
      local uv_python = (vim.env.UV_TOOL_DIR or (data .. "/uv/tools")) .. "/pynvim/bin/python"
      local host = vim.g.python3_host_prog
      if vim.fn.executable(uv_python) == 1 then
        if host ~= uv_python then
          t.fail("python:provider", ("python3_host_prog=%s, want %s"):format(tostring(host), uv_python))
        elseif vim.fn.has("python3") ~= 1 then
          t.fail("python:provider", "has('python3') is 0 with " .. uv_python)
        else
          -- vim-mundo is a python3 plugin; this only runs where uv's pynvim is installed
          t.scope("mundo")
          local mok, merr = pcall(vim.cmd, "MundoToggle")
          if not mok or vim.bo.filetype ~= "Mundo" then
            -- a nested autocmd error's first line ends with its cause, after a long call chain
            local cause = tostring(merr):match("^[^\n]*")
            cause = #cause > 200 and ("..." .. cause:sub(-200)) or cause
            t.fail("mundo:open", ":MundoToggle did not open the Mundo window: " .. cause)
          end
          pcall(vim.cmd, "MundoHide")
          vim.cmd("silent buffer " .. buf)
        end
      elseif host ~= nil then
        t.fail("python:provider", ("python3_host_prog=%s, but %s does not exist"):format(host, uv_python))
      end
      if vim.g.loaded_node_provider ~= 0 then
        t.fail("python:provider", "the node provider is enabled; no node remote plugin needs it")
      end
    end,
  },
  {
    name = "lua",
    file = "test/lua/test_sample.lua",
    clients = { "lua_ls" },
    lang = "lua",
    textobjects = true,
    folds = true,
    settings = { lua_ls = { ["Lua.runtime.version"] = "LuaJIT" } },
    diags = { ["lsp:lua_ls"] = true, luacheck = true },
    requests = {
      { method = "textDocument/definition", line = 10, col = 9, expect_line = 4 },
      { method = "textDocument/hover", line = 10, col = 9 },
      { method = "textDocument/prepareRename", line = 10, col = 9 },
      { method = "textDocument/codeAction", line = 7, col = 6 },
    },
    check = function(_, t)
      keymap_checks(t)
      inert_checks(t)
    end,
  },
  {
    name = "javascript",
    file = "test/javascript/test_sample.js",
    clients = { "ts_ls" },
    lang = "javascript",
    textobjects = true,
    diags = { ["lsp:ts_ls"] = true },
  },
  {
    name = "typescript",
    file = "test/typescript/test_sample.ts",
    clients = { "ts_ls" },
    lang = "typescript",
    textobjects = true,
    diags = { ["lsp:ts_ls"] = true },
    check = function(_, t)
      comment_check(t, 11, "^// const label")
      builtin_map_checks(t)
      -- gco and gcO open a commented line below and above
      for _, c in ipairs({ { keys = "gco", lnum = 12 }, { keys = "gcO", lnum = 11 } }) do
        vim.api.nvim_win_set_cursor(0, { 11, 0 })
        local ok, err = pcall(vim.api.nvim_feedkeys, vim.keycode(c.keys .. "added<Esc>"), "mx", false)
        local got = vim.trim(vim.api.nvim_buf_get_lines(0, c.lnum - 1, c.lnum, false)[1] or "")
        vim.cmd("silent! undo")
        if not ok or got ~= "// added" then
          t.fail(
            "typescript:comment",
            ("%s gave line %d %q, want '// added' (%s)"):format(c.keys, c.lnum, got, tostring(err))
          )
        end
      end
      -- with no commentstring, gco opens a plain line instead of leaving a stray "x"
      vim.cmd("enew")
      local scratch = vim.api.nvim_get_current_buf()
      vim.bo.commentstring = ""
      vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { "text" })
      pcall(vim.api.nvim_feedkeys, vim.keycode("gcoadded<Esc>"), "mx", false)
      local lines = vim.api.nvim_buf_get_lines(scratch, 0, -1, false)
      vim.cmd("silent buffer #")
      vim.api.nvim_buf_delete(scratch, { force = true })
      if table.concat(lines, "|") ~= "text|added" then
        t.fail("typescript:comment", ("gco with no commentstring gave %s, want text|added"):format(vim.inspect(lines)))
      end
      vim.cmd("silent edit!")
    end,
  },
  {
    name = "tsx",
    file = "test/typescript/test_sample.tsx",
    clients = { "ts_ls" },
    lang = "tsx",
    textobjects = true,
    diags = { ["lsp:ts_ls"] = true },
    check = function(_, t)
      -- the comment style follows the node under the cursor: nvim-treesitter's jsx query sets
      -- bo.commentstring metadata, which native gc reads before 'commentstring'
      comment_check(t, 10, "^{/%* <span>{upper}</span> %*/}$")
      comment_check(t, 7, "^// const upper")
      if package.loaded["ts_context_commentstring"] then
        t.fail("tsx:comment", "nvim-ts-context-commentstring is loaded; the jsx query's metadata replaces it")
      end
      vim.cmd("silent edit!")
    end,
  },
  {
    name = "bash",
    file = "test/bash/test_sample.sh",
    clients = { "bashls" },
    lang = "bash",
    textobjects = true,
    -- bashls runs shellcheck itself; nvim-lint must not run it a second time
    diags = { ["lsp:bashls"] = true, shellcheck = false },
  },
  {
    name = "zsh",
    file = "test/zsh/test_sample.zsh",
    clients = { "bashls" },
    lang = "bash",
    textobjects = true,
    -- bash-language-server 5.8+ shellchecks zsh too (as bash), so it owns zsh like sh and bash
    diags = { ["lsp:bashls"] = 3, shellcheck_zsh = false },
  },
  {
    name = "yaml",
    file = "test/yaml/test_sample.yaml",
    clients = { "yamlls" },
    lang = "yaml",
    -- no folds check: the sample's deliberate syntax errors leave treesitter no fold ranges
    settings = { yamlls = { ["yaml.format.enable"] = false } },
    diags = { ["lsp:yamlls"] = true },
  },
  {
    name = "json",
    file = "test/json/test_sample.json",
    clients = { "jsonls" },
    lang = "json",
    diags = { ["lsp:jsonls"] = true },
  },
  {
    name = "toml",
    file = "test/toml/test_sample.toml",
    clients = { "taplo" },
    lang = "toml",
  },
  {
    name = "markdown",
    file = "test/markdown/test_sample.md",
    clients = { "marksman" },
    lang = "markdown",
    diags = { markdownlint = 3 },
    check = function(buf, t)
      -- <leader>F reveals the file in Finder (`open -R`; elsewhere vim.ui.open on its folder),
      -- both stubbed here
      local called
      local real_system, real_open = vim.system, vim.ui.open
      vim.system = function(cmd)
        called = table.concat(cmd, " ")
        return { wait = function() end }
      end
      vim.ui.open = function(path)
        called = "ui.open " .. path
        return nil, nil
      end
      local ok, err = pcall(vim.api.nvim_feedkeys, vim.keycode("<leader>F"), "mx", false)
      vim.system, vim.ui.open = real_system, real_open
      local file = vim.fn.resolve(vim.api.nvim_buf_get_name(buf))
      local want = vim.fn.has("mac") == 1 and ("open -R " .. file) or ("ui.open " .. vim.fn.fnamemodify(file, ":h"))
      if not ok then
        t.fail("markdown:open", "<leader>F raised: " .. tostring(err))
      elseif called ~= want then
        t.fail("markdown:open", ("<leader>F ran %s, want %s"):format(tostring(called), want))
      end
      -- <leader>x is only Trouble's prefix (a mapping on it would make <leader>xx wait), and
      -- <leader>X (Typora) exists in Markdown buffers only
      if vim.fn.maparg("<leader>x", "n") ~= "" then
        t.fail(
          "markdown:open",
          ("<leader>x maps to %q; it is Trouble's prefix"):format(vim.fn.maparg("<leader>x", "n"))
        )
      end
      local typora = vim.fn.maparg("<leader>X", "n", false, true)
      if typora.buffer ~= 1 or not (typora.desc or ""):find("Typora", 1, true) then
        t.fail(
          "markdown:open",
          ("<leader>X is %s, want a buffer-local Typora mapping"):format(vim.inspect(typora.desc))
        )
      end
      -- glow.nvim is gone, with its :Glow command and preview keys
      if
        vim.fn.exists(":Glow") == 2
        or vim.fn.maparg("<leader>mg", "n") ~= ""
        or vim.fn.maparg("<Leader>p", "n") ~= ""
      then
        t.fail("markdown:glow", ":Glow, <leader>mg or <Leader>p still exists; glow.nvim was removed")
      end
      -- markdown stays unfolded (vim-markdown.lua disables its folding; treesitter folds skip it)
      if vim.wo.foldmethod ~= "manual" then
        t.fail("markdown:folds", ("foldmethod=%s, want manual"):format(vim.wo.foldmethod))
      end
      keymap_doc_checks(buf, t, true)
    end,
  },
  {
    name = "sql",
    file = "test/sql/test_sample.sql",
    -- SQL has no LSP on purpose: dadbod completes, sqlfluff formats
    clients = {},
    lang = "sql",
    check = function(buf, t)
      -- sql has no textobjects query, so its ftplugin keeps `]]` (next BEGIN)
      local brackets = vim.fn.maparg("]]", "n", false, true)
      if brackets.buffer ~= 1 or not (brackets.rhs or ""):find("search(", 1, true) then
        t.fail("sql:keymaps", ("]] is %s, want the sql ftplugin's search"):format(vim.inspect(brackets.rhs)))
      end
      local function text()
        return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      end
      local before = text()
      -- sqlfluff is too slow for the save timeout, so saving must not format SQL
      local wok, werr = pcall(vim.cmd, "silent write")
      if not wok then
        t.fail("sql:format", ":write raised: " .. tostring(werr))
      elseif text() ~= before then
        t.fail("sql:format", ":write formatted the SQL buffer; SQL formats on <leader>cf only")
      end
      -- the sample has no .sqlfluff, so conform must pass a default dialect
      local fok, attempted = pcall(require("conform").format, { bufnr = buf, async = false, timeout_ms = 30000 })
      if not fok then
        t.fail("sql:format", "conform.format() raised: " .. tostring(attempted))
      elseif not attempted then
        t.fail("sql:format", "conform.format() ran no formatter on the SQL buffer")
      elseif text() == before then
        t.fail("sql:format", "conform.format() left the SQL buffer unchanged")
      end
      vim.cmd("silent edit!")
    end,
  },
}

-- The exact set of enabled LSP configs (checked once per run as startup:enabled).
cases.enabled_servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "ts_ls",
  "bashls",
  "yamlls",
  "jsonls",
  "dockerls",
  "taplo",
  "marksman",
}

return cases
