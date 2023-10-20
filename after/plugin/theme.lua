-- Status bar
require("lualine").setup()

-- Tabs
require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "center",
				separator = true
			}
		}
	}
})

-- File Explorer
require("nvim-tree").setup()

-- Colorscheme
local c = require("vscode.colors").get_colors()
require("vscode").setup({
	transparent = true,
	italic_comments = true,
	disable_nvimtree_bg = true,
})
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function ()
    vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = "#808080" })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#808080" })
    vim.api.nvim_set_hl(0, "@lsp.mod.mutable", { fg = "#A6ACF6", bold = true })
    vim.api.nvim_set_hl(0, "@lsp.mod.reference", { italic = true })
    vim.api.nvim_set_hl(0, "@lsp.typemod.deriveHelper.attribute", { fg = "#C5B6C0" })
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.constant", { fg = c.vscAccentBlue })
    vim.api.nvim_set_hl(0, "@lsp.typemod.selfKeyword.mutable", { fg = "#F6AFF6" })
    vim.api.nvim_set_hl(0, "@lsp.type.selfKeyword", { fg = c.vscBlue })
    vim.api.nvim_set_hl(0, "@lsp.type.selfTypeKeyword", { fg = c.vscBlue })
    vim.api.nvim_set_hl(0, "@lsp.type.decorator", { fg = "#A596B9" })
    vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = "#C0FED8" })
    vim.api.nvim_set_hl(0, "@lsp.type.interface", { fg = "#40A940", italic = true })
    vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = "#8EC9B0" })
    vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = "#00A980" })
    vim.api.nvim_set_hl(0, "@lsp.type.formatSpecifier", { fg = c.vscBlue })
    vim.api.nvim_set_hl(0, "@lsp.type.builtinType", { fg = c.vscBlueGreen })
    vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = c.vscBlue })
    vim.api.nvim_set_hl(0, "@function.macro", { fg = c.vscBlue })
  end
})
vim.cmd.colorscheme "vscode"
vim.cmd.syntax("enable")
vim.cmd "filetype plugin indent on"

-- Code
require("gitsigns").setup()
require("nvim-surround").setup() -- ys<delimeter> (surround), ds<delimeter> (delete surround)
require("treesj").setup() -- <leader>m - Toggle block/inline.
