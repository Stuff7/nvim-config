vim.g.user_emmet_leader_key = '<C-y>'
vim.g.mapleader = " "
vim.g.rust_recommended_style = 0
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- tree style view
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 20
vim.o.signcolumn = "yes"
vim.o.swapfile = false
vim.o.title = true
vim.o.nu = true
vim.o.relativenumber = true
vim.o.tabstop = 8
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.o.linebreak = true
vim.o.winborder = "rounded"

local M = {}

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local map = M.map

map({ "n", "v", "i" }, "<C-c>", "<Esc>")

-- Move selection up and down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Append line below with a space and keep cursor in place
map("n", "J", "mzJ`z")

-- Keep cursor in the middle when half page jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "<S-Down>", "4<C-e>4j")
map("n", "<S-Up>", "4<C-y>4k")
map("n", "}", "}zz")
map("n", "{", "{zz")

-- Keep cursor in the middle while searching
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Keep copied content when pasting over selection
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>d", [["_d]])

-- Copy to clipboard
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- Indentation
map("n", "<Tab>", ">><Right><Right>")
map("n", "<S-Tab>", "<<<Left><Left>")
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

map("v", "<leader>ss", [[y:%s///g<Left><Left>]])
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Insert mode mappings
map("i", "<C-z>", "<C-o>u")         -- Undo last change
map("i", "<C-r>", "<C-o>:redo<CR>") -- Redo last change
map("i", "<C-H>", "<C-w>")          -- Delete word before cursor (Ctrl-Backspace)
map("i", "<C-d>", '<C-o>"_dw')      -- Delete word in front
map("i", "<C-s>", "<C-o>:w<CR>")    -- Save changes and stay in insert mode

-- Save
map("n", "<C-s>", ":w<CR>")
map("n", "<C-a>", "ggVG")

-- New line in normal mode
map("n", "<leader>o", ":normal o<CR>")
map("n", "<leader>O", ":normal O<CR>")
map("n", "<BS>", "daw")

-- Gitsigns hunks
map("n", "<C-Down>", ":Gitsigns next_hunk<CR>:Gitsigns preview_hunk_inline<CR>zz")
map("n", "<C-Up>", ":Gitsigns prev_hunk<CR>:Gitsigns preview_hunk_inline<CR>zz")
map("n", "<C-x>", ":Gitsigns reset_hunk<CR>")
map("n", "<leader>hp", function()
  require("gitsigns").preview_hunk()

  -- Find the float that just opened and focus it
  vim.defer_fn(function()
    local cur = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if win ~= cur then
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative ~= "" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end
  end, 10) -- tiny delay so gitsigns actually creates the window
end, { desc = "Preview hunk and focus it" })


-- Buffers
map("n", ",", "<C-w>w")                         -- Cycle panes
map("n", "<C-w>", ":bd<CR>", { nowait = true }) -- Close
map("n", "<C-k>", ":bnext<CR>")                 -- Navigation
map("n", "<C-j>", ":bprev<CR>")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Format
map("n", "<leader>f", vim.lsp.buf.format)
map("n", "<leader>f", "ggVG=<C-c>")
map("n", "<leader>m", ":TSJToggle<CR>")

vim.opt.listchars = {
  eol = '↵',
  trail = '•',
  tab = '→ ',
  nbsp = '·',
  extends = '»',
  precedes = '«',
  space = '·'
}

vim.opt.guicursor = "n:blinkon5-Cursor,i:blinkon5-ver100-Cursor,v:block-Cursor,c:blinkon5-Cursor,r:hor25-Cursor"

vim.api.nvim_create_autocmd({ "ModeChanged" }, {
  pattern = "*",
  callback = function()
    local mode = vim.fn.mode()
    local colors = {
      n = { bg = "lime", fg = "black" },
      i = { bg = "yellow", fg = "black" },
      v = { bg = "cyan", fg = "black" },
      V = { bg = "lightblue", fg = "black" },
      ["\22"] = { bg = "skyblue", fg = "black" }, -- Ctrl-V
      c = { bg = "pink", fg = "black" },
      r = { bg = "lightcoral", fg = "black" },
      R = { bg = "hotpink", fg = "black" },
    }
    local hl = colors[mode] or colors.n
    vim.api.nvim_set_hl(0, "Cursor", hl)
  end,
})

-- Fix buggy grey highlight for function signature autocomplete
vim.api.nvim_win_set_option(0, "winhighlight", "SnippetTabstop:None")

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup { defaults = { file_ignore_patterns = { "vendor/" } } }

vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("rg > "), use_regex = true })
end)

return M
