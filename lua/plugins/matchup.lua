return {
  "andymass/vim-matchup",
  event = "BufReadPost",
  init = function()
    vim.g.matchup_treesitter_stopline = 500
  end,
  ---@type matchup.Config
  opts = {
    treesitter = {
      stopline = 500,
    },
  },
}
