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

  -- Autocomplete
  'https://github.com/hrsh7th/nvim-cmp.git',
  'https://github.com/hrsh7th/cmp-nvim-lsp.git',
  'https://github.com/hrsh7th/cmp-buffer.git',
  'https://github.com/L3MON4D3/LuaSnip.git',
  'https://github.com/saadparwaiz1/cmp_luasnip.git',
})

dofile(script_dir .. "remap.lua")
dofile(script_dir .. "cmp.lua")
dofile(script_dir .. "lspconfig.lua")
dofile(script_dir .. "theme.lua")

-- Check for LSP_LOG environment variable and enable logging if present
do
  local log_file = vim.env.LSP_LOG or os.getenv("LSP_LOG")

  if log_file and log_file ~= "" then
    local ok, lsp_logger = pcall(require, 'lsp_logger')
    if ok and lsp_logger.setup then
      lsp_logger.setup(log_file)
      vim.notify("LSP logging enabled: " .. log_file, vim.log.levels.INFO)
    else
      vim.notify("Failed to load lsp_logger.lua", vim.log.levels.ERROR)
    end
  end
end
