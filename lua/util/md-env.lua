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
  "equation_environment",
  "align_environment",
  "display_math",
  "formula",
  "math",
  "equation",
  "math_delimiter",
  "dollar_math",

  -- Markdown
  "inline_math", -- $...$
  "math_block", -- $$...$$
  "latex_block",
  "code_fence_content", -- 代码块内容
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
  "split",
  "array",
  "matrix",
  "pmatrix",
  "bmatrix",
  "Bmatrix",
  "vmatrix",
  "Vmatrix",
  "eqnarray",
  "eqnarray*",
})

-- 安全地获取节点文本，防止错误
local function safe_get_node_text(node, bufnr)
  if not node then
    return ""
  end

  -- 检查节点是否有效
  local start_row, start_col, end_row, end_col = node:range()
  if start_row < 0 or end_row < 0 or start_col < 0 or end_col < 0 then
    return ""
  end

  -- 使用 pcall 安全调用
  local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr or 0)
  if not ok or not text then
    return ""
  end

  return text
end

-- 获取当前光标所在的节点
local function get_node_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- Tree-sitter 使用 0-indexed API
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]
  local buf = vim.api.nvim_get_current_buf()

  -- 使用更兼容的方式获取 filetype
  local filetype
  if vim.api.nvim_get_option_value then
    -- Neovim 0.10+
    filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
  else
    -- 旧版本兼容
    filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  end

  -- 简单处理，可以根据需要扩展到 quarto, rmarkdown 等
  local lang
  if filetype == "markdown" or filetype == "quarto" or filetype == "rmarkdown" then
    lang = "markdown"
  elseif filetype == "tex" or filetype == "latex" or filetype == "plaintex" then
    lang = "latex"
  else
    return nil
  end

  -- 安全地获取解析器
  local parser = parsers.get_parser(buf, lang)
  if not parser then
    return nil
  end

  -- 解析语法树
  local trees = parser:parse()
  if not trees or #trees == 0 then
    return nil
  end

  local tree = trees[1]
  if not tree then
    return nil
  end

  local root = tree:root()
  if not root then
    return nil
  end

  -- 安全地获取光标位置的节点
  local ok, node = pcall(root.descendant_for_range, root, cursor_row, cursor_col, cursor_row, cursor_col)
  if not ok or not node then
    return nil
  end

  -- 返回光标所在位置的最深层节点
  return node
end

-- 检查是否在 LaTeX 数学环境中（修复版本）
local function is_in_latex_math_environment(node, bufnr)
  if not node or node:type() ~= "generic_environment" then
    return false
  end

  -- 遍历所有子节点寻找 begin 节点
  for i = 0, node:child_count() - 1 do
    local child = node:child(i)
    if child and child:type() == "begin" then
      local begin_text = safe_get_node_text(child, bufnr)
      if begin_text and begin_text ~= "" then
        -- 更强健的环境名称提取
        local patterns = {
          "^\\begin%s*{([^}]+)}", -- 标准模式
          "\\begin%s*{([^}]+)}", -- 宽松模式
          "{([^}]+)}", -- 最后的备选
        }

        for _, pattern in ipairs(patterns) do
          local env_name = begin_text:match(pattern)
          if env_name and latex_math_environments[env_name] then
            return true
          end
        end
      end
      break -- 找到 begin 节点后就跳出
    end
  end

  return false
end

-- 检查是否在 Markdown 的数学代码块中
local function is_in_markdown_math_block(node, bufnr)
  local current = node
  while current do
    local node_type = current:type()

    -- 检查代码围栏块
    if node_type == "fenced_code_block" or node_type == "code_fence_content" then
      -- 尝试获取语言标识符
      local first_child = current:child(0)
      if first_child then
        local lang_text = safe_get_node_text(first_child, bufnr)
        if lang_text and (lang_text:match("latex") or lang_text:match("tex") or lang_text:match("math")) then
          return true
        end
      end

      -- 备选方案：检查整个块的内容
      local block_text = safe_get_node_text(current, bufnr)
      if block_text and block_text:match("```%s*latex") then
        return true
      end
    end

    current = current:parent()
  end
  return false
end

