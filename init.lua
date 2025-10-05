-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.fn.has("linux") == 1 then
  -- 手动配置 clangd 使用系统版本
  require("lspconfig").clangd.setup({
    cmd = { "/etc/profiles/per-user/manjack/bin/clangd" }, -- 这会使用 PATH 中的 clangd（来自 Nix）
    -- 其他配置保持不变
  })
end
