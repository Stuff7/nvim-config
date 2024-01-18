vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  -- System
  use "wbthomason/packer.nvim"
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use { "nvim-telescope/telescope.nvim", tag = "0.1.4", requires = { {"nvim-lua/plenary.nvim"} } }

  -- UI
  use "Mofiqul/vscode.nvim" -- Colorscheme
  use "nvim-tree/nvim-web-devicons" -- Icons
  use "akinsho/bufferline.nvim" -- Tabs
  use "nvim-tree/nvim-tree.lua" -- File explorer
  use { -- Status bar
    "nvim-lualine/lualine.nvim",
    requires = { "nvim-tree/nvim-web-devicons", opt = true },
  }

  -- Code
  use "numToStr/Comment.nvim" -- Toggle selection into comment with gc
  use "rust-lang/rust.vim"
  use "lewis6991/gitsigns.nvim" -- Git gutters
  use "ggandor/leap.nvim" -- Code navigation
  use { "kylechui/nvim-surround", tag = "*" }
  use "cohama/lexima.vim" -- Auto close brackets
  use { "Wansmer/treesj", requires = { "nvim-treesitter/nvim-treesitter" } } -- Toggle blocks inline/expanded

  -- LSP
  use {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" }, -- LSP manager
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
    }
  }
end)
