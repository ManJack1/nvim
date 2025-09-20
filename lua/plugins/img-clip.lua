return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    -- For other filetypes, the default is markdown
    filetypes = {
      tex = {
        use_absolute_path = true,
      },
    },
  },
}
