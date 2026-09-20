vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("plugins")
require("lsp")
require("config.keymaps") -- after plugins: uses snacks and which-key
require("config.autocmds")
