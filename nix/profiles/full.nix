{ lib, ... }:
let
  disabledSpec = {
    enable = false;
    data = lib.mkDefault null;
  };
in
{
  config.settings.aliases = lib.mkDefault [ "cvim" ];
  config.settings.theme.name = lib.mkDefault "kanagawa";

  config.specs.database = disabledSpec;
  config.specs.explorer = disabledSpec;
  config.specs.devops = disabledSpec;
  config.specs."langs.rust" = disabledSpec;
  config.specs."langs.dotnet" = disabledSpec;
  config.specs."langs.java" = disabledSpec;
  config.specs."langs.zig" = disabledSpec;
  config.specs."langs.qml" = disabledSpec;
  config.specs."langs.yuck" = disabledSpec;
}
