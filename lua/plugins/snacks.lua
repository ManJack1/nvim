-- lazy.nvim
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {

    picker = {
      sources = {
        noice = {
          confirm = { "yank", "close" },
        },
      },
    },
  },
  image = {
    ---@class snacks.image.Config
    enabled = true,
    doc = {
      -- enable image viewer for documents
      -- a treesitter parser must be available for the enabled languages.
      -- supported language injections: markdown, html
      enabled = true,
      -- render the image inline in the buffer
      -- if your env doesn't support unicode placeholders, this will be disabled
      -- takes precedence over `opts.float` on supported terminals
      inline = true,
      -- render the image in a floating window
      -- only used if `opts.inline` is disabled
      float = true,
      max_width = 40,
      max_height = 40,
      math = {
        latex = {
          font_size = "normalsize",
        },
      },
    },
  },
}
