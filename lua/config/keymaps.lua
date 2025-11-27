-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keymaps are automatically loaded on the VeryLazy event
-- Add any additional keymaps here
local luasnip = require("luasnip")
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local wk = require("which-key")

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
map("n", "<leader>so", ":Telescope vim_options<CR>", { desc = "search options" })
map("n", "<leader>se", ":Telescope diagnostics<CR>", { desc = "View Errors" })
map("i", "<C-l>", "<Right>", opts)
map("i", "<C-h>", "<Left>", opts)
map("v", "<C-h>", "0", opts)
map("v", "<C-l>", function()
  vim.cmd("normal! $")
end, opts)

map("i", "<C-j>", "<Cmd>lua jump_to_next_cell()<CR>", opts)
map("i", "<C-k>", "<Cmd>lua jump_to_previous_cell()<CR>", opts)

wk.add({ { "<leader>K", icon = "🍬" } })

map({ "n", "v" }, "<leader>aP", "<Cmd>CopilotChatPrompts<CR>", { desc = "Copilot Prompts" })

map({ "n", "v" }, "<leader>aA", "<Cmd>CopilotChat<CR>", { desc = "Copilot Prompts" })

wk.add({ "<leader>m", group = "markdown-table", icon = "🍬" })
map("n", "<leader>mm", ":TableModeToggle<CR>", { desc = "Toggle Table Mode" })
map("n", "<leader>mr", ":TableModeRealign<CR>", { desc = "Realign Table" })
map("n", "<leader>mc", ":lua InsertTableRowBelow()<CR>", { desc = "Insert Table Row Below" })
map("n", "<leader>sl", ":Telescop luasnip<CR>", { desc = "elescop luasnip" })
