local M = {}

-- Completion configuration
vim.o.complete = ".,o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.autocomplete = true
vim.o.pumheight = 15
vim.o.pummaxwidth = 50

local CmpInsFmt = {
  PlainText = 1,
  Snippet = 2,
}

local CmpKind = {
  Text = 1,
  Method = 2,
  Function = 3,
  Constructor = 4,
  Field = 5,
  Variable = 6,
  Class = 7,
  Interface = 8,
  Module = 9,
  Property = 10,
  Unit = 11,
  Value = 12,
  Enum = 13,
  Keyword = 14,
  Snippet = 15,
  Color = 16,
  File = 17,
  Reference = 18,
  Folder = 19,
  EnumMember = 20,
  Constant = 21,
  Struct = 22,
  Event = 23,
  Operator = 24,
  TypeParameter = 25,
  Macro = 26,
}

-- Completion icons mapping
local COMPLETION_ICONS = {
  [CmpKind.Text] = "",
  [CmpKind.Method] = "󰆧",
  [CmpKind.Function] = "󰊕",
  [CmpKind.Constructor] = "",
  [CmpKind.Field] = "󰇽",
  [CmpKind.Variable] = "󰂡",
  [CmpKind.Class] = "󰠱",
  [CmpKind.Interface] = "",
  [CmpKind.Module] = "",
  [CmpKind.Property] = "󰜢",
  [CmpKind.Unit] = "",
  [CmpKind.Value] = "󰎠",
  [CmpKind.Enum] = "",
  [CmpKind.Keyword] = "󰌋",
  [CmpKind.Snippet] = "",
  [CmpKind.Color] = "󰏘",
  [CmpKind.File] = "󰈙",
  [CmpKind.Reference] = "",
  [CmpKind.Folder] = "󰉋",
  [CmpKind.EnumMember] = "",
  [CmpKind.Constant] = "󰏿",
  [CmpKind.Struct] = "",
  [CmpKind.Event] = "",
  [CmpKind.Operator] = "󰆕",
  [CmpKind.TypeParameter] = "󰅲",
  [CmpKind.Macro] = " ",
}

-- State management
local state = {
  completion_items = {},
  completion_start = 0,
  has_selection = false,
  hover_win = nil,
  hover_buf = nil,
}

-- Utility functions
local function close_hover()
  if state.hover_win and vim.api.nvim_win_is_valid(state.hover_win) then
    vim.api.nvim_win_close(state.hover_win, true)
    state.hover_win = nil
  end
end

