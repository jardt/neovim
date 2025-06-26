# Neovim configuration

Personal neovim config.

uses:

- [nixCats](https://github.com/BirdeeHub/nixCats-nvim) to create different variants of neovim with differest configs if used as part of nix config or if it is ran with nix.
- [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin managemant if config is just copied to `.config/nvim`

## Nix

Run it with full config: `nix run github:jardt/neovim`

Run minimal config: `nix run github:jardt/neovim#catsvi`

## LSP`s

Does not include mason for installing linters or lsp`s.
use package manager or nix to install these
