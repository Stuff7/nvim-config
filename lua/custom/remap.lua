vim.g.mapleader = " "
vim.g.rust_recommended_style = 0

-- Move selection up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Append line below with a space and keep cursor in place
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle when half page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Keep copied content when pasting over selection
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- Copy to clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Insert mode mappings
vim.keymap.set("i", "<C-c>", "<Esc>") -- Switch to normal mode
vim.keymap.set("i", "<C-z>", "<C-O>u") -- Undo last change
vim.keymap.set("i", "<C-H>", "<C-w>") -- Delete word before cursor (Ctrl-Backspace)
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>i<Right>") -- Save changes and stay in insert mode

-- Save / Source
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("n", "<C-a>", ":so<CR>")

-- New line in normal mode
vim.keymap.set("n", "<leader>o", ":normal o<CR>")
vim.keymap.set("n", "<leader>O", ":normal O<CR>")

-- Motions (leap.nvim)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set({"n", "x", "o"}, "f", "<Plug>(leap-forward-to)")
vim.keymap.set({"n", "x", "o"}, "F", "<Plug>(leap-backward-to)")

-- Tabs
vim.keymap.set("n", "<leader>tc", ":bd<CR>") -- Close
vim.keymap.set("n", "<C-k>", ":bnext<CR>") -- Navigation
vim.keymap.set("n", "<C-j>", ":bprev<CR>")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- LSP
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
