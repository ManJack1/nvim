return {
  {
    lazy = false,
    "KeitaNakamura/tex-conceal.vim",
    ft = "tex", -- 仅在 tex 文件类型时加载
    config = function()
      -- 启用 conceal 功能
      vim.opt.conceallevel = 2

      -- tex-conceal 推荐设置
      vim.g.tex_superscripts = "[0-9a-zA-W.,:;+-<>/()=]"
      vim.g.tex_subscripts = "[0-9aehijklmnoprstuvx,+-/().]"
      vim.g.tex_conceal_frac = 1
      vim.g.tex_conceal = "abdgm"
    end,
  },
}
