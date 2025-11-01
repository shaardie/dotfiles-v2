-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Disable autoformatting for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml" }, -- Replace with your language(s)
  callback = function()
    vim.b.autoformat = false
  end,
})

-- handle all files in templates/* as helm files and disable diagnostic,
-- because it's crap
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*/templates/*.yaml" },
  callback = function()
    vim.bo.filetype = "helm"
    vim.diagnostic.enable(false)
  end,
})

-- do not conceal markdown.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Conceal ausschalten
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
  end,
})
