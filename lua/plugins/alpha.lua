return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    -- Define and set highlight groups for each logo line
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo1", { fg = "#311B92" }) -- Indigo
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo2", { fg = "#512DA8" }) -- Deep Purple
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo3", { fg = "#673AB7" }) -- Deep Purple
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo4", { fg = "#9575CD" }) -- Medium Purple
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo5", { fg = "#B39DDB" }) -- Light Purple
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo6", { fg = "#D1C4E9" }) -- Very Light Purple
    vim.api.nvim_set_hl(0, "NeovimDashboardUsername", { fg = "#D1C4E9" }) -- light purple

    dashboard.section.header.type = "group"
    dashboard.section.header.val = {
      {
        type = "text",
        val = "                          ", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "                          ", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "                               +     Z", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo6", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "                                A_   z", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "                               /\\-\\ z", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = '                              _||"_', -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "                              ~^~^~^~^", -- Adjusted spaces if needed
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        opts = { hl = "NeovimDashboardLogo1", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        opts = { hl = "NeovimDashboardLogo2", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        opts = { hl = "NeovimDashboardLogo3", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        opts = { hl = "NeovimDashboardLogo4", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" },
      },
      {
        type = "text",
        val = "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        opts = { hl = "NeovimDashboardLogo6", shrink_margin = false, position = "center" },
      },
      {
        type = "padding",
        val = 1,
      },
      {
        type = "text",
        val = "ᴄɪᴛʏ ᴏғ sᴛᴀʀs, ᴀʀᴇ ʏᴏᴜ sʜɪɴɪɴɢ ᴊᴜsᴛ ғᴏʀ ᴍᴇ? :) ",
        opts = { hl = "NeovimDashboardUsername", shrink_margin = false, position = "center" },
      },
    }
    -- stylua: ignore
    dashboard.section.buttons.val = {
        -- 使用 fzf-lua 替代 LazyVim.pick()
        dashboard.button("f", " " .. " Find file",      "<cmd>lua Snacks.dashboard.pick('files')<cr>"),
        dashboard.button("n", " " .. " New file",       [[<cmd> ene <BAR> startinsert <cr>]]),
        -- 使用 fzf-lua 替代 LazyVim.pick("oldfiles")
        dashboard.button("r", " " .. " Recent files",   "<cmd>lua Snacks.dashboard.pick('oldfiles')<cr>"),
        -- 使用 fzf-lua 替代 LazyVim.pick("live_grep")
        -- 你也可以根据需要使用 'live_grep' 或其他 fzf-lua 提供的 grep 函数
        dashboard.button("g", " " .. " Find text",      "<cmd>lua Snacks.dashboard.pick('live_grep')<cr>"),
        -- 使用 fzf-lua 在配置目录中查找文件
        dashboard.button("c", " " .. " Config",         "<cmd>lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})<cr>"),
        dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
        dashboard.button("x", " " .. " Lazy Extras",    "<cmd> LazyExtras <cr>"),
        dashboard.button("l", "󰒲 " .. " Lazy",           "<cmd> Lazy <cr>"),
        dashboard.button("q", " " .. " Quit",           "<cmd> qa <cr>"),
    }
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#311B92" }) -- Dark Indigo
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#D1C4E9" }) -- Light Purple
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#8BC34A" }) -- Greenish
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#edd691" })

    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
    end
    dashboard.section.header.opts.hl = "AlphaHeader"
    dashboard.section.buttons.opts.hl = "AlphaButtons"
    dashboard.section.footer.opts.hl = "AlphaFooter"
    dashboard.opts.layout[1].val = 3
    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "AlphaReady",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    require("alpha").setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = "⚡ Neovim loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. ms
          .. "ms"
        -- 使用 pcall 避免 alpha 未加载完成时出错
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
