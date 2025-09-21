local M = {}

vim.o.complete = ".,o"                       -- use buffer and omnifunc
vim.o.completeopt = "fuzzy,menuone,noselect" -- add 'popup' for docs (sometimes)
vim.o.autocomplete = true
vim.o.pumheight = 15
vim.o.pummaxwidth = 50

local autocomplete_icons = {
  [1] = "", -- Text
  [2] = "󰆧", -- Method
  [3] = "󰊕", -- Function
  [4] = "", -- Constructor
  [5] = "󰇽", -- Field
  [6] = "󰂡", -- Variable
  [7] = "󰠱", -- Class
  [8] = "", -- Interface
  [9] = "", -- Module
  [10] = "󰜢", -- Property
  [11] = "", -- Unit
  [12] = "󰎠", -- Value
  [13] = "", -- Enum
  [14] = "󰌋", -- Keyword
  [15] = "", -- Snippet
  [16] = "󰏘", -- Color
  [17] = "󰈙", -- File
  [18] = "", -- Reference
  [19] = "󰉋", -- Folder
  [20] = "", -- EnumMember
  [21] = "󰏿", -- Constant
  [22] = "", -- Struct
  [23] = "", -- Event
  [24] = "󰆕", -- Operator
  [25] = "󰅲", -- TypeParameter
  [26] = " ", -- Macro
}

-- Store completion items for snippet expansion
local completion_items = {}
local current_completion_start = 0

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.lsp.completion.enable(true, client.id, bufnr, {
    convert = function(item)
      local icon = autocomplete_icons[item.kind] or ""
      local abbr = icon .. "  " .. (item.label or "")

      -- Store the original item for potential snippet expansion
      completion_items[item.label or ""] = item

      return { abbr = abbr, menu = item.kind or "" }
    end,
  })

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
  vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end

function M.lspcfg(lsp_name, opts)
  vim.lsp.enable(lsp_name)
  local options = { on_attach = on_attach }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.lsp.config(lsp_name, options)
end

require('mason').setup()

local map = require("remap").map

-- Trigger completion
map('i', '<C-f>', function()
  current_completion_start = vim.fn.col('.') - 1
  return '<C-x><C-o>'
end, { expr = true })

local function move_with_completion(key)
  return function()
    return vim.fn.pumvisible() ~= 0 and key .. '<C-x><C-o>' or key
  end
end

-- Movement keys that retrigger completion
for _, key in ipairs({ '<Left>', '<Right>', '<C-left>', '<C-right>' }) do
  map('i', key, move_with_completion(key), { expr = true })
end

-- Tab handling with snippet expansion
map('i', '<Tab>', function()
  if vim.fn.pumvisible() ~= 0 then
    -- Accept the completion first
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, true, true), 'n', false)

    -- Schedule the snippet expansion to happen after completion
    vim.schedule(function()
      local completed_item = vim.v.completed_item
      if not completed_item or not completed_item.word then
        return
      end

      local word = completed_item.word

      local stored_item = completion_items[word]
      if stored_item and stored_item.kind == 15 and stored_item.insertText then
        local current_col = vim.fn.col('.') - 1

        -- Find the start of the completed word by looking backwards
        local start_col = current_col - #word

        -- Replace the completed text with the snippet
        vim.api.nvim_buf_set_text(0,
          vim.fn.line('.') - 1, start_col,
          vim.fn.line('.') - 1, current_col,
          {})

        -- Position cursor at the start and expand snippet
        vim.api.nvim_win_set_cursor(0, { vim.fn.line('.'), start_col })

        if stored_item.insertTextFormat == 2 then -- LSP snippet format
          vim.snippet.expand(stored_item.insertText)
        else
          -- Fallback for non-LSP snippets
          vim.api.nvim_put({ stored_item.insertText }, 'c', false, true)
        end
      end
    end)

    return ""
  else
    if vim.snippet.active({ direction = 1 }) then
      return '<cmd>lua vim.snippet.jump(1)<CR>'
    end
    return '<Tab>'
  end
end, { expr = true })

-- Shift-Tab for jumping backwards in snippets
map('i', '<S-Tab>', function()
  if vim.snippet.active({ direction = -1 }) then
    return '<cmd>lua vim.snippet.jump(-1)<CR>'
  end
  return '<S-Tab>'
end, { expr = true })

map('i', '<Esc>', function()
  return vim.fn.pumvisible() ~= 0 and '<C-e><Esc>' or '<Esc>'
end, { expr = true })

-- Quick fix
map("n", "<leader>qf", function()
  vim.lsp.buf.code_action({
    filter = function(a) return a.isPreferred end,
    apply = true
  })
end, { silent = true })

vim.diagnostic.config({ virtual_text = true })

-- Hover preview system
local hover_win, hover_buf

local function close_hover()
  if hover_win and vim.api.nvim_win_is_valid(hover_win) then
    vim.api.nvim_win_close(hover_win, true)
    hover_win = nil
  end
end

local function show_hover()
  -- Use the original LSP hover request method which works reliably
  vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(), function(_, result)
    if not result or not result.contents then return close_hover() end

    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    if vim.tbl_isempty(lines) then return close_hover() end

    close_hover()

    if not hover_buf or not vim.api.nvim_buf_is_valid(hover_buf) then
      hover_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[hover_buf].filetype = 'markdown'
    end

    vim.bo[hover_buf].modifiable = true
    vim.api.nvim_buf_set_lines(hover_buf, 0, -1, false, lines)
    vim.bo[hover_buf].modifiable = false

    hover_win = vim.api.nvim_open_win(hover_buf, false, {
      relative = 'editor',
      row = 1,
      col = vim.o.columns - math.min(80, vim.o.columns - 4) - 2,
      width = math.min(80, vim.o.columns - 4),
      height = math.min(#lines, 15),
      style = 'minimal',
      border = 'rounded',
      focusable = false,
    })

    -- Enable syntax highlighting and concealing
    vim.wo[hover_win].conceallevel = 2
    vim.wo[hover_win].concealcursor = 'nv'
  end)
end

map('i', '<Down>', function()
  if vim.fn.pumvisible() ~= 0 then
    -- Move down in completion menu and trigger hover
    vim.schedule(function()
      show_hover()
    end)
    return '<C-n>'
  end
  return '<Down>'
end, { expr = true })

map('i', '<Up>', function()
  if vim.fn.pumvisible() ~= 0 then
    -- Move up in completion menu and trigger hover
    vim.schedule(function()
      show_hover()
    end)
    return '<C-p>'
  end
  return '<Up>'
end, { expr = true })

-- Auto-close hover
vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave", "CursorMoved", "CursorMovedI" }, { callback = close_hover })

-- Track completion start position
vim.api.nvim_create_autocmd("CompleteChanged", {
  callback = function()
    if vim.fn.pumvisible() ~= 0 then
      if current_completion_start == 0 then
        current_completion_start = vim.fn.col('.') - 1
      end
    else
      current_completion_start = 0
    end
  end
})

return M
