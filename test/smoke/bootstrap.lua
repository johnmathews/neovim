-- Smoke gate bootstrap, run by `scripts/smoke --bootstrap` inside SMOKE_HOME, in two
-- Nvim processes (SMOKE_BOOTSTRAP_PHASE), because a restore swaps plugin code on disk
-- that the running process has already loaded:
--   plugins  restore every plugin to its lazy-lock.json commit
--   tools    install the Mason packages the config asks for (LSP servers and tools),
--            then treesitter parsers the way the installed nvim-treesitter branch does it
-- Exits 0 on success, 1 if any step failed. Needs network.

local failed = false
local function log(msg)
  io.stderr:write("bootstrap: " .. msg .. "\n")
end
local function step_failed(msg)
  failed = true
  log("FAILED " .. msg)
end

local function restore_plugins()
  log("restoring plugins from lazy-lock.json")
  require("lazy").restore({ wait = true, show = false })
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    if not plugin._.installed then
      step_failed("plugin not installed: " .. plugin.name)
    end
  end
end

local function install_tools()
  -- Mason: the servers mason-lspconfig ensures, then mason-tool-installer's list.
  local registry = require("mason-registry")
  local refreshed = false
  registry.refresh(function()
    refreshed = true
  end)
  vim.wait(120000, function()
    return refreshed
  end, 200)
  local servers = {}
  local okm, mlc_settings = pcall(require, "mason-lspconfig.settings")
  local okmap, mappings = pcall(function()
    return require("mason-lspconfig").get_mappings().lspconfig_to_package
  end)
  if okm and okmap then
    for _, server in ipairs(mlc_settings.current.ensure_installed or {}) do
      table.insert(servers, mappings[server] or server)
    end
  end
  local pending = 0
  for _, name in ipairs(servers) do
    local okp, pkg = pcall(registry.get_package, name)
    if not okp then
      step_failed("unknown Mason package " .. name)
    elseif not pkg:is_installed() and not pkg:is_installing() then
      log("installing " .. name)
      pending = pending + 1
      pkg:install({}, function(success, err)
        pending = pending - 1
        if not success then
          step_failed("Mason package " .. name .. ": " .. tostring(err))
        end
      end)
    end
  end
  vim.wait(900000, function()
    return pending == 0
  end, 500)
  if vim.fn.exists(":MasonToolsInstallSync") == 2 then
    log("installing Mason tools (mason-tool-installer)")
    vim.cmd("MasonToolsInstallSync")
  end

  -- Parsers. master installs through :TSUpdateSync; main exports its parser list.
  if pcall(require, "nvim-treesitter.configs") then
    log("installing parsers (nvim-treesitter master)")
    vim.cmd("TSUpdateSync")
  else
    local okc, ts_config = pcall(require, "plugins.treesitter")
    if okc and type(ts_config) == "table" and ts_config.parsers then
      log("installing parsers (nvim-treesitter main)")
      local okw, err = pcall(function()
        require("nvim-treesitter").install(ts_config.parsers):wait(900000)
      end)
      if not okw then
        step_failed("parser install: " .. tostring(err))
      end
    else
      log("nvim-treesitter main without a parser list in plugins.treesitter: skipping parsers")
    end
  end
end

local phase = vim.env.SMOKE_BOOTSTRAP_PHASE
local ok, err = xpcall(phase == "plugins" and restore_plugins or install_tools, debug.traceback)
if not ok then
  step_failed(tostring(err))
end
vim.cmd(failed and "cquit 1" or "qall!")
