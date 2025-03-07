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
local nvim_tree = require("nvim-tree")

nvim_tree.setup({
  diagnostics = {
    enable = true,
  }
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.filetype ~= "NvimTree" then
      vim.cmd("NvimTreeClose")
    end
  end,
})

-- Colorscheme
require("vscode").setup({
  transparent = true,
  italic_comments = true,
  disable_nvimtree_bg = true,
})
local c = {
  blue = "#569CD6",
  blueGreen = "#4EC9B0",
  accentBlue = "#4FC1FE",
  pink = "#FF8FFF",
  lightRed = "#FF8484",
  lightBrown = "#E29D9D",
  orange = "#FF9547",
  grey = "#808080",
  purple = "#998CFF",
  palePurple = "#C5B6C0",
  darkPalePurple = "#A596B9",
  paleGreen = "#C0FED8",
  palePink = "#FBD1FF",
  mediumGreen = "#40A940",
  darkAquamarine = "#2FAF84",
  paleAquamarine = "#93CDB9",
  yellow = "#FFFF00",
  violet = "#C586C0",
}

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function ()
    -- Rust
    vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = c.grey })
    vim.api.nvim_set_hl(0, "@comment", { fg = c.grey })
    vim.api.nvim_set_hl(0, "@lsp.mod.mutable", { fg = c.purple, bold = true })
    vim.api.nvim_set_hl(0, "@lsp.mod.reference", { italic = true })
    vim.api.nvim_set_hl(0, "@lsp.typemod.deriveHelper.attribute", { fg = c.palePurple })
    vim.api.nvim_set_hl(0, "@lsp.typemod.variable.constant", { fg = c.accentBlue })
    vim.api.nvim_set_hl(0, "@lsp.typemod.method.mutable", { fg = c.yellow })
    vim.api.nvim_set_hl(0, "@lsp.type.keyword", { fg = c.violet })
    vim.api.nvim_set_hl(0, "@lsp.type.selfKeyword", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@lsp.type.selfTypeKeyword", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@lsp.type.decorator", { fg = c.darkPalePurple })
    vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = c.paleGreen })
    vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = c.palePink })
    vim.api.nvim_set_hl(0, "@lsp.type.interface", { fg = c.orange, italic = true })
    vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = c.paleAquamarine })
    vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = c.lightRed })
    vim.api.nvim_set_hl(0, "@lsp.type.derive", { fg = c.lightBrown })
    vim.api.nvim_set_hl(0, "@lsp.type.formatSpecifier", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@lsp.type.builtinType", { fg = c.blueGreen })
    vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@lsp.type.procMacro", { fg = c.blue })
    vim.api.nvim_set_hl(0, "@function.macro", { fg = c.blue })
    -- C
    vim.api.nvim_set_hl(0, "@lsp.mod.usedAsMutablePointer", { fg = c.purple, bold = true })
    vim.api.nvim_set_hl(0, "@lsp.mod.readonly", { fg = c.accentBlue })
    vim.api.nvim_set_hl(0, "@lsp.type.label", { fg = c.orange, italic = true })
    vim.api.nvim_set_hl(0, "@lsp.mod.static", { bold = true })
    -- CSS
    vim.api.nvim_set_hl(0, "@variable.css", { fg = c.paleGreen })
    vim.api.nvim_set_hl(0, "@plain_value.css", { fg = c.yellow })
  end
})
vim.cmd.colorscheme "vscode"
vim.cmd.syntax("enable")
vim.cmd "filetype plugin indent on"
vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

-- Code
require("gitsigns").setup()
require("nvim-surround").setup() -- ys<delimeter> (surround), ds<delimeter> (delete surround)
require("treesj").setup({
  use_default_keymaps = false,
})
