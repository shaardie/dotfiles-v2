--- disable inlay_hints, I think they are annoying
--- disable yamlls inside helm_ls, it reports bogus errors on template syntax
return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      helm_ls = {
        settings = {
          ["helm-ls"] = {
            yamlls = { enabled = false },
          },
        },
      },
    },
  },
}
