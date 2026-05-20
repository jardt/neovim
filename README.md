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

### Use this flake from your Nix config

Add it as a flake input:

```nix
{
  inputs.jardt-neovim.url = "github:jardt/neovim";
}
```

Then install one of the package outputs like any other package.

NixOS:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.jardt-neovim.packages.${pkgs.system}.default
    # or: inputs.jardt-neovim.packages.${pkgs.system}.catsvi
    # or: inputs.jardt-neovim.packages.${pkgs.system}.cats_dotang_nvim
  ];
}
```

Home Manager:

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.jardt-neovim.packages.${pkgs.system}.default
  ];
}
```

For a one-off install into your user profile:

```sh
nix profile install github:jardt/neovim
# or a specific variant
nix profile install github:jardt/neovim#catsvi
```

### Build a custom variant

The wrapper module exposes feature flags through `config.info` and user-facing wrapper settings through `config.settings`. Use the exported module with `nix-wrapper-modules` when you want a local variant instead of one of the packaged defaults:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    jardt-neovim.url = "github:jardt/neovim";
  };

  outputs = inputs@{ nixpkgs, nix-wrapper-modules, jardt-neovim, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    baseModule = nixpkgs.lib.modules.importApply "${jardt-neovim}/module.nix" jardt-neovim.inputs;
    myNvim = (nix-wrapper-modules.lib.evalModules {
      modules = [
        baseModule
        ({ lib, ... }: {
          settings.aliases = [ "myvim" ];
          settings.theme.name = "gruvbox";

          # Feature metadata exported to Lua.
          info.devops = true;
          info.database = true;
          info.langs.rust = true;
          info.langs.dotnet = true;
          info.langs.java = false;

          # Disable/enable the matching Nix plugin/tool groups.
          specs.devops.enable = true;
          specs.database.enable = true;
          specs."langs.rust".enable = true;
          specs."langs.dotnet".enable = true;
          specs."langs.java".enable = false;
        })
      ];
      specialArgs = { inherit pkgs; };
    }).config.wrap { inherit pkgs; };
  in {
    packages.${system}.default = myNvim;
  };
}
```

Available language groups currently include `typst`, `rust`, `web`, `go`, `markdown`, `lua`, `dotnet`, `zig`, `java`, `qml`, `yuck`, and `tex`. Other top-level feature groups include `devops`, `database`, `explorer`, `test`, `debugtest`, `formatlint`, `git`, `ai`, `obsidian`, and more; see `module.nix` for the full list.

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
