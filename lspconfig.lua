local util = require("lspconfig/util")

local function merge_tables(t1, t2)
  local r = {}
  for k, v in pairs(t1) do r[k] = v end
  for k, v in pairs(t2) do r[k] = v end
  return r
end

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr, remap = false }

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
    { "i", "<C-h>", function()
      vim.lsp.buf.signature_help()
    end, { expr = true, remap = true },
    },
  }

  for _, keymap in ipairs(keymaps) do
    local options = opts
    if keymap[4] ~= nil then options = merge_tables(opts, keymap[4]) end
    vim.keymap.set(keymap[1], keymap[2], keymap[3], options)
  end
end

local function lspcfg(lsp_name, opts)
  vim.lsp.enable(lsp_name)
  local options = { on_attach = on_attach }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.lsp.config(lsp_name, options)
end

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

lspcfg("gopls")

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
