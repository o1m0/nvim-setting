-- Language servers managed by Mason, keyed by their nvim-lspconfig name.
-- The value lists the executables a server needs to be installed and run.
-- Servers whose prerequisites are missing are skipped, so a machine without
-- e.g. Node or a JDK starts cleanly instead of failing the install every time.
-- gopls is not listed: it comes from `go install` and is set up in config/lsp.lua.
local servers = {
  ts_ls = { "node", "npm" },
  html = { "node", "npm" },
  cssls = { "node", "npm" },
  jsonls = { "node", "npm" },
  yamlls = { "node", "npm" },
  bashls = { "node", "npm" },
  basedpyright = { "python3" },
  jdtls = { "java", "python3" },
}

local function mason_has(package)
  return vim.uv.fs_stat(vim.fn.stdpath("data") .. "/mason/packages/" .. package) ~= nil
end

local function installable(name, bins)
  for _, bin in ipairs(bins) do
    if vim.fn.executable(bin) == 0 then
      return false
    end
  end
  -- Mason installs basedpyright into a venv; Debian/Ubuntu ship that
  -- separately as python3-venv. Only probe while it is not installed yet.
  if name == "basedpyright" and not mason_has("basedpyright") then
    return vim.system({ "python3", "-c", "import ensurepip" }):wait().code == 0
  end
  return true
end

return {
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      -- only used as a source of server definitions (lsp/*.lua) for vim.lsp.config
      "neovim/nvim-lspconfig",
    },
    opts = function()
      local ensure_installed = {}
      for name, bins in pairs(servers) do
        if installable(name, bins) then
          table.insert(ensure_installed, name)
        end
      end
      table.sort(ensure_installed)

      return {
        ensure_installed = ensure_installed,
        -- calls vim.lsp.enable() for every server installed through Mason
        automatic_enable = true,
      }
    end,
  },
}
