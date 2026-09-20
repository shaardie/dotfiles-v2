local o = vim.o

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 4
o.wrap = false
o.termguicolors = true
o.laststatus = 3
o.smoothscroll = true
o.jumpoptions = "view"

-- Indentation: 2 spaces
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.shiftround = true

-- Search
o.ignorecase = true
o.smartcase = true
o.grepprg = "rg --vimgrep"

-- Windows
o.splitright = true
o.splitbelow = true

-- Behaviour
o.undofile = true
o.updatetime = 200
o.timeoutlen = 300
o.confirm = true
o.mouse = "a"
o.autoread = true
if not vim.env.SSH_TTY then
  o.clipboard = "unnamedplus"
end

-- Whitespace hints
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"
