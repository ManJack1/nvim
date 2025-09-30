return {
  lazy = "VeryLazy",
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local wk = require("which-key")
    wk.add({
      {
        "<leader>o",
        function()
          require("oil").toggle_float()
        end,
        desc = "Oil_Float",
        icon = "",
      },
    })
    require("oil").setup({

      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
      columns = { "icon" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["<BS>"] = "actions.parent",
        ["<CR>"] = "actions.select",
        ["<C-t>"] = "actions.select_tab",
        ["<C-r>"] = "actions.refresh",
      },
    })
  end,
}
