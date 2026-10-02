-- LSP via Neovim 0.11's built-in client (vim.lsp.config / vim.lsp.enable).
-- Servers other than gopls are installed and enabled in plugins/lsp.lua.
--
-- Keymaps: K, grn, grr, gra, gri, gO and <C-s> (insert) are Neovim defaults;
-- only gd/gD are added below.

-- gopls comes from `go install`, which may not be on PATH (e.g. GUI launch)
local gopls = vim.fn.exepath("gopls")
if gopls == "" then
  gopls = vim.fn.expand("~/go/bin/gopls")
end

-- Advertise nvim-cmp's completion capabilities to every server
vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config("gopls", {
  cmd = { gopls },
  filetypes = { "go", "gomod" },
  root_markers = { "go.work", "go.mod", ".git" },
})
vim.lsp.enable("gopls")

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  end,
})

-- Format Go files with gopls on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("go_format_on_save", { clear = true }),
  pattern = "*.go",
  callback = function(args)
    if #vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" }) == 0 then
      return
    end
    vim.lsp.buf.format({ bufnr = args.buf, name = "gopls", timeout_ms = 2000 })
  end,
})
