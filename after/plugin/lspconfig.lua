local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

-- Rust config
lspconfig.rust_analyzer.setup {
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy"
      }
    },
  },
}

vim.g.rustfmt_autosave = 1
