-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
----nvim-cmp
local cmp = require("cmp")

-- NOTE:会导致没有选项栏
local default_mapping = {
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<C-e>"] = cmp.mapping.abort(),
  ["<CR>"] = cmp.mapping.confirm({ select = true }),
  ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
  ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
}
-- tex 文件类型映射
local tex_mapping = {
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<C-e>"] = cmp.mapping.abort(),
  ["<CR>"] = cmp.mapping.confirm({ select = true }),
  ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
  ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
}

-- 自动命令回调函数
local function set_mappings()
  -- 针对 tex 和 markdown 文件类型设置特殊映射
  if vim.bo.filetype == "tex" or vim.bo.filetype == "markdown" then
    cmp.setup.buffer({ mapping = tex_mapping })
  else
    cmp.setup.buffer({ mapping = default_mapping })
  end
end

-- 定义和设置自动命令
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = set_mappings,
})

---------------illustrate
-- keymap.lua

-- 确保 'illustrate' 插件已经加载

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
