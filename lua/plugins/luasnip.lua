return {
  event = "VeryLazy",
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local ls = require("luasnip")
    -- require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_lua").load({
      paths = "~/.config/nvim/snippet",
    })
    ls.config.setup({ enable_autosnippets = true })
  end,
}
