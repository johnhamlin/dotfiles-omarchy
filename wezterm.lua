-- WezTerm configuration for WSL development
-- Copy to ~/.wezterm.lua on Windows (or %USERPROFILE%\.wezterm.lua)
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Font (matches kitty config)
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 9.0

-- Window padding (matches kitty config: 14px)
config.window_padding = {
  left = 14,
  right = 14,
  top = 14,
  bottom = 14,
}

-- Color scheme
config.color_scheme = 'One Half Dark'

-- WSL Ubuntu as default, auto-launch into tmux
local wsl_domains = wezterm.default_wsl_domains()
for _, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    -- fish -c ensures fish is the shell; tmux -A attaches or creates
    dom.default_prog = { '/usr/bin/fish', '-c', 'tmux new-session -A -s main' }
  end
end
config.wsl_domains = wsl_domains
config.default_domain = 'WSL:Ubuntu'

-- Keybindings: unbind WezTerm defaults that conflict with tmux/nvim,
-- and set up Ctrl+Insert / Shift+Insert for copy/paste
-- (PowerToys remaps Win+C/V to these)
config.keys = {
  -- Pass through to tmux/nvim (smart-splits)
  { key = 'h', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'j', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'k', mods = 'CTRL', action = act.DisableDefaultAssignment },
  { key = 'l', mods = 'CTRL', action = act.DisableDefaultAssignment },

  -- Pass through to tmux (prefix)
  { key = 'b', mods = 'CTRL', action = act.DisableDefaultAssignment },

  -- Pass through to tmux (tab switching)
  { key = 'h', mods = 'ALT', action = act.DisableDefaultAssignment },
  { key = 'l', mods = 'ALT', action = act.DisableDefaultAssignment },

  -- Copy/paste via Ctrl+Insert / Shift+Insert
  -- PowerToys translates Win+C -> Ctrl+Insert, Win+V -> Shift+Insert
  { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'ClipboardAndPrimarySelection' },
  { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'Clipboard' },
}

return config
