{
  description = "Neovim configuration packaged with nix-wrapper-modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

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

    plugins-sidekick = {
      url = "github:folke/sidekick.nvim";
      flake = false;
    };

    plugins-ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
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
      systems = lib.systems.flakeExposed;
      forEachSystem = lib.genAttrs systems;
      wrapperModule = lib.modules.importApply ./module.nix inputs;
      extraPkgConfig = {
        allowUnfree = true;
        doCheck = true;
      };
      mkPkgs = system: import nixpkgs { inherit system; config = extraPkgConfig; };
      mkWrapper =
        pkgs: profile:
        (nix-wrapper-modules.lib.evalModules {
          modules = [
            wrapperModule
            profile
          ];
          specialArgs = { inherit pkgs; };
        }).config.wrap
          { inherit pkgs; };
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = mkPkgs system;
          wrap = mkWrapper pkgs;
        in
        rec {
          catsvim = wrap ./nix/profiles/full.nix;
          catsvi = wrap ./nix/profiles/minimal.nix;
          cats_dotang_nvim = wrap ./nix/profiles/dotang.nix;
          default = catsvim;
        }
      );

      apps = forEachSystem (
        system:
        let
          mkApp = package: {
            type = "app";
            program = "${package}/bin/nvim";
          };
        in
        rec {
          catsvim = mkApp self.packages.${system}.catsvim;
          catsvi = mkApp self.packages.${system}.catsvi;
          cats_dotang_nvim = mkApp self.packages.${system}.cats_dotang_nvim;
          default = catsvim;
        }
      );

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
