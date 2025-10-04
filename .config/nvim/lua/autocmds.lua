-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Disable autoformatting for specific filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'yaml' }, -- Replace with your language(s)
  callback = function()
    vim.b.autoformat = false
  end,
})

-- handle all files in templates/* as helm files and disable diagnostic,
-- because it's crap
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*/templates/*.yaml' },
  callback = function()
    vim.bo.filetype = 'helm'
    vim.diagnostic.enable(false)
  end,
})
