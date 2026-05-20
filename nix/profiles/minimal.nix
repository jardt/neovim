{ lib, pkgs, ... }:
let
  disabledSpec = {
    enable = false;
    data = lib.mkDefault null;
  };
in
{
  config.package = lib.mkForce pkgs.neovim-unwrapped;
  config.settings.aliases = lib.mkForce [ "cvi" ];

  config.specs.completion = disabledSpec;
  config.specs.database = disabledSpec;
  config.specs.snippets = disabledSpec;
  config.specs.extras = disabledSpec;
  config.specs.practice = disabledSpec;
  config.specs.explorer = disabledSpec;
  config.specs.welcome = disabledSpec;
  config.specs.undotree = disabledSpec;
  config.specs.statusline = disabledSpec;
  config.specs.formatlint = disabledSpec;
  config.specs.debugtest = disabledSpec;
  config.specs.devops = disabledSpec;
  config.specs.notify = disabledSpec;
  config.specs.ai = disabledSpec;
  config.specs.git = disabledSpec;
  config.specs.obsidian = disabledSpec;

  config.specs."langs.typst" = disabledSpec;
  config.specs."langs.rust" = disabledSpec;
  config.specs."langs.web" = disabledSpec;
  config.specs."langs.go" = disabledSpec;
  config.specs."langs.markdown" = disabledSpec;
  config.specs."langs.lua" = disabledSpec;
  config.specs."langs.dotnet" = disabledSpec;
  config.specs."langs.zig" = disabledSpec;
  config.specs."langs.java" = disabledSpec;
  config.specs."langs.qml" = disabledSpec;
  config.specs."langs.yuck" = disabledSpec;
  config.specs."langs.tex" = disabledSpec;
}