local function show_hover()
  vim.lsp.buf_request(0, 'textDocument/hover', vim.lsp.util.make_position_params(), function(_, result)
    if not result or not result.contents then
      return close_hover()
    end

    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    if vim.tbl_isempty(lines) then
      return close_hover()
    end

    close_hover()

    if not state.hover_buf or not vim.api.nvim_buf_is_valid(state.hover_buf) then
      state.hover_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[state.hover_buf].filetype = 'markdown'
    end

    vim.bo[state.hover_buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.hover_buf, 0, -1, false, lines)
    vim.bo[state.hover_buf].modifiable = false

    local width = math.min(80, vim.o.columns - 4)
    local height = math.min(#lines, 15)

    state.hover_win = vim.api.nvim_open_win(state.hover_buf, false, {
      relative = 'editor',
      row = 1,
      col = vim.o.columns - width - 2,
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      focusable = false,
    })

    vim.wo[state.hover_win].conceallevel = 2
    vim.wo[state.hover_win].concealcursor = 'nv'
  end)
end

local function handle_snippet_expansion(completed_item)
  if not completed_item or not completed_item.word then
    return
  end

  local word = completed_item.word
  local stored_item = state.completion_items[word]

  if not stored_item or stored_item.kind ~= CmpKind.Snippet then
    return
  end

  if not stored_item.insertText or stored_item.insertText == word then
    return
  end

  local current_line = vim.api.nvim_get_current_line()
  local cursor_col = vim.fn.col('.') - 1

  if current_line:sub(cursor_col - #word + 1, cursor_col) ~= word then
    return
  end

  local start_col = cursor_col - #word

  vim.api.nvim_buf_set_text(0,
    vim.fn.line('.') - 1, start_col,
    vim.fn.line('.') - 1, cursor_col,
    {})

  vim.api.nvim_win_set_cursor(0, { vim.fn.line('.'), start_col })

  if stored_item.insertTextFormat == CmpInsFmt.Snippet then
    vim.snippet.expand(stored_item.insertText)
  else
    vim.api.nvim_put({ stored_item.insertText }, 'c', false, true)
  end
end

-- LSP attach function
local function on_attach(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.lsp.completion.enable(true, client.id, bufnr, {
    convert = function(item)
      local icon = COMPLETION_ICONS[item.kind] or ""
      local abbr = icon .. "  " .. (item.label or "")

      -- Disable snippet expansion for these
      if item.textEdit ~= nil and item.insertTextFormat == CmpInsFmt.Snippet and (
            item.kind == CmpKind.Method or
            item.kind == CmpKind.Function or
            item.kind == CmpKind.Struct
          ) then
        item.textEdit = nil;
        item.insertText = (item.label or "") .. "($1)"
        item.insertTextFormat = CmpInsFmt.Snippet
      end

      state.completion_items[item.label or ""] = item

      return { abbr = abbr, menu = item.kind or "" }
    end,
  })

  -- LSP keymaps
  local keymaps = {
    { "n", "gd",          vim.lsp.buf.definition },
    { "n", "K",           vim.lsp.buf.hover },
    { "n", "<leader>vws", vim.lsp.buf.workspace_symbol },
    { "n", "<leader>vd",  vim.diagnostic.open_float },
    { "n", "[d",          function() vim.diagnostic.jump({ count = 1, float = true }) end },
    { "n", "]d",          function() vim.diagnostic.jump({ count = -1, float = true }) end },
    { "n", "<leader>vca", vim.lsp.buf.code_action },
    { "n", "<leader>vrr", vim.lsp.buf.references },
    { "n", "<leader>vrn", vim.lsp.buf.rename },
    { "i", "<C-h>",       vim.lsp.buf.signature_help },
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], opts)
  end
end

-- Completion keymaps
local function setup_completion_keymaps()
  local map = require("remap").map

  -- Trigger completion
  map('i', '<C-f>', function()
    state.completion_start = vim.fn.col('.') - 1
    state.has_selection = false
    return '<C-x><C-o>'
  end, { expr = true })

  -- Movement keys that retrigger completion
  local function move_with_completion(key)
    return function()
      return vim.fn.pumvisible() ~= 0 and key .. '<C-x><C-o>' or key
    end
  end

  for _, key in ipairs({ '<Left>', '<Right>', '<C-left>', '<C-right>' }) do
    map('i', key, move_with_completion(key), { expr = true })
  end

  -- Tab handling with snippet expansion
  map('i', '<Tab>', function()
    if vim.fn.pumvisible() ~= 0 then
      local keys = state.has_selection and '<C-y>' or '<C-n><C-y>'
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), 'n', false)
      state.has_selection = false

      vim.schedule(function()
        handle_snippet_expansion(vim.v.completed_item)
      end)

      return ""
    else
      if vim.snippet.active({ direction = 1 }) then
        return '<cmd>lua vim.snippet.jump(1)<CR>'
      end
      return '<Tab>'
    end
  end, { expr = true })

  -- Shift-Tab for snippet navigation
  map('i', '<S-Tab>', function()
    if vim.snippet.active({ direction = -1 }) then
      return '<cmd>lua vim.snippet.jump(-1)<CR>'
    end
    return '<S-Tab>'
  end, { expr = true })

  -- Escape handling
  map('i', '<Esc>', function()
    if vim.fn.pumvisible() ~= 0 then
      state.has_selection = false
      return '<C-e><Esc>'
    end
    return '<Esc>'
  end, { expr = true })

  -- Completion navigation with hover
  local function nav_with_hover(direction)
    return function()
      if vim.fn.pumvisible() ~= 0 then
        state.has_selection = true
        vim.schedule(show_hover)
        return direction == 'down' and '<C-n>' or '<C-p>'
      end
      return direction == 'down' and '<Down>' or '<Up>'
    end
  end

  map('i', '<Down>', nav_with_hover('down'), { expr = true })
  map('i', '<Up>', nav_with_hover('up'), { expr = true })

  -- Quick fix
  map("n", "<leader>qf", function()
    vim.lsp.buf.code_action({
      filter = function(a) return a.isPreferred end,
      apply = true
    })
  end, { silent = true })
end

-- Auto commands
local function setup_autocmds()
  vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave", "CursorMoved", "CursorMovedI" }, {
    callback = close_hover
  })

  vim.api.nvim_create_autocmd("CompleteChanged", {
    callback = function()
      if vim.fn.pumvisible() ~= 0 then
        if state.completion_start == 0 then
          state.completion_start = vim.fn.col('.') - 1
        end
      else
        state.completion_start = 0
      end
    end
  })
end

-- Public API
function M.lspcfg(lsp_name, opts)
  vim.lsp.enable(lsp_name)
  local options = { on_attach = on_attach }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.lsp.config(lsp_name, options)
end

-- Initialize
require('mason').setup()
vim.diagnostic.config({ virtual_text = true })

setup_completion_keymaps()
setup_autocmds()

return M
