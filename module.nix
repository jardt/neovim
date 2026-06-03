inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  categoryInfo = {
    general = true;
    completion = true;
    database = false;
    snippets = true;
    extras = true;
    practice = true;
    explorer = false;
    test = true;
    welcome = true;
    undotree = true;
    statusline = true;
    formatlint = true;
    debugtest = true;
    devops = false;
    notify = true;
    ai = true;
    git = true;
    obsidian = false;

    langs = {
      typst = true;
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
      picker = {
        fzf = false;
        snacks = true;
      };
      theme = {
        base16 = {
          enable = false;
          table = { };
        };
        name = "kanagawa";
      };
    };
  };
in
{
  imports = [ wlib.wrapperModules.neovim ];

  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  options.settings.theme.name = lib.mkOption {
    type = lib.types.str;
    default = "kanagawa";
    description = "Theme name exported to Lua metadata.";
  };

  config.settings.config_directory = ./.;
  config.settings.aliases = [ "cvim" ];
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
  config.info = lib.mapAttrsRecursive (_: lib.mkDefault) categoryInfo;
  config.runtimeLibs = with pkgs; [
    libgit2
    libxml2
    imagemagick
  ];

  config.specMods =
    { ... }:
    {
      options.runtimePkgs = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Runtime packages to put on PATH when this spec is enabled.";
      };
    };

  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

  config.specs.general = {
    runtimePkgs = with pkgs; [
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
      taplo
      yaml-language-server
      bash-language-server
      tree-sitter
      curl
      coreutils
      mercurial
      chafa
      viu
      ueberzugpp
    ];
    data =
      with pkgs.vimPlugins;
      [
        config.nvim-lib.neovimPlugins.lze
        config.nvim-lib.neovimPlugins.lzextras
        fzf-lua
        yazi-nvim
        SchemaStore-nvim
        plenary-nvim
        lazydev-nvim
        harpoon2
        vim-tmux-navigator
        mini-base16
        catppuccin-nvim
        kanagawa-nvim
        cyberdream-nvim
        blink-pairs
        mini-icons
        config.nvim-lib.neovimPlugins.treesitter-textobjects
        flash-nvim
        gruvbox-nvim
        nord-nvim
        which-key-nvim
        (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            nix
            c
            lua
            vimdoc
            json
            json5
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
          ]
        ))
      ]
      ++ [
        config.nvim-lib.neovimPlugins.nvim-lsp-endhints
        config.nvim-lib.neovimPlugins.blink-indent
      ];
  };

  config.specs.database = {
    lazy = true;
    runtimePkgs = with pkgs; [
      sqruff
      sqlfluff
    ];
    data = with pkgs.vimPlugins; [
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      (nvim-treesitter.withPlugins (plugins: with plugins; [ sql ]))
    ];
  };

  config.specs.formatlint = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      conform-nvim
      nvim-lint
    ];
  };
  config.specs.completion = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      blink-cmp
      blink-compat
      blink-ripgrep-nvim
      friendly-snippets
      lazydev-nvim
      colorful-menu-nvim
    ];
  };
  config.specs.snippets = {
    lazy = true;
    data = with pkgs.vimPlugins; [ luasnip ];
  };
  config.specs.explorer = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      neo-tree-nvim
      nui-nvim
      plenary-nvim
      mini-icons
    ];
  };
  config.specs.welcome = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      snacks-nvim
      alpha-nvim
      mini-icons
    ];
  };
  config.specs.undotree = {
    lazy = true;
    data = with pkgs.vimPlugins; [ undotree ];
  };
  config.specs.git = {
    lazy = true;
    runtimePkgs = with pkgs; [ gh ];
    data = with pkgs.vimPlugins; [
      snacks-nvim
      plenary-nvim
      diffview-nvim
      fzf-lua
      gitsigns-nvim
      config.nvim-lib.neovimPlugins.delta-lua
      config.nvim-lib.neovimPlugins.deltaview
    ];
  };
  config.specs.practice = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      hardtime-nvim
      nui-nvim
    ];
  };
  config.specs.extras = {
    lazy = true;
    data = with pkgs.vimPlugins; [
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
      config.nvim-lib.neovimPlugins.nvim-lsp-endhints
    ];
  };
  config.specs.statusline = {
    lazy = true;
    data = with pkgs.vimPlugins; [ lualine-nvim ];
  };
  config.specs.notify = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      noice-nvim
      nui-nvim
    ];
  };
  config.specs.ai = {
    lazy = true;
    runtimePkgs = with pkgs; [ copilot-language-server ];
    data = with pkgs.vimPlugins; [
      config.nvim-lib.neovimPlugins.sidekick
      copilot-lsp
    ];
  };
  config.specs.debugtest = {
    lazy = true;
    runtimePkgs = with pkgs; [
      lldb
      delve
      clang-tools
    ];
    data = with pkgs.vimPlugins; [
      nvim-treesitter
      plenary-nvim
      nvim-dap-go
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ];
  };
  config.specs.devops = {
    lazy = true;
    runtimePkgs = with pkgs; [
      ansible-lint
      dockerfile-language-server
      hadolint
      terraform-ls
      tflint
    ];
    data = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          dockerfile
          bicep
          terraform
          hcl
        ]
      ))
      config.nvim-lib.neovimPlugins.nvim-ansible
    ];
  };
  config.specs.obsidian = {
    lazy = true;
    data = with pkgs.vimPlugins; [ obsidian-nvim ];
  };

  config.specs."langs.typst" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      typst
      tinymist
      typstyle
    ];
    data = with pkgs.vimPlugins; [ typst-preview-nvim ];
  };
  config.specs."langs.rust" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      rustup
      rust-analyzer-unwrapped
    ];
    data = with pkgs.vimPlugins; [
      rustaceanvim
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          rust
          ron
        ]
      ))
    ];
  };
  config.specs."langs.go" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      gopls
      impl
      gofumpt
      gomodifytags
      goimports-reviser
    ];
    data = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          go
          gomod
          gosum
          gowork
        ]
      ))
    ];
  };
  config.specs."langs.markdown" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      markdownlint-cli
      marksman
    ];
    data = with pkgs.vimPlugins; [
      render-markdown-nvim
      markdown-preview-nvim
      plenary-nvim
      (nvim-treesitter.withPlugins (plugins: with plugins; [ markdown ]))
    ];
  };
  config.specs."langs.lua" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      stylua
      lua-language-server
      lua54Packages.lua
      lua54Packages.luacheck
      luajitPackages.luarocks
    ];
    data = with pkgs.vimPlugins; [ (nvim-treesitter.withPlugins (plugins: with plugins; [ lua ])) ];
  };
  config.specs."langs.web" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      tailwindcss-language-server
      svelte-language-server
      vtsls
      eslint_d
      prettierd
      astro-language-server
      angular-language-server
      vscode-langservers-extracted
    ];
    data = with pkgs.vimPlugins; [
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
      tsc-nvim
      config.nvim-lib.neovimPlugins.ts-error-translator
    ];
  };
  config.specs."langs.dotnet" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      csharpier
      roslyn-ls
      netcoredbg
    ];
    data = with pkgs.vimPlugins; [
      roslyn-nvim
      (nvim-treesitter.withPlugins (plugins: with plugins; [ c_sharp ]))
    ];
  };
  config.specs."langs.java" = {
    lazy = true;
    runtimePkgs = with pkgs; [
      ktlint
      kotlin-language-server
      jdt-language-server
    ];
    data = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        plugins: with plugins; [
          kotlin
          java
        ]
      ))
    ];
  };
  config.specs."langs.zig" = {
    lazy = true;
    runtimePkgs = with pkgs; [ zls ];
    data = with pkgs.vimPlugins; [ (nvim-treesitter.withPlugins (plugins: with plugins; [ zig ])) ];
  };
  config.specs."langs.qml" = {
    lazy = true;
    runtimePkgs = with pkgs; [ kdePackages.qtdeclarative ];
    data = with pkgs.vimPlugins; [ (nvim-treesitter.withPlugins (plugins: with plugins; [ qmljs ])) ];
  };
  config.specs."langs.yuck" = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      yuck-vim
      (nvim-treesitter.withPlugins (plugins: with plugins; [ yuck ]))
    ];
  };
  config.specs."langs.tex" = {
    lazy = true;
    data = with pkgs.vimPlugins; [ vimtex ];
  };
}
