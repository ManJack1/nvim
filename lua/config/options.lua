local filetype = require("vim.filetype")
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- 启用自动换行

vim.g.maplocalleader = "m"

vim.opt.wrap = true
-- 当窗口尺寸变化时自动换行
vim.opt.linebreak = true

if vim.fn.has("macunix") == 1 then
  vim.g.python3_host_prog = "/opt/homebrew/bin/python" -- 根据你的实际路径调整
  vim.g.python3_host_prog = "~/.venv/bin/python"
else
  vim.g.python3_host_prog = "/usr/sbin/python3" -- 根据你的实际路径调整
end

-- vimtex 配置
if vim.fn.has("macunix") == 1 then
  -- macOS: 使用 Skim
  vim.g.vimtex_view_method = "skim"
  vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
  vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
  -- 以下两个参数用于更好地配合 Skim 做同步搜索与自动跳转
  vim.g.vimtex_view_skim_sync = 1
  vim.g.vimtex_view_skim_activate = 1
else
  -- 其他 *nix 系统: 使用 Zathura
  vim.g.vimtex_view_method = "zathura"
  vim.g.vimtex_view_general_viewer = "zathura"
  vim.g.vimtex_view_general_options = "--synctex-forward @line:@col:@pdf @tex"
end

-- vim.opt.conceallevel = 0

if vim.env.SSH_TTY then
  vim.opt.clipboard = "" -- SSH 会话中禁用剪贴板
elseif vim.fn.executable("win32yank.exe") == 1 then
  vim.opt.clipboard:append({ "unnamedplus" })
  vim.g.clipboard = {
    name = "win32yank",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
else
  vim.opt.clipboard = "unnamedplus" -- 本地环境启用剪贴板整合
  if vim.env.TERM == "xterm-kitty" or vim.env.TERM == "kitty" then
    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
      },
    }
  end
end

vim.g.vimtex_compiler_progname = "nvr"

-- vim.g.vimtex_view_general_viewer = "zathura"

if vim.g.neovide then
  vim.o.guifont = "Victor Mono:h14" -- text below applies for VimScript
end
vim.g.tokyonight_dark_float = false

if vim.fn.has("macunix") == 1 then
  vim.g.smartim_default = "com.apple.keylayout.ABC"
end

-- Ensure vimtex is loaded
vim.g.vimtex_compiler_latexmk = {
  build_dir = "",
  callback = 1,
  continuous = 1,
  executable = "latexmk",
  options = {
    "-pdf",
    "-shell-escape",
    "-verbose",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode",
  },
}

vim.g.vimtex_syntax_enabled = 0
-- 设置 Visual 模式下选择文本的颜色为蓝色，保持文本颜色不变
-- 确保 Visual 模式的颜色在主题之后设置

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "mypmenu", { bg = "#bb9af7", fg = "#414868" })
vim.api.nvim_set_hl(0, "MyPmenuSel", { bg = "#bb9af7", fg = "#414868", bold = true, italic = true })

function orgtbl_to_latex_matrix()
  -- 转换选中的表格为 LaTeX 格式
  -- 获取选中的行范围
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- 读取选中的行
  local input_table = vim.fn.getline(start_line, end_line)
  local result = {}

  for _, line in ipairs(input_table) do
    -- 去除行首和行尾的空白字符
    line = vim.trim(line)

    -- 使用 vim.split 分割行，保留空的单元格
    local cells = vim.split(line, "|", { plain = true, trimempty = false })

    -- 修剪每个单元格的空白字符
    for i, cell in ipairs(cells) do
      cells[i] = vim.trim(cell)
    end

    -- 检查并移除首尾的空单元格（如果原始行以 | 开始或结束）
    if line:sub(1, 1) == "|" and cells[1] == "" then
      table.remove(cells, 1)
    end
    if line:sub(-1, -1) == "|" and cells[#cells] == "" then
      table.remove(cells, #cells)
    end

    -- 使用 & 连接单元格，并添加 \\ 作为行结束
    local formatted_row = table.concat(cells, " & ") .. " \\\\"
    table.insert(result, formatted_row)
  end

  -- 用转换后的内容替换选中的文本
  vim.fn.setline(start_line, result)
end

-- 向后跳转到下一个单元格
function jump_to_next_cell()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")

  -- 当前行包含 | 符号，说明是表格行
  if line:find("|") then
    -- 在当前列之后查找下一个 |
    local next_pipe = line:find("|", col + 1)
    if next_pipe then
      -- 如果找到下一个 |，则跳转到该单元格
      vim.fn.cursor(vim.fn.line("."), next_pipe + 1)
    else
      -- 当前行中没有下一个 |，则跳转到下一行的第一个 |
      vim.cmd("normal! j")
      local next_line = vim.fn.getline(".")

      -- 循环寻找下一行的 |，直到找到为止
      while next_line ~= "" do
        local first_pipe = next_line:find("|")
        if first_pipe then
          -- 跳转到下一行的第一个 |
          vim.fn.cursor(vim.fn.line("."), first_pipe + 1)
          break
        else
          -- 没有找到 | 就继续往下跳
          vim.cmd("normal! j")
          next_line = vim.fn.getline(".")
        end
      end
    end
  else
    -- 当前行不是表格行，正常执行 Tab 键功能
    vim.cmd("normal! <Tab>")
  end
end

-- 向前跳转到上一个单元格
function jump_to_previous_cell()
  local line = vim.fn.getline(".")
  local col = vim.fn.col(".")

  -- 如果当前行是表格（包含 | 符号）
  if line:find("|") then
    -- 查找前一个 | 的位置
    local last_pipe = line:sub(1, col - 2):find("|[^|]*$")
    if last_pipe then
      -- 跳转到前一个单元格
      vim.fn.cursor(vim.fn.line("."), last_pipe + 1)
    else
      -- 如果没有前一个 |，跳转到上一行的最后一个单元格
      vim.cmd("normal! k$")
      local prev_line = vim.fn.getline(".")
      local last_pipe_prev = prev_line:find("|[^|]*$")
      if last_pipe_prev then
        vim.fn.cursor(vim.fn.line("."), last_pipe_prev + 1)
      end
    end
  else
    -- 如果当前行不是表格，正常执行 Shift+Tab 功能
    vim.cmd("normal! <S-Tab>")
  end
end

function InsertTableRowBelow()
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_get_current_line()

  -- 检查当前行是否是表格的一部分
  if not line_content:find("|") then
    print("当前行不是表格行。")
    return
  end

  -- 计算当前行中'|'字符的数量
  local _, num_pipes = line_content:gsub("|", "")

  -- 列数为'|'的数量减一
  local num_columns = num_pipes - 1

  if num_columns <= 0 then
    print("当前行不是有效的表格行。")
    return
  end

  -- 创建一个具有相同列数的新行
  local new_row = "|"
  for _ = 1, num_columns do
    new_row = new_row .. "     |"
  end

  -- 在当前行下面插入新行
  vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, true, { new_row })
end

-- Ensure diagnostic configuration is set for each attached LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = false, -- Disable virtual text
    })
  end,
})
