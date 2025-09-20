-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
local luasnip = require("luasnip")
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local wk = require("which-key")

wk.add({
  {
    "<leader>o",
    function()
      require("oil").toggle_float()
    end,
    desc = "Oil_Float",
    icon = "",
  },
})
-- which-key 添加快捷键
wk.add({
  { "m", "<cmd>WhichKey m<cr>", desc = "󰬔 trigger" },
  { "mo", "<cmd>CompilerOpen<cr>", desc = "CompilerOpen" },
  { "mm", "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", desc = "CompilerRedo" },
  { "mt", "<cmd>CompilerToggleResults<cr>", desc = "CompilerToggleResults" },
})

wk.add({
  "<leader>cP",
  function()
    local file_path = vim.fn.expand("%:p") -- Get the full path of the current file
    vim.fn.setreg("+", file_path) -- Copy it to the clipboard
    vim.notify("File path copied: " .. file_path) -- Show a notification
  end,
  desc = "Copy current file path",
})

-- Telescope 映射
map("n", "<leader>so", ":Telescope vim_options<CR>", { desc = "Options" })
map("n", "<leader>se", ":Telescope diagnostics<CR>", { desc = "View Errors" })
map("i", "<C-e>", "<C-o>A", opts)

-- 删除插入模式下的 <Tab> 映射（UltiSnips 用法）
-- vim.api.nvim_del_keymap("i", "<Tab>")
-- vim.api.nvim_del_keymap("s", "<Tab>")

-- 绑定 <Tab> 键用于 UltiSnips 扩展或跳转
-- map("i", "<Tab>", "v:lua.MaybeExpandOrJump()", { expr = true, noremap = true, silent = true })
-- map("s", "<Tab>", "v:lua.MaybeExpandOrJump()", { expr = true, noremap = true, silent = true })

-- Lua 函数实现 UltiSnips 扩展或跳转
-- function MaybeExpandOrJump()
--   if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
--     return vim.api.nvim_replace_termcodes("<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>", true, true, true)
--   else
--     return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
--   end
-- end

map("i", "<C-l>", "<Right>", opts)

map("i", "<C-h>", "<Left>", opts)

-- -- 使用 <C-l> 前向跳出
-- map("i", "<C-l>", "<Plug>(Tabout)", opts)
-- -- 使用 <C-h> 反向跳出
-- map("i", "<C-h>", "<Plug>(TaboutBack)", opts)

-- 将 Tab 键绑定到表格单元格跳转
-- 使用 <Leader> 键作为前缀
map("i", "<C-j>", "<Cmd>lua jump_to_next_cell()<CR>", opts)
map("i", "<C-k>", "<Cmd>lua jump_to_previous_cell()<CR>", opts)

-- Table Mode 快捷键设置
map("n", "<leader>mm", ":TableModeToggle<CR>", { desc = "Toggle Table Mode" })
map("n", "<leader>mr", ":TableModeRealign<CR>", { desc = "Realign Table" })
map("n", "<leader>mc", ":lua InsertTableRowBelow()<CR>", { desc = "Insert Table Row Below" })
map("n", "<leader>mb", ":MdEval<CR>", { desc = "Insert Table Row Below" })

-- 加载LuaSnip
local ls = require("luasnip")

-- 定义可以Tabout的字符
local tabout_forward_chars = { "]", ")", "}", ">", '"', "'", "`", "," }
local tabout_backward_chars = { "[", "(", "{", "<", '"', "'", "`" }

-- 辅助函数：检查是否可以向前Tabout
local function can_tabout_forward()
  local col = vim.fn.col(".") - 1
  local line = vim.fn.getline(".")
  if col < #line then
    local next_char = line:sub(col + 1, col + 1)
    for _, char in ipairs(tabout_forward_chars) do
      if next_char == char then
        return true
      end
    end
  end
  return false
end

-- 辅助函数：检查是否可以向后Tabout
local function can_tabout_backward()
  local col = vim.fn.col(".") - 1
  local line = vim.fn.getline(".")
  if col > 0 then
    local curr_char = line:sub(col, col)
    for _, char in ipairs(tabout_backward_chars) do
      if curr_char == char then
        return true
      end
    end
  end
  return false
end

-- Tab键映射 (插入和选择模式)
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  -- 1. 检查LuaSnip
  if ls.jumpable(1) then
    return "<Plug>luasnip-jump-next"
  end

  -- 仅在插入模式下
  if vim.fn.mode() == "i" then
    -- 2. 检查LuaSnip是否可展开
    if ls.expandable() then
      return "<Plug>luasnip-expand"
    end

    -- 3. 检查是否可以Tabout
    if can_tabout_forward() then
      return "<Plug>(TaboutMulti)"
    end
  end

  -- 4. 默认行为：插入Tab
  return "<Tab>"
end, { expr = true })

-- Shift+Tab键映射 (插入和选择模式)
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  -- 1. 检查LuaSnip
  if ls.jumpable(-1) then
    return "<Plug>luasnip-jump-prev"
  end

  -- 仅在插入模式下
  if vim.fn.mode() == "i" then
    -- 2. 检查是否可以向后Tabout
    if can_tabout_backward() then
      return "<Plug>(TaboutBackMulti)"
    end
  end

  -- 3. 默认行为：插入Shift+Tab
  return "<S-Tab>"
end, { expr = true })

-- Set up keymaps with conditional logic
vim.keymap.set({ "i", "s" }, "<C-n>", function()
  local luasnip = require("luasnip")
  if luasnip.choice_active() then
    return "<Plug>luasnip-next-choice"
  else
    vim.notify("No active choice nodes", vim.log.levels.INFO)
    return ""
  end
end, { expr = true })

vim.keymap.set({ "i", "s" }, "<C-p>", function()
  local luasnip = require("luasnip")
  if luasnip.choice_active() then
    return "<Plug>luasnip-prev-choice"
  else
    vim.notify("No active choice nodes", vim.log.levels.INFO)
    return ""
  end
end, { expr = true })
