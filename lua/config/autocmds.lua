-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("mygroup_" .. name, { clear = true })
end
-----TODO:nabla.lua
local function configure_nabla()
  require("nabla").enable_virt({
    autogen = true,
    silent = true,
  })
end

--设置一个自动命令以便在打开 '.tex' 文件时调用 `configure_nabla`
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("latex_nabla"),
  pattern = { "tex" },
  callback = configure_nabla,
})
-----nabla.lua
