local tex_utils = {}

-- 获取当前光标所在节点的工具函数
local function get_node_at_cursor()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- 转换为 0 索引

  local buf = vim.api.nvim_get_current_buf()
  local lang_tree = vim.treesitter.get_parser(buf, "latex")
  if not lang_tree then
    return nil
  end

  local tree = lang_tree:parse()[1]
  if not tree then
    return nil
  end

  return tree:root():named_descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)
end

-- 获取节点文本的工具函数（使用新 API）
local function get_node_text(node)
  if not node then
    return ""
  end

  local buf = vim.api.nvim_get_current_buf()
  -- 使用新的 API：vim.treesitter.get_node_text
  local ok, text = pcall(vim.treesitter.get_node_text, node, buf)
  if ok then
    return type(text) == "string" and text or table.concat(text, "\n")
  end

  -- 如果新 API 不可用，回退到手动获取文本
  local start_row, start_col, end_row, end_col = node:range()
  local lines = vim.api.nvim_buf_get_lines(buf, start_row, end_row + 1, false)

  if #lines == 0 then
    return ""
  end

  if #lines == 1 then
    return string.sub(lines[1], start_col + 1, end_col)
  end

  -- 多行处理
  lines[1] = string.sub(lines[1], start_col + 1)
  lines[#lines] = string.sub(lines[#lines], 1, end_col)

  return table.concat(lines, "\n")
end

-- 通用的环境检测函数
local function in_specific_env(envs)
  local node = get_node_at_cursor()
  while node do
    if node:type() == "generic_environment" then
      local start_tag = node:child(0)
      if start_tag and start_tag:type() == "begin" then
        local text = get_node_text(start_tag)
        for _, env in ipairs(envs) do
          if text:match("\\begin{" .. env .. "}") then
            return true
          end
        end
      end
    end
    node = node:parent()
  end
  return false
end

-- 通用的类型检测函数
local function in_specific_node_types(types)
  local node = get_node_at_cursor()
  while node do
    if vim.tbl_contains(types, node:type()) then
      return true
    end
    node = node:parent()
  end
  return false
end

-- 检测是否在数学环境中
tex_utils.in_mathzone = function()
  return in_specific_node_types({
    "inline_formula",
    "displayed_equation",
    "math_environment",
  }) or in_specific_env(tex_utils.in_math_envs)
end

-- 检测是否在文本环境中
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end

-- 检测是否在注释中
tex_utils.in_comment = function()
  return in_specific_node_types({ "comment" })
end

-- 通用环境检测函数
tex_utils.in_env = function(env_name)
  return in_specific_env({ env_name })
end

-- 列表环境检测函数
tex_utils.in_list = function()
  return in_specific_env({ "itemize", "enumerate", "description" })
end

-- 图表环境检测函数
tex_utils.in_fig_table = function()
  return in_specific_env({ "figure", "table" })
end

-- 代码环境检测函数
tex_utils.in_code = function()
  return in_specific_env({ "verbatim", "lstlisting", "minted" })
end

-- 其他特定环境检测函数
tex_utils.in_tikz = function()
  return tex_utils.in_env("tikzpicture")
end

tex_utils.in_bib = function()
  return tex_utils.in_env("thebibliography")
end

tex_utils.in_minipage = function()
  return tex_utils.in_env("minipage")
end

tex_utils.in_frame = function()
  return tex_utils.in_env("frame")
end

tex_utils.in_ampersand_env = function()
  return in_specific_env({
    "align",
    "align*",
    "alignat",
    "alignat*",
    "matrix",
    "pmatrix",
    "bmatrix",
    "vmatrix",
    "Vmatrix",
    "cases",
    "split",
    "gather",
    "gather*",
  })
end

-- 定义数学环境
tex_utils.in_math_envs = {
  "equation",
  "equation*",
  "align",
  "align*",
  "alignat",
  "alignat*",
  "gather",
  "gather*",
  "multline",
  "multline*",
  "flalign",
  "flalign*",
  "eqnarray",
  "eqnarray*",
}

-- 更健壮的 parser 获取方式
tex_utils.get_parser = function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(buf, "filetype")

  if ft ~= "tex" and ft ~= "latex" then
    return nil
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf, "latex")
  if not ok then
    -- 尝试获取 tex parser
    ok, parser = pcall(vim.treesitter.get_parser, buf, "tex")
  end

  return ok and parser or nil
end

-- 获取当前环境名称
tex_utils.get_current_env = function()
  local node = get_node_at_cursor()
  while node do
    if node:type() == "generic_environment" then
      local start_tag = node:child(0)
      if start_tag and start_tag:type() == "begin" then
        local text = get_node_text(start_tag)
        local env_name = text:match("\\begin{([^}]+)}")
        if env_name then
          return env_name
        end
      end
    end
    node = node:parent()
  end
  return nil
end

-- 检查是否有可用的 treesitter parser
tex_utils.has_parser = function()
  return tex_utils.get_parser() ~= nil
end

return tex_utils
