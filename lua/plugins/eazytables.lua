return {
  {
    "dhruvasagar/vim-table-mode",
    config = function()
      -- 配置 vim-table-mode，启用 Markdown 风格的表格边框
      vim.g.table_mode_corner = "|"
    end,
  },
}
