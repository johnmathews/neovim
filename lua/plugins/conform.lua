local conform = require("conform")
conform.setup({
  notify_on_error = true,
  -- Filetypes with no conform formatter use the LSP server's formatter
  default_format_opts = { lsp_format = "fallback" },

  format_on_save = function(bufnr)
    -- Don’t auto-format huge files
    local max = 200 * 1024
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if ok and stats and stats.size > max then
      return nil
    end
    -- sqlfluff is too slow for the save timeout: format SQL with <leader>cf
    if vim.bo[bufnr].filetype == "sql" then
      return nil
    end
    return { timeout_ms = 1000 }
  end,

  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" }, -- fast, modern Python formatter (handles black's functionality)
    javascript = { "biome" }, -- fast, modern JS/TS formatter and linter
    typescript = { "biome" },
    json = { "biome", "jq" },
    yaml = { "yamlfmt" },
    markdown = { "prettierd" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    toml = { "taplo" },
    sql = { "sqlfluff" }, -- manual only, see format_on_save
  },

  -- Prefer project-local binaries where possible
  formatters = {
    prettierd = {
      prepend_args = function(_self, ctx)
        local prose_wrap = vim.b[ctx.buf].markdown_print_mode and "never" or "always"
        return {
          "--parser=markdown",
          "--prose-wrap=" .. prose_wrap,
          "--print-width=121",
        }
      end,
    },
    -- sqlfluff refuses to run without a dialect. A .sqlfluff file sets it; otherwise
    -- default to postgres (bigquery for .bq). Exit code 1 means "fixed, but some
    -- violations remain", which still produced formatted output.
    sqlfluff = {
      require_cwd = false,
      exit_codes = { 0, 1 },
      args = function(_self, ctx)
        local args = { "fix", "--stdin-filename", "$FILENAME" }
        if not vim.fs.root(ctx.dirname, { ".sqlfluff" }) then
          vim.list_extend(args, { "--dialect", ctx.filename:match("%.bq$") and "bigquery" or "postgres" })
        end
        table.insert(args, "-")
        return args
      end,
    },
  },
})

-- Optional mapping
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true })
end, { desc = "Format file/range" })
