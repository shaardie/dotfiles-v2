-- :checkhealth config  -- reports missing tools, servers and parsers
local M = {}
local h = vim.health

-- Entries: { binary, pacman package (optional) }
local required = {
  { "git" },
  { "gcc" },
  { "rg", "ripgrep" },
  { "fd" },
  { "tree-sitter", "tree-sitter-cli" },
}

-- Language servers
local servers = {
  { "lua-language-server", "lua-language-server" },
  { "rust-analyzer", "rust-analyzer" },
  { "gopls", "gopls" },
  { "basedpyright-langserver" },
  { "ruff", "ruff" },
  { "yaml-language-server", "yaml-language-server" },
  { "helm_ls" },
  { "marksman", "marksman" },
}

-- Formatters and linters (only used on demand)
local extras = {
  { "prettier" },
  { "hadolint" },
}

local function check(list, report_missing)
  for _, t in ipairs(list) do
    local bin, hint = t[1], t[2]
    if vim.fn.executable(bin) == 1 then
      h.ok(bin)
    else
      report_missing(bin .. " not found" .. (hint and (" (pacman: " .. hint .. ")") or ""))
    end
  end
end

function M.check()
  h.start("Required tools")
  check(required, h.error)

  h.start("Language servers")
  check(servers, h.warn)

  h.start("Formatters / linters")
  check(extras, h.warn)

  h.start("Treesitter parsers")
  local missing = {}
  for _, lang in ipairs(require("config.plugins").parsers) do
    if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 then
      table.insert(missing, lang)
    end
  end
  if #missing == 0 then
    h.ok("all parsers installed")
  else
    h.warn("missing parsers: " .. table.concat(missing, ", "), "Run :TSUpdate or check :messages")
  end

  h.start("Plugins")
  for _, p in ipairs(vim.pack.get()) do
    if p.active then
      h.ok(p.spec.name)
    else
      h.warn(p.spec.name .. " installed but not loaded")
    end
  end
end

return M
