return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      injected = {
        options = {
          -- Set to true to ignore errors
          ignore_errors = false,
          -- Map of treesitter language to filetype
          lang_to_ft = {
            bash = "sh",
          },
          -- Map of treesitter language to file extension
          -- A temporary file name with this extension will be generated during formatting
          -- because some formatters care about the filename.
          lang_to_ext = {
            bash = "sh",
            c_sharp = "cs",
            elixir = "exs",
            javascript = "js",
            julia = "jl",
            latex = "tex",
            markdown = "md",
            python = "py",
            ruby = "rb",
            rust = "rs",
            teal = "tl",
            typescript = "ts",
          },
          -- Map of treesitter language to formatters to use
          -- (defaults to the value from formatters_by_ft)
          lang_to_formatters = {},
        },
      },
    },
    formatters_by_ft = {
      kdl = { "kdlfmt" },

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
      asm = { "asm-fmt" },
    },
  },
}
