return {
  -- { -- This plugin
  --   "Zeioth/compiler.nvim",
  --   cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  --   dependencies = { "stevearc/overseer.nvim" },
  --   opts = {},
  --   keys = {
  --     { "mm", "<cmd>CompilerOpen<cr>", desc = "CompilerOpen" },
  --     { "mt", "<cmd>CompilerToggleResults<cr>", desc = "CompilerToggleResults" },
  --   },
  -- },
  -- -- { -- The task runner we use
  -- --   "stevearc/overseer.nvim",
  -- --   commit = "3047ede61cc1308069ad1184c0d447ebee92d749",
  -- --   cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  -- --   opts = {
  -- --     task_list = {
  -- --       direction = "bottom",
  -- --       min_height = 25,
  -- --       max_height = 25,
  -- --       default_detail = 1,
  -- --       bindings = {
  -- --         ["q"] = function()
  -- --           vim.cmd("OverseerClose")
  -- --         end,
  -- --       },
  -- --     },
  -- --   },
  -- -- },
  -- { -- The task runner we use
  --   "stevearc/overseer.nvim",
  --   commit = "19aac0426710c8fc0510e54b7a6466a03a1a7377",
  --   cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  --   opts = {
  --     task_list = {
  --       direction = "bottom",
  --       min_height = 25,
  --       max_height = 25,
  --       default_detail = 1,
  --       bindings = {
  --         ["q"] = function()
  --           vim.cmd("OverseerClose")
  --         end,
  --       },
  --     },
  --   },
  -- },
  { -- This plugin
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
    -- keys = {
    --   { "mm", "<cmd>CompilerOpen<cr>", desc = "CompilerOpen" },
    --   { "mt", "<cmd>CompilerToggleResults<cr>", desc = "CompilerToggleResults" },
    -- },
    -- config = function()
    --   require("which-key").add({
    --     { "mm", "<cmd>CompilerOpen<cr>", desc = "CompilerOpen" },
    --     { "mt", "<cmd>CompilerToggleResults<cr>", desc = "CompilerToggleResults" },
    --   })
    -- end,
  },
  { -- The task runner we use
    "stevearc/overseer.nvim",
    commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },
}
