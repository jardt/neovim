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
  config.info.snippets = false;
  config.info.explorer = false;
  config.info.obsidian = false;
  config.info.opts.theme.name = "gruvbox";
  config.info.langs.typst = false;
  config.info.langs.rust = false;
  config.info.langs.go = false;
  config.info.langs.lua = false;
  config.info.langs.zig = false;
  config.info.langs.java = false;
  config.info.langs.qml = false;
  config.info.langs.yuck = false;
  config.info.langs.tex = false;
  config.info.langs.dotnet = true;
  config.info.database = true;
  config.info.devops = true;

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
