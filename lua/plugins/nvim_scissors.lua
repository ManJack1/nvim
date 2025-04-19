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
}
