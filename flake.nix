# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license

# This is an empty nixCats config.
# you may import this template directly into your nvim folder
# and then add plugins to categories here,
# and call the plugins with their default functions
# within your lua, rather than through the nvim package manager's method.
# Use the help, and the example config github:BirdeeHub/nixCats-nvim?dir=templates/example

# It allows for easy adoption of nix,
# while still providing all the extra nix features immediately.
# Configure in lua, check for a few categories, set a few settings,
# output packages with combinations of those categories and settings.

# All the same options you make here will be automatically exported in a form available
# in home manager and in nixosModules, as well as from other flakes.
# each section is tagged with its relevant help section.

{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    plugins-nvim-ansible = {
      url = "github:mfussenegger/nvim-ansible";
      flake = false;
    };

    plugins-nvim-lsp-endhints = {
      url = "github:chrisgrieser/nvim-lsp-endhints";
      flake = false;
    };

    # see :help nixCats.flake.inputs
    # If you want your plugin to be loaded by the standard overlay,
    # i.e. if it wasnt on nixpkgs, but doesnt have an extra build step.
    # Then you should name it "plugins-something"
    # If you wish to define a custom build step not handled by nixpkgs,
    # then you should name it in a different format, and deal with that in the
    # overlay defined for custom builds in the overlays directory.
    # for specific tags, branches and commits, see:
    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples

  };

  # see :help nixCats.flake.outputs
  outputs =
    {
      self,
      nixpkgs,
      nixCats,
      ...
    }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      # the following extra_pkg_config contains any values
      # which you want to pass to the config set of nixpkgs
      # import nixpkgs { config = extra_pkg_config; inherit system; }
      # will not apply to module imports
      # as that will have your system values
      extra_pkg_config = {
        allowUnfree = true;
      };
      # management of the system variable is one of the harder parts of using flakes.

      # so I have done it here in an interesting way to keep it out of the way.
      # It gets resolved within the builder itself, and then passed to your
      # categoryDefinitions and packageDefinitions.

      # this allows you to use ${pkgs.system} whenever you want in those sections
      # without fear.

      # see :help nixCats.flake.outputs.overlays
      dependencyOverlays = # (import ./overlays inputs) ++
        [
          # This overlay grabs all the inputs named in the format
          # `plugins-<pluginName>`
          # Once we add this overlay to our nixpkgs, we are able to
          # use `pkgs.neovimPlugins`, which is a set of our plugins.
          (utils.standardPluginOverlay inputs)
          # add any other flake overlays here.

          # when other people mess up their overlays by wrapping them with system,
          # you may instead call this function on their overlay.
          # it will check if it has the system in the set, and if so return the desired overlay
          # (utils.fixSystemizedOverlay inputs.codeium.overlays
          #   (system: inputs.codeium.overlays.${system}.default)
          # )
        ];

      # see :help nixCats.flake.outputs.categories
      # and
      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }@packageDef:
        {
          # to define and use a new category, simply add a new list to a set here,
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              nixd
              ripgrep
              fd
              universal-ctags
              stdenv.cc.cc
              git
              gcc
              yamllint
              gnumake
              unzip
              fzf
              fixjson
              yamlfmt
              nixfmt-rfc-style
              taplo-lsp
              yaml-language-server
              bash-language-server
            ];

            devops = with pkgs; [
              ansible-lint
              ansible-language-server
              dockerfile-language-server-nodejs
              hadolint
            ];

            debug = with pkgs; [
              lldb
              delve
              clang-tools
            ];
            database = with pkgs; [
              sqruff
              sqlfluff
            ];

            langs = {
              rust = with pkgs; [
                cargo
                rust-analyzer-unwrapped
              ];
              go = with pkgs; [
                gopls
                impl
                gofumpt
                gomodifytags
                goimports-reviser
              ];
              markdown = with pkgs; [
                markdownlint-cli
                marksman
              ];
              lua = with pkgs; [
                stylua
                lua-language-server
                lua54Packages.lua
                lua54Packages.luacheck
                luajitPackages.luarocks
              ];
              web = with pkgs; [
                tailwindcss-language-server
                svelte-language-server
                vtsls
                eslint_d
                prettierd
                astro-language-server
                vscode-langservers-extracted
              ];
              dotnet = with pkgs; [
                csharpier
                csharp-ls
              ];
              java = with pkgs; [
                ktlint
                kotlin-language-server
                jdt-language-server
              ];
              zig = with pkgs; [
                zls
              ];
            };
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = {
            gitPlugins = with pkgs.neovimPlugins; [
              nvim-ansible
              nvim-lsp-endhints
            ];
            general = with pkgs.vimPlugins; [
              lazy-nvim
              fzf-lua
              yazi-nvim
              SchemaStore-nvim
              plenary-nvim
              lazydev-nvim
              mini-base16
              harpoon2
              vim-tmux-navigator
              which-key-nvim
              (nvim-treesitter.withPlugins (
                plugins: with plugins; [
                  nix
                  c
                  lua
                  vimdoc
                  json
                  json5
                  jsonc
                  comment
                  git_rebase
                  toml
                  yaml
                  tmux
                  xml
                  csv
                  regex
                  diff
                  vim
                  vimdoc
                ]
              ))
              nvim-treesitter-textobjects
              flash-nvim
            ];
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          optionalPlugins = {
            gitPlugins = with pkgs.neovimPlugins; [ ];
            database = with pkgs.vimPlugins; [
              vim-dadbod
              vim-dadbod-ui
              vim-dadbod-completion
              (nvim-treesitter.withPlugins (
                plugins: with plugins; [
                  sql
                ]
              ))
            ];
            formatlint = with pkgs.vimPlugins; [
              conform-nvim
              nvim-lint
            ];
            completion = with pkgs.vimPlugins; [
              blink-cmp
              blink-compat
              blink-ripgrep-nvim
              friendly-snippets
              lazydev-nvim
              colorful-menu-nvim
            ];
            snippets = with pkgs.vimPlugins; [
              luasnip
            ];
            explorer = with pkgs.vimPlugins; [
              neo-tree-nvim
              nui-nvim
              plenary-nvim
            ];
            welcome = with pkgs.vimPlugins; [
              snacks-nvim
              alpha-nvim
              mini-icons
            ];
            undotree = with pkgs.vimPlugins; [
              undotree
            ];
            git = with pkgs.vimPlugins; [
              neogit
              plenary-nvim
              diffview-nvim
              fzf-lua
              gitsigns-nvim
              vim-fugitive
              git-worktree-nvim
            ];
            practice = with pkgs.vimPlugins; [
              hardtime-nvim
              nui-nvim
            ];
            extras = with pkgs.vimPlugins; [
              grug-far-nvim
              nvim-surround
              vim-illuminate
              trouble-nvim
              todo-comments-nvim
              plenary-nvim
              snacks-nvim
              ts-comments-nvim
              mini-ai
              mini-hipatterns
            ];
            statusline = with pkgs.vimPlugins; [
              lualine-nvim
              trouble-nvim
            ];
            notify = with pkgs.vimPlugins; [
              noice-nvim
            ];
            debugtest = with pkgs.vimPlugins; [
              neotest
              nvim-nio
              nvim-treesitter
              plenary-nvim
              neotest-vitest
              neotest-golang
              nvim-dap-go
              nvim-dap
              nvim-dap-ui
              nvim-dap-ui
              nvim-dap-virtual-text
            ];
            devops = with pkgs.vimPlugins; [
              (nvim-treesitter.withPlugins (
                plugins: with plugins; [
                  dockerfile
                ]
              ))
            ];

            langs = {
              rust = with pkgs.vimPlugins; [
                rustaceanvim
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    rust
                    ron
                  ]
                ))
              ];
              markdown = with pkgs.vimPlugins; [
                render-markdown-nvim
                obsidian-nvim
                markdown-preview-nvim
                plenary-nvim
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    markdown
                  ]
                ))
              ];
              go = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    go
                    gomod
                    gosum
                    gowork
                  ]
                ))
              ];
              lua = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    lua
                  ]
                ))
              ];
              web = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    javascript
                    typescript
                    html
                    css
                    tsx
                    svelte
                    angular
                    jsdoc
                    astro
                  ]
                ))
              ];
              dotnet = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    c_sharp
                  ]
                ))
              ];
              java = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    kotlin
                    java
                  ]
                ))
              ];
              zig = with pkgs.vimPlugins; [
                (nvim-treesitter.withPlugins (
                  plugins: with plugins; [
                    zig
                  ]
                ))
              ];

            };
          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = {
            general = with pkgs; [
              libgit2
              libxml2
              imagemagick
            ];
          };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = {
            test = {
              CATTESTVAR = "It worked!";
            };
          };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = {
            test = [
              ''--set CATTESTVAR2 "It worked again!"''
            ];
          };

          # lists of the functions you would have passed to
          # python.withPackages or lua.withPackages
          # do not forget to set `hosts.python3.enable` in package settings

          # get the path to this python environment
          # in your lua config via
          # vim.g.python3_host_prog
          # or run from nvim terminal via :!<packagename>-python3
          python3.libraries = {
            test = (_: [ ]);
          };
          # populates $LUA_PATH and $LUA_CPATH
          extraLuaPackages = {
            test = [ (_: [ ]) ];
          };
        };

      # And then build a package with specific categories from above here:
      # All categories you wish to include must be marked true,
      # but false may be omitted.
      # This entire set is also passed to nixCats for querying within the lua.

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {
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
                  base16 = false;
                };
                toThisSet = [
                  "and the contents of this categories set"
                  "will be accessible to your lua with"
                  "nixCats('path.to.value')"
                  "see :help nixCats"
                ];
              };
            };

          };
      };
      # In this section, the main thing you will need to do is change the default package name
      # to the name of the packageDefinitions entry you wish to use as the default.
      defaultPackageName = "catsvim";
    in

    # see :help nixCats.flake.outputs.exports
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        # this is just for using utils such as pkgs.mkShell
        # The one used to build neovim is resolved inside the builder
        # and is passed to our categoryDefinitions and packageDefinitions
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # these outputs will be wrapped with ${system} by utils.eachSystem

        # this will make a package out of each of the packageDefinitions defined above
        # and set the default package to the one passed in here.
        packages = utils.mkAllWithDefault defaultPackage;

        # choose your package for devShell
        # and add whatever else you want in it.
        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            inputsFrom = [ ];
            shellHook = '''';
          };
        };

      }
    )
    // (
      let
        # we also export a nixos module to allow reconfiguration from configuration.nix
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
        # and the same for home manager
        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {

        # these outputs will be NOT wrapped with ${system}

        # this will make an overlay out of each of the packageDefinitions defined above
        # and set the default overlay to the one named here.
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );

}
