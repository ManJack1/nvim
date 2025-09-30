return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown", "tex" },
  opts = {
    -- For other filetypes, the default is markdown
    filetypes = {
      tex = {
        use_absolute_path = true,
      },
    },
  },
  config = function()
    local map = vim.keymap.set
    local wk = require("which-key")
    wk.add({ "<leader>i", group = "image-clip", icon = "🍬" })
    map("n", "<leader>ip", "<cmd>PasteImage<cr>", { desc = "paste image for system clipboard" })
  end,
}
