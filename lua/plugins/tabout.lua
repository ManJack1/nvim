return {
  "abecodes/tabout.nvim",
  lazy = false,
  config = function()
    require("tabout").setup({
      tabkey = "", -- 禁用默认的 Tab 键绑定
      backwards_tabkey = "", -- 禁用默认的 Shift-Tab 键绑定
      act_as_tab = true,
      act_as_shift_tab = false,
      enable_backwards = true,
      completion = false,
      tabouts = {
        { open = "'", close = "'" },
        { open = '"', close = '"' },
        { open = "`", close = "`" },
        { open = "(", close = ")" },
        { open = "[", close = "]" },
        { open = "{", close = "}" },
        { open = "<", close = ">" },
      },
      ignore_beginning = true,
      exclude = {},
    })
  end,
}
