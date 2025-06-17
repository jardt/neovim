inputs:
let
  inherit (inputs.nixCats) utils;
in
{
  pkgs,
  settings,
  categories,
  name,
  extra,
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
      terraform-ls
      tflint
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
        rustup
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
      qml = with pkgs; [
        kdePackages.qtdeclarative
      ];
    };
  };

  # This is for plugins that will load at startup without using packadd:
  startupPlugins = {
    general =
      with pkgs.vimPlugins;
      [
        lazy-nvim
        fzf-lua
        yazi-nvim
        SchemaStore-nvim
        plenary-nvim
        lazydev-nvim
        harpoon2
        vim-tmux-navigator

        #themes
        mini-base16
        catppuccin-nvim
        kanagawa-nvim
        cyberdream-nvim

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
      ]
      ++ [
        pkgs.neovimPlugins.nvim-lsp-endhints

      ];
  };

  # not loaded automatically at startup.
  # use with packadd and an autocommand in config to achieve lazy loading
  optionalPlugins = {
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
      mini-icons
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
    extras =
      with pkgs.vimPlugins;
      [
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
      ]
      ++ [
        pkgs.neovimPlugins.nvim-lsp-endhints

      ];
    statusline = with pkgs.vimPlugins; [
      lualine-nvim
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
    devops =
      with pkgs.vimPlugins;
      [
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            dockerfile
            bicep
            terraform
            hcl
          ]
        ))
      ]
      ++ [
        pkgs.neovimPlugins.nvim-ansible
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
      web =
        with pkgs.vimPlugins;
        [
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
        ]
        ++ [
          pkgs.neovimPlugins.blink-css-vars
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
      qml = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            qmljs
          ]
        ))
      ];
      yuck = with pkgs.vimPlugins; [
        yuck-vim
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            yuck
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
}
