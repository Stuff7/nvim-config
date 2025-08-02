local lsp_zero = require('lsp-zero')

lsp_zero.set_sign_icons({
  error = "",
  warn = "",
  hint = "",
  info = ""
})

lsp_zero.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end)

vim.cmd [[au! BufRead,BufNewFile *.vert,*.frag,*.comp,*.rchit,*.rmiss,*.rahit set filetype=glsl]]
vim.cmd [[autocmd BufWritePre *.{c,cpp,h,hpp,go,zig,svelte} lua vim.lsp.buf.format()]]

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {
    "*.css",
    "*.astro",
    "*.graphql",
    "*.js",
    "*.ts",
    "*.jsx",
    "*.tsx",
    "*.json",
    "*.jsonc",
    -- "*.svelte",
    "*.cjs",
    "*.vue",
  },
  callback = function()
    local file = vim.fn.expand("%:p")
    vim.cmd("silent !~/.local/share/nvim/mason/bin/biome format --write --indent-style space " .. vim.fn.shellescape(file))
  end
})

require('mason').setup({})
require('mason-lspconfig').setup({
  automatic_installation = false,
  automatic_setup = false,
  automatic_enable = false,
  ensure_installed = {},
  handlers = nil
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

cmp.setup({
  sources = {
    {name = "path"},
    {name = "nvim_lsp"},
    {name = "nvim_lua"},
  },
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = kind_icons[vim_item.kind] .. " " .. vim_item.kind
      vim_item.menu = ({
        buffer = "[Buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        nvim_lua = "[Nvim]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end,
    fields = { "abbr", "kind" }
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    ["<C-f>"] = cmp.mapping.complete(),
  }),
})

vim.diagnostic.config({
  virtual_text = true
})

vim.keymap.set("n", "<leader>qf", function()
  vim.lsp.buf.code_action({
    filter = function(a) return a.isPreferred end,
    apply = true
  })
end, { noremap=true, silent=true })
