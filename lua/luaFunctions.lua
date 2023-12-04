local M = {}

function M.asyncGitCommitAndPush(commitMessage)

    if commitMessage == nil or commitMessage == '' then
        commitMessage = "background commit"  -- Default commit message
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
            vim.api.nvim_out_write('git commit -m "' .. commitMessage .. '"\n')
        end)
    end)
end

-- convert ascii typographuc quotes to normal quotes including slanty quotes,
function M.Convert_smart_and_fancy_ascii_chars_to_normal_chars()
  vim.cmd([[
    exe 'normal! ma' | %!iconv -f utf-8 -t ascii//translit | if search('pattern') == 0 | exe 'normal! `a' | endif
  ]])
end

print("Smoke 2")
return M