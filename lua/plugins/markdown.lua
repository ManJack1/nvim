return {
  "MeanderingProgrammer/render-markdown.nvim",
  config = function()
    require("render-markdown").setup({
      callout = {
        theorem = {
          raw = "[!Theorem]",
          rendered = "  Theorem",
          highlight = "RenderMarkdownInfo",
          category = "github",
        },
      },
    })
  end,
}
