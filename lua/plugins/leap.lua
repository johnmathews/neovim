-- Leap: Lightning-fast motion plugin for jumping to any location
-- Set up custom mappings instead of using default ones to avoid conflicts
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

-- Note: x and X mappings are not set up to avoid conflicts with Visual mode
-- If you need them, you can set them up manually:
-- vim.keymap.set({ 'x', 'o' }, 'x', '<Plug>(leap-forward)')
-- vim.keymap.set({ 'x', 'o' }, 'X', '<Plug>(leap-backward)')

-- https://github.com/ggandor/leap.nvim/issues/103
-- https://github.com/ggandor/leap.nvim/blob/7140feed70a5911b8c8a7eb9c218d198772f69cf/doc/leap.txt#L430-L431
-- leap.leap{ offset= 2}
