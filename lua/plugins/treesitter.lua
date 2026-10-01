return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- master builds parsers with just a C compiler; main needs the tree-sitter CLI
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      -- lua/vim/vimdoc/etc. keep using the parsers bundled in /usr/lib/nvim
      ensure_installed = { "go" },
      highlight = { enable = true },
    },
  },
}
