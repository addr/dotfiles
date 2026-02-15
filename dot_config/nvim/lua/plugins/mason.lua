---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "vtsls",
        "eslint-lsp",
        "css-lsp",
        "json-lsp",
        "yaml-language-server",
        "prisma-language-server",
        "lua-language-server",

        -- Formatters
        "prettier",

        -- Linters
        "eslint_d",

        -- Utilities
        "tree-sitter-cli",
      },
    },
  },
}
