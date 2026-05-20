inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  config.settings.config_directory = ./.;
  config.settings.aliases = [ "cvim" ];
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;

  config.runtimePkgs = with pkgs; [
    git
    ripgrep
    fd
    tree-sitter
    curl
    unzip
  ];

  config.specs.general = with pkgs.vimPlugins; [
    lazy-nvim
  ];
}
