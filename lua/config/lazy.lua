local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- lazy.nvim resets the runtimepath and guesses /usr/lib64/nvim on Ubuntu,
-- but the bundled Tree-sitter parsers live in /usr/lib/nvim. Keep that dir.
-- The path is derived from the nvim binary, so on macOS (Homebrew) this just
-- re-adds the dir lazy.nvim already keeps and is harmless.
local rtp_paths = {}
local nvim_lib = vim.fn.fnamemodify(vim.v.progpath, ":p:h:h") .. "/lib/nvim"
if vim.loop.fs_stat(nvim_lib) then
  table.insert(rtp_paths, nvim_lib)
end

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  performance = {
    rtp = {
      paths = rtp_paths,
    },
  },
})
