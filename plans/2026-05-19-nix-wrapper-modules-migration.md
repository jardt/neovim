# nix-wrapper-modules Migration Implementation Plan

**Goal:** Replace this repo's nixCats packaging with nix-wrapper-modules while preserving the current normal Lua Neovim config workflow without Nix.

**Architecture:** Keep `init.lua`, `lua/`, and `lsp/` as normal Neovim config files. First migrate the Nix wrapper from nixCats to nix-wrapper-modules with minimal Lua disruption; then replace lazy.nvim with native `vim.pack` for non-Nix plugin installation and `lze`/`lzextras` for lazy loading. Nix mode remains declarative, while plain `nvim` mode uses `nvim-pack-lock.json`.

**Tech Stack:** Nix flakes, nix-wrapper-modules Neovim wrapper, neovim-nightly-overlay, Neovim native `vim.pack`, `lze`, `lzextras`.

---

## File Structure

- Modify: `flake.nix` — replace nixCats input/output plumbing with nix-wrapper-modules package outputs.
- Create: `module.nix` — shared base wrapper module importing `wlib.wrapperModules.neovim` and defining common plugins, runtime packages, settings, and custom options.
- Create: `nix/profiles/full.nix`, `nix/profiles/minimal.nix`, `nix/profiles/dotang.nix` — package variant modules composed by `flake.nix`.
- Modify or replace: `cats.nix` — either remove after migration or convert into reusable category/spec declarations consumed by `module.nix`.
- Modify or replace: `nvims.nix` — either remove after migration or convert package variant definitions into wrapper module imports/options.
- Modify: `init.lua` — replace nixCats-specific bootstrap with a small compatibility layer for both Nix and non-Nix runs.
- Modify then delete: `lua/config/lazy.lua` — keep temporarily during the wrapper migration, then remove when native `vim.pack` plus `lze` replaces lazy.nvim.
- Delete after migration: `lua/nixCatsUtils/` — remove only after all references to `nixCatsUtils`, `nixCats`, and `lazyCat` are gone.
- Modify: `README.md` — update project description and commands from nixCats to nix-wrapper-modules.
- Keep: `lua/plugins/**`, `lua/config/**`, `lsp/**`, `lazy-lock.json` — preserve normal Lua dotfiles layout unless a plugin spec needs a small compatibility change.

## Migration Constraints

- Preserve plain Neovim use: copying this repo to `~/.config/nvim` and launching system `nvim` must use native `vim.pack` and read `nvim-pack-lock.json`.
- Preserve Nix use: `nix run .` must launch the full config with Nix-installed plugins/runtime packages.
- Preserve variants where practical: current variants are `catsvim`/default, `catsvi` minimal, and `cats_dotang_nvim` with alias `fvim`.
- Keep old output names and binary aliases during migration for compatibility. Add a post-migration todo to consider renaming `catsvim`, `catsvi`, and `cats_dotang_nvim` now that nixCats is gone.
- Define variants as Nix profile modules rather than recreating nixCats categories as the main package-construction model.
- Use feature flags as the single source of truth for both Nix-installed plugin groups/tools and Lua `lze` registration. Keep the current nixCats category names as feature names during migration. Add a post-migration todo to revisit the feature taxonomy.
- Native `vim.pack` mode does not automatically run lazy.nvim-style `build` hooks. Use a conservative approach: do not auto-run build commands; document manual install/update commands for plugins that need them.
- Non-Nix plugin management requires a Neovim build with `vim.pack`; older Neovim should degrade gracefully by loading bare config without plugin management.
- Preserve current Neovim package choices except make `cats_dotang_nvim` use neovim-nightly too. `catsvim` uses nightly, `catsvi` keeps nixpkgs stable/unwrapped, and `cats_dotang_nvim` uses nightly.
- Use a pure wrapper config directory: `settings.config_directory = ./.`; do not add an impure/live dev wrapper in this migration.
- Maintain `lua/config/pack.lua` manually for non-Nix `vim.pack` plugin URLs. Keep Nix flake plugin inputs for Nix mode and duplicate URLs in the Lua manifest for now.
- Track both `lazy-lock.json` and `nvim-pack-lock.json` during the transition; remove `lazy-lock.json` only at the end of Part 2.
- Do not rewrite plugin configs during Part 1 just to match the new wrapper framework. In Part 2, convert lazy.nvim specs into `lze` specs and setup callbacks.
- Use nix-wrapper-modules' `settings.config_directory = ./.` for the migration; defer any impure/live dev wrapper.

