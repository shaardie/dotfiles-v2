local M = {}

-- Treesitter parsers to install (also read by :checkhealth config)
M.parsers = {
  "bash", "c", "diff", "dockerfile", "go", "gomod", "gosum", "helm", "json",
  "lua", "luadoc", "markdown", "markdown_inline", "python", "query", "regex",
  "rust", "toml", "vim", "vimdoc", "yaml",
}

-- Build hooks: must be registered before vim.pack.add() to catch installs
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

-- Plugins via built-in vim.pack; versions are pinned in nvim-pack-lock.json
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/snacks.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/rafamadriz/friendly-snippets",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
})

require("catppuccin").setup({ transparent_background = true })
vim.cmd.colorscheme("catppuccin")

require("which-key").setup({ preset = "helix" })

-- Snacks: picker (fuzzy finder) and explorer; keymaps are in config/keymaps.lua
require("snacks").setup({
  picker = { enabled = true },
  explorer = { enabled = true },
  bigfile = { enabled = true },
})

-- Auto-close brackets and quotes
require("mini.pairs").setup()

-- Completion: Enter accepts a selected item, <C-y> accepts the first one
require("blink.cmp").setup({
  keymap = {
    preset = "enter",
    ["<C-y>"] = { "select_and_accept" },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = {
    -- nothing preselected: Enter only accepts after picking an item (arrows, <C-n>/<C-p>)
    list = { selection = { preselect = false } },
    documentation = { auto_show = true },
  },
})

-- Treesitter (branch main): install parsers, then start highlighting per filetype
require("nvim-treesitter").install(M.parsers)
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

return M
