return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    config = function()
      require("render-markdown").setup({
        render_modes = true,
        latex = {
          enabled = true,
          render_modes = false,
          converter = "latex2text",
          highlight = "RenderMarkdownMath",
          position = "above",
          top_pad = 0,
          bottom_pad = 0,
        },
      })
    end,
  },
  {
    event = "VeryLazy",
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- 仅在 markdown 文件类型时启用
    config = function()
      require("markdown").setup({
        -- 在这里可以添加其他配置选项
        mappings = {
          inline_surround_toggle = "gs", -- 切换行内强调
          link_add = "gl", -- 添加链接
          link_follow = "gx", -- 跟随链接
          go_curr_heading = "]c", -- 跳转到当前标题
          go_next_heading = "]]", -- 跳转到下一个标题
          go_prev_heading = "[[", -- 跳转到上一个标题
        },
      })
    end,
  },
}
