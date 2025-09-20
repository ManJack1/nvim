local parsers = require("nvim-treesitter.parsers")

local tex_utils = {}

-- 获取当前光标所在节点的工具函数
local function get_node_at_cursor()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- 转换为 0 索引
  local parser = parsers.get_parser(0, "latex")
  if not parser then
    return nil
  end
  local tree = parser:parse()[1]
  if not tree then
    return nil
  end
  return tree:root():named_descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)
end

-- 获取节点文本的工具函数
local function get_node_text(node)
  if not node then
    return ""
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local text = vim.treesitter.get_node_text(node, bufnr)
  return type(text) == "string" and text or table.concat(text, "\n")
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
  return in_specific_node_types({ "inline_formula", "displayed_equation", "math_environment" })
    or in_specific_env(tex_utils.in_math_envs)
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
  return in_specific_env({ "verbatim", "lstlisting" })
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
  return in_specific_env({ "align", "align*", "matrix", "pmatrix", "bmatrix", "vmatrix", "Vmatrix", "cases" })
end

-- 定义数学环境
tex_utils.in_math_envs = {
  "equation",
  "align",
  "align*",
  "gather",
  "multline",
  "equation*",
}

return tex_utils
