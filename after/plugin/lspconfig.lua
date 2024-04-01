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

-- Make zig use neovim space indentation
vim.cmd([[
  autocmd BufWritePre *.zig let save_cursor = getpos(".")
\ | execute 'normal gg=G'
\ | call setpos('.', save_cursor)
]])
vim.g.zig_fmt_autosave = 0

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

require'lspconfig'.volar.setup{
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}
