---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "typescript",
      "tsx",
      "javascript",
      "json",
      "jsonc",
      "yaml",
      "css",
      "html",
      "markdown",
      "markdown_inline",
      "prisma",
      "graphql",
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "regex",
      "diff",
      "gitcommit",
    },
  },
}