---

## Part 1: nixCats to nix-wrapper-modules Migration

Part 1 changes only the Nix wrapper architecture. lazy.nvim remains the plugin manager for plain non-Nix mode and remains the Lua plugin-spec format while the wrapper is migrated.

### Part 1 End State

At the end of Part 1:

- `flake.nix` uses `nix-wrapper-modules` instead of nixCats for package outputs.
- `module.nix` is the shared base wrapper module.
- `nix/profiles/full.nix`, `nix/profiles/minimal.nix`, and `nix/profiles/dotang.nix` define the current variants.
- Package outputs still exist as `default`, `catsvim`, `catsvi`, and `cats_dotang_nvim`.
- Binary aliases still exist as `cvim`, `cvi`, and `fvim`.
- `catsvim` and `cats_dotang_nvim` use neovim-nightly; `catsvi` keeps nixpkgs stable/unwrapped Neovim.
- The wrapper uses a pure config directory: `settings.config_directory = ./.`.
- A typed `features` option controls installed plugin groups/tools and is exported to Lua as settings metadata.
- Current feature names match the old nixCats category names for compatibility.
- Lua no longer depends on `nixCatsUtils`, `nixCats`, `lazyCat`, or `pawsible`.
- lazy.nvim still works, `lazy-lock.json` remains tracked, and plugin specs are not yet converted to `lze`.
- Plain non-Nix `nvim` still behaves as before with lazy.nvim.

### Part 1 Definition of Done

Part 1 is done when all of these pass:

```bash
! rg 'nixCats|nixCatsUtils|lazyCat|pawsible' init.lua lua lsp flake.nix module.nix nix
nix flake show
nix build .#catsvim .#catsvi .#cats_dotang_nvim
nix run .#catsvim -- --headless '+lua print("catsvim ok")' +qa
nix run .#catsvi -- --headless '+lua print("catsvi ok")' +qa
nix run .#cats_dotang_nvim -- --headless '+lua print("cats_dotang_nvim ok")' +qa
nvim --headless '+lua print("plain lazy mode ok")' +qa
```

Expected:

- no nixCats runtime references remain; historical docs/plan references are acceptable only outside runtime files
- all three Nix packages build
- all three wrapped Neovim variants start headlessly
- plain Neovim starts with lazy.nvim still managing plugins

---

### Task 1: Add nix-wrapper-modules input and keep the old build intact temporarily

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add the new input next to existing inputs**

Add this input without deleting `nixCats` yet:

```nix
nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
```

- [ ] **Step 2: Update the lockfile**

Run:

```bash
nix flake lock --update-input nix-wrapper-modules
```

Expected: `flake.lock` contains a new `nix-wrapper-modules` node.

- [ ] **Step 3: Confirm the current nixCats build still works**

Run:

```bash
nix flake show
nix build .#catsvim
```

Expected: existing outputs still evaluate/build before migration starts.

- [ ] **Step 4: Commit the isolated input addition**

```bash
git add flake.nix flake.lock
git commit -m "chore: add nix-wrapper-modules input"
```

---

### Task 2: Create the first wrapper module with only core settings

**Files:**
- Create: `module.nix`
- Modify: `flake.nix`

- [ ] **Step 1: Create `module.nix` with a minimal wrapped Neovim**

```nix
inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  config.settings.config_directory = ./.;
  config.settings.aliases = [ "cvim" ];
  config.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;

  config.runtimePkgs = with pkgs; [
    git
    ripgrep
    fd
    tree-sitter
    curl
    unzip
  ];

  config.specs.general = with pkgs.vimPlugins; [
    lazy-nvim
  ];
}
```

- [ ] **Step 2: Add a temporary package output that evaluates this module**

In `flake.nix`, add a package named `wrapper-test` using the nix-wrapper-modules library. Follow the interface from `templates/neovim/flake.nix` in `/home/jdr/.cache/checkouts/github.com/BirdeeHub/nix-wrapper-modules`.

- [ ] **Step 3: Build the temporary wrapper**

Run:

```bash
nix build .#wrapper-test
```

Expected: a wrapped Neovim package builds successfully.

- [ ] **Step 4: Commit the minimal wrapper**

```bash
git add flake.nix module.nix
git commit -m "feat: add initial nix wrapper module"
```

---

### Task 3: Replace nixCats Lua bootstrap with a compatibility module

**Files:**
- Modify: `init.lua`
- Modify: `lua/config/lazy.lua`
- Create: `lua/config/nix.lua`

