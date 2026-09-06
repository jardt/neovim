{ lib, pkgs, inputs, config, ... }:
{
  imports = [ ./minimal.nix ];

  config.info.agent = true;
  config.runtimeLibs = lib.mkForce [ ];
  config.specs.general = {
    runtimePkgs = lib.mkForce [ pkgs.ripgrep pkgs.git pkgs.yazi ];
    data = lib.mkForce (with pkgs.vimPlugins; [
      config.nvim-lib.neovimPlugins.lze
      config.nvim-lib.neovimPlugins.lzextras
      inputs.fff-nvim.packages.${pkgs.stdenv.hostPlatform.system}.fff-nvim
      yazi-nvim
      snacks-nvim
      mini-icons
      mini-base16
      catppuccin-nvim
      kanagawa-nvim
      cyberdream-nvim
      gruvbox-nvim
      nord-nvim
      render-markdown-nvim
      (nvim-treesitter.withPlugins (p: with p; [
        markdown markdown_inline nix lua vim vimdoc bash c cpp python rust go
        javascript typescript tsx html css json yaml toml diff regex
      ]))
    ]);
  };
  config.specs.completion.data = lib.mkForce [ pkgs.vimPlugins.blink-cmp ];
}
