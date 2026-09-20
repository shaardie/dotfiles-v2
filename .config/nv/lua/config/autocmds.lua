local function aug(name)
  return vim.api.nvim_create_augroup("nv_" .. name, { clear = true })
end

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug("yank"),
  callback = function() vim.hl.on_yank() end,
})

-- Equalize splits on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
  group = aug("resize"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug("last_pos"),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some buffers with q
vim.api.nvim_create_autocmd("FileType", {
  group = aug("close_q"),
  pattern = { "help", "qf", "man", "checkhealth" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Reload files changed on disk (e.g. by an agent in another terminal)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
  group = aug("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Prose: spell check and soft wrap
vim.api.nvim_create_autocmd("FileType", {
  group = aug("prose"),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    -- spelllang is set here, not globally, so dictionaries load only when needed
    vim.bo.spelllang = "de,en"
    vim.wo.spell = true
    vim.wo.wrap = true
    vim.wo.linebreak = true
  end,
})

-- `nvim <dir>`: make that directory the working directory
vim.api.nvim_create_autocmd("VimEnter", {
  group = aug("cd_dir"),
  callback = function()
    local arg = vim.fn.argv(0)
    if vim.fn.argc() == 1 and type(arg) == "string" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd.cd(vim.fn.fnameescape(arg))
    end
  end,
})

-- Files in templates/ are Helm templates; their diagnostics are noise (buffer-local)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = aug("helm_templates"),
  pattern = { "*/templates/*.yaml" },
  callback = function(ev)
    vim.bo[ev.buf].filetype = "helm"
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})