- [ ] **Step 1: Create `lua/config/nix.lua`**

```lua
local M = {}

local plugin_name = vim.g.nix_info_plugin_name
local ok, nix_info = false, nil

if plugin_name then
  ok, nix_info = pcall(require, plugin_name)
end

if not ok then
  nix_info = setmetatable({}, {
    __call = function(_, default)
      return default
    end,
  })
end

M.is_nix = plugin_name ~= nil and ok
M.info = nix_info

function M.get(default, ...)
  if type(nix_info) == "function" then
    return nix_info(default, ...)
  end
  return default
end

function M.plugin_path(name)
  return M.get(nil, "plugins", "start", name) or M.get(nil, "plugins", "lazy", name)
end

return M
```

- [ ] **Step 2: Replace nixCats setup in `init.lua`**

Remove these lines:

```lua
require("nixCatsUtils").setup({
	non_nix_value = true,
})
```

Add this near the top instead:

```lua
_G.nix_config = require("config.nix")
```

- [ ] **Step 3: Replace the lockfile helper in `init.lua`**

Use this implementation:

```lua
local function getlockfilepath()
	local unwrapped = nix_config.get(nil, "settings", "unwrappedCfgPath")
	if nix_config.is_nix and type(unwrapped) == "string" then
		return unwrapped .. "/lazy-lock.json"
	end
	return vim.fn.stdpath("config") .. "/lazy-lock.json"
end
```

- [ ] **Step 4: Replace `lazyCat.setup` with normal lazy setup in `init.lua`**

Remove:

```lua
local lazyCat = require("nixCatsUtils.lazyCat")
lazyCat.setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), { import = "plugins" }, lazyOptions)
```

Add:

```lua
require("config.lazy").setup(lazyOptions)
```

- [ ] **Step 5: Convert `lua/config/lazy.lua` into a callable setup module**

Keep the existing bootstrap logic, but wrap setup like this:

```lua
local M = {}

function M.setup(opts)
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not nix_config.plugin_path("lazy.nvim") and not (vim.uv or vim.loop).fs_stat(lazypath) then
		local lazyrepo = "https://github.com/folke/lazy.nvim.git"
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
		if vim.v.shell_error ~= 0 then
			vim.api.nvim_echo({
				{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
				{ out, "WarningMsg" },
				{ "\nPress any key to exit..." },
			}, true, {})
			vim.fn.getchar()
			os.exit(1)
		end
	end

	if not nix_config.plugin_path("lazy.nvim") then
		vim.opt.rtp:prepend(lazypath)
	end

	vim.g.mapleader = " "
	vim.g.maplocalleader = "\\"

	require("lazy").setup({
		spec = {
			{ import = "plugins" },
		},
		install = { colorscheme = { "cat" } },
		checker = { enabled = true },
	}, opts or {})
end

return M
```

- [ ] **Step 6: Test plain non-Nix Neovim**

Run:

```bash
nvim --headless '+Lazy! sync' +qa
```

Expected: lazy.nvim bootstraps or loads normally and plugin specs are read.

- [ ] **Step 7: Test wrapped Neovim**

Run:

```bash
nix run .#wrapper-test -- --headless '+Lazy! sync' +qa
```

Expected: lazy.nvim is loaded from the wrapper-provided plugin; no `nixCatsUtils` module is required.

- [ ] **Step 8: Commit the Lua bridge**

```bash
git add init.lua lua/config/lazy.lua lua/config/nix.lua
git commit -m "feat: add nix-wrapper Lua compatibility bridge"
```

---

### Task 4: Migrate plugin and runtime categories into wrapper specs

**Files:**
- Modify: `module.nix`
- Reference: `cats.nix`
- Reference: `nvims.nix`

- [ ] **Step 1: Add `pluginsFromPrefix` helper for custom plugin inputs**

Add the helper pattern from the nix-wrapper-modules Neovim template so inputs named `plugins-*` become available as `config.nvim-lib.neovimPlugins.<name>`.

- [ ] **Step 2: Port `cats.nix` `lspsAndRuntimeDeps` to `config.runtimePkgs` or per-spec `runtimePkgs`**

Move these groups from `cats.nix`:

```nix
general, devops, git, debug, database, langs.typst, langs.rust, langs.go, langs.markdown, langs.lua, langs.web, langs.dotnet, langs.java, langs.zig, langs.qml
```

Expected: full wrapper has the same command-line tools/LSPs available on `PATH` as `catsvim` currently has.

