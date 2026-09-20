-- LSP servers, diagnostics, format on save and linting (keymaps: config/keymaps.lua)

-- Completion capabilities for all servers
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      diagnostics = { globals = { "Snacks" } },
      completion = { callSnippet = "Replace" },
      hint = { enable = true },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = { check = { command = "clippy" } },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- YAML: schemas come from SchemaStore (Compose, CI, ...)
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
})

-- Enable a server only if its binary is installed
local servers = { "lua_ls", "rust_analyzer", "gopls", "basedpyright", "ruff", "yamlls" }
for _, name in ipairs(servers) do
  local cmd = vim.lsp.config[name].cmd
  if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
    vim.lsp.enable(name)
  end
end

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  severity_sort = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nv_lsp_attach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end
    -- ruff is used for lint/format only; leave hover to basedpyright
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    -- Inlay hints on by default
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- Format on save via LSP; off by default, toggled with <leader>uf
vim.g.autoformat = false
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("nv_format_on_save", { clear = true }),
  callback = function(ev)
    if vim.g.autoformat then
      vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 3000 })
    end
  end,
})

-- Linting: only register linters whose binary exists, to avoid error spam
local lint = require("lint")
if vim.fn.executable("hadolint") == 1 then
  lint.linters_by_ft = { dockerfile = { "hadolint" } }
end
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("nv_lint", { clear = true }),
  callback = function() lint.try_lint() end,
})
