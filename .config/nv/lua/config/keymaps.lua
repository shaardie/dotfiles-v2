-- All keymaps live here (plugins must be loaded first: see init.lua)
local map = vim.keymap.set
local Snacks = require("snacks")
local p = Snacks.picker

require("which-key").add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>f", group = "file/find" },
  { "<leader>q", group = "quit" },
  { "<leader>s", group = "search" },
  { "<leader>u", group = "ui/toggle" },
  { "<leader>w", group = "windows" },
  { "<leader>x", group = "diagnostics" },
})

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })
map("n", "<leader>-", "<C-w>s", { desc = "Split below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete window" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Alternate buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit #|bdelete #<cr>", { desc = "Delete other buffers" })

-- Editing
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map({ "i", "n", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map({ "n", "x" }, "<leader>cf", function()
  vim.lsp.buf.format({ timeout_ms = 3000 })
end, { desc = "Format" })

-- Find / search (snacks picker)
map("n", "<leader><space>", function() p.files() end, { desc = "Find files" })
map("n", "<leader>,", function() p.buffers() end, { desc = "Buffers" })
map("n", "<leader>/", function() p.grep() end, { desc = "Grep" })
map("n", "<leader>:", function() p.command_history() end, { desc = "Command history" })
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "Explorer" })

map("n", "<leader>ff", function() p.files() end, { desc = "Find files" })
map("n", "<leader>fb", function() p.buffers() end, { desc = "Buffers" })
map("n", "<leader>fg", function() p.git_files() end, { desc = "Git files" })
map("n", "<leader>fr", function() p.recent() end, { desc = "Recent files" })
map("n", "<leader>fc", function() p.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Config files" })

map("n", "<leader>sg", function() p.grep() end, { desc = "Grep" })
map({ "n", "x" }, "<leader>sw", function() p.grep_word() end, { desc = "Grep word/selection" })
map("n", "<leader>sd", function() p.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>sh", function() p.help() end, { desc = "Help pages" })
map("n", "<leader>sk", function() p.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>ss", function() p.lsp_symbols() end, { desc = "LSP symbols" })
map("n", "<leader>sr", function() p.resume() end, { desc = "Resume last picker" })

map("n", "<leader>xx", function() p.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>xX", function() p.diagnostics_buffer() end, { desc = "Buffer diagnostics" })

-- Toggles
map("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Toggle wrap" })
map("n", "<leader>us", function()
  vim.bo.spelllang = "de,en"
  vim.wo.spell = not vim.wo.spell
end, { desc = "Toggle spell" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
map("n", "<leader>uf", function()
  vim.g.autoformat = not vim.g.autoformat
  vim.notify("Format on save " .. (vim.g.autoformat and "enabled" or "disabled"))
end, { desc = "Toggle format on save" })
map("n", "<leader>uC", function() p.colorschemes() end, { desc = "Colorschemes" })

-- LSP (buffer-local, set when a server attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nv_lsp_keymaps", { clear = true }),
  callback = function(ev)
    local function m(lhs, rhs, desc, mode)
      map(mode or "n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    m("gd", function() p.lsp_definitions() end, "Goto definition")
    m("gr", function() p.lsp_references() end, "References")
    m("gI", function() p.lsp_implementations() end, "Goto implementation")
    m("gy", function() p.lsp_type_definitions() end, "Goto type definition")
    m("gD", vim.lsp.buf.declaration, "Goto declaration")
    m("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
    m("<leader>cr", vim.lsp.buf.rename, "Rename")
  end,
})
