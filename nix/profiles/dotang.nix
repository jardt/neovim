{ lib, ... }:
let
  disabledSpec = {
    enable = false;
    data = lib.mkDefault null;
  };
in
{
  config.settings.aliases = lib.mkForce [ "fvim" ];
  config.settings.theme.name = "gruvbox";

  config.specs.snippets = disabledSpec;
  config.specs.explorer = disabledSpec;
  config.specs.obsidian = disabledSpec;

  config.specs."langs.typst" = disabledSpec;
  config.specs."langs.rust" = disabledSpec;
  config.specs."langs.go" = disabledSpec;
  config.specs."langs.lua" = disabledSpec;
  config.specs."langs.zig" = disabledSpec;
  config.specs."langs.java" = disabledSpec;
  config.specs."langs.qml" = disabledSpec;
  config.specs."langs.yuck" = disabledSpec;
  config.specs."langs.tex" = disabledSpec;
}
