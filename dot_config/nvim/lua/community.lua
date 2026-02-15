---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- Language packs
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.prisma" },
  { import = "astrocommunity.pack.css" },
  { import = "astrocommunity.pack.lua" },

  -- Git
  { import = "astrocommunity.git.neogit" },
  { import = "astrocommunity.git.diffview-nvim" },

  -- Editing
  { import = "astrocommunity.editing-support.vim-visual-multi" },

  -- Motion
  { import = "astrocommunity.motion.flash-nvim" },
}
