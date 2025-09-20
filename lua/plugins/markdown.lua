return {
  "MeanderingProgrammer/render-markdown.nvim",
  config = function()
    require("render-markdown").setup({
      callout = {
        definition = {
          raw = "[!Definition]",
          rendered = "  Definition",
          highlight = "RenderMarkdownInfo",
          category = "github",
        },

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
