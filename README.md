# Neovim configuration

Personal Neovim config.

Uses:

- [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) to build wrapped Neovim packages with Nix-provided plugins and runtime tools.
- Neovim native `vim.pack` for plugin installation when this repo is used as plain `~/.config/nvim`.
- [`lze`](https://github.com/BirdeeHub/lze) and `lzextras` for lazy loading in both Nix and non-Nix modes.

## Nix

Run full config: `nix run github:jardt/neovim`

Run minimal config: `nix run github:jardt/neovim#catsvi`

Run dotnet/angular config: `nix run github:jardt/neovim#cats_dotang_nvim`

The package outputs remain `catsvim`, `catsvi`, and `cats_dotang_nvim` during this compatibility migration. A later cleanup should consider clearer names such as `full`, `minimal`, and `dotang` while preserving the old outputs for a transition period.

## Plain non-Nix mode

Plain `nvim` uses native `vim.pack` and `nvim-pack-lock.json` from this config directory. Use a Neovim build that provides `vim.pack` for automatic plugin installation.

Older Neovim builds without `vim.pack` degrade gracefully: startup emits a warning that non-Nix plugin management requires `vim.pack`, then continues without installing or loading packaged plugins. Use a Nix wrapper output or upgrade Neovim for the full config.

Plugin build hooks from the previous plugin manager are not run automatically by `vim.pack`. Run affected build steps manually after plugin install/update when needed, for example:

```sh
# markdown-preview.nvim
cd "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/core/opt/markdown-preview.nvim/app" && npm install

# rustowl
cd "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/core/opt/rustowl" && cargo install --path .
```

## LSPs, formatters, and linters

This config does not use Mason to install LSPs, formatters, or linters.

- Nix wrapper mode provides configured runtime tools through the wrapper.
- Plain non-Nix mode expects the host system to provide required LSPs, formatters, and linters through your system package manager or another tool.