-- 检查是否在内联数学模式中（$ ... $ 或 $$ ... $$）
local function is_in_inline_math(cursor_row, cursor_col)
  -- 获取当前行
  local line = vim.api.nvim_buf_get_lines(0, cursor_row, cursor_row + 1, false)[1]
  if not line then
    return false
  end

  -- 检查光标前后的 $ 符号
  local before = line:sub(1, cursor_col + 1)
  local after = line:sub(cursor_col + 1)

  -- 查找最近的 $ 符号
  local dollar_before_pos = before:reverse():find("%$")
  local dollar_after_pos = after:find("%$")

  if dollar_before_pos and dollar_after_pos then
    local before_pos = #before - dollar_before_pos + 1

    -- 检查是否是单个 $ (内联数学) 而不是 $$ (显示数学)
    local is_single_before = before_pos == 1 or before:sub(before_pos - 1, before_pos - 1) ~= "$"
    local is_single_after = dollar_after_pos == 1 or after:sub(dollar_after_pos + 1, dollar_after_pos + 1) ~= "$"

    if is_single_before and is_single_after then
      return true
    end

    -- 检查 $$ ... $$ (显示数学)
    if
      before_pos >= 2
      and before:sub(before_pos - 1, before_pos - 1) == "$"
      and dollar_after_pos < #after
      and after:sub(dollar_after_pos + 1, dollar_after_pos + 1) == "$"
    then
      return true
    end
  end

  return false
end

-- 检测是否在 LaTeX 或 Markdown 的数学环境中
function M.in_mathzone()
  local node = get_node_at_cursor()
  if not node then
    return false
  end

  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1 -- 转换为 0-indexed
  local cursor_col = cursor[2]

  -- 首先检查是否在内联数学模式中
  if is_in_inline_math(cursor_row, cursor_col) then
    return true
  end

  -- 遍历节点树，从当前节点向上查找
  local current_node = node
  while current_node do
    local node_type = current_node:type()

    -- 1. 直接检查节点类型是否在我们的数学节点集合中
    if math_node_types[node_type] then
      return true
    end

    -- 2. 特别处理 LaTeX 的通用环境 (generic_environment)
    --    因为某些解析器不会为所有数学环境提供唯一的节点类型
    if is_in_latex_math_environment(current_node, buf) then
      return true
    end

    -- 3. 检查 Markdown 中的 LaTeX 代码块
    if is_in_markdown_math_block(current_node, buf) then
      return true
    end

    -- 4. 额外检查：某些节点可能包含数学内容
    if node_type == "text" or node_type == "inline" then
      local text = safe_get_node_text(current_node, buf)
      if text and text:match("%$.*%$") then
        return true
      end
    end

    current_node = current_node:parent()
  end

  return false
end

-- 检测是否在文本环境中
function M.in_text()
  -- 如果不在数学环境中，则认为在文本环境中
  return not M.in_mathzone()
end

-- 添加调试功能，帮助排查问题
function M.debug_mathzone()
  local node = get_node_at_cursor()
  if not node then
    print("❌ 未找到光标处的节点")
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)

  print("🔍 数学环境调试信息:")
  print(string.format("   光标位置: (%d, %d)", cursor[1], cursor[2]))
  print(string.format("   文件类型: %s", vim.bo.filetype))
  print(string.format("   当前行: %s", vim.api.nvim_get_current_line()))

  -- 显示节点层次结构
  print("📊 节点层次 (从叶子到根):")
  local current = node
  local level = 1
  while current and level <= 10 do -- 限制层级避免过长输出
    local text = safe_get_node_text(current, buf)
    if #text > 30 then
      text = text:sub(1, 30) .. "..."
    end
    text = text:gsub("\n", "\\n") -- 替换换行符以便显示
    print(string.format("   %d. %s: '%s'", level, current:type(), text))
    current = current:parent()
    level = level + 1
  end

  -- 显示最终结果
  local in_math = M.in_mathzone()
  print(string.format("🎯 结果: %s", in_math and "在数学环境中 ✅" or "在文本环境中 ❌"))
end

-- 创建用户命令以便调试
vim.api.nvim_create_user_command("MathZoneDebug", M.debug_mathzone, {
  desc = "调试数学环境检测",
})

return M
