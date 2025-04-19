local lspkind = require("lspkind")
return {
  -- 安装 nvim-cmp 和相关插件
  {
    "xzbdmw/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind-nvim", -- 图标插件
      "zbirenbaum/copilot.lua",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- 自定义图标
      local kind_icons = {
        Text = " Text",
        Method = " Method",
        Function = " Function",
        Constructor = " Constructor",
        Field = " Field",
        Variable = " Variable",
        Class = " Class",
        Interface = " Interface",
        Module = " Module",
        Property = " Property",
        Unit = " Unit",
        Value = " Value",
        Enum = " Enum",
        Keyword = " Keyword",
        Snippet = " Snippet",
        Color = " Color",
        File = " File",
        Reference = " Reference",
        Folder = " Folder",
        EnumMember = " EnumMember",
        Constant = " Constant",
        Struct = " Struct",
        Event = " Event",
        Operator = " Operator",
        TypeParameter = " TypeParameter",
        Copilot = " Copilot",
      }

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      vim.api.nvim_set_hl(0, "mypmenu", { bg = "#bb9af7", fg = "#414868" })
      vim.api.nvim_set_hl(0, "MyPmenuSel", { bg = "#bb9af7", fg = "#414868", bold = true, italic = true })

      -- 加载 friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      local tex_mapping = {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      }

      local default_mapping = {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
      }
      -- 自动命令回调函数
      local function set_mappings()
        if vim.bo.filetype == "tex" then
          cmp.setup.buffer({ mapping = tex_mapping })
        else
          cmp.setup.buffer({ mapping = default_mapping })
        end
      end
      -- 定义和设置自动命令
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = set_mappings,
      })
      -- 配置 nvim-cmp
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "emoji" },
          { name = "copilot" }, -- 添加 copilot 补全源
        }),
        -- 默认选择第一项
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        -- 确保第一次展示时选择第一项
        preselect = cmp.PreselectMode.Item,
        -- 确保补全菜单打开时默认选择第一项
        experimental = {
          ghost_text = false, -- 可选：显示补全的幽灵文本
        },
        formatting = {
          format = function(entry, vim_item)
            -- 设置图标和变量名
            vim_item.kind = kind_icons[vim_item.kind] or vim_item.kind
            -- 设置来源标签
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[LuaSnip]",
              nvim_lua = "[Lua]",
              latex_symbols = "[Latex]",
              copilot = "[Copilot]",
            })[entry.source.name]
            return vim_item
          end,
        },
        -- window = {
        --   completion = {
        --     border = "single",
        --     winhighlight = "Normal:Pmenu,CursorLine:MyPmenuSel,Search:None",
        --   },
        --   documentation = {
        --     border = "rounded",
        --   },
        -- },
      })

      -- 为 `/` 命令行模式配置 buffer 源
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- 为 `:` 命令行模式配置 path 和 cmdline 源
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
