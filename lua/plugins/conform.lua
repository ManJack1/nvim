return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      options = {
        ignore_errors = true,
        lang_to_formatters = {
          cpp = "clang-format",
          python = { "isort", "black" },
          c = "clang-format",
          lua = "stylua",
        },
      },
    },
    formatters_by_ft = {

      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "isort", "black" },
      -- You can customize some of the format options for the filetype (:help conform.format)
      rust = { "rustfmt", lsp_format = "fallback" },
      -- Conform will run the first available formatter
      javascript = { "prettierd", "prettier", stop_after_first = true },

      tex = { "tex-fmt" },

      c = { "clang-format" },
      cpp = { "clang-format" },

      markdown = { "prettierd", "injected" },
    },
  },
}
