return {
  "kawre/leetcode.nvim",
  lazy = false,
  build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  dependencies = {
    -- include a picker of your choice, see picker section for more details
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- ---@type lc.lang
    lang = "typescript",
  },
  keys = {
    -- Create a which-key group for "LeetCode" under '\l'
    -- <localleader> is '\' in LazyVim by default
    { "<localleader>l", group = "LeetCode" },

    -- Problem Navigation
    { "<localleader>ll", "<cmd>Leet list<cr>", desc = "List Problems" },
    { "<localleader>ld", "<cmd>Leet daily<cr>", desc = "Daily Problem" },
    { "<localleader>lr", "<cmd>Leet random<cr>", desc = "Random Problem" },
    { "<localleader>la", "<cmd>Leet tabs<cr>", desc = "List Open Problems (Tabs)" },
    { "<localleader>lo", "<cmd>Leet open<cr>", desc = "Open Problem on Web" },

    -- In-Buffer Actions
    { "<localleader>lt", "<cmd>Leet test<cr>", desc = "Run/Test Solution" },
    { "<localleader>ls", "<cmd>Leet submit<cr>", desc = "Submit Solution" },

    -- UI Toggles
    { "<localleader>lc", "<cmd>Leet console<cr>", desc = "Toggle Console" },
    { "<localleader>lh", "<cmd>Leet desc toggle<cr>", desc = "Toggle Description" },

    -- Authentication
    { "<localleader>lx", "<cmd>Leet cookie update<cr>", desc = "Update Cookie (Auth)" },
  },
}
