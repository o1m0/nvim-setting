vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- keep the sign column open so git signs/diagnostics don't shift the text
vim.opt.signcolumn = "yes"
require("config.lazy")
require("config.lsp")
