return {
  "L3MON4D3/LuaSnip",
  opts = function(_, opts)
    local ls = require("luasnip")
    -- Clear snippet state when you stop editing it
    ls.config.set_config({
      region_check_events = "CursorMoved,CursorHold,InsertEnter",
      delete_check_events = "TextChanged,InsertLeave",
    })

    -- Optional: a key to “finish” a snippet and remove markers immediately
    vim.keymap.set({ "i", "s" }, "<C-e>", function()
      if ls.in_snippet() then
        ls.unlink_current()
      end
    end, { desc = "Finish snippet (unlink)" })
  end,
}
