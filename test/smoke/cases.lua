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
    -- ruff runs as an LSP server only, so there is no nvim-lint "ruff" namespace
    diags = { ["lsp:basedpyright"] = 4, ["lsp:ruff"] = 4, ruff = false },
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
    diags = { shellcheck_zsh = 3 },
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
      -- <leader>x opens the file in the default app through vim.ui.open (stubbed here)
      local opened
      local real_open = vim.ui.open
      vim.ui.open = function(path)
        opened = path
        return nil, nil
      end
      local ok, err = pcall(vim.api.nvim_feedkeys, vim.keycode("<leader>x"), "mx", false)
      vim.ui.open = real_open
      local want = vim.api.nvim_buf_get_name(buf)
      if not ok then
        t.fail("markdown:open", "<leader>x raised: " .. tostring(err))
      elseif opened == nil or vim.fn.resolve(opened) ~= vim.fn.resolve(want) then
        t.fail("markdown:open", ("<leader>x called vim.ui.open(%s), want %s"):format(tostring(opened), want))
      end
      -- glow.nvim is gone, with its :Glow command and preview keys
      if
        vim.fn.exists(":Glow") == 2
        or vim.fn.maparg("<leader>mg", "n") ~= ""
        or vim.fn.maparg("<Leader>p", "n") ~= ""
      then
        t.fail("markdown:glow", ":Glow, <leader>mg or <Leader>p still exists; glow.nvim was removed")
      end
    end,
  },
  {
    name = "sql",
    file = "test/sql/test_sample.sql",
    -- SQL has no LSP on purpose: dadbod completes, sqlfluff formats
    clients = {},
    lang = "sql",
    check = function(buf, t)
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
