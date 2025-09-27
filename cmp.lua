local cmp = require('cmp')
local luasnip = require('luasnip')

luasnip.config.setup({})

local cmp_select = { behavior = cmp.SelectBehavior.Select }

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
  Macro = " ",
}

cmp.setup({
  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
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

  experimental = {
    ghost_text = true,
  },
})
