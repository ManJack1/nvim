return {
  "jubnzv/mdeval.nvim",
  ft = "markdown",
  cmd = { "MdEval" },
  config = function()
    local map = vim.keymap.set
    map("n", "<leader>mb", ":MdEval<CR>", { desc = "Run markdown code block" })
  end,
}
