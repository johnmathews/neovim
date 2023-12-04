local M = {}

function M.asyncGitCommitAndPush(commitMessage)
  if commitMessage == nil or commitMessage == '' then
    commitMessage = "background commit" -- Default commit message
  end

  vim.loop.spawn('git', {
    args = { 'rev-parse', '--is-inside-work-tree' },
    cwd = vim.loop.cwd(),
  }, function(code)
    if code ~= 0 then
      vim.schedule(function()
        vim.api.nvim_out_write("Can't commit, not in a git repository\n")
      end)
      return
    end

    vim.schedule(function()
      vim.fn.system('git add .')
      vim.fn.system('git commit -m "' .. commitMessage .. '"')
      vim.fn.system('git push')
      vim.api.nvim_out_write('git commit --all --message "' .. commitMessage .. '"\n')
    end)
  end)
end

-- convert ascii typographuc quotes to normal quotes including slanty quotes,
function M.Convert_smart_and_fancy_ascii_chars_to_normal_chars()
  vim.cmd([[
    exe 'normal! ma' | %!iconv -f utf-8 -t ascii//translit | if search('pattern') == 0 | exe 'normal! `a' | endif
  ]])
end

-- toggle the quickfix window
-- in mappings.lua gq is mapped to this
vim.cmd [[
  function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen 15
      setlocal norelativenumber
    else
      cclose
    endif
  endfunction
]]

-- blog post
vim.cmd [[
function! s:NewPost(fn)
  execute "e " . "~/projects/blog/data/blog/" . a:fn . ".md"
endfunction
command! -nargs=1 Mp call s:NewPost(<q-args>)
]]

-- clear registers and overwrite shada file so that register state is persisted
vim.cmd [[
function! ClearAllRegisters()
    let regs='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-="*+'
    let i=0
    while (i<strlen(regs))
        exec 'let @'.regs[i].'=""'
        let i=i+1
    endwhile
    wsh!
    echom "cleared all registers. Inspect with :reg"
endfunction

command! ClearAllRegisters call ClearAllRegisters()
]]

vim.cmd [[
function! ClearLetterRegisters()
    let regs='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    let i=0
    while (i<strlen(regs))
        exec 'let @'.regs[i].'=""'
        let i=i+1
    endwhile
    wsh!
    echom "cleared letter registers. Inspect with :reg"
endfunction

command! ClearLetterRegisters call ClearLetterRegisters()
]]

vim.cmd [[
function! ClearNumberRegisters()
    let regs='0123456789'
    let i=0
    while (i<strlen(regs))
        exec 'let @'.regs[i].'=""'
        let i=i+1
    endwhile
    wsh!
    echom "reset registers 1 - 9. Inspect with :reg"
endfunction

command! ClearNumberRegisters call ClearNumberRegisters()
]]

return M
