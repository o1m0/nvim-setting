-- gopls via Neovim 0.11's built-in LSP client (no plugin needed)
local gopls = vim.fn.exepath("gopls")
if gopls == "" then
  gopls = vim.fn.expand("~/go/bin/gopls")
end

vim.lsp.config("gopls", {
  cmd = { gopls },
  filetypes = { "go", "gomod" },
  root_markers = { "go.work", "go.mod", ".git" },
})
vim.lsp.enable("gopls")

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/completion") then
      vim.opt_local.completeopt = { "menuone", "noselect", "popup" }
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, opts)
  end,
})
