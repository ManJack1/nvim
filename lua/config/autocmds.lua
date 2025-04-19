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

-- 针对 TeX 文件加载自定义 Snippet 文件
-- 递归加载特定目录下的所有 snippets 文件
-- local scandir = require("plenary.scandir")

-- function UltiSnipsAdd(opts)
--   local dir = opts.dir or "~/.config/nvim/ultisnips" -- snippets 文件夹路径
--   local filetypes = opts.filetypes or {} -- 文件类型列表
--   local auto_load = opts.auto_load or false -- 是否自动加载
--   local pattern = opts.pattern or "%.snippets$" -- 文件匹配模式
--
--   -- 扫描目录下符合条件的 snippets 文件
--   local files = scandir.scan_dir(vim.fn.expand(dir), { search_pattern = pattern })
--
--   -- 为每个指定的文件类型设置 autocommand 或立即加载
--   for _, ft in ipairs(filetypes) do
--     if auto_load then
--       -- 设置 autocommand，自动加载 snippets
--       vim.api.nvim_create_autocmd("FileType", {
--         pattern = ft,
--         callback = function()
--           for _, file in ipairs(files) do
--             vim.cmd("UltiSnipsAddFiletypes " .. vim.fn.fnamemodify(file, ":t:r"))
--           end
--         end,
--       })
--     else
--       -- 立即加载 snippets 文件
--       for _, file in ipairs(files) do
--         vim.cmd("UltiSnipsAddFiletypes " .. vim.fn.fnamemodify(file, ":t:r"))
--       end
--     end
--   end
-- end
--
-- UltiSnipsAdd({
--   dir = "~/.config/nvim/ultisnips/tex",
--   filetypes = { "tex" },
--   auto_load = true, -- 设置 autocommand，自动加载
-- })

-- 自动为 LaTeX 文件类型添加命令和快捷键映射
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "markdown" }, -- 当文件类型为 .tex 或 .md 时触发
  callback = function()
    -- 创建命令来执行转换操作
    vim.api.nvim_create_user_command("OrgTblToLatex", function()
      print("OrgTblToLatex command triggered!") -- 调试：确认命令触发
      orgtbl_to_latex_matrix()
    end, { range = true })

    -- 设置键映射，按 m l z 触发表格转换，仅在 LaTeX 文件类型中生效
    vim.api.nvim_set_keymap("v", "mlZ", ":<C-U>OrgTblToLatex<CR>", { noremap = true, silent = true })
    print("Keymap for mlz set!") -- 调试：确认键映射设置成功
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
