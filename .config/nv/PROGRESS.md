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
- LSP keymaps: prefer Neovim's own `gr*` defaults (`grn` rename, `gra` code action, `grx` codelens,
  `gO` document symbols, see `:h grr`) over custom LazyVim-style ones. Only `grr`/`gri`/`grt`
  (references/implementation/type definition) are overridden per-buffer to use Snacks' picker
  instead of quickfix/loclist. `gd`/`gD` stay custom since Neovim has no default for them. This
  deviates from the briefing's original "same keymaps as LazyVim" framing on purpose: built-in
  Neovim functionality wins over reproducing LazyVim's exact scheme, to keep the config smaller.
  (Also fixes a real bug: our old custom `gr` collided with Neovim's global `grr/grn/gra/gri/grt`
  defaults, which share the "gr" prefix, causing an ambiguous which-key popup on `gr`.)
- Python: `pyright` (official Arch package) instead of `basedpyright` (AUR-only), same role —
  hover/goto/diagnostics from pyright, ruff for lint/format (hover disabled on the ruff client).
- No Mason. All LSP/format/lint binaries come from official Arch packages where possible.
  `helm_ls` and `hadolint` are AUR-only, so they're installed manually as GitHub release binaries
  instead of pulling in Mason for two tools — avoids a second, parallel package manager next to
  pacman. A dedicated tool to manage these manually installed binaries is planned for later.

## Steps

Done and confirmed working: 1 (base), 2 (plugins, snacks, blink, mini.pairs), 3 (treesitter,
LSP scaffold with lua_ls).

All tools installed, `:checkhealth config` fully green.

Step 4, partially confirmed:
- Rust (rust-analyzer): `grr`/`gri`/`grt`/`grn`/`gra` all confirmed working interactively.
  (A one-off rust-analyzer crash, `-32603 TextRange -offset overflowed`, showed up during the
  earlier `gr`/which-key keymap collision but did not reproduce afterwards with clean `grr` — was
  very likely a side effect of the ambiguous keypresses, not a real bug.)
- Still to test: Go (gopls) goto/hints, Python (pyright hover + ruff diagnostics), format-on-save
  toggle (`<leader>uf`) for Rust/Go/Python, inlay hints.

Step 5, not yet tested interactively: yamlls + SchemaStore, hadolint, Helm template filetype
detection.

Open:
- 6: Helm: `towolf/vim-helm`, `helm_ls`. Check filetype detection and yamlls errors in templates.
- 7: Markdown/prose: render-markdown.nvim, marksman.
- 8: conform (Prettier for markdown/yaml, no Dockerfile formatter) for manual formatting.
- 9: polish: root detection (optional), optional plugins (mini.surround, flash, lualine,
  rustaceanvim, crates.nvim), agent integration (claudecode.nvim).

## Setting up on another machine

1. Install the tools. `:checkhealth config` lists what is missing.
   - Official Arch packages (`pacman -S`): `git gcc ripgrep fd tree-sitter-cli lua-language-server
     rust-analyzer gopls ruff pyright yaml-language-server marksman prettier`.
   - No AUR, no Mason on purpose (see "Decisions taken" above): `helm_ls` and `hadolint` have no pacman
     package. Install them as static GitHub release binaries (both are single Go binaries) into
     something like `~/.local/bin`. A small script to track/update these manually installed
     binaries is planned but not written yet.
2. Copy this directory to `~/.config/nv` and start `NVIM_APPNAME=nv nvim`. `vim.pack` clones the
   plugins and the `PackChanged` hook runs `:TSUpdate` (needs the `tree-sitter` CLI).
3. Copy `nvim-pack-lock.json` too if you want the same plugin revisions.
4. Run `:checkhealth config` and `:checkhealth vim.lsp`.

