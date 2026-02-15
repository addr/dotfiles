---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
      },
      -- Use prettier/eslint for formatting, not the TS language server
      disabled = {
        "vtsls",
        "ts_ls",
      },
      timeout_ms = 3000, -- monorepo can be slow
    },
    ---@diagnostic disable: missing-fields
    config = {
      vtsls = {
        settings = {
          typescript = {
            -- Use the workspace TypeScript SDK
            tsdk = "node_modules/typescript/lib",
            preferences = {
              importModuleSpecifier = "project-relative",
            },
          },
          javascript = {
            preferences = {
              importModuleSpecifier = "project-relative",
            },
          },
        },
      },
    },
  },
}
