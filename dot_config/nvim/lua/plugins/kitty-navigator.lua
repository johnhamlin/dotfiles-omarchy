return {
  "knubie/vim-kitty-navigator",
  build = "cp ./*.py ~/.config/kitty/",
  cond = not vim.env.TMUX,
}
