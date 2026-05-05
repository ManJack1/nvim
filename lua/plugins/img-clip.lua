return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown", "tex" },
  opts = {
    default = {
      dir_path = "assets",
      use_absolute_path = false,
      relative_to_current_file = false,
    },
    filetypes = {
      markdown = {
        dir_path = function()
          return vim.fn.expand("%:p:h") .. "/assets"
        end,
        relative_template_path = true,
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)",
        use_cursor_in_template = true,
        download_images = false,
      },
      tex = {
        use_absolute_path = true,
      },
    },
  },
  config = function(_, opts)
    require("img-clip").setup(opts)
    local map = vim.keymap.set
    local wk = require("which-key")
    wk.add({ "<leader>i", group = "image-clip", icon = "🍬" })
    map("n", "<leader>ip", "<cmd>PasteImage<cr>", { desc = "paste image for system clipboard" })
  end,
}
