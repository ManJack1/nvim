-- Visual 模式下快速批量替换文本
-- 使用方法: 在 visual 模式选中文本后按 Ctrl-r

-- 获取 visual 模式选中的文本
local function get_visual_selection()
  -- 保存当前寄存器内容
  local save_reg = vim.fn.getreg('"')
  local save_regtype = vim.fn.getregtype('"')

  -- 复制选中内容到寄存器
  vim.cmd('normal! "xy')
  local selection = vim.fn.getreg("x")

  -- 恢复寄存器
  vim.fn.setreg('"', save_reg, save_regtype)

  return selection
end

-- 转义特殊字符用于搜索
local function escape_pattern(text)
  return vim.fn.escape(text, "/\\")
end

-- Visual 模式替换函数
local function visual_replace()
  -- 获取选中的文本
  local selection = get_visual_selection()

  if selection == "" then
    print("No text selected")
    return
  end

  -- 转义特殊字符
  local escaped = escape_pattern(selection)

  -- 构建替换命令并进入命令行
  -- 用户可以修改替换目标文本
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":<C-u>%s/" .. escaped .. "/", "n", true, true), "n", false)
end

-- 设置快捷键: Visual 模式下 Ctrl-r 进行批量替换
vim.keymap.set("x", "<C-r>", visual_replace, {
  noremap = true,
  silent = false,
  desc = "Replace visual selection",
})

print("Visual replace loaded: Select text and press Ctrl-r")
