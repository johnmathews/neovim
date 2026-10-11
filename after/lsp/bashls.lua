-- Bash: overrides merged over nvim-lspconfig's lsp/bashls.lua
-- bashls runs shellcheck itself (when it is on PATH) and owns sh, bash and zsh diagnostics
-- (zsh from bash-language-server 5.8, which shellchecks it as bash).
return {
  filetypes = { "sh", "bash", "zsh" }, -- Attach to sh, bash, and zsh files
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
      shellcheckArguments = { "-x" }, -- follow sourced files (optional)
    },
  },
}
