local snip_status_ok, ls = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

local snip = ls.snippet
local node = ls.snippet_node
local text = ls.text_node
local insert = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

local date = function()
  return { os.date("%Y-%m-%d %H:%M:%S") }
end

-- for choice nodes, use <C-j> and <C-k> to toggle through the options
-- see luasnip.lua:125
return {
  snip("shebang", {
    text({ "#!/usr/bin/lua", "", "" }),
    insert(0),
  }),
  snip("req", {
    text("require('"),
    insert(1, "Module-name"),
    text("')"),
    insert(0),
  }),
  snip("func", {
    text("function("),
    insert(1, "Arguments"),
    text({ ")", "\t" }),
    insert(2),
    text({ "", "end", "" }),
    insert(0),
  }),
  snip("forp", {
    text("for "),
    insert(1, "k"),
    text(", "),
    insert(2, "v"),
    text(" in pairs("),
    insert(3, "table"),
    text({ ") do", "\t" }),
    insert(4),
    text({ "", "end", "" }),
    insert(0),
  }),
  snip("fori", {
    text("for "),
    insert(1, "k"),
    text(", "),
    insert(2, "v"),
    text(" in ipairs("),
    insert(3, "table"),
    text({ ") do", "\t" }),
    insert(4),
    text({ "", "end", "" }),
    insert(0),
  }),
  snip("if", {
    text("if "),
    insert(1),
    text({ " then", "\t" }),
    insert(2),
    text({ "", "end", "" }),
    insert(0),
  }),
  snip("M", {
    text({ "local M = {}", "", "" }),
    insert(0),
    text({ "", "", "return M" }),
  }),
}
