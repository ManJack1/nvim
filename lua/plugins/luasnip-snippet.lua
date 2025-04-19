return {
  -- 安装 luasnip-latex-snippets.nvim
  -- {
  --   "iurimateus/luasnip-latex-snippets.nvim",
  --   dependencies = {
  --     "L3MON4D3/LuaSnip", -- 必须依赖 LuaSnip 插件
  --     "lervag/vimtex", -- 如果使用 treesitter，这里可以省略
  --   },
  --   config = function()
  --     require("luasnip-latex-snippets").setup({
  --       use_treesitter = false, -- 是否使用 treesitter 来判断光标是否在数学模式中
  --       allow_on_markdown = true, -- 是否在 Markdown 文件类型中启用代码片段
  --     })
  --     require("luasnip").config.setup({ enable_autosnippets = true }) -- 启用自动片段
  --   end,
  -- },
}
