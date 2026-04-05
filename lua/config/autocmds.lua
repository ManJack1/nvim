-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

---------------illustrate
-- 定义一个函数来设置 tex 文件类型的键映射
local function set_tex_keymaps(event)
  local map = vim.keymap.set
  local opts = { buffer = event.buf, silent = true }

  map("n", "<leader>is", function()
    require("illustrate").create_and_open_svg()
  end, vim.tbl_extend("force", opts, { desc = "Create and open a new SVG file with provided name." }))

  map("n", "<leader>ia", function()
    require("illustrate").create_and_open_ai()
  end, vim.tbl_extend("force", opts, { desc = "Create and open a new Adobe Illustrator file with provided name." }))

  map("n", "<leader>io", function()
    require("illustrate").open_under_cursor()
  end, vim.tbl_extend("force", opts, { desc = "Open file under cursor (or file within environment under cursor)." }))

  map("n", "<leader>if", function()
    require("illustrate.finder").search_and_open()
  end, vim.tbl_extend("force", opts, { desc = "Use telescope to search and open illustrations in default app." }))

  map("n", "<leader>ic", function()
    require("illustrate.finder").search_create_copy_and_open()
  end, vim.tbl_extend("force", opts, {
    desc = "Use telescope to search existing file, copy it with new name, and open it in default app.",
  }))
end

local function open_trouble_quickfix()
  vim.cmd("Trouble quickfix")
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
  callback = open_trouble_quickfix,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileFailed",
  callback = open_trouble_quickfix,
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
    vim.diagnostic.enable(false, { bufnr = 0 })
  end,
})
