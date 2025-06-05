inputs: {
  # These are the names of your packages
  # you can include as many as you wish.
  catsvim =
    { pkgs, name, ... }:
    {
      # they contain a settings set defined above
      # see :help nixCats.flake.outputs.settings
      settings = {
        suffix-path = true;
        suffix-LD = true;
        wrapRc = true;
        # IMPORTANT:
        # your alias may not conflict with your other packages.
        aliases = [ "n" ];
        neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
      };
      # and a set of categories that you want
      # (and other information to pass to lua)
      categories = {
        general = true;
        gitPlugins = true;
        completion = true;
        database = true;
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

    };
}
