local script_path = debug.getinfo(1, "S").source:sub(2) -- remove the "@" prefix
local script_dir = script_path:match("(.*/)")
if not script_dir then script_dir = "./" end

local level = vim.env.NVIM_LSP_LOG_LEVEL or "warn"
vim.lsp.log.set_level(level)

local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
vim.env.PATH = mason_path .. ":" .. vim.env.PATH

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
  { src = 'https://github.com/Stuff7/nvim-treesitter.git', version = 'latest' },
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

do
  local log_file = vim.env.LSP_LOG or os.getenv("LSP_LOG")
  local outgoing_file = vim.env.LSP_LOG_OUTGOING or os.getenv("LSP_LOG_OUTGOING")

  if (log_file and log_file ~= "") or (outgoing_file and outgoing_file ~= "") then
    local ok, lsp_logger = pcall(require, 'lsp_logger')
    if ok and lsp_logger.setup then
      lsp_logger.setup(log_file, outgoing_file)
    else
      vim.notify("Failed to load lsp_logger.lua", vim.log.levels.ERROR)
    end
  end
end