- [ ] **Step 3: Port startup plugins**

Move `startupPlugins.general` from `cats.nix` into `config.specs.general.data` or equivalent wrapper spec data.

Expected: core plugins such as `lazy-nvim`, `fzf-lua`, `yazi-nvim`, `SchemaStore-nvim`, `lazydev-nvim`, treesitter grammars, themes, and custom plugin inputs are installed by Nix.

- [ ] **Step 4: Port optional plugins into named specs**

Create named specs matching current category names:

```nix
database, formatlint, completion, snippets, explorer, welcome, undotree, git, practice, extras, statusline, notify, ai, debugtest, devops, obsidian, langs.*
```

Expected: each spec can be enabled/disabled independently in wrapper variants.

- [ ] **Step 5: Build and smoke test**

Run:

```bash
nix build .#wrapper-test
nix run .#wrapper-test -- --headless '+checkhealth' +qa
```

Expected: wrapper builds and starts without missing plugin errors.

- [ ] **Step 6: Commit migrated specs**

```bash
git add module.nix
git commit -m "feat: migrate nixCats categories to wrapper specs"
```

---

### Task 5: Recreate package variants and final flake outputs

**Files:**
- Modify: `flake.nix`
- Modify: `module.nix`
- Reference: `nvims.nix`

- [ ] **Step 1: Recreate the full default package**

Map current `catsvim` categories/settings from `nvims.nix` into the default wrapper package:

```nix
aliases = [ "cvim" ];
completion = true;
snippets = true;
extras = true;
practice = true;
test = true;
welcome = true;
undotree = true;
statusline = true;
formatlint = true;
debugtest = true;
notify = true;
ai = true;
git = true;
langs.web = true;
langs.go = true;
langs.markdown = true;
langs.lua = true;
langs.tex = true;
settings.theme.name = "kanagawa";
```

- [ ] **Step 2: Recreate the minimal package**

Map current `catsvi` settings into a `catsvi` output with alias `cvi`, stable `pkgs.neovim-unwrapped`, and most optional specs disabled.

- [ ] **Step 3: Recreate the dotnet/angular package**

Map current `cats_dotang_nvim` settings into a `cats_dotang_nvim` output with alias `fvim`, database/devops/dotnet/web enabled, theme `gruvbox`, and neovim-nightly as its Neovim package.

- [ ] **Step 4: Set package defaults**

Ensure:

```bash
nix run .
nix run .#catsvim
nix run .#catsvi
nix run .#cats_dotang_nvim
```

all resolve to wrapper packages.

- [ ] **Step 5: Commit package outputs**

```bash
git add flake.nix module.nix
git commit -m "feat: recreate neovim wrapper variants"
```

---

### Task 6: Remove nixCats leftovers

**Files:**
- Modify: `flake.nix`
- Delete: `cats.nix` if fully superseded
- Delete: `nvims.nix` if fully superseded
- Delete: `lua/nixCatsUtils/`
- Modify: `.luarc.json` if it references nixCats-only globals

- [ ] **Step 1: Search for nixCats references**

Run:

```bash
rg "nixCats|nixCatsUtils|lazyCat|pawsible|catsvim_settings|categoryDefinitions|packageDefinitions"
```

Expected before deletion: only known migration leftovers appear.

- [ ] **Step 2: Remove obsolete files and inputs**

Delete old nixCats-specific files only after the wrapper variants build:

```bash
git rm -r lua/nixCatsUtils
git rm cats.nix nvims.nix
```

Remove `nixCats.url` and all nixCats builder code from `flake.nix`.

- [ ] **Step 3: Update the lockfile**

Run:

```bash
nix flake lock
```

Expected: `flake.lock` no longer requires `nixCats` unless another input still references it.

- [ ] **Step 4: Verify no Lua references remain**

Run:

```bash
rg "nixCats|nixCatsUtils|lazyCat|pawsible" init.lua lua lsp
```

Expected: no matches.

- [ ] **Step 5: Commit cleanup**

```bash
git add flake.nix flake.lock .luarc.json
git rm -r lua/nixCatsUtils cats.nix nvims.nix
git commit -m "chore: remove nixCats migration leftovers"
```

---

### Task 7: Update interim documentation and verification commands

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update project description**

For the interim wrapper migration, replace the nixCats bullet with:

```markdown
- [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) to build wrapped Neovim packages with Nix-provided plugins and runtime tools.
- [lazy.nvim](https://github.com/folke/lazy.nvim) for normal non-Nix plugin management when this repo is used as plain `~/.config/nvim`.
```

