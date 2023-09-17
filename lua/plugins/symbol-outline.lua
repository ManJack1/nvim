return {
  "simrat39/symbols-outline.nvim",
  config = function()
    require("symbols-outline").setup()
  end,
  keys = {
    { "<leader>S", desc = "SymbolsOutline" },
    { "<leader>Ss", "<cmd>SymbolsOutlineOpen<cr>", desc = "symbolsOutlineOpen" },
    { "<leader>SS", "<cmd>SymbolsOutlineClose<cr>", desc = "symbolsOutlineClose" },
  },
}
