return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<CR>"] = {},
      ["<C-y>"] = { "accept", "fallback" },
      ["<C-space>"] = {
        function(cmp)
          cmp.show({ providers = { "lsp", "path", "buffer" } })
        end,
      },
      ["<C-S-space>"] = {
        function(cmp)
          local ls = require("luasnip")
          if ls.expandable() then
            vim.schedule(function()
              ls.expand()
            end)
          else
            cmp.show({ providers = { "snippets" } })
          end
        end,
      },
    },
    completion = {
      ghost_text = {
        enabled = true,
        show_with_selection = true, -- show when item selected
        show_without_selection = true, -- show even without selection (first item)
        show_with_menu = false, -- hide ghost when menu open
        show_without_menu = true, -- show ghost when menu closed
      },
      list = {
        selection = { preselect = true, auto_insert = false },
      },
      menu = {
        -- Only show menu on trigger characters (. :), not while typing keywords
        auto_show = function(ctx)
          return ctx.trigger.initial_kind == "trigger_character"
        end,
      },
      trigger = {
        show_on_keyword = true, -- Fetch completions while typing (for ghost text)
        show_on_trigger_character = true, -- Also fetch on . : etc
      },
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
      providers = {
        snippets = {
          min_keyword_length = 0,
          score_offset = 0,
          -- After trigger characters (e.g., "."), only show postfix snippets (triggers starting with ".")
          -- This keeps regular snippets hidden after "console." while letting ".log" etc through
          transform_items = function(ctx, items)
            if ctx.trigger.initial_kind == "trigger_character" then
              local postfix = {}
              for _, item in ipairs(items) do
                if item.label:sub(1, 1) == "." then
                  item.score_offset = -100
                  postfix[#postfix + 1] = item
                end
              end
              return postfix
            end
            return items
          end,
        },
        lsp = {
          score_offset = 0,
        },
      },
    },
  },
}
