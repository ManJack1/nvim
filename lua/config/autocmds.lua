-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

---------------illustrate
-- 定义一个函数来设置 tex 文件类型的键映射
local function set_tex_keymaps()
  vim.api.nvim_set_keymap(
    "n",
    "<leader>is",
    '<cmd>lua require"illustrate".create_and_open_svg()<CR>',
    { noremap = true, silent = true, desc = "Create and open a new SVG file with provided name." }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>ia",
    '<cmd>lua require"illustrate".create_and_open_ai()<CR>',
    { noremap = true, silent = true, desc = "Create and open a new Adobe Illustrator file with provided name." }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>io",
    '<cmd>lua require"illustrate".open_under_cursor()<CR>',
    { noremap = true, silent = true, desc = "Open file under cursor (or file within environment under cursor)." }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>if",
    '<cmd>lua require"illustrate.finder".search_and_open()<CR>',
    { noremap = true, silent = true, desc = "Use telescope to search and open illustrations in default app." }
  )
  vim.api.nvim_set_keymap("n", "<leader>ic", '<cmd>lua require"illustrate.finder".search_create_copy_and_open()<CR>', {
    noremap = true,
    silent = true,
    desc = "Use telescope to search existing file, copy it with new name, and open it in default app.",
  })
end

-- 创建一个自动命令，当文件类型为 tex 时调用上述函数
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = set_tex_keymaps,
})

-- 禁用 VimTeX 的 quickfix 功能
vim.g.vimtex_quickfix_mode = 0
-- 配置 VimTeX 使用 Trouble 插件
vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileSuccess",
  callback = function()
    vim.cmd("Trouble quickfix")
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileFailed",
  callback = function()
    vim.cmd("Trouble quickfix")
  end,
})

-- Ensure diagnostic configuration is set for each attached LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = false, -- Disable virtual text
    })
  end,
})

-- 当打开 markdown 文件时自动禁用诊断
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.diagnostic.disable(0)
  end,
})
