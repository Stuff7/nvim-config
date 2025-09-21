local script_path = debug.getinfo(1, "S").source:sub(2) -- remove the "@" prefix
local script_dir = script_path:match("(.*/)")
if not script_dir then script_dir = "./" end

package.path = script_dir .. "?.lua;" .. package.path

vim.pack.add({
  'https://github.com/Mofiqul/vscode.nvim.git',
  'https://github.com/Wansmer/treesj.git',
  'https://github.com/akinsho/bufferline.nvim.git',
  'https://github.com/kylechui/nvim-surround.git',
  'https://github.com/lewis6991/gitsigns.nvim.git',
  'https://github.com/mattn/emmet-vim.git',
  'https://github.com/neovim/nvim-lspconfig.git',
  'https://github.com/numToStr/Comment.nvim.git',
  'https://github.com/nvim-lua/plenary.nvim.git',
  'https://github.com/nvim-lualine/lualine.nvim.git',
  'https://github.com/nvim-telescope/telescope.nvim.git',
  'https://github.com/nvim-tree/nvim-web-devicons.git',
  'https://github.com/nvim-treesitter/nvim-treesitter.git',
  'https://github.com/williamboman/mason.nvim.git',
  'https://github.com/windwp/nvim-autopairs.git',
})

dofile(script_dir .. "remap.lua")
dofile(script_dir .. "autocomplete.lua")
dofile(script_dir .. "lspconfig.lua")
dofile(script_dir .. "theme.lua")
