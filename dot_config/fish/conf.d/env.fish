set -gx EDITOR nvim
set -gx VISUAL nvim

# GitHub token for tools that want it (was in ~/.zshrc)
type -q gh; and set -gx GITHUB_PERSONAL_ACCESS_TOKEN (gh auth token)
