-- No example configuration was found for this plugin.
--
-- For detailed information on configuring this plugin, please refer to its
-- official documentation:
--
--   https://github.com/chrisgrieser/nvim-scissors
--
-- If you wish to use this plugin, you can optionally modify and then uncomment
-- the configuration below.

-- lazy.nvim
return {
  event = "VeryLazy",
  "chrisgrieser/nvim-scissors",
  dependencies = "nvim-telescope/telescope.nvim",
  config = function()
    require("scissors").setup({
      snippetDir = "~/.config/nvim/snippet/snippetDir",
    })
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { "~/.config/nvim/snippet/snippetDir" },
    })
  end,
  config = function()
    local wk = require("which-key")
    local map = vim.keymap.set

    map("n", "<leader>Te", function()
      require("scissors").editSnippet()
    end, { desc = "Snippet: Edit" })

    -- when used in visual mode, prefills the selection as snippet body
    map({ "n", "x" }, "<leader>Ta", function()
      require("scissors").addNewSnippet()
    end, { desc = "Snippet: Add" })
    wk.add({ "<leader>T", group = "editSnippet", icon = "🍬" })
  end,
}
