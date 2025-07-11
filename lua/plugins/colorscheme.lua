return {
  "Mofiqul/dracula.nvim",
  priority = 1000, -- Ensure it loads first
  config = function()
    vim.o.background = "dark" -- or "light" for light mode
    vim.cmd([[colorscheme dracula]])
  end,
}
