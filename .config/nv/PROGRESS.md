# nvim-slim: progress notes

Small, explicit, LazyVim-like Neovim config on `vim.pack`. Source of truth for the plan:
`nvim-slim-briefing.md`. This file records where the build stands.

Run it in parallel to LazyVim with `NVIM_APPNAME=nv nvim` (config dir `~/.config/nv`).
Neovim 0.12.5 is required (built-in `vim.pack`, `vim.lsp.config/enable`).

## Layout

```
init.lua                 leader, loads modules in order
lua/config/plugins.lua   vim.pack.add, plugin setup, treesitter parser list (M.parsers)
lua/config/lsp.lua       servers, diagnostics, format on save, nvim-lint
lua/config/options.lua   
lua/config/keymaps.lua   ALL keymaps (snacks, LSP on attach, toggles)
lua/config/autocmds.lua  yank, resize, last pos, q-close, checktime, prose, cd to dir, helm ft
lua/config/health.lua    :checkhealth config (missing tools, servers, parsers, plugins)
```

Load order matters: options, plugins, lsp, keymaps (needs snacks + which-key), autocmds.

## Decisions taken

- Colorscheme: catppuccin, `transparent_background = true`.
- blink.cmp: Enter accepts a selected item, nothing is preselected, `<C-y>` accepts the first.
- `nvim <dir>` sets the cwd to that directory (no root detection; pickers search from cwd).
- Format on save: off by default (`vim.g.autoformat`), toggle `<leader>uf`, applies to every
  buffer with an attached LSP server. No Helm exception is configured on purpose.
  `<leader>cf` formats manually via LSP (whole buffer, also in visual mode).
- Go `organizeImports` on save is NOT implemented (dropped to keep things simple).
- `spelllang = "de,en"` is set per buffer (prose filetypes, `<leader>us`), not globally.
  Dictionaries download to `stdpath("data")/site/spell`.
- No Kubernetes schema glob for yamlls; only SchemaStore. Files in `*/templates/*.yaml` get
  filetype `helm` with buffer-local diagnostics off.
- Docker: only `hadolint` via nvim-lint, no Docker language servers for now.
- `<A-j>/<A-k>` line moving was removed on purpose.

## Steps

Done and confirmed working: 1 (base), 2 (plugins, snacks, blink, mini.pairs), 3 (treesitter,
LSP scaffold with lua_ls).

Written, not yet confirmed by testing:
- 4: rust-analyzer (clippy), gopls, basedpyright + ruff, format toggle.
- 5: yamlls + SchemaStore, hadolint, Helm template filetype detection.
- The refactor into fewer files (last change): needs one clean start and `:checkhealth config`.

Open:
- 6: Helm: `towolf/vim-helm`, `helm_ls`. Check filetype detection and yamlls errors in templates.
- 7: Markdown/prose: render-markdown.nvim, marksman.
- 8: conform (Prettier for markdown/yaml, no Dockerfile formatter) for manual formatting.
- 9: polish: root detection (optional), optional plugins (mini.surround, flash, lualine,
  rustaceanvim, crates.nvim), agent integration (claudecode.nvim).

## Setting up on another machine

1. Install the tools. `:checkhealth config` lists what is missing. Known packages:
   `git gcc ripgrep fd tree-sitter-cli lua-language-server rust-analyzer gopls ruff`
   `yaml-language-server hadolint prettier marksman` (package names for `basedpyright`, `helm_ls`
   are unverified; check pacman/AUR/npm).
2. Copy this directory to `~/.config/nv` and start `NVIM_APPNAME=nv nvim`. `vim.pack` clones the
   plugins and the `PackChanged` hook runs `:TSUpdate` (needs the `tree-sitter` CLI).
3. Copy `nvim-pack-lock.json` too if you want the same plugin revisions.
4. Run `:checkhealth config` and `:checkhealth vim.lsp`.

## Cleanup left to do

- Remove the unused tokyonight clone: `:lua vim.pack.del({ "tokyonight.nvim" })`.
