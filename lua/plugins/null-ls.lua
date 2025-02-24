local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  print("null-ls not found")
  return
end

-- BUILTIN DOCS
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
null_ls.setup({
  debug = false,
  sources = {

    -- XML
    null_ls.builtins.formatting.xmllint,
    null_ls.builtins.formatting.tidy.with({
      filetypes = { "xml" },
      extra_args = { "--quiet", "--show-warnings", "--show-errors", "--show-info" },
    }),
    null_ls.builtins.diagnostics.tidy.with({
      filetypes = { "xml" },
      extra_args = { "--quiet", "--show-warnings", "--show-errors", "--show-info" },
    }),

    -- shell, zsh, bash
    null_ls.builtins.formatting.shellharden,
    null_ls.builtins.formatting.shfmt,

    --  Prettier formatting works on Markdown, JavaScript, TypeScript, JSX, yaml
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "yaml", "yml", "css", "html", "scss", "less", "markdown", "markdown.mdx", "JSX", "javascript", "typescript", "typescriptreact", "javascriptreact" },
      extra_args = { "--prose-wrap", "always" },
    }),

    -- yaml formatters
    null_ls.builtins.formatting.yamlfix,
    null_ls.builtins.formatting.yamlfmt,

    -- ESLint https://github.com/mantoni/eslint_d.js
    -- this might not be necessary in addition to prettier
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.formatting.eslint_d,

    -- PYTHON
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
    -- null_ls.builtins.diagnostics.pyproject_flake8,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.autoflake,
    null_ls.builtins.formatting.black.with({
      -- extra_args = { "--line-length=120" }
    }), -- use pyproject.toml for modifications

    -- SQL
    null_ls.builtins.formatting.sqlfluff.with({
      extra_args = { "--dialect", "postgres" }, -- change to your dialect
    }),
    -- null_ls.builtins.diagnostics.sqlfluff.with({
    --   extra_args = { "--dialect", "postgres" },   -- change to your dialect
    -- }),
  },
})
