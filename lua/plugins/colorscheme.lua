return {
  "neanias/everforest-nvim",
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    require("everforest").setup({
      -- 配置
    })
    vim.cmd([[colorscheme everforest]])
  end,
}
