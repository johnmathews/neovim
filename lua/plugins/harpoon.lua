-- Harpoon: Quick file navigation and marking for frequently used files

require("harpoon").setup({
  menu = {
    width = 100,
  },
})

local map = vim.api.nvim_set_keymap

map("n", "gm", ":lua require('harpoon.mark').add_file()<CR>:echom 'added to Harpoon'<CR>", KeymapOptions("Harpoon Add"))
map("n", "gh", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", KeymapOptions("Harpoon Toggle")) -- use telescope
map("n", "gn", ":lua require('harpoon.ui').nav_next()<CR>", KeymapOptions("Harpoon Next"))
map("n", "gp", ":lua require('harpoon.ui').nav_prev()<CR>", KeymapOptions("Harpooon Previous"))
map("n", "<Tab>1", ":lua require('harpoon.ui').nav_file(1)<CR>", KeymapOptions("Harpoon buffer"))
map("n", "<Tab>2", ":lua require('harpoon.ui').nav_file(2)<CR>", KeymapOptions("Harpoon buffer"))
map("n", "<Tab>3", ":lua require('harpoon.ui').nav_file(3)<CR>", KeymapOptions("Harpoon buffer"))
map("n", "<Tab>4", ":lua require('harpoon.ui').nav_file(4)<CR>", KeymapOptions("Harpoon buffer"))
map("n", "<Tab>5", ":lua require('harpoon.ui').nav_file(5)<CR>", KeymapOptions("Harpoon buffer"))