- [ ] **Step 2: Update Nix commands**

Document:

```markdown
Run full config: `nix run github:jardt/neovim`
Run minimal config: `nix run github:jardt/neovim#catsvi`
Run dotnet/angular config: `nix run github:jardt/neovim#cats_dotang_nvim`
```

- [ ] **Step 3: Document non-Nix behavior**

Add:

```markdown
Without Nix during Part 1, this config still bootstraps lazy.nvim into `stdpath('data')/lazy/lazy.nvim` and uses `lazy-lock.json` from the config directory. Part 2 replaces this with native `vim.pack` and `nvim-pack-lock.json`. LSPs, formatters, and linters must be installed by the host system.
```

- [ ] **Step 4: Commit docs**

```bash
git add README.md
git commit -m "docs: describe nix-wrapper-modules setup"
```

---

### Task 7.5: Record post-migration rename todo

**Files:**
- Create or modify: `plans/2026-05-19-nix-wrapper-modules-migration.md` or a repo todo file if one exists

- [ ] **Step 1: Record compatibility naming decision**

Add a note that package outputs remain `catsvim`, `catsvi`, and `cats_dotang_nvim` during this migration for compatibility.

- [ ] **Step 2: Record future rename candidates**

Add this post-migration todo:

```markdown
Post-migration rename todo: consider adding clearer output aliases such as `full`, `minimal`, and `dotang` or renaming the primary outputs away from `cats*` once nixCats has been removed. Preserve old outputs for at least one transition period.

