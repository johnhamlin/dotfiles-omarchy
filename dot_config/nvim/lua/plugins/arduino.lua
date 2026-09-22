return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      arduino_language_server = {
        mason = false,
        cmd = {
          "/usr/bin/arduino-language-server",
          "-cli",
          "/usr/bin/arduino-cli",
          "-clangd",
          "/usr/bin/clangd",
        },
      },
    },
  },
}
