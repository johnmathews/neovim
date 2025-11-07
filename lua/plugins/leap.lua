local leap = require("leap")
leap.add_default_mappings()

-- see the FAQ
vim.keymap.del({ "x", "o" }, "x")
vim.keymap.del({ "x", "o" }, "X")

-- https://github.com/ggandor/leap.nvim/issues/103
-- https://github.com/ggandor/leap.nvim/blob/7140feed70a5911b8c8a7eb9c218d198772f69cf/doc/leap.txt#L430-L431
-- leap.leap{ offset= 2}
