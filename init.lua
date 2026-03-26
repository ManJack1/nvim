-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Defer custom visual-replace keymap setup until LazyVim finishes startup.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("scripts.replace")
  end,
})
