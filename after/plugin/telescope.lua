local telescope = require("telescope")
local builtin = require("telescope.builtin")
telescope.setup{
  defaults = {
    file_ignore_patterns = { "vendor/" }
  }
}
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("rg > "), use_regex = true })
end)
