local parsers = require("nvim-treesitter.parsers")
local M = {}

-- 获取当前光标所在的节点
local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1 -- 行号从 0 开始
  local cursor_col = cursor[2] -- 列号从 0 开始
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local lang = filetype == "markdown" and "markdown" or "latex"

  -- 尝试获取解析器
  local ok, parser = pcall(parsers.get_parser, buf, lang)
  if not ok or not parser then
    return nil
  end

  -- 解析语法树
  local tree = parser:parse()[1]
  if not tree then
    return nil
  end

  -- 返回光标所在位置的节点
  return tree:root():descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)
end

-- 检查是否在代码块中
local function in_code_block()
  local node = get_node_at_cursor()
  while node do
    local node_type = node:type()
    -- 检查各种代码块节点类型
    if
      node_type == "fenced_code_block"
      or node_type == "code_block"
      or node_type == "indented_code_block"
      or node_type == "code_fence_content"
      or node_type == "code_span"
      or node_type == "inline_code"
    then
      return true
    end
    node = node:parent()
  end
  return false
end

-- 基于文本模式的数学环境检测（备用方案）
local function text_based_math_detection()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- 检查行内数学 $...$
  local before_cursor = line:sub(1, col)
  local after_cursor = line:sub(col + 1)

  -- 计算光标前后的 $ 符号数量
  local dollars_before = 0
  local dollars_after = 0

  for _ in before_cursor:gmatch("%$") do
    dollars_before = dollars_before + 1
  end

  for _ in after_cursor:gmatch("%$") do
    dollars_after = dollars_after + 1
  end

  -- 如果前面有奇数个 $，后面有至少一个 $，则可能在数学环境中
  if dollars_before % 2 == 1 and dollars_after > 0 then
    return true
  end

  -- 检查多行数学环境 $$...$$
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1]
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- 向上查找 $$
  local math_start = false
  for i = current_line, 1, -1 do
    if buf_lines[i] and buf_lines[i]:match("%$%$") then
      math_start = true
      break
    end
  end

  if math_start then
    -- 向下查找结束的 $$
    for i = current_line, #buf_lines do
      if buf_lines[i] and buf_lines[i]:match("%$%$") and i > current_line then
        return true
      end
    end
  end

  return false
end

-- 检测是否在 LaTeX 或 Markdown 的数学环境中
function M.in_mathzone()
  -- 首先检查是否在代码块中
  if in_code_block() then
    return false
  end

  -- Treesitter 检测
  local node = get_node_at_cursor()
  if node then
    while node do
      local node_type = node:type()

      -- 检查所有可能的数学相关节点类型
      local math_node_types = {
        "inline_math",
        "math_block",
        "displayed_equation",
        "inline_formula",
        "math_environment",
        "latex_block",
        "math_span",
      }

      for _, math_type in ipairs(math_node_types) do
        if node_type == math_type then
          return true
        end
      end

      -- 检查包含 $ 的节点
      if node_type == "inline" or node_type == "$" or node_type == "text" then
        local success, node_text = pcall(vim.treesitter.get_node_text, node, 0)
        if success and node_text and node_text:match("%$") then
          return true
        end
      end

      -- 检查 LaTeX 环境
      if node_type == "generic_environment" or node_type == "math_environment" then
        local start_node = node:child(0)
        if start_node then
          local success, text = pcall(vim.treesitter.get_node_text, start_node, 0)
          if success and text then
            local math_envs = {
              "equation",
              "align",
              "gather",
              "multline",
              "displaymath",
              "eqnarray",
              "flalign",
              "alignat",
              "math",
              "displaymath",
            }
            for _, env in ipairs(math_envs) do
              if text:match("\\begin{" .. env .. "}") then
                return true
              end
            end
          end
        end
      end

      node = node:parent()
    end
  end

  -- 如果 Treesitter 检测失败，使用基于文本的检测
  return text_based_math_detection()
end

-- 检测是否在文本环境中
function M.in_text()
  return not M.in_mathzone()
end

return M
