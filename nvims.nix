inputs:
let
  inherit (inputs.nixCats) utils;
  catsvim_settings =
    { pkgs, name, ... }:
    {
      # see :help nixCats.flake.outputs.settings
      suffix-path = true;
      suffix-LD = true;
      wrapRc = true;
      # IMPORTANT:
      # your alias may not conflict with your other packages.
      aliases = [ "cvim" ];
      neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    };
  catsvim_categories =
    { pkgs, ... }:
    {
      general = true;
      gitPlugins = true;
      completion = true;
      database = false;
      snippets = true;
      extras = true;
      practice = true;
      explorer = true;
      test = true;
      welcome = false;
      undotree = true;
      statusline = true;
      formatlint = true;
      debugtest = true;
      devops = false;
      notify = true;
      git = true;

      langs = {
        rust = false;
        web = true;
        go = true;
        markdown = true;
        lua = true;
        dotnet = false;
        zig = false;
        java = false;
        qml = false;
        yuck = false;
        tex = true;
      };
      opts = {
        welcome = {
          snacks = true;
          alpha = false;
        };
        theme = {
          base16 = {
            enable = false;
            table = { };
          };
          name = "kanagawa"; # "kanagawa"; # "catppuccin-gruvbox";
        };
      };
    };
in
{
  catsvim = args: {
    settings = catsvim_settings args // {
    };
    categories = catsvim_categories args // {
      welcome = true;
    };
  };
  #minimal
  catsvi = args: {
    settings = catsvim_settings args // {
      aliases = [ "cvi" ];
      neovim-unwrapped = args.pkgs.neovim-unwrapped;
    };
    categories = catsvim_categories args // {
      general = true;
      completion = true;
      database = false;
      snippets = false;
      extras = false;
      practice = false;
      explorer = false;
      test = false;
      welcome = false;
      undotree = false;
      statusline = false;
      formatlint = false;
      debugtest = false;
      devops = false;
      notify = false;
      git = false;
      langs = {
        rust = false;
        web = false;
        go = false;
        markdown = false;
        lua = false;
        dotnet = false;
        zig = false;
        java = false;
        qml = false;
        yuck = false;
        tex = false;
      };
    };
  };
  #dotnet aglularnvim
  cats_dotang_nvim = args: {
    settings = catsvim_settings args // {
      aliases = [
        "fvim"
      ];
      neovim-unwrapped = args.pkgs.neovim-unwrapped;
    };
    categories = catsvim_categories args // {
      general = true;
      completion = true;
      database = true;
      snippets = false;
      extras = true;
      practice = true;
      explorer = true;
      test = true;
      welcome = true;
      undotree = true;
      statusline = true;
      formatlint = true;
      debugtest = true;
      devops = true;
      notify = true;
      git = true;
      langs = {
        rust = false;
        web = true;
        go = false;
        markdown = true;
        lua = false;
        dotnet = true;
        zig = false;
        java = false;
        qml = false;
        yuck = false;
        tex = false;
      };

    };
  };
}
