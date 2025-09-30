return {
  "mg979/vim-visual-multi",
  version = "*",
  ft = "markdown",
  config = function()
    local wk = require("which-key")
    local map = vim.keymap.set
    wk.add({ "<leader>m", group = "markdown-table", icon = "🍬" })
    map("n", "<leader>mm", ":TableModeToggle<CR>", { desc = "Toggle Table Mode" })
    map("n", "<leader>mr", ":TableModeRealign<CR>", { desc = "Realign Table" })
    map("n", "<leader>mc", ":lua InsertTableRowBelow()<CR>", { desc = "Insert Table Row Below" })
    map("n", "<leader>mb", ":MdEval<CR>", { desc = "Insert Table Row Below" })
  end,
}
