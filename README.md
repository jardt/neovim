# Neovim configuration

Personal Neovim config.

Uses:

- [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) to build wrapped Neovim packages with Nix-provided plugins and runtime tools.
- Neovim native `vim.pack` for plugin installation when this repo is used as plain `~/.config/nvim`.
- [`lze`](https://github.com/BirdeeHub/lze) and `lzextras` for lazy loading in both Nix and non-Nix modes.

## Nix

Run full config: `nix run github:jardt/neovim`

Run minimal config: `nix run github:jardt/neovim#minimal`

Run agent config: `nix run github:jardt/neovim#agent`

The agent profile uses standard nixpkgs Neovim (`neovim-unwrapped`), not nightly. It inherits minimal's disabled feature groups but replaces its general plugins/tools and Lua startup with a small code-browsing and Markdown-editing setup:

- fff file search (`<leader>o`) and live grep (`<leader>/`).
- Yazi directory browsing (`<leader>y` at the current file, `<leader>Y` at the working directory, `<C-Up>` to resume), with the Yazi executable included.
- Treesitter highlighting for Markdown and common code/config formats, plus the existing themes.
- Blink completion for paths and buffer words, with local Pi prompt-template completion.
- In-buffer Markdown rendering, soft wrapping, and visual-line navigation.
- The in-repo `lua/pi` integration for prompting Pi through Herdr (Herdr and a running Pi pane must be available externally).

Snacks and mini.icons provide UI dependencies. No LSPs, formatters, browser preview, Git UI, or other editing plugins are enabled. The existing `minimal` output is unchanged. Agent-specific customizations live in `nix/profiles/agent.nix` and `lua/config/agent.lua`.

Run dotnet/angular config: `nix run github:jardt/neovim#dotang`

The canonical package and app outputs are `full`, `minimal`, `agent`, and `dotang`. The old `catsvim`, `catsvi`, and `cats_dotang_nvim` names remain as compatibility aliases.

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
    # or: inputs.jardt-neovim.packages.${pkgs.system}.minimal
    # or: inputs.jardt-neovim.packages.${pkgs.system}.agent
    # or: inputs.jardt-neovim.packages.${pkgs.system}.dotang
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
nix profile install github:jardt/neovim#minimal
```

### Build a custom variant

The wrapper module exposes feature flags through `config.info` and user-facing wrapper settings through `config.settings`. Use the exported module with `nix-wrapper-modules` when you want a local variant instead of one of the packaged defaults:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jardt-neovim = {
      url = "github:jardt/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-wrapper-modules, jardt-neovim, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg:
        nixpkgs.lib.getName pkg == "copilot-language-server";
    };
    baseModule = jardt-neovim.wrapperModules.default;
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

Available language groups currently include `typst`, `rust`, `web`, `go`, `markdown`, `lua`, `dotnet`, `zig`, `java`, `qml`, and `yuck`. Other top-level feature groups include `devops`, `database`, `explorer`, `test`, `debugtest`, `formatlint`, `git`, `ai`, and more; see `module.nix` for the full list.

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
