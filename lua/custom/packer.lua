-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
	-- System
	use "wbthomason/packer.nvim"
	use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
	use { "nvim-telescope/telescope.nvim", tag = "0.1.4", requires = { {"nvim-lua/plenary.nvim"} } }

	-- Colorschemes
	use "EdenEast/nightfox.nvim"
	use "Mofiqul/vscode.nvim"

	-- Icons
	use "nvim-tree/nvim-web-devicons"

	-- UI
	use "akinsho/bufferline.nvim"
	use "nvim-tree/nvim-tree.lua"
	use { "nvim-lualine/lualine.nvim", requires = { "nvim-tree/nvim-web-devicons", opt = true } }

	-- Code
	use "numToStr/Comment.nvim"
	use "rust-lang/rust.vim"
	use "lewis6991/gitsigns.nvim"
  use "ggandor/leap.nvim"
  use { "kylechui/nvim-surround", tag = "*" }
  use "cohama/lexima.vim"
  use { "Wansmer/treesj", requires = { "nvim-treesitter/nvim-treesitter" } }
	-- use {"arzg/vim-rust-syntax-ext", rtp = "after/syntax/rust.vim"}

	-- LSP
	use {
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		}
	}
end)
