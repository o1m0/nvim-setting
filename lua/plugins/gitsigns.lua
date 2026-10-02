return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("]h", function()
          gitsigns.nav_hunk("next")
        end, "Next hunk")
        map("[h", function()
          gitsigns.nav_hunk("prev")
        end, "Previous hunk")
        map("<leader>hp", gitsigns.preview_hunk, "Preview hunk")
        map("<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, "Blame line")
      end,
    },
  },
}
