require("gitsigns").setup({
  signs = {
    add = { hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
    change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
    changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  yadm = {
    enable = false,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "GitSigns: next hunk" })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true, desc = "GitSigns: navigate hunk" })

    -- Actions
    map({ "n", "v" }, "<Leader>shs", "Gitsigns: stage_hunk<CR>")
    map({ "n", "v" }, "<Leader>shr", "Gitsigns: reset_hunk<CR>")
    map("n", "<Leader>sS", gs.stage_buffer, KeymapOptions("GitSigns: Stage buffer"))
    map("n", "<Leader>shu", gs.undo_stage_hunk, KeymapOptions("GitSigns: Unstage hunk"))
    map("n", "<Leader>shR", gs.reset_buffer, KeymapOptions("GitSigns: Reset buffer"))
    map("n", "<Leader>shp", gs.preview_hunk, KeymapOptions("Gitsigns: Preview hunk"))
    map("n", "<Leader>sb", gs.toggle_current_line_blame, KeymapOptions("GitSigns: blame current line"))
    map("n", "<Leader>sB", function() gs.blame_line({ full = true }) end, KeymapOptions("GitSigns: blame w/ preview"))
    map("n", "<Leader>sd", gs.diffthis, KeymapOptions("GitSigns: Diff current buffer"))
    map("n", "<Leader>sD", function() gs.diffthis("~") end, KeymapOptions("GitSigns: Diff ??"))
    map("n", "<Leader>st", gs.toggle_deleted, KeymapOptions("GitSigns: Toggle Deleted"))

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", KeymapOptions("GitSigns: select hunk"))
  end,
})
