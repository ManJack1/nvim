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
  vim.g.python3_host_prog = "/etc/profiles/per-user/manjack/bin/python"
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
  vim.o.guifont = "Maple Mono NF" -- text below applies for VimScript
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

-- Ensure diagnostic configuration is set for each attached LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.diagnostic.config({
      virtual_text = false, -- Disable virtual text
    })
  end,
})

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
