-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--

-- Disable autoformatting for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml" }, -- Replace with your language(s)
  callback = function()
    vim.b.autoformat = false
  end,
})

-- do not conceal ``` in Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "md" },
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.diagnostic.enable(false)
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
