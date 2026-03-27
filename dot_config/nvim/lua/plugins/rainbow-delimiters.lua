return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      require("rainbow-delimiters.setup").setup({
        query = {
          ["scheme"] = "rainbow-delimiters",
          ["racket"] = "rainbow-delimiters",
        },
      })
    end,
  },
}
