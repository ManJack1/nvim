# 💤 ManJack's LazyVim Configuration

一个基于 [LazyVim](https://github.com/LazyVim/LazyVim) 的个人 Neovim 配置，专为多语言开发和学术写作优化。

## ✨ 特色功能

### 🤖 AI 辅助编程
- **GitHub Copilot**: 智能代码补全
- **Copilot Chat**: 对话式 AI 编程助手，包含自定义 Markdown 格式化提示
- **Sidekick**: 额外的 AI 编程助手

### 📝 学术写作支持
- **LaTeX 集成**: 完整的 TeX 编译和预览支持
  - macOS: 集成 Skim PDF 查看器，支持正向/反向搜索
  - Linux: 使用 Zathura PDF 查看器
- **Markdown 增强**: 
  - 实时渲染预览
  - 自定义图标和样式
  - 代码块语法高亮
  - Todo 列表支持

### 💻 多语言开发环境
支持以下编程语言的完整开发体验：
- **系统编程**: C/C++ (Clangd), Rust, Go
- **Web 开发**: TypeScript/JavaScript, JSON
- **数据科学**: Python (Black 格式化), SQL
- **JVM 生态**: Java
- **配置文件**: TOML, Git 配置

### 🛠 开发工具集成
- **代码格式化**: Prettier, Black, Biome
- **代码检查**: ESLint
- **调试支持**: DAP (Debug Adapter Protocol)
- **测试框架**: 核心测试支持
- **版本控制**: Git 集成和增强

### ⚡ 编辑器增强
- **文件管理**: 
  - Oil.nvim 文件管理器
  - Yazi 终端文件管理器集成
- **代码导航**:
  - Telescope 模糊搜索
  - Aerial 代码结构视图
  - 快速重命名 (inc-rename)
- **编辑工具**:
  - 智能环绕 (mini-surround)
  - 撤销树可视化
  - 多行编辑
  - 智能缩进调整 (dial)

### 🎨 用户界面
- **启动页面**: Alpha 欢迎界面
- **状态栏**: 现代化状态显示
- **主题**: 支持多种配色方案
- **图标**: 丰富的文件类型图标

### 🌏 中文支持
- **输入法集成**: 
  - Fcitx 自动切换
  - SmartIM 智能输入法管理
- **中文编辑优化**: 针对中文文档的编辑体验优化

## 📁 目录结构

```
~/.config/nvim/
├── init.lua              # 入口文件
├── lazy-lock.json        # 插件版本锁定
├── lazyvim.json          # LazyVim 配置
├── stylua.toml           # Lua 代码格式化配置
├── lua/
│   ├── config/           # 核心配置
│   │   ├── autocmds.lua  # 自动命令
│   │   ├── keymaps.lua   # 键位映射
│   │   ├── lazy.lua      # 插件管理器配置
│   │   ├── options.lua   # Vim 选项设置
│   │   └── test.lua      # 测试配置
│   ├── plugins/          # 插件配置
│   └── util/             # 工具函数
├── snippet/              # 代码片段
│   ├── lua/
│   ├── markdown/
│   ├── tex/
│   └── ...
└── assets/               # 资源文件
```

## ⚙️ 安装和使用

### 前置要求

- Neovim >= 0.9.0
- Git
- 一个 [Nerd Font](https://www.nerdfonts.com/) (推荐用于图标显示)
- Python 3 (用于某些插件)
- Node.js (用于 LSP 服务器)

### 安装步骤

1. **备份现有配置** (如果有的话):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **克隆配置**:
   ```bash
   git clone <your-repo-url >~/.config/nvim
   ```

3. **启动 Neovim**:
   ```bash
   nvim
   ```
   
   首次启动时，LazyVim 会自动安装所有插件。

### 🔧 自定义配置

#### 添加新插件
在 `lua/plugins/` 目录下创建新的 `.lua` 文件，例如:

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- 插件配置
  end,
}
```

#### 修改键位绑定
编辑 `lua/config/keymaps.lua` 文件，添加自定义键位映射。

#### 调整编辑器选项
在 `lua/config/options.lua` 中修改 Vim 选项设置。

## 🚀 快速开始

### 常用快捷键

| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>ff` | 文件搜索 | Telescope 文件查找 |
| `<leader>fg` | 全局搜索 | 在项目中搜索文本 |
| `<leader>e` | 文件管理器 | 打开文件树 |
| `<leader>gg` | Git 状态 | 打开 Git 界面 |
| `m` | 本地快捷键 | 触发 local leader 键位 |
| `mm` | 编译重做 | 重新编译当前项目 |
| `mo` | 打开编译器 | 打开编译工具 |
| `<leader>cP` | 复制路径 | 复制当前文件路径 |

### AI 助手使用

- **Copilot**: 在编写代码时自动提供建议
- **Copilot Chat**: 使用 `:CopilotChat` 开启对话
- **Markdown 格式化**: 使用自定义的 `MDFormat` 提示

### LaTeX 写作

1. 打开 `.tex` 文件
2. 使用 `\ll` 开始编译
3. 使用 `\lv` 打开 PDF 预览
4. 支持正向和反向搜索同步

## 🔍 故障排除

### 常见问题

1. **插件安装失败**: 检查网络连接，尝试 `:Lazy sync`
2. **LSP 服务器未启动**: 使用 `:Mason` 安装语言服务器
3. **字体图标显示异常**: 确保安装了 Nerd Font

### 获取帮助

- 查看 LazyVim 文档: [lazyvim.github.io](https://lazyvim.github.io)
- 使用 `:checkhealth` 检查配置状态
- 查看 `:Lazy` 管理插件

## 📄 许可证

本配置基于 Apache License 2.0 开源协议。

## 🙏 致谢

- [LazyVim](https://github.com/LazyVim/LazyVim) - 优秀的 Neovim 配置框架
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - 现代化的插件管理器
- 所有插件作者的辛勤工作

---

💡 **提示**: 这个配置持续更新中，建议定期使用 `git pull` 获取最新改进。
