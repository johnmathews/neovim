-- macOS or Unix
local is_mac = vim.fn.has "macunix" == 1
if is_mac then
  local home_dir = "/Users/john"
else
  local home_dir = "/home/john"
end

local function set_python_host_prog()
    -- Default Python interpreter path
    local default_python_path = "~/.pyenv/versions/3.10.12/envs/nvim/bin/python3"

    -- Command to get Poetry's Python interpreter path
    local poetry_python_cmd = "poetry env info -p"

    -- Execute the command to get Poetry's environment path
    local handle = io.popen(poetry_python_cmd .. " 2> /dev/null") -- Suppress errors
    local result = handle:read("*a")
    handle:close()

    if result and result ~= '' then
        -- Process the result to format the path correctly
        local poetry_env_path = result:gsub("[\r\n]", "") -- Remove newlines
        poetry_env_path = poetry_env_path .. "/bin/python" -- Append bin/python to get the interpreter path

        -- Use vim.cmd to set the variable, ensuring to escape special characters
        vim.cmd("let g:python3_host_prog = '" .. poetry_env_path:gsub("'", "\\'") .. "'")
    else
        -- Fallback to default interpreter using vim.cmd and expand
        vim.cmd("let g:python3_host_prog = expand('" .. default_python_path .. "')")
    end
end

-- Call the function to dynamically set the Python interpreter
set_python_host_prog()


vim.cmd("let g:node_host_prog = expand('~/.nvm/versions/node/v20.12.2/bin/node')")

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
    vim.cmd [[
    syntax clear
    syntax match EnvComment "#.*" contains=@Spell
    syntax match EnvKey "^\s*\w\+" nextgroup=EnvSeparator
    syntax match EnvSeparator "=" contained nextgroup=EnvValue
    syntax match EnvValue "[\w@-]\+" contained

    highlight EnvComment ctermfg=Cyan guifg=Cyan
    highlight EnvKey ctermfg=White guifg=White
    highlight EnvSeparator ctermfg=Yellow guifg=Yellow
    highlight EnvValue ctermfg=Red guifg=Red
    ]]
end

-- Use vim.api.nvim_create_autocmd to set up the autocommand
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.env",
    callback = function()
        setup_env_syntax()
    end,
})

-- use the following to see what highlight group the text under the cursor is part of
-- :exe 'hi '.synIDattr(synstack(line('.'), col('.'))[-1], 'name')
