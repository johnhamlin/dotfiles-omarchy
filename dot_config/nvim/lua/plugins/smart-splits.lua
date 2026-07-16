-- Navigate nvim splits with Ctrl+hjkl. Cross-pane behavior depends on context:
--   * Inside zellij ($ZELLIJ set) — smart-splits' zellij integration uses
--     `zellij action move-focus` for the edge case. zellij-autolock keeps
--     zellij in Locked mode while nvim is focused, so these Ctrl+H/J/K/L
--     keypresses reach nvim cleanly without zellij intercepting first.
--   * Inside tmux ($TMUX set) — smart-splits' tmux integration sets the
--     @pane-is-vim user option on the current tmux pane; tmux's own bindings
--     (see ~/.config/tmux/tmux.conf) check it and either send the key through
--     to nvim or run select-pane themselves.
--   * In bare kitty ($KITTY_LISTEN_ON set) — smart-splits' kitty integration
--     signals the IS_NVIM user var that custom.conf's `--when-focus-on var:IS_NVIM`
--     maps key off of, and hops panes with `kitten neighboring_window.py` at the
--     edge. It must be named explicitly: multiplexer_integration = false skips
--     the auto-detect that would otherwise pick kitty.
--   * Outside all three, in WezTerm — async wezterm CLI hop at the edge.
local in_zellij = vim.env.ZELLIJ ~= nil and vim.env.ZELLIJ ~= ""
local in_tmux = vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
local in_kitty = vim.env.KITTY_LISTEN_ON ~= nil and vim.env.KITTY_LISTEN_ON ~= ""

local function move_or_wezterm(move_fn, wez_direction)
  return function()
    local win = vim.api.nvim_get_current_win()
    move_fn()
    if vim.api.nvim_get_current_win() == win and vim.env.WEZTERM_PANE then
      vim.system({ "wezterm", "cli", "activate-pane-direction", wez_direction })
    end
  end
end

local function bind(move_fn_name, wez_direction)
  local move_fn = function() require("smart-splits")[move_fn_name]() end
  if in_zellij or in_tmux then
    return move_fn
  else
    return move_or_wezterm(move_fn, wez_direction)
  end
end

local function mux()
  if in_zellij then return "zellij" end
  if in_tmux then return "tmux" end
  if in_kitty then return "kitty" end
  return false
end

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits.mux").__mux = nil -- clear cached mux from auto-detection
    require("smart-splits").setup({
      at_edge = (in_zellij or in_tmux) and "wrap" or "stop",
      multiplexer_integration = mux(),
    })
  end,
  keys = {
    { "<C-h>", bind("move_cursor_left",  "Left"),  desc = "Move to left split" },
    { "<C-j>", bind("move_cursor_down",  "Down"),  desc = "Move to below split" },
    { "<C-k>", bind("move_cursor_up",    "Up"),    desc = "Move to above split" },
    { "<C-l>", bind("move_cursor_right", "Right"), desc = "Move to right split" },
  },
}
