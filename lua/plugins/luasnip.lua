return {
  "L3MON4D3/LuaSnip",
  -- lazy_load = false,
  -- keys = function()
  --   return {}
  -- end,
  config = function()
    local ls = require("luasnip")
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippet" })
    ls.config.setup({ enable_autosnippets = true })
  end,
}
