-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--python loaded filetypes

--leting python into python3
vim.g.pymode_python = "python3"
vim.g.syntastic_python_python_exec = "python3"

-- 启用自动换行
vim.opt.wrap = true
-- 当窗口尺寸变化时自动换行
vim.opt.linebreak = true
