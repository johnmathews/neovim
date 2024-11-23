-- https://dockyard.com/blog/2018/06/01/simple-vim-session-management-part-1
-- this is a custom variable to be used with a custom command defined in the linked article
vim.g.session_dir = "~/.config/nvim/sessions/"

-- recommended
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("auto-session").setup {
  -- log_level = "debug",
  auto_save = true,
  bypass_save_filetypes = { "NvimTree" },
  pre_save_cmds = { "NvimTreeClose" },
  session_lens = {
    previewer = false,
    theme_conf = {
      border = true
    }
  },
  suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" }
}

vim.cmd [[
  let g:auto_session_pre_save_cmds = ["tabdo NvimTreeClose"]
]]


-- this stops sessions from being loaded automatically
-- vim.cmd("let g:auto_session_enabled = v:false")
