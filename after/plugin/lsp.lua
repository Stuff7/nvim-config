vim.fn.sign_define("DiagnosticSignError", {text="", texthl="DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text="", texthl="DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignHint",  {text="", texthl="DiagnosticSignHint"})
vim.fn.sign_define("DiagnosticSignInfo",  {text="", texthl="DiagnosticSignInfo"})

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

-- Set completion options
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Override the completion handler
local orig_handler = vim.lsp.handlers['textDocument/completion']
vim.lsp.handlers['textDocument/completion'] = function(err, result, ctx, config)
  if result and result.items then
    for _, item in ipairs(result.items) do
      if item.kind then
        local kind_name = vim.lsp.protocol.CompletionItemKind[item.kind] or "Unknown"
        -- Here's where we actually use the formatting
        item.kind = (kind_icons[kind_name] or "") .. " " .. kind_name
        
        -- Add menu labels like nvim-cmp does
        if not item.detail then
          item.detail = "[LSP]"
        end
      end
    end
  end
  
  return orig_handler(err, result, ctx, config)
end

function map(mode, lhs, rhs, opts)
  local options = { expr = true, silent = false, noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

vim.keymap.set('i', '<C-f>', '<C-x><C-o>')

map('i', '<Left>', function()
  if vim.fn.pumvisible() ~= 0 then return '<Left><C-x><C-o>' end
  return '<Left>'
end)

map('i', '<Right>', function()
  if vim.fn.pumvisible() ~= 0 then return '<Right><C-x><C-o>' end
  return '<Right>'
end)

map('i', '<C-left>', function()
  if vim.fn.pumvisible() ~= 0 then return '<C-left><C-x><C-o>' end
  return '<C-left>'
end)

map('i', '<C-right>', function()
  if vim.fn.pumvisible() ~= 0 then return '<C-right><C-x><C-o>' end
  return '<C-right>'
end)

map('i', '<Down>', function()
  if vim.fn.pumvisible() ~= 0 then return '<C-n>' end
  return '<Down>'
end)

map('i', '<Up>', function()
  if vim.fn.pumvisible() ~= 0 then return '<C-p>' end
  return '<Up>'
end)

map('i', '<Esc>', function()
  if vim.fn.pumvisible() ~= 0 then return '<C-e>' end
  return '<Esc>'
end)

vim.diagnostic.config({
  virtual_text = true
})

vim.keymap.set("n", "<leader>qf", function()
  vim.lsp.buf.code_action({
    filter = function(a) return a.isPreferred end,
    apply = true
  })
end, { noremap=true, silent=true })
