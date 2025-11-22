local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  print("lazy not found")
  vim.notify("lazy not found")
  return
end

return lazy.setup({
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },
  { "dstein64/vim-startuptime" },
  { "gioele/vim-autoswap" },

  -- WIP my plugin to show git stats when you open a project
  {
    dir = "/Users/john/projects/neovim-dashboard",
    name = "project-dashboard.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("project-dashboard").setup({
        auto_open = false,
        show_timing = true,
        github = {
          enabled = true,
          timeout = 5000,
        },
        layout = {
          margin_x = 12, -- more padding from edges
          margin_y = 2, -- more top/bottom padding
          max_width = 0.5,
        },
        tiles = {
          gap_x = 4, -- wider gaps between tiles
          gap_y = 1, -- tight vertical spacing
          background = true,
          border_style = "rounded",
        },
      })
    end,
    event = "VimEnter",
  },

  -- dont open a file accidentally in the filetree or preview window
  { "stevearc/stickybuf.nvim" },

  {
    -- https://github.com/cpea2506/one_monokai.nvim
    "cpea2506/one_monokai.nvim",
    config = function()
      require("plugins.one_monokai")
    end,
  },
  {
    "folke/which-key.nvim",
    config = function()
      require("plugins.whichkey")
    end,
  },
  {
    "goolord/alpha-nvim",
    event = "VimEnter", -- Lazy-load dashboard on startup (after other plugins)
    config = function()
      require("plugins.alpha")
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("plugins.project")
    end,
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("plugins.notify")
    end,
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.dressing")
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("plugins.noice")
    end,
  },

  {
    "rmagatti/auto-session",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "rmagatti/session-lens",
    },
    config = function()
      require("plugins.auto-session")
      pcall(function()
        require("plugins.telescope").load_extension("session-lens")
      end)
    end,
  },

  -- copy text to the system clipboard using the ANSI OSC52 sequence.
  {
    "ojroques/vim-oscyank",
  },

  -- resizing windows
  {
    "simeji/winresizer",
    config = function()
      vim.cmd([[let g:winresizer_keycode_finish=96 ]])
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope-smart-history.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = { "<Tab>" }, -- Lazy-load on first Tab keypress (all telescope keymaps use <Tab> prefix)
    cmd = "Telescope", -- Also load on :Telescope command
    config = function()
      require("plugins.telescope")
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },

  {
    "ThePrimeagen/harpoon",
    dependencies = "nvim-lua/plenary.nvim",
    keys = { "ga", "gh", "gn", "gp" }, -- Lazy-load on harpoon keybinds
    config = function()
      require("plugins.harpoon")
    end,
  },

  -- the statusline at the bottom
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "WhoIsSethDaniel/lualine-lsp-progress.nvim",
    },
    event = "VeryLazy", -- Defer statusline to after UI is ready
    config = function()
      require("plugins.lualine")
    end,
  },

  -- comments
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      require("plugins.comment")
    end,
  },

  -- lsp status indicator, because maybe the lualine one is broken?
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require("fidget").setup({
        align = {
          bottom = false, -- align fidgets along bottom edge of buffer
          right = true, -- align fidgets along right edge of buffer
        },
      })
    end,
  },

  {
    "SmiteshP/nvim-navic",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      require("plugins.navic")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("plugins.lsp") -- <- this loads lua/plugins/lsp.lua
    end,
  },
  -- Load Mason early and configure in your existing plugins/mason.lua
  {
    "williamboman/mason.nvim",
    lazy = false, -- ensure it's available before anything depending on it
    priority = 1000, -- load very early
    config = function()
      require("plugins.mason") -- your mason.lua already calls mason.setup() and mason-lspconfig.setup()
    end,
  },

  -- Bridge Mason <-> LSP (no opts here; setup happens in plugins/mason.lua)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  {
    "smjonas/inc-rename.nvim",
    opts = {},
  },

  -- (Optional) DAP bridge, no duplicate mason spec
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
  },

  -- Formatters and linters are handled by conform.nvim and nvim-lint
  {
    "stevearc/conform.nvim",
    config = function()
      require("plugins.conform")
    end,
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("plugins.nvim-lint")
    end,
  },

  { "ray-x/lsp_signature.nvim", dependencies = "neovim/nvim-lspconfig" },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  -- use instead of LSPSaga outline
  {
    "stevearc/aerial.nvim",
    opts = {},
    config = function()
      require("plugins.aerial")
    end,
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- buffers and window management
  {
    "marklcrns/vim-smartq",
    config = function()
      require("plugins.smartq")
    end,
    init = function()
      -- Set the variable before the plugin loads, otherwise it has no effect.
      vim.g.smartq_default_mappings = 0
    end,
  },

  {
    "Asheq/close-buffers.vim",
    config = function()
      require("plugins.close-buffers")
    end,
  },

  {
    "nvim-mini/mini.nvim",
    version = false,
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    config = function()
      require("plugins.minimap")
    end,
  },

  -- completions
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Lazy-load completion on entering insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "lukas-reineke/cmp-under-comparator",
    },
    config = function()
      require("cmp")
    end,
  },

  -- snippets engine
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter", -- Lazy-load snippets on entering insert mode
    build = "make install_jsregexp",
    config = function()
      require("plugins.luasnip")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
    dependencies = {
      "nvim-treesitter/playground",
      -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- this is an (unmaintained) treesitter plugin.
      -- config is in the `rainbow` attribute in treesitter.lua
      "HiPhish/rainbow-delimiters.nvim",
      -- "p00f/nvim-ts-rainbow",
    },
    event = "bufread",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
  },

  -- autoclose and autorename html tags (html,tsx,vue,svelte,php,rescript)
  -- this is a treesitter plugin. config is the `autotag` attribute in treesitter.lua
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function()
      require("plugins.autopairs")
    end,
    event = "InsertEnter",
  },

  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("plugins.toggleterm")
    end,
    event = "VimEnter",
  },

  {
    "tpope/vim-dadbod",
    lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      require("plugins.dadbod").setup()
    end,
    cmd = {
      "DBUIToggle",
      "DBUI",
      "DBUIAddConnection",
      "DBUIFindBuffer",
      "DBUIRenameBuffer",
      "DBUILastQueryInfo",
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre", -- Lazy-load when reading a file
    config = function()
      require("plugins.git-signs")
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup({
        -- The scope is *not* the current indentation level! Instead, it is the
        -- indentation level where variables or functions are accessible. This depends
        -- on the language you are writing.
        scope = {
          enabled = false,
          show_start = false,
          show_end = false,
        },
      })
    end,
  },

  {
    "gaoDean/autolist.nvim",
    ft = {
      "markdown",
      "text",
      "tex",
      "plaintex",
      "norg",
    },
    config = function()
      require("autolist").setup()

      vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
      vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
      -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
      -- vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
      -- vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
      -- vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
      -- vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
      -- vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

      -- cycle list types with dot-repeat
      vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
      vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

      -- if you don't want dot-repeat
      -- vim.keymap.set("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
      -- vim.keymap.set("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")

      -- functions to recalculate list on edit
      vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
      vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
      vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
      vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
    end,
  },

  -- used only because it can format yaml frontmatter in a markdown blog post
  {
    "preservim/vim-markdown",
    dependencies = {
      "godlygeek/tabular",
    },
    config = function()
      require("plugins.vim-markdown")
    end,
  },

  -- Beautiful markdown preview in terminal
  {
    "ellisonleao/glow.nvim",
    ft = { "markdown" }, -- Only load for markdown buffers
    cmd = "Glow", -- Also load on :Glow command
    keys = {
      {
        "<leader>mg",
        function()
          vim.cmd("Glow")
        end,
        desc = "Markdown: preview with Glow",
      },
    },
    config = function()
      require("plugins.glow")
    end,
  },

  {
    "simnalamburt/vim-mundo",
    config = function()
      require("plugins.mundo")
    end,
  },

  { "MisanthropicBit/vim-numbers" },

  {
    "tyru/open-browser.vim",
    config = function()
      require("plugins.open-browser")
    end,
  },

  --  interacting with and manipulating Vim marks
  {
    "chentoast/marks.nvim",
    config = function()
      require("plugins.marks")
    end,
  },

  -- adds various text objects to give you more targets to operate on
  { "wellle/targets.vim" },

  -- movement, like sneak
  {
    "ggandor/leap.nvim",
    config = function()
      require("plugins.leap")
    end,
  },

  -- search enhancements with customizable virtual text
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("plugins.hlslens")
    end,
  },

  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  { "tpope/vim-unimpaired" },

  { "chrisbra/csv.vim" },

  {
    "vim-test/vim-test",
    config = function()
      require("plugins.vim-test")
    end,
    dependencies = {
      "skywind3000/asyncrun.vim",
    },
  },

  { "hashivim/vim-vagrant" },

  -- highlight matching tags in html, js, jsx, vue, svelte
  {
    "leafOfTree/vim-matchtag",
    config = function()
      require("plugins.vim-matchtag")
    end,
  },

  -- alloy filetype
  { "grafana/vim-alloy" },

  -- syntax highlighting for coffeeScript
  { "kchmck/vim-coffee-script" },

  -- syntax highlighting for requirements.txt files
  { "raimon49/requirements.txt.vim" },
  {
    "pearofducks/ansible-vim",
    config = function()
      require("plugins.ansible-vim")
    end,
  },

  -- file explorer
  -- https://github.com/nvim-tree/nvim-tree.lua/commits/master
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("plugins.nvim-tree")
    end,
    event = "VeryLazy",
  },

  -- COLORS + colorschemes

  -- show hexcodes etc with a bg that matches the color they represent
  -- off by default, use :ColorHighlight! to toggle. see :h colorizer
  { "chrisbra/Colorizer" },

  -- required by several plugins
  -- " " toml icon ,
  {
    "nvim-tree/nvim-web-devicons",
    -- config = function()
    --   require("nvim-web-devicons").set_icon {
    --     toml = {
    --       icon = "",
    --       color = "#6d8086",
    --       name = "Toml"
    --     },
    --   }
    -- end,
  },
})
