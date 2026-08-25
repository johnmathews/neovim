-- Noice: Enhanced UI for messages, cmdline, and popups
local ok, noice = pcall(require, "noice")
if not ok then
  return
end

noice.setup({
  cmdline = {
    format = {
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
    },
  },
  lsp = {
    progress = { enabled = true },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  messages = {
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_search = false,
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    lsp_doc_border = true,
  },
  views = {
    cmdline_popup = {
      border = {
        style = "rounded",
      },
      position = {
        row = "30%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
      win_options = {
        -- Keep the cmdline popup fully opaque so buffer text does not bleed through
        winblend = 0,
        winhighlight = "Normal:NoiceCmdlinePopup,FloatBorder:NoiceCmdlinePopupBorder",
      },
    },
    popupmenu = {
      relative = "editor",
      position = {
        row = "40%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
      },
      win_options = {
        winblend = 10,
      },
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
        find = "written",
      },
      opts = { skip = true },
    },
  },
})

-- Ensure the cmdline popup has a solid, opaque background so buffer text does
-- not bleed through. Applied on ColorScheme so it survives theme reloads.
local function set_noice_cmdline_hl()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal and normal.bg
  if not bg then
    return
  end
  local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
  local border_fg = (border and border.fg) or normal.fg
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = bg, fg = normal.fg })
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = bg, fg = border_fg })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg, fg = normal.fg })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = bg, fg = border_fg })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("NoiceCmdlineOpaque", { clear = true }),
  callback = set_noice_cmdline_hl,
})

-- Apply immediately in case the colorscheme is already loaded.
set_noice_cmdline_hl()
