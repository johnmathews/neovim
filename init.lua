vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Ensure neovim-node-host is found (works with NVM/Homebrew)
local function set_node_host_prog()
  -- try to find the host in PATH
  local h = io.popen("command -v neovim-node-host 2>/dev/null")
  local p = h and h:read("*a") or ""
  if h then
    h:close()
  end
  p = (p or ""):gsub("%s+$", "")
  if p ~= "" then
    vim.g.node_host_prog = p
    return
  end

  -- fallback: add common NVM path (adjust version if needed)
  local nvm_bin = vim.fn.expand("~/.nvm/versions/node/v20.12.2/bin")
  if vim.fn.isdirectory(nvm_bin) == 1 then
    vim.env.PATH = nvm_bin .. ":" .. vim.env.PATH
    local h2 = io.popen("command -v neovim-node-host 2>/dev/null")
    local p2 = h2 and h2:read("*a") or ""
    if h2 then
      h2:close()
    end
    p2 = (p2 or ""):gsub("%s+$", "")
    if p2 ~= "" then
      vim.g.node_host_prog = p2
    end
  end
end
set_node_host_prog()

local function set_python_host_prog()
  local default_py = vim.fn.expand("~/.pyenv/versions/3.10.12/envs/nvim/bin/python3")
  local host = nil

  -- Prefer Poetry ONLY if it's on PATH and returns a path
  if vim.fn.executable("poetry") == 1 then
    local handle = io.popen("poetry env info -p 2>/dev/null")
    local result = handle and handle:read("*a") or ""
    if handle then
      handle:close()
    end
    result = (result or ""):gsub("[\r\n]", "")
    local poetry_py = result ~= "" and (result .. "/bin/python") or nil
    if poetry_py and vim.fn.executable(poetry_py) == 1 then
      host = poetry_py
    end
  end

  if not host then
    host = default_py
  end

  vim.cmd(("let g:python3_host_prog = '%s'"):format(host:gsub("'", "\\'")))
end
set_python_host_prog()

-- convenience function for adding keybind details to whichkey from a plugins config
function KeymapOptions(description)
  description = description or "no description"
  return {
    noremap = true,
    silent = true,
    desc = description,
  }
end

vim.api.nvim_set_keymap("n", "<Space>", "<Nop>", KeymapOptions("unmap space so it can be the Leader Key"))
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("options")
require("plugins")

require("functions")
require("mappings")
require("autocmd")

-- load custom snippets. dont remove this.
require("luasnip.loaders.from_lua").load({ paths = "./lua/snippets" })

-- this is just some stuff to make syntax highlighting work in .env files
-- Ensure the setup_env_syntax function is local to avoid polluting the global namespace
local function setup_env_syntax()
  vim.cmd([[
    syntax clear
    syntax match EnvComment "#.*" contains=@Spell
    syntax match EnvKey "^\s*\w\+" nextgroup=EnvSeparator
    syntax match EnvSeparator "=" contained nextgroup=EnvValue
    syntax match EnvValue "[\w@-]\+" contained

    highlight EnvComment ctermfg=Cyan guifg=Cyan
    highlight EnvKey ctermfg=White guifg=White
    highlight EnvSeparator ctermfg=Yellow guifg=Yellow
    highlight EnvValue ctermfg=Red guifg=Red
    ]])
end

-- Use vim.api.nvim_create_autocmd to set up the autocommand
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.env",
  callback = function()
    setup_env_syntax()
  end,
})

vim.lsp.set_log_level("WARN")

-- use the following to see what highlight group the text under the cursor is part of
-- :exe 'hi '.synIDattr(synstack(line('.'), col('.'))[-1], 'name')

-- persistent undo. see `undofile` in options.lua
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir
