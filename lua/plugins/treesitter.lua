return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- master builds parsers with just a C compiler; main needs the tree-sitter CLI
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      -- vim/vimdoc/query/c keep using the parsers bundled with Neovim
      ensure_installed = {
        "bash",
        "css",
        "go",
        "gomod",
        "gosum",
        "html",
        "java",
        "javascript",
        "json",
        -- tsconfig.json and friends are detected as jsonc
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "tsx",
        "typescript",
        "yaml",
      },
      highlight = { enable = true },
    },
  },
}
