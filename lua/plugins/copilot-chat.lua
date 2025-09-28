return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  opts = {
    prompts = {
      MDFormat = {
        prompt = "Markdown-formatter",
        system_prompt = "As a professional Markdown formatter and English proofreader, optimize the current buffer by only refining Markdown formatting (headings, indentation, spacing, lists, code blocks, etc.) and fixing spelling errors. Do not rewrite sentences, change word choices, or alter word order. Ensure proper use of backtick code blocks and consistent formatting—do not miss any details. Additionally, keep LaTeX code on a single line as much as possible.",
        description = "Format markdown file into well formatted markdown file",
      },
    },
  },
}
