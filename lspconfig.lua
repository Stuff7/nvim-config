local lspcfg = require("autocomplete").lspcfg
local util = require("lspconfig/util")

lspcfg("rust_analyzer", {
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy"
      }
    },
  },
})
vim.g.rustfmt_autosave = 1

lspcfg("ts_ls")

lspcfg("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false, -- don’t scan random crap
        library = {},            -- don’t preload Neovim + plugins and eat a bunch of RAM
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

lspcfg("svelte")

lspcfg("clangd", {
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
})

lspcfg("zls", {
  settings = {
    zls = {
      enable_build_on_save = true,
      semantic_tokens = "partial",
    }
  }
})

local home_dir = os.getenv("HOME")
local configs = require('lspconfig.configs')

if not configs.ziglsp then
  configs.ziglsp = {
    default_config = {
      cmd = { util.path.join(home_dir, 'dev/zig/ziglsp/zig-out/bin/ziglsp-dbg') },
      filetypes = { 'text', 'txt' },

      root_dir = function(fname)
        return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1]) or vim.fn.getcwd()
      end,

      settings = {},
      init_options = {},
      capabilities = vim.lsp.protocol.make_client_capabilities(),
    },
  }
end

lspcfg("ziglsp")
