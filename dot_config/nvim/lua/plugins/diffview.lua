-- File-by-file diff viewer for PR reviews
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  opts = {
    default_args = {
      DiffviewOpen = { "--imply-local" },
    },
    enhanced_diff_hl = true,
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View (uncommitted)" },
    {
      "<leader>gD",
      function()
        -- Auto-detect default branch and open PR review diff
        local function open_diff(base)
          vim.cmd("DiffviewOpen origin/" .. base .. "...HEAD")
        end
        vim.system({ "git", "rev-parse", "--verify", "origin/main" }, {}, function(out)
          vim.schedule(function()
            open_diff(out.code == 0 and "main" or "master")
          end)
        end)
      end,
      desc = "Diff View (PR review vs main)",
    },
    { "<leader>gc", "<cmd>DiffviewFileHistory %<cr>", desc = "File Commit History" },
    {
      "<leader>gC",
      function()
        local function open_history(base)
          vim.cmd("DiffviewFileHistory --range=origin/" .. base .. "...HEAD")
        end
        vim.system({ "git", "rev-parse", "--verify", "origin/main" }, {}, function(out)
          vim.schedule(function()
            open_history(out.code == 0 and "main" or "master")
          end)
        end)
      end,
      desc = "PR Commit History",
    },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
  },
}
