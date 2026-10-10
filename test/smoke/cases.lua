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
--   check        function(buf, t) for anything else; report with t.fail(id, msg)
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
    check = function(_, t)
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
