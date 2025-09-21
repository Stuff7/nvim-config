-- Status bar
require("lualine").setup()

-- Tabs
require("bufferline").setup()

-- Colorscheme
require("vscode").setup({
  transparent = true,
  italic_comments = true,
})

require("nvim-autopairs").setup()

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
  callback = function()
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

-- Git gutters
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "Error",
      [vim.diagnostic.severity.WARN] = "Warn",
      [vim.diagnostic.severity.INFO] = "Info",
      [vim.diagnostic.severity.HINT] = "Hint",
    },
  },
})

-- Format on save
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.vert", "*.frag", "*.comp", "*.rchit", "*.rmiss", "*.rahit" },
  callback = function() vim.bo.filetype = "glsl" end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.go", "*.zig", "*.svelte", "*.lua" },
  callback = function() vim.lsp.buf.format() end
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.css", "*.astro", "*.graphql", "*.js", "*.ts", "*.jsx", "*.tsx", "*.json", "*.jsonc", "*.cjs", "*.vue" },
  callback = function()
    local file = vim.fn.expand("%:p")
    vim.cmd("silent !~/.local/share/nvim/mason/bin/biome format --write --indent-style space " ..
      vim.fn.shellescape(file))
  end
})

require 'nvim-treesitter.configs'.setup {
  auto_install = true,
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  custom_captures = { ["plain_value"] = "css" }
}

require('Comment').setup()
