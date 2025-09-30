return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  config = function()
    require("render-markdown").setup({
      completions = { lsp = { enabled = true } },
      heading = {
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        right_pad = 1,
        sign = false,
        width = "block",
      },
      checkbox = {
        checked = {
          icon = "   󰄲 ",
          scope_highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = {
            rendered = "   󰥔 ",
          },
        },
        position = "inline",
        unchecked = {
          icon = "   󰄱 ",
        },
      },
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
