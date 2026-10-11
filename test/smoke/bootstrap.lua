-- Smoke gate bootstrap, run by `scripts/smoke --bootstrap` inside SMOKE_HOME and by
-- scripts/sync-plugins on a real data dir, in two Nvim processes (SMOKE_BOOTSTRAP_PHASE),
-- because a restore swaps plugin code on disk that the running process has already loaded:
--   plugins  restore every plugin to its lazy-lock.json commit, reinstalling any plugin
--            lazy could not move there
--   tools    install the Mason packages the config asks for (LSP servers and tools),
--            then the treesitter parsers lua/plugins/treesitter.lua lists
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
  local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local Lock, Git = require("lazy.manage.lock"), require("lazy.manage.git")
  -- Installing a missing plugin at startup made lazy rewrite every lockfile entry from the
  -- installed commits, so a plugin installed at another commit would be "restored" to itself.
  -- Restore from the repository's lockfile instead, and make lazy read it again.
  local repo_lock = (vim.env.SMOKE_REPO or "") .. "/lazy-lock.json"
  if vim.fn.filereadable(repo_lock) == 1 then
    vim.fn.writefile(vim.fn.readfile(repo_lock, "b"), lockfile, "b")
    Lock._loaded = false
  end
  -- The pins, read now: every restore ends by rewriting the lockfile from the installed commits.
  local pinned_text = vim.fn.readfile(lockfile, "b")
  local okp, pinned = pcall(vim.json.decode, table.concat(pinned_text, "\n"))
  if not okp or type(pinned) ~= "table" then
    step_failed("cannot read " .. lockfile)
    return
  end

  -- plugins that are missing or not at their pinned commit
  local function off_pin()
    local off = {}
    for _, plugin in pairs(require("lazy.core.config").plugins) do
      local pin = pinned[plugin.name]
      if not plugin._.installed then
        table.insert(off, { plugin = plugin, have = "not installed", want = pin and pin.commit or "?" })
      elseif pin and not plugin._.is_local then
        local info = Git.info(plugin.dir)
        if not info or info.commit ~= pin.commit then
          table.insert(off, { plugin = plugin, have = info and info.commit or "?", want = pin.commit })
        end
      end
    end
    return off
  end

  log("restoring plugins from lazy-lock.json")
  require("lazy").restore({ wait = true, show = false })

  -- lazy reports a plugin it could not move (local changes, a checkout that fails on a new
  -- submodule) and carries on. Do what it advises by hand: remove the plugin, install it again.
  local off = off_pin()
  if #off > 0 then
    vim.fn.writefile(pinned_text, lockfile, "b")
    Lock._loaded = false
    for _, o in ipairs(off) do
      log(("reinstalling %s: lazy left it at %s, lazy-lock.json pins %s"):format(o.plugin.name, o.have, o.want))
      vim.fn.delete(o.plugin.dir, "rf")
    end
    require("lazy.core.plugin").update_state()
    require("lazy.manage").install({ wait = true, show = false, lockfile = true })
    for _, o in ipairs(off_pin()) do
      step_failed(("%s is at %s, lazy-lock.json pins %s"):format(o.plugin.name, o.have, o.want))
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

  -- Parsers: the list lua/plugins/treesitter.lua exports, built synchronously.
  local okc, ts_config = pcall(require, "plugins.treesitter")
  if okc and type(ts_config) == "table" and ts_config.parsers then
    log("installing parsers")
    local okw, err = pcall(function()
      require("nvim-treesitter").install(ts_config.parsers):wait(900000)
    end)
    if not okw then
      step_failed("parser install: " .. tostring(err))
    end
  else
    step_failed("lua/plugins/treesitter.lua exports no parser list (nvim-treesitter master checked out?)")
  end
end

local phase = vim.env.SMOKE_BOOTSTRAP_PHASE
local ok, err = xpcall(phase == "plugins" and restore_plugins or install_tools, debug.traceback)
if not ok then
  step_failed(tostring(err))
end
vim.cmd(failed and "cquit 1" or "qall!")
