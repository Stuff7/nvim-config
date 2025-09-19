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

local home_dir = os.getenv("HOME")

local function get_typescript_server_path(root_dir)
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

-- lspconfig.biome.setup{
  -- root_dir = util.root_pattern("package.json"),
-- }

lspconfig.ts_ls.setup{}

lspconfig.svelte.setup{}

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

lspconfig.zls.setup {
  settings = {
    zls = {
      enable_build_on_save = true,
      semantic_tokens = "partial",
    }
  }
}

local configs = require('lspconfig.configs')

if not configs.simple_text_lsp then
  configs.simple_text_lsp = {
    default_config = {
      cmd = { util.path.join(home_dir, 'dev/zig/ziglsp/zig-out/bin/ziglsp-dbg') },
      filetypes = { 'text', 'txt' },

      root_dir = function(fname)
        return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1]) or vim.fn.getcwd()
      end,

      settings = {},
      init_options = {},
      capabilities = vim.lsp.protocol.make_client_capabilities(),
    },
  }
end

lspconfig.simple_text_lsp.setup({})
