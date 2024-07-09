vim.g.mapleader = " "
vim.g.rust_recommended_style = 0
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3 -- tree style view
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 20
vim.opt.title = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.list = true
vim.opt.linebreak = true
vim.opt.listchars = {
  eol = '↵',
  trail = '•',
  tab = '→ ',
  nbsp = '·',
  extends = '»',
  precedes = '«',
  space = '·'
}

function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

map("n", "<C-b>", ":NvimTreeToggle<CR>")

-- Move selection up and down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Append line below with a space and keep cursor in place
map("n", "J", "mzJ`z")

-- Keep cursor in the middle when half page jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle while searching
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Keep copied content when pasting over selection
map("x", "<leader>p", [["_dP]])
map({"n", "v"}, "<leader>d", [["_d]])

-- Copy to clipboard
map({"n", "v"}, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

-- Indentation
map("n", "<Tab>", ">><Right><Right>")
map("n", "<S-Tab>", "<<<Left><Left>")
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")
map("i", "<C-[>", "<C-O><<<Left><Left>")
map("i", "<C-]>", "<C-O>>><Right><Right>")

map("v", "<leader>ss", [[y:%s///g<Left><Left>]])

-- Insert mode mappings
map("i", "<C-c>", "<Esc>") -- Switch to normal mode
map("i", "<C-z>", "<C-O>u") -- Undo last change
map("i", "<C-y>", "<C-O><C-r>") -- Redo last change
map("i", "<C-H>", "<C-w>") -- Delete word before cursor (Ctrl-Backspace)
map("i", "<C-d>", "<Esc><Right>dwi") -- Delete word in front
map("i", "<C-s>", "<Esc>:w<CR>i<Right>") -- Save changes and stay in insert mode

-- Save
map("n", "<C-s>", ":w<CR>")
map("n", "<C-a>", "ggVG")

-- New line in normal mode
map("n", "<leader>o", ":normal o<CR>")
map("n", "<leader>O", ":normal O<CR>")
map("n", "<BS>", "daw")
map("n", "<C-e>", "3<C-e>")
map("n", "<C-y>", "3<C-y>")

-- Motions (leap.nvim)
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
map({"n", "x", "o"}, "f", "<Plug>(leap-forward-to)")
map({"n", "x", "o"}, "F", "<Plug>(leap-backward-to)")
map("n", "<C-n>", ":Gitsigns next_hunk<CR>:Gitsigns preview_hunk<CR>")
map("n", "<C-m>", ":Gitsigns prev_hunk<CR>:Gitsigns preview_hunk<CR>")
map("n", "<C-x>", ":Gitsigns reset_hunk<CR>")

-- Buffers
map("n", ",", "<C-w>w") -- Cycle panes
map("n", "<C-w>", ":bd<CR>", { nowait = true }) -- Close
map("n", "<C-k>", ":bnext<CR>") -- Navigation
map("n", "<C-j>", ":bprev<CR>")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Format
map("n", "<leader>f", vim.lsp.buf.format)
map("n", "<leader>f", "ggVG=<C-c>")
map("n", "<leader>m", ":TSJToggle<CR>")
