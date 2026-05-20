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
  config.info.completion = true;
  config.info.database = false;
  config.info.snippets = false;
  config.info.extras = false;
  config.info.practice = false;
  config.info.explorer = false;
  config.info.test = false;
  config.info.welcome = false;
  config.info.undotree = false;
  config.info.statusline = false;
  config.info.formatlint = false;
  config.info.debugtest = false;
  config.info.devops = false;
  config.info.notify = false;
  config.info.ai = false;
  config.info.git = false;
  config.info.obsidian = false;
  config.info.langs.typst = false;
  config.info.langs.rust = false;
  config.info.langs.web = false;
  config.info.langs.go = false;
  config.info.langs.markdown = false;
  config.info.langs.lua = false;
  config.info.langs.dotnet = false;
  config.info.langs.zig = false;
  config.info.langs.java = false;
  config.info.langs.qml = false;
  config.info.langs.yuck = false;
  config.info.langs.tex = false;

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
