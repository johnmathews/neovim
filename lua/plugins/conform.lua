local conform = require("conform")
conform.setup({
  notify_on_error = true,

  format_on_save = function(bufnr)
    -- Don’t auto-format huge files
    local max = 200 * 1024
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if ok and stats and stats.size > max then
      return nil
    end
    return { timeout_ms = 1000, lsp_fallback = true }
  end,

  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" }, -- fast, modern Python formatter (handles black's functionality)
    javascript = { "biome" }, -- fast, modern JS/TS formatter and linter
    typescript = { "biome" },
    json = { "biome", "jq" },
    yaml = { "yamlfmt", "lsp" },
    markdown = { "prettierd" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    toml = { "taplo" },
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
  },
})

-- Optional mapping
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file/range" })
