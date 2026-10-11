-- Treesitter: highlighting, folds, indent and text objects (nvim-treesitter `main` branch).
-- `main` needs Neovim 0.12, plus the tree-sitter CLI (0.26.1+) and a C compiler to build
-- parsers. It has no modules: each buffer is started by the FileType autocmd below.

local ok, ts = pcall(require, "nvim-treesitter")
if not ok or type(ts.install) ~= "function" then
  vim.notify(
    "nvim-treesitter `main` not found (is the old `master` branch still checked out?). Run scripts/sync-plugins.",
    vim.log.levels.ERROR
  )
  return {}
end

-- `latex` is left out: nothing here uses its highlighting (vimtex has its own syntax).
local parsers = {
  "bash",
  "css",
  "fish",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- Install what is missing. Building a parser needs the tree-sitter CLI. Only built parsers
-- count: get_installed() also lists query directories, so a language whose parser is gone
-- would look installed, and force makes install() rebuild it.
local installed = {}
for _, lang in ipairs(ts.get_installed("parsers")) do
  installed[lang] = true
end
local missing = vim.tbl_filter(function(lang)
  return not installed[lang]
end, parsers)
if #missing > 0 then
  if vim.fn.executable("tree-sitter") == 1 then
    ts.install(missing, { force = true })
  else
    vim.notify(
      "tree-sitter CLI not found: cannot install treesitter parsers " .. table.concat(missing, ", "),
      vim.log.levels.WARN
    )
  end
end

-- zsh has no parser of its own; the bash parser is close enough.
vim.treesitter.language.register("bash", { "zsh" })

-- yaml and markdown keep their runtime indent scripts
local no_ts_indent = { yaml = true, markdown = true }
-- folds only where they were enabled before; markdown stays unfolded (vim-markdown.lua)
local fold_filetypes = { python = true, yaml = true, lua = true }

-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local textobjects_ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
if textobjects_ok then
  textobjects.setup({
    select = { lookahead = true },
    move = { set_jumps = true }, -- whether to set jumps in the jumplist
  })
end

local selects = {
  { "af", "@function.outer", "Function (outer)" },
  { "if", "@function.inner", "Function (inner)" },
  { "ac", "@class.outer", "Class (outer)" },
  { "ic", "@class.inner", "Class (inner)" },
}

local moves = {
  { "]m", "goto_next_start", "@function.outer", "Next function start" },
  { "]]", "goto_next_start", "@class.outer", "Next class start" },
  { "]M", "goto_next_end", "@function.outer", "Next function end" },
  { "][", "goto_next_end", "@class.outer", "Next class end" },
  { "[m", "goto_previous_start", "@function.outer", "Previous function start" },
  { "[[", "goto_previous_start", "@class.outer", "Previous class start" },
  { "[M", "goto_previous_end", "@function.outer", "Previous function end" },
  { "[]", "goto_previous_end", "@class.outer", "Previous class end" },
}

---Buffer-local textobject maps, so a runtime ftplugin's `]]` or `]m` cannot shadow them.
---@param buf integer
local function map_textobjects(buf)
  local select = require("nvim-treesitter-textobjects.select")
  local move = require("nvim-treesitter-textobjects.move")
  local swap = require("nvim-treesitter-textobjects.swap")
  for _, s in ipairs(selects) do
    vim.keymap.set({ "x", "o" }, s[1], function()
      select.select_textobject(s[2], "textobjects")
    end, { buffer = buf, desc = s[3] })
  end
  for _, m in ipairs(moves) do
    vim.keymap.set({ "n", "x", "o" }, m[1], function()
      move[m[2]](m[3], "textobjects")
    end, { buffer = buf, desc = m[4] })
  end
  vim.keymap.set("n", "<leader>tsa", function()
    swap.swap_next("@parameter.inner")
  end, { buffer = buf, desc = "Swap next parameter" })
  vim.keymap.set("n", "<leader>tsA", function()
    swap.swap_previous("@parameter.inner")
  end, { buffer = buf, desc = "Swap previous parameter" })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang or not vim.treesitter.language.add(lang) then
      return
    end
    if not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end
    if fold_filetypes[args.match] and vim.api.nvim_get_current_buf() == args.buf then
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo[0][0].foldlevel = 99
    end
    if not no_ts_indent[args.match] then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    -- only where a textobjects query exists; elsewhere the ftplugin's maps stay (sql `]]`)
    if textobjects_ok and vim.treesitter.query.get(lang, "textobjects") then
      map_textobjects(args.buf)
    end
  end,
})

vim.keymap.set("n", "<leader>tc", "<cmd>Inspect<CR>", { desc = "Treesitter: highlight groups under cursor" })
vim.keymap.set("n", "<leader>tp", "<cmd>InspectTree<CR>", { desc = "Treesitter: inspect syntax tree" })

return { parsers = parsers }
