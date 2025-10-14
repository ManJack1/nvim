return {
  event = "VeryLazy",
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local ls = require("luasnip")
    -- 定义可以Tabout的字符
    local tabout_forward_chars = { "]", ")", "}", ">", '"', "'", "`", "," }
    local tabout_backward_chars = { "[", "(", "{", "<", '"', "'", "`" }

    -- 辅助函数：检查是否可以向前Tabout
    local function can_tabout_forward()
      local col = vim.fn.col(".") - 1
      local line = vim.fn.getline(".")
      if col < #line then
        local next_char = line:sub(col + 1, col + 1)
        for _, char in ipairs(tabout_forward_chars) do
          if next_char == char then
            return true
          end
        end
      end
      return false
    end

    -- 辅助函数：检查是否可以向后Tabout
    local function can_tabout_backward()
      local col = vim.fn.col(".") - 1
      local line = vim.fn.getline(".")
      if col > 0 then
        local curr_char = line:sub(col, col)
        for _, char in ipairs(tabout_backward_chars) do
          if curr_char == char then
            return true
          end
        end
      end
      return false
    end

    -- Tab键映射 (插入和选择模式)
    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      -- 1. 检查LuaSnip
      if ls.jumpable(1) then
        return "<Plug>luasnip-jump-next"
      end

      -- 仅在插入模式下
      if vim.fn.mode() == "i" then
        -- 2. 检查LuaSnip是否可展开
        if ls.expandable() then
          return "<Plug>luasnip-expand"
        end

        -- 3. 检查是否可以Tabout
        if can_tabout_forward() then
          return "<Plug>(TaboutMulti)"
        end
      end

      -- 4. 默认行为：插入Tab
      return "<Tab>"
    end, { expr = true })

    -- Shift+Tab键映射 (插入和选择模式)
    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      -- 1. 检查LuaSnip
      if ls.jumpable(-1) then
        return "<Plug>luasnip-jump-prev"
      end

      -- 仅在插入模式下
      if vim.fn.mode() == "i" then
        -- 2. 检查是否可以向后Tabout
        if can_tabout_backward() then
          return "<Plug>(TaboutBackMulti)"
        end
      end

      -- 3. 默认行为：插入Shift+Tab
      return "<S-Tab>"
    end, { expr = true })

    -- Set up keymaps with conditional logic
    vim.keymap.set({ "i", "s" }, "<C-n>", function()
      local luasnip = require("luasnip")
      if luasnip.choice_active() then
        return "<Plug>luasnip-next-choice"
      else
        vim.notify("No active choice nodes", vim.log.levels.INFO)
        return ""
      end
    end, { expr = true })

    vim.keymap.set({ "i", "s" }, "<C-p>", function()
      local luasnip = require("luasnip")
      if luasnip.choice_active() then
        return "<Plug>luasnip-prev-choice"
      else
        vim.notify("No active choice nodes", vim.log.levels.INFO)
        return ""
      end
    end, { expr = true })
    -- require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_lua").load({
      paths = "~/.config/nvim/snippet",
    })
    ls.config.setup({ enable_autosnippets = true })
  end,
}
