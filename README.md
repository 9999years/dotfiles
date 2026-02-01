# Dotfiles

Dotfiles for [rcm(7)](https://github.com/thoughtbot/rcm).

Setup with `git clone https://github.com/9999years/dotfiles.git ~/.dotfiles && rcup -v`.

## Utility software I like

- `bat`
- [`eza`](https://github.com/eza-community/eza)
- `fd`
- `fish`
- `fzf`/`fzy`
- `git-absorb`
- `git-delta`
- [`git-flip-history`](https://blog.aloni.org/posts/gitology-1-git-flip-history/)
- `hub`/`gh`
    - [`gh extension install seachicken/gh-poi`](https://github.com/seachicken/gh-poi)
- `neovim`
- `rg`
- `tmux`
- `topgrade`
- `pandoc`
- [`npm i -g vscode-langservers-extracted`](https://github.com/hrsh7th/vscode-langservers-extracted)
- [`npm i -g yaml-language-server`](https://github.com/redhat-developer/yaml-language-server)
- [`brew install so`](https://github.com/samtay/so)
- [`brew install topgrade`](https://github.com/r-darwish/topgrade)

## macOS software

- [`brew install --cask raycast`](https://www.raycast.com/)
- [`brew install --cask rectangle`](https://rectangleapp.com/)
- [`brew install --cask alt-tab`](https://alt-tab-macos.netlify.app/)
- [`brew install mas`](https://github.com/mas-cli/mas)
- [`brew install font-kreative-square`](https://www.kreativekorp.com/software/fonts/ksquare/)
- [`brew install pam-reattach`](https://github.com/fabianishere/pam_reattach)
  for Touch ID authentication for `sudo`. Add to `/etc/pam.d/sudo_local`:
  ```
  auth     optional     /opt/homebrew/lib/pam/pam_reattach.so
  auth     sufficient   pam_tid.so
  ```
