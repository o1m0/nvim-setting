return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- file icons; needs a Nerd Font (WezTerm ships a fallback)
      "nvim-tree/nvim-web-devicons",
    },

    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle<cr>",
        desc = "Toggle file tree",
      },
    },
    opts = {
      filesystem = {
        filtered_items = {
          -- show dotfiles and gitignored files (dimmed); H toggles them
          visible = true,
        },
        follow_current_file = { enabled = true },
      },
    },
  },
}