Feature taxonomy todo: review feature names after migration, especially broad names like `extras`, combined names like `debugtest`, and language/tool overlap. Prefer clearer names only after behavior is stable.
```

---

### Task 8: Final validation

**Files:**
- No code changes expected unless validation finds defects.

- [ ] **Step 1: Evaluate flake outputs**

Run:

```bash
nix flake show
```

Expected: package outputs include default, `catsvim`, `catsvi`, and `cats_dotang_nvim`.

- [ ] **Step 2: Build all migrated packages**

Run:

```bash
nix build .#catsvim .#catsvi .#cats_dotang_nvim
```

Expected: all packages build.

- [ ] **Step 3: Smoke test headless startup for each variant**

Run:

```bash
nix run .#catsvim -- --headless '+lua print("catsvim ok")' +qa
nix run .#catsvi -- --headless '+lua print("catsvi ok")' +qa
nix run .#cats_dotang_nvim -- --headless '+lua print("cats_dotang_nvim ok")' +qa
```

Expected: each command exits 0 and prints its marker.

- [ ] **Step 4: Smoke test plain Neovim path**

Run from the repo root with this repo as config:

```bash
XDG_CONFIG_HOME="$PWD/.tmp-xdg-config" XDG_DATA_HOME="$PWD/.tmp-xdg-data" sh -c 'mkdir -p "$XDG_CONFIG_HOME" && ln -s "$PWD" "$XDG_CONFIG_HOME/nvim" && nvim --headless "+lua print(\"plain nvim ok\")" +qa'
```

Expected: exits 0 and prints `plain nvim ok`.

- [ ] **Step 5: Remove temporary test output**

Delete the `wrapper-test` output if it still exists and the real package outputs replace it.

- [ ] **Step 6: Commit final fixes**

```bash
git add -A
git commit -m "test: validate nix-wrapper migration"
```


## Part 2: Native `vim.pack` Migration and `lze` Lazy Loading Strategy

Neovim now has native package management through `vim.pack.add()`. After the nix-wrapper-modules wrapper exists, migrate non-Nix plugin management from lazy.nvim to `vim.pack`, and migrate lazy-loading semantics from lazy.nvim to `lze`/`lzextras`, matching the nix-wrapper-modules Neovim template recommendation.

### Design Decisions

- Nix mode remains declarative: plugins are installed by nix-wrapper-modules specs and exposed on runtimepath/package path.
- Non-Nix mode uses `vim.pack.add()` instead of lazy.nvim.
- Replace `lazy-lock.json` with Neovim's native `nvim-pack-lock.json` in the config directory.
- Existing files under `lua/plugins/` should be converted from lazy.nvim specs into `lze` specs.
- Use `lze` handlers for lazy-loading semantics instead of hand-written autocmd/key/command wrappers.
- Keep Nix optional plugins marked with nix-wrapper-modules `lazy = true`; `lze` should call `packadd` when the trigger fires.
- Prefer eager loading for cheap/core plugins. Use `lze` lazy specs for expensive plugins, language-specific tooling, UI tools, DAP/test tools, database tools, and AI tools.

### Native `vim.pack` facts from Neovim docs

- `vim.pack.add({ specs }, opts)` installs plugins into `stdpath('data')/site/pack/core/opt` and adds them to the current session.
- The native lockfile is `$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json`. Track it in git.
- `vim.pack.add()` supports `{ src, name, version, data }` specs.
- `vim.pack.add(..., { load = false })` installs/registers without loading, equivalent to `:packadd!`.
- Lazy loading can be implemented by later calling `vim.cmd.packadd(plugin_name)` and then running plugin setup; `lze` provides the trigger framework for this.
- Updates are managed with `:packupdate`; removals with `:packdel`.
- lazy.nvim `build` fields are not preserved automatically. Manual build/install commands must be documented for affected plugins such as markdown-preview and rustowl.

---

### Part 2 End State

At the end of Part 2:

- lazy.nvim is removed from Nix specs and non-Nix bootstrap code.
- `lua/config/lazy.lua` is deleted.
- `lazy-lock.json` is deleted.
- `nvim-pack-lock.json` is tracked.
- Plain non-Nix mode installs plugins through native `vim.pack.add()`.
- Plain non-Nix mode uses the full/default profile plugin set.
- `lze` and `lzextras` are installed eagerly in both Nix and non-Nix modes.
- Current lazy.nvim trigger behavior is preserved as closely as practical through `lze` specs.
- Plugin setup remains owned by the existing `lua/plugins/*.lua` files where practical.
- Nix feature flags remain the single source of truth for wrapped package contents and Lua/`lze` enablement.
- Plugins with former lazy.nvim `build` hooks do not auto-run builds; manual commands are documented.
- Older non-Nix Neovim without `vim.pack` degrades gracefully to bare config and warns instead of crashing.

### Part 2 Definition of Done

Part 2 is done when all of these pass:

```bash
! rg 'lazy.nvim|require\\("lazy"|lazy-lock|Lazy!|nixCats|nixCatsUtils|lazyCat|pawsible' init.lua lua module.nix flake.nix README.md
test -f nvim-pack-lock.json
test ! -e lazy-lock.json
test ! -e lua/config/lazy.lua
nix flake show
nix build .#catsvim .#catsvi .#cats_dotang_nvim
nix run .#catsvim -- --headless '+lua print(require("lze") ~= nil)' +qa
nix run .#catsvi -- --headless '+lua print("catsvi ok")' +qa
nix run .#cats_dotang_nvim -- --headless '+lua print(require("lze") ~= nil)' +qa
nvim --headless '+lua print(vim.pack ~= nil)' '+lua print(require("lze") ~= nil)' +qa
```

Expected:

- no lazy.nvim/nixCats runtime references remain
- native pack lockfile exists and old lazy lockfile is gone
- all Nix variants build and start
- both Nix and non-Nix modes can load `lze`
- plain non-Nix mode has `vim.pack` available or emits the documented graceful warning on older Neovim

---

### Task 9: Add a native package registry for non-Nix mode

**Files:**
- Create: `lua/config/pack.lua`
- Modify: `init.lua`
- Add after generation: `nvim-pack-lock.json`

- [ ] **Step 1: Create `lua/config/pack.lua` with helper functions**

```lua
local M = {}

local function gh(repo)
	return "https://github.com/" .. repo
end

M.plugins = {
	{ src = gh("folke/snacks.nvim"), name = "snacks.nvim" },
	{ src = gh("ibhagwan/fzf-lua"), name = "fzf-lua" },
	{ src = gh("nvim-treesitter/nvim-treesitter"), name = "nvim-treesitter" },
	{ src = gh("neovim/nvim-lspconfig"), name = "nvim-lspconfig" },
	{ src = gh("folke/which-key.nvim"), name = "which-key.nvim" },
}

M.lazy_plugins = {
	{ src = gh("kristijanhusak/vim-dadbod-ui"), name = "vim-dadbod-ui" },
	{ src = gh("mfussenegger/nvim-dap"), name = "nvim-dap" },
	{ src = gh("nvim-neotest/neotest"), name = "neotest" },
}

function M.add()
	if nix_config.is_nix then
		return
	end

	if vim.pack == nil then
		vim.notify("This config requires Neovim with vim.pack for non-Nix plugin management", vim.log.levels.ERROR)
		return
	end

	vim.pack.add(M.plugins, { confirm = false })
	vim.pack.add(M.lazy_plugins, { confirm = false, load = false })
end

function M.load(name)
	if nix_config.is_nix then
		return true
	end
	local ok = pcall(vim.cmd.packadd, name)
	return ok
end

return M
```

- [ ] **Step 2: Call native pack setup from `init.lua`**

Add after `_G.nix_config = require("config.nix")`:

```lua
_G.pack_config = require("config.pack")
pack_config.add()
```

- [ ] **Step 3: Generate native lockfile**

Run:

```bash
nvim --headless '+lua require("config.pack").add()' +qa
```

Expected: `nvim-pack-lock.json` is created in the config directory.

- [ ] **Step 4: Commit the native pack bootstrap**

```bash
git add init.lua lua/config/pack.lua nvim-pack-lock.json
git commit -m "feat: add native vim.pack plugin bootstrap"
```

---

### Task 10: Prepare plugin setup functions for `lze`

**Files:**
- Modify/Create: `lua/plugins/*.lua`
- Modify: `init.lua`
- Delete after conversion: `lua/config/lazy.lua`
- Delete after conversion: `lazy-lock.json`

- [ ] **Step 1: Inventory current lazy.nvim fields**

Run:

```bash
rg "event =|cmd =|keys =|ft =|dependencies =|opts =|config =|init =|build =" lua/plugins
```

Expected: list every lazy.nvim-specific behavior that must be represented in `lze` specs.

- [ ] **Step 2: Create an eager plugin setup loader**

For eager plugins only, replace lazy setup with direct setup calls:

```lua
require("plugins.themes").setup()
require("plugins.treesitter").setup()
require("plugins.completion").setup()
require("plugins.lsp").setup()
require("plugins.git").setup()
require("plugins.statusline").setup()
```

Each eager module must return a table with `setup = function() ... end`. Lazy modules may export either `setup()` or `specs()` depending on the final organization.

- [ ] **Step 3: Convert each plugin module**

For each `lua/plugins/<name>.lua`, replace lazy.nvim return specs like:

```lua
return {
	"owner/plugin.nvim",
	opts = {},
}
```

with setup functions usable from `lze.after` callbacks, like:

```lua
local M = {}

function M.setup()
	local ok, plugin = pcall(require, "plugin")
	if not ok then
		return
	end
	plugin.setup({})
end

return M
```

- [ ] **Step 4: Commit converted eager modules in small batches**

Use one commit per related group:

```bash
git add lua/plugins/themes.lua lua/plugins/treesitter.lua
git commit -m "refactor: convert core plugin setup from lazy specs"
```

---

### Task 11: Implement lazy loading with `lze` and `lzextras`

**Files:**
- Create: `lua/config/lze.lua`
- Modify: `init.lua`
- Modify: selected `lua/plugins/*.lua`
- Modify: `module.nix`
- Modify: `flake.nix`

- [ ] **Step 1: Add `lze` and `lzextras` flake inputs**

Add these inputs to `flake.nix`:

```nix
plugins-lze = {
  url = "github:BirdeeHub/lze";
  flake = false;
};

plugins-lzextras = {
  url = "github:BirdeeHub/lzextras";
  flake = false;
};
```

- [ ] **Step 2: Install `lze` and `lzextras` in the wrapper**

In `module.nix`, include them as startup plugins so lazy loading is available immediately:

```nix
config.specs.lze = [
  config.nvim-lib.neovimPlugins.lze
  {
    name = "lzextras";
    data = config.nvim-lib.neovimPlugins.lzextras;
  }
];
```

Expected: `require("lze")` and `require("lzextras")` work at startup in Nix mode.

- [ ] **Step 3: Add `lze` and `lzextras` to native `vim.pack` startup plugins**

In `lua/config/pack.lua`, add:

```lua
{ src = "https://github.com/BirdeeHub/lze", name = "lze" },
{ src = "https://github.com/BirdeeHub/lzextras", name = "lzextras" },
```

Expected: `require("lze")` and `require("lzextras")` work at startup in non-Nix mode.

- [ ] **Step 4: Create `lua/config/lze.lua`**

```lua
local M = {}

function M.setup()
	local ok_lze, lze = pcall(require, "lze")
	if not ok_lze then
		return
	end

	local ok_extras, lzextras = pcall(require, "lzextras")
	if ok_extras then
		setmetatable(lze, getmetatable(lzextras))
		lze.register_handlers({
			lzextras.lsp,
		})
	end

	return lze
end

return M
```

- [ ] **Step 5: Initialize `lze` from `init.lua`**

Add before plugin setup modules are loaded:

```lua
_G.lze = require("config.lze").setup()
```

- [ ] **Step 6: Convert lazy.nvim specs to `lze` specs**

For each plugin module, replace lazy.nvim specs like:

```lua
return {
	"kristijanhusak/vim-dadbod-ui",
	cmd = "DBUI",
	config = function()
		require("plugins.dadbod").setup()
	end,
}
```

with `lze` specs like:

```lua
return {
	{
		"vim-dadbod-ui",
		cmd = "DBUI",
		after = function()
			require("plugins.dadbod").setup()
		end,
	},
}
```

Use plugin names that match the Nix package `pname` / native `vim.pack` `name`, because `lze` will ultimately load with `packadd`.

- [ ] **Step 7: Register all `lze` specs**

Create a loader that gathers converted plugin spec tables and passes them to `lze.load()`:

```lua
local specs = {}

for _, module in ipairs({
	"plugins.dadbod",
	"plugins.neotest",
	"plugins.dap",
	"plugins.markdown",
	"plugins.typst",
}) do
	local ok, plugin_specs = pcall(require, module)
	if ok and type(plugin_specs) == "table" then
		vim.list_extend(specs, plugin_specs)
	end
end

if lze then
	lze.load(specs)
end
```

- [ ] **Step 8: Test `lze` lazy loading**

Run:

```bash
nvim --headless '+lua print(require("lze") ~= nil)' '+lua vim.cmd("DBUI")' +qa
nix run .#catsvim -- --headless '+lua print(require("lze") ~= nil)' +qa
```

Expected: `lze` loads in both non-Nix and Nix mode; command/key/filetype-triggered plugins load without lazy.nvim.

- [ ] **Step 9: Commit `lze` migration**

```bash
git add flake.nix module.nix init.lua lua/config/lze.lua lua/config/pack.lua lua/plugins
git commit -m "feat: use lze for lazy loading"
```


### Task 12: Remove lazy.nvim from both Nix and non-Nix paths

**Files:**
- Modify: `module.nix`
- Delete: `lua/config/lazy.lua`
- Delete: `lazy-lock.json`
- Modify: `README.md`

- [ ] **Step 1: Remove lazy.nvim from wrapper specs**

Delete `lazy-nvim` from all nix-wrapper module plugin specs unless another plugin still requires it.

- [ ] **Step 2: Remove lazy.nvim bootstrap file and lockfile**

```bash
git rm lua/config/lazy.lua lazy-lock.json
```

- [ ] **Step 3: Verify no lazy.nvim references remain**

Run:

```bash
rg "lazy.nvim|require\("lazy"|lazy-lock|Lazy!|event =|cmd =|keys =|ft =" init.lua lua module.nix README.md
```

Expected: no lazy.nvim dependency references remain. Lazy-loading helper names may remain only as `config.lazyload`.

- [ ] **Step 4: Update README**

Replace the lazy.nvim bullet with:

```markdown
- Neovim native `vim.pack` for plugin installation when this repo is used as plain `~/.config/nvim`.
- `lze`/`lzextras` for lazy loading in both Nix and non-Nix modes.
```

- [ ] **Step 5: Final validation for native package mode**

Run:

```bash
nvim --headless '+lua print(vim.pack ~= nil)' +qa
nix run .#catsvim -- --headless '+lua print("nix wrapper ok")' +qa
```

Expected: plain mode has `vim.pack`; Nix mode starts without lazy.nvim; both modes can `require("lze")`.

- [ ] **Step 6: Commit lazy.nvim removal**

```bash
git add -A
git commit -m "refactor: replace lazy.nvim with native vim.pack"
```


## Self-Review

- Spec coverage: The plan preserves normal Lua config, adds nix-wrapper-modules, migrates Nix plugin/runtime definitions, recreates package variants, removes nixCats, adds native `vim.pack` plugin management, replaces lazy.nvim lazy loading with `lze`/`lzextras`, and updates docs.
- Placeholder scan: No `TBD`, `TODO`, or empty implementation steps remain. Task 4 intentionally references existing category names because the source lists already exist in `cats.nix`; each concrete group is named.
- Type/name consistency: The package names stay `catsvim`, `catsvi`, and `cats_dotang_nvim`; Lua bridge names are consistently `nix_config`, `config.nix`, `plugin_path`, and `get`.
