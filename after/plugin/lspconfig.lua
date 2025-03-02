local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

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

local function get_typescript_server_path(root_dir)
  local home_dir = os.getenv("HOME")
  if not home_dir then
    error("HOME environment variable is not set.")
  end

  local global_ts = util.path.join(home_dir, '.npm/lib/node_modules/typescript/lib')
  local found_ts = ''

  local function check_dir(path)
    found_ts = util.path.join(path, 'node_modules', 'typescript', 'lib')
    if util.path.exists(found_ts) then
      return path
    end
  end

  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return global_ts
  end
end

lspconfig.volar.setup{
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}

lspconfig.cssls.setup{
  settings = {
    css = {
      lint = {
        unknownAtRules = "ignore"
      }
    }
  }
}

lspconfig.clangd.setup {
  cmd = {
    "clangd",
    "--background-index",
    "--compile-commands-dir=" .. vim.fn.getcwd() .. "/cmake_build",
    "--clang-tidy",
    "--query-driver=/usr/bin/**/clang-*,/bin/clang,/bin/clang++,/usr/bin/gcc,/usr/bin/g++",
    "--all-scopes-completion",
    "--completion-style=detailed",
    "--header-insertion-decorators",
    "--header-insertion=iwyu",
  }
}

-- nvim-lint
require('lint').linters_by_ft = {
  css = {'stylelint',}
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "BufModifiedSet" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

lspconfig.zls.setup {
  cmd = {
    "zls",
    "--config-path",
    "~/.config/zls.json",
  }
}
