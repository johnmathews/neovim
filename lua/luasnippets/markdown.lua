local snip_status_ok, ls = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
-- local r = ls.restore_node
-- local l = require("luasnip.extras").lambda
-- local rep = require("luasnip.extras").rep
-- local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local conds = require("luasnip.extras.expand_conditions")

local date = function()
  return { os.date("%Y-%m-%d %H:%M:%S") }
end

local slugify = function(args, _)
  local text = args[1][1]
  text = string.lower(text)
  text = string.gsub(text, "[%p%c]", "")
  text = string.gsub(text, "^%s*(.-)%s*$", "%1")
  text = string.gsub(text, "[%s]", "-")
  return text
end

local catChooser = function(args, snip, table)
  if args[1][1] == "Technical/" then
    return c(3, {
      t("Developer Tools"),
      t("Data"),
      t("Web"),
      t("Other"),
      t("Cryptocurrencies"),
      t("Engineering"),
    })
  else
    return c(3, {
      t("Photographs"),
      t("Entrepreneurship"),
      t("Journal"),
      t("Learning"),
      t("Social"),
      t("Other"),
    })
  end
end

-- for choice nodes, use <C-j> and <C-k> to toggle through the options
-- see mappings.lua:105
return {
  s("meta", {
    t({ "---" }),
    t({ "", "title: " }),
    i(1),
    t({ "", "date: " }),
    f(date, {}),
    t({ "", "category: " }),
    c(2, {
      {
        -- put an insertNode here so it's possible
        -- to change the outer choice.
        -- (without it, the cursor would always jump
        -- directly into the inner choiceNode).
        i(1),
        t("Technical/"),
        c(2, {
          t("Developer Tools"),
          t("Data"),
          t("Web"),
          t("Other"),
          t("Cryptocurrencies"),
          t("Engineering"),
        }),
      },
      {
        i(1),
        t("Non-technical/"),
        c(2, {
          t("Photographs"),
          t("Entrepreneurship"),
          t("Journal"),
          t("Learning"),
          t("Social"),
          t("Other"),
        }),
      },
      {
        i(1),
        t("snippet"),
      },
    }),
    t({ "", 'tags: ["' }),
    i(3),
    t({ '"]' }),
    t({ "", "" }),
    t({ "---" }),
    t({ "", "" }),
    t({ "", "" }),
    i(0),
  }),

  s("snip", {
    t({ "---" }),
    t({ "", "title: " }),
    i(1),
    t({ "", "date: " }),
    f(date, {}),
    t({ "", "category: snippet " }),
    t({ "", 'tags: ["' }),
    i(2),
    t({ '"]' }),
    t({ "", "---" }),
    t({ "", "" }),
    t({ "", "" }),
    i(3),
  }),


  s({
    dscr = "links to an internal page",
    name = "article link link",
    trig = "internal-link",
  }, {
    t({ "[" }),
    i(1, "<text>"),
    t({ "](" }),
    i(2, "<slug>"),
    t({ ") " }),
  }),

  s({
    dscr = "download a link",
    name = "download link",
    trig = "external-link",
  }, {
    t({ "[" }),
    i(1, "<text>"),
    t({ "](" }),
    i(2, "<url>"),
    t({ ") " }),
  }),

  s({
    dscr = "download a file",
    name = "file download",
    trig = "dl",
  }, {
    t({ "[" }),
    i(1, "<text>"),
    t({ "](/documents/" }),
    i(2, "<file-name>"),
    t({ ") " }),
  }),

  s({
    dscr = "download a big (100mb+) file",
    name = "download from bucket",
    trig = "dlb",
  }, {
    t({ "[" }),
    i(1, "<text>"),
    t({ "](https://us-east1-johnmathews-website.cloudfunctions.net/download?obj=" }),
    i(2, "<text>"),
    t({ ") " }),
  }),

  s({
    namr = "link to GCS asset",
    dscr = "link to GCS asset",
    trig = "gcs",
  }, {
    t({ "[archive](https://us-east1-johnmathews-website.cloudfunctions.net/download?obj=movies/" }),
    i(1, "<text>"),
    t({ ".mp4) " }),
  }),

  s({
    namr = "image embed",
    dscr = "embed an image (not clickable)",
    trig = "image-embed",
  }, {
    t({ "![" }),
    i(1, "<text>"),
    t({ "](/static/images/" }),
    i(2, "<text>"),
    t({ ") " }),
  }),

  s({
    namr = "clickable image link",
    dscr = "insert a clickable image",
    trig = "clickable-image-embed",
  }, {
    t({ "[![" }),
    i(1, "<text>"),
    t({ "](/static/images/" }),
    i(2, "<text>"),
    t({ ")](/static/images/" }),
    d(3, function(args) return sn(nil, {i(2, args[1])}) end, {2}),
    t({ ')' }),
  }),

  s({
    namr = "superscript",
    dscr = "superscript text",
    trig = "superscript",
  }, {
    t({ "$^{" }),
    i(1, "<text>"),
    t({ "}$ " }),
  }),

  s({
    namr = "bible verse",
    dscr = "highlighted bible verse with superscript",
    trig = "verse",
  }, {
    t({ "$^{" }),
    i(1, "verse number"),
    t({ "}$<mark>" }),
    i(2, "text here"),
    t({ "</mark> " }),
  }),

  s({
    namr = "highlight",
    dscr = "highlighted (marked) text tag",
    trig = "highlight",
  }, {
    t({ "<mark>" }),
    i(1, "text here"),
    t({ "</mark> " }),
  }),

  s({
    namr = "comment",
    dscr = "comment text",
    trig = "comment",
  }, {
    t({ "", "[comment]: # (" }),
    i(1),
    t({ ") " }),
  }),

  s({
    namr = "youtube movie",
    dscr = "embed responsive iframe, type='youtube|amazon'",
    trig = "if",
  }, {
    t({
      "import IframeEmbed from '../components/IframeEmbed'",
      "",
      "<IframeEmbed type='youtube' src='https://youtube.com/embed/"
    }),
    i(1, "<URL>"),
    t({
      "' />"
    }),
  }),
}
