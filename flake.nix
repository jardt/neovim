{
  description = "Neovim configuration packaged with nix-wrapper-modules";

  inputs = {
    # `nixos-unstable`, not `nixpkgs-unstable`: the consumer repository builds this
    # flake with its own `nixos-unstable` nixpkgs through `follows`. Tracking the
    # faster branch here would check this repository against a newer tree than the
    # one that actually builds it, so a break would only appear downstream.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };

    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };

    plugins-nvim-ansible = {
      url = "github:mfussenegger/nvim-ansible";
      flake = false;
    };

    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };

    plugins-nvim-lsp-endhints = {
      url = "github:chrisgrieser/nvim-lsp-endhints";
      flake = false;
    };

    plugins-blink-indent = {
      url = "github:saghen/blink.indent";
      flake = false;
    };

    plugins-ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };

    plugins-delta-lua = {
      url = "github:kokusenz/delta.lua";
      flake = false;
    };

    plugins-deltaview = {
      url = "github:kokusenz/deltaview.nvim";
      flake = false;
    };

    fff-nvim = {
      url = "github:dmtrKovalenko/fff.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forEachSystem = lib.genAttrs systems;
      wrapperModule = lib.modules.importApply ./module.nix inputs;
      extraPkgConfig = {
      };
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = extraPkgConfig;
        };
      mkWrapper =
        pkgs: profile:
        (nix-wrapper-modules.lib.evalModules {
          modules = [
            wrapperModule
            profile
          ];
          specialArgs = { inherit pkgs inputs; };
        }).config.wrap
          { inherit pkgs; };
    in
    {
      wrapperModules = {
        neovim = wrapperModule;
        default = self.wrapperModules.neovim;
      };

      packages = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
          wrap = mkWrapper pkgs;
        in
        rec {
          full = wrap ./nix/profiles/full.nix;
          minimal = wrap ./nix/profiles/minimal.nix;
          agent = wrap ./nix/profiles/agent.nix;
          dotang = wrap ./nix/profiles/dotang.nix;

          # Compatibility aliases.
          catsvim = full;
          catsvi = minimal;
          cats_dotang_nvim = dotang;
          default = full;
        }
      );

      apps = forEachSystem (
        system:
        let
          mkApp = description: package: {
            type = "app";
            program = "${package}/bin/nvim";
            meta = { inherit description; };
          };
        in
        rec {
          full = mkApp "Run the full Neovim configuration" self.packages.${system}.full;
          minimal = mkApp "Run the minimal Neovim configuration" self.packages.${system}.minimal;
          agent = mkApp "Run the agent-focused Neovim configuration" self.packages.${system}.agent;
          dotang = mkApp "Run the .NET and Angular Neovim configuration" self.packages.${system}.dotang;

          # Compatibility aliases.
          catsvim = full;
          catsvi = minimal;
          cats_dotang_nvim = dotang;
          default = full;
        }
      );

      checks = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
          packages = self.packages.${system};
          mkStartupCheck =
            name: package:
            pkgs.runCommand "${name}-startup-check" { } ''
              export HOME="$TMPDIR/home"
              export XDG_CACHE_HOME="$TMPDIR/cache"
              export XDG_DATA_HOME="$TMPDIR/data"
              export XDG_STATE_HOME="$TMPDIR/state"
              mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
              ${package}/bin/nvim --headless +qa
              touch "$out"
            '';
        in
        {
          inherit (packages) full minimal agent dotang;
          full-startup = mkStartupCheck "full" packages.full;
          minimal-startup = mkStartupCheck "minimal" packages.minimal;
          agent-startup = mkStartupCheck "agent" packages.agent;
          dotang-startup = mkStartupCheck "dotang" packages.dotang;
        }
      );

      formatter = forEachSystem (system: (mkPkgs system).nixfmt-tree);

      devShells = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            name = "catsvim";
            packages = [ self.packages.${system}.default ];
          };
        }
      );
    };
}
