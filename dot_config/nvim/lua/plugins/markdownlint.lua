return {
  -- nvim-lint runs markdownlint-cli2 by piping the buffer over stdin (args = { "-" }).
  -- In stdin mode markdownlint-cli2 only reads a config file from the cwd and does
  -- NOT walk parent dirs, so a dropped-in project config is unreliable. Point it at
  -- a fixed global config via --config to keep MD013 (line-length) disabled
  -- everywhere, regardless of nvim's cwd. Config lives in ~/.config/markdownlint/.
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        prepend_args = { "--config", vim.fn.expand("~/.config/markdownlint/config.jsonc") },
      },
    },
  },
}
