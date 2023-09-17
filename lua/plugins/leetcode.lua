return {
  "Dhanus3133/LeetBuddy.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("leetbuddy").setup({
      domain = "com", -- `cn` for chinese leetcode
      language = "py",
    })
  end,
  keys = {
    { "<leader>o", desc = "LeetCode" },
    { "<leader>oq", "<cmd>LBQuestions<cr>", desc = "List Questions" },
    { "<leader>ol", "<cmd>LBQuestion<cr>", desc = "View Question" },
    { "<leader>or", "<cmd>LBReset<cr>", desc = "Reset Code" },
    { "<leader>ot", "<cmd>LBTest<cr>", desc = "Run Code" },
    { "<leader>os", "<cmd>LBSubmit<cr>", desc = "Submit Code" },
  },
}
