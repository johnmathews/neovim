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
  -- The old checkout is moved aside, not deleted, until the new one is on its pin.
  -- lazy.nvim itself is never moved: this process is running its code.
  local off = off_pin()
  if #off > 0 then
    vim.fn.writefile(pinned_text, lockfile, "b")
    Lock._loaded = false
    local moved = {}
    for _, o in ipairs(off) do
      local dir = o.plugin.dir
      if o.plugin.name == "lazy.nvim" then
        step_failed(("lazy.nvim is at %s, lazy-lock.json pins %s; run :Lazy restore"):format(o.have, o.want))
      elseif vim.fn.isdirectory(dir) == 1 then
        log(("reinstalling %s: lazy left it at %s, lazy-lock.json pins %s"):format(o.plugin.name, o.have, o.want))
        vim.fn.delete(dir .. ".off-pin", "rf")
        if vim.fn.rename(dir, dir .. ".off-pin") == 0 then
          moved[o.plugin.name] = dir
        else
          step_failed("cannot move " .. dir .. " aside")
        end
      end
    end
    require("lazy.core.plugin").update_state()
    require("lazy.manage").install({ wait = true, show = false, lockfile = true })
    local still = {}
    for _, o in ipairs(off_pin()) do
      still[o.plugin.name] = true
      step_failed(("%s is at %s, lazy-lock.json pins %s"):format(o.plugin.name, o.have, o.want))
    end
    for name, dir in pairs(moved) do
      if still[name] then
        -- the reinstall failed: put the old checkout back rather than leave none
        vim.fn.delete(dir, "rf")
        vim.fn.rename(dir .. ".off-pin", dir)
      else
        vim.fn.delete(dir .. ".off-pin", "rf")
      end
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
  if not vim.wait(120000, function()
    return refreshed
  end, 200) then
    step_failed("the Mason registry did not refresh within 2 minutes")
  end
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
  if not vim.wait(900000, function()
    return pending == 0
  end, 500) then
    step_failed(("%d Mason installs still running after 15 minutes"):format(pending))
  end
  if vim.fn.exists(":MasonToolsInstallSync") == 2 then
    log("installing Mason tools (mason-tool-installer)")
    vim.cmd("MasonToolsInstallSync")
  end
  -- neither callback above nor :MasonToolsInstallSync raises on a failed install, so check
  local okt, mason_config = pcall(require, "plugins.mason")
  local tools = okt and type(mason_config) == "table" and mason_config.tools or {}
  for _, name in ipairs(vim.list_extend(vim.deepcopy(servers), tools)) do
    if registry.has_package(name) and not registry.is_installed(name) then
      step_failed("Mason package not installed: " .. name)
    end
  end

  -- Parsers: the list lua/plugins/treesitter.lua exports, built synchronously.
  local okc, ts_config = pcall(require, "plugins.treesitter")
  if okc and type(ts_config) == "table" and ts_config.parsers then
    local ts = require("nvim-treesitter")
    -- Built parsers only: get_installed() also counts query directories, so a language whose
    -- parser is missing but whose queries remain counts as installed, and install() skips it.
    -- force rebuilds those half-installed languages.
    local function missing_parsers()
      local built = {}
      for _, lang in ipairs(ts.get_installed("parsers")) do
        built[lang] = true
      end
      return vim.tbl_filter(function(lang)
        return not built[lang]
      end, ts_config.parsers)
    end
    local missing = missing_parsers()
    if #missing > 0 then
      log("installing parsers: " .. table.concat(missing, ", "))
      local okw, err = pcall(function()
        return ts.install(missing, { force = true }):wait(900000)
      end)
      if not okw then
        step_failed("parser install: " .. tostring(err))
      end
    end
    -- the install task reports a failed build only through its return value; check the result
    for _, lang in ipairs(missing_parsers()) do
      step_failed("parser not installed: " .. lang)
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
