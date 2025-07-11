local parsers = require("nvim-treesitter.parsers")

local M = {}

---
-- 创建一个 Set 以便快速查找.
-- @param list (table) 一个数组 list.
-- @return (table) 一个 set-like table.
local function new_set(list)
  local set = {}
  for _, item in ipairs(list) do
    set[item] = true
  end
  return set
end

-- 为 LaTeX 和 Markdown 定义已知的数学节点类型
-- 你可以通过 :TSEdit 命令查看并添加更多特定的节点类型
local math_node_types = new_set({
  -- LaTeX
  "inline_formula", -- $...$
  "displayed_equation", -- $$...$$
  "math_environment", -- \begin{equation}...\end{equation}

  -- Markdown
  "inline_math", -- $...$
  "math_block", -- $$...$$
})

-- 定义已知的 LaTeX 数学环境名称
local latex_math_environments = new_set({
  "math",
  "displaymath",
  "equation",
  "equation*",
  "align",
  "align*",
  "alignat",
  "alignat*",
  "gather",
  "gather*",
  "flalign",
  "flalign*",
  "multline",
  "multline*",
  "cases",
  "dmath",
  "dmath*",
})

-- 获取当前光标所在的节点
local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- Tree-sitter a a 0-indexed API
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]

  local buf = vim.api.nvim_get_current_buf()
  -- 使用 vim.bo[buf] 来确保获取的是指定缓冲区的 filetype
  local filetype = vim.bo[buf].filetype
  -- 简单处理，可以根据需要扩展到 quarto, rmarkdown 等
  local lang = (filetype == "markdown" or filetype == "quarto") and "markdown" or "latex"

  local parser = parsers.get_parser(buf, lang)
  if not parser then
    return nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  -- 返回光标所在位置的最深层节点
  return tree:root():descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)
end

-- 检测是否在 LaTeX 或 Markdown 的数学环境中
function M.in_mathzone()
  local node = get_node_at_cursor()
  if not node then
    return false
  end

  while node do
    local node_type = node:type()

    -- 1. 直接检查节点类型是否在我们的数学节点集合中
    if math_node_types[node_type] then
      return true
    end

    -- 2. 特别处理 LaTeX 的通用环境 (generic_environment)
    --    因为某些解析器不会为所有数学环境提供唯一的节点类型
    if node_type == "generic_environment" then
      local begin_node = node:child(0)
      -- 检查第一个子节点是否为 \begin{...}
      if begin_node and begin_node:type() == "begin" then
        local begin_text = vim.treesitter.get_node_text(begin_node, 0)
        -- 精确提取环境名称
        local env_name = begin_text:match("^\\begin%s*{(.-)}")
        if env_name and latex_math_environments[env_name] then
          return true
        end
      end
    end

    node = node:parent()
  end

  return false
end

-- 检测是否在文本环境中
function M.in_text()
  -- 如果不在数学环境中，则认为在文本环境中
  return not M.in_mathzone()
end

return M
