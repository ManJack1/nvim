return {
  "jiaoshijie/undotree",
  dependencies = "nvim-lua/plenary.nvim",
  config = true,
  keys = { -- load the plugin only when using it's keybinding:
  },
  config = function()
    local wk = require("which-key")
    wk.add({ "<leader>U", "<cmd>lua require('undotree').toggle()<cr>", icon = "🍬", desc = "undotree" })
  end,
}
