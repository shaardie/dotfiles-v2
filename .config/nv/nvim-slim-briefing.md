# Briefing: schlanke, LazyVim-nahe Neovim-Config ("nvim-slim")

Dieses Dokument fasst alle Entscheidungen aus der Vorplanung zusammen. Ziel: Claude Code baut damit
zusammen mit Sven live am Rechner die eigentliche Konfiguration.

## 1. Ziel und Arbeitsweise

- Sven nutzt LazyVim, findet es aber zu groß und komplex, will aber keine eigene, große Config pflegen.
  Ziel: **kleine, explizite Config, die sich wie LazyVim anfühlt** (gleiche Keymaps, gleiche Grundbausteine).
- Code einfach und explizit halten, wenig Abstraktion, kurze Kommentare. Kein Nachbau von LazyVim-Magie.
- Schrittweise vorgehen (Reihenfolge siehe Abschnitt 10), jeden Schritt am Rechner testen lassen.
- **Parallel zu LazyVim** entwickeln, LazyVim nicht anfassen:
  `tar`/Ordner nach `~/.config/nvim-slim`, Start mit `NVIM_APPNAME=nvim-slim nvim`
  (eigene Daten-, State- und Cache-Ordner). Umstieg erst nach 1 bis 2 Wochen Praxistest.

## 2. Umgebung

- Arch Linux, Sway. Neovim **>= 0.11**, getestet mit **0.12.5** (eingebautes `vim.pack`, `vim.lsp.config/enable`).
- Sven arbeitet parallel mit einem KI-Agenten (Claude Code oder OpenCode) in einem separaten Terminal.
- Abhängigkeiten: `git`, `gcc`, `ripgrep`, `fd`, `tree-sitter-cli` (für nvim-treesitter `main`), Nerd Font im Terminal.

## 3. Sprachen und Dateitypen

Rust, Go, Python, Markdown/Prosa, Helm-Charts, Kubernetes-Manifeste (YAML), Dockerfiles.

## 4. Was Sven aus LazyVim nutzt und behalten will

Dateibaum (Explorer), Fuzzy-Finder (Dateien/Grep), Autovervollständigung, Linter, Gotos
(Definition, Referenzen ...), Syntax-/Snippet-Vervollständigung. **Kein gitsigns** (nicht gewünscht).
Auto-Format siehe Abschnitt 6.

## 5. Plugin-Manager: `vim.pack` (nicht lazy.nvim)

Entscheidung: eingebautes `vim.pack` statt lazy.nvim, weil weniger Schichten (kein `opts`/`keys`/`event`),
Lockdatei `nvim-pack-lock.json` in der Config, Updates per `vim.pack.update()`.

- **Getestet** (headless, 0.12.5): `vim.pack.add({...})` installiert Plugins;
  `{ src = ..., version = vim.version.range("1.*") }` funktioniert; `version = "main"` als Branch;
  Lockdatei wird erzeugt.
- **Nicht getestet:** `PackChanged`-Autocmd für Build-Schritte (z. B. `:TSUpdate`). Autocmd vor
  `vim.pack.add` definieren und die aktuelle Doku (`:help vim.pack`) prüfen.
- Kein Lazy-Loading: bei ~15 Plugins unproblematisch. Setup explizit per `require("x").setup({...})`
  und Keymaps in normalen `vim.keymap.set`-Aufrufen.
- Fallback: Es existiert eine getestete lazy.nvim-Vorlage (`nvim-slim.tar.gz`, ~475 Zeilen, 13 Plugins).
  Sie kann als Referenz für Keymaps, Options und Autocmds dienen, muss aber auf `vim.pack` umgestellt werden.

## 6. Plugins

Repo-Namen sind bis auf `towolf/vim-helm`, `coder/claudecode.nvim` und die Kernplugins der Vorlage
aus dem Gedächtnis: beim Installieren prüfen, `vim.pack` meldet falsche URLs sofort.

**Kern**
- `folke/snacks.nvim`: Picker (Fuzzy-Finder) und Explorer in einem; `bigfile` optional. `require("snacks").setup(...)` nötig.
- `saghen/blink.cmp` (`version = vim.version.range("1.*")`): Completion. Preset `enter`, `<C-y>` = select_and_accept,
  Quellen: lsp, path, snippets, buffer; Doku-Popup automatisch. LSP-Capabilities über `require("blink.cmp").get_lsp_capabilities()`.
- `rafamadriz/friendly-snippets`: Snippet-Sammlung für blink.cmp.
- `neovim/nvim-lspconfig`: liefert nur Server-Defaults (`lsp/*.lua`), Aktivierung über `vim.lsp.config` / `vim.lsp.enable`.
- `nvim-treesitter/nvim-treesitter` (Branch `main`, braucht `tree-sitter` CLI + C-Compiler).
  Parser: bash, c, diff, go, gomod, gosum, json, lua, luadoc, markdown, markdown_inline, python, query, regex, rust, toml, vim, vimdoc, yaml, dockerfile, helm (falls verfügbar). Highlighting per `FileType`-Autocmd mit `vim.treesitter.start`.
- `folke/tokyonight.nvim` (Style `moon`), `folke/which-key.nvim` (Preset `helix`).
- `echasnovski/mini.pairs` bzw. `nvim-mini/mini.pairs` (beide Namen liefen in der Vorlage), Klammern automatisch schließen.

**Sprachen/Tools**
- `towolf/vim-helm`: Filetype `helm` (Voraussetzung für `helm_ls`).
- `b0o/SchemaStore.nvim`: JSON-/YAML-Schemas für yamlls (Compose, CI ...).
- `MeanderingProgrammer/render-markdown.nvim`: Markdown im Buffer rendern.
- `stevearc/conform.nvim`: Formatter für manuelles Formatieren (siehe Abschnitt 7).
- `mfussenegger/nvim-lint`: hadolint für Dockerfiles (Markdown: markdownlint, live entscheiden).

**Optional, erst bei Bedarf**
`mini.surround` (`gsa/gsd/gsr`), `flash.nvim` (`s`/`S`), `lualine.nvim`, `mrcjkb/rustaceanvim`,
`saecki/crates.nvim`, `nvim-dap` (später), `coder/claudecode.nvim` (siehe Abschnitt 9).

**Bewusst nicht**: gitsigns, LanguageTool/ltex (Rechtschreibung reicht eingebaut), noice, bufferline,
dashboard, mason (vorerst; nur für Nischen-Server erwägen, falls AUR/npm nervt).

## 7. LSP-Server (keine Plugins, aus Paketmanager)

Nur aktivieren, wenn das Binary im PATH liegt (Muster: `vim.lsp.config[name].cmd[1]` mit `vim.fn.executable` prüfen).

| Sprache | Server | Anmerkung |
|---|---|---|
| Rust | `rust-analyzer` | `check.command = "clippy"` |
| Go | `gopls` | `gofumpt`, `staticcheck`, Hints |
| Python | `basedpyright` + `ruff` | ruff auch für Format/Lint |
| YAML/k8s | `yaml-language-server` | Kubernetes-Schema per Glob für Manifeste außerhalb von Helm |
| Helm | `helm_ls` | nutzt yamlls mit Kubernetes-Schema für `templates/**` |
| Docker | Dockerfile-Language-Server, `docker-compose-language-service` | oft npm oder AUR |
| Markdown | `marksman` | |
| Lua | `lua-language-server` | für das Bearbeiten der eigenen Config (`Snacks` als Global) |

LspAttach-Keymaps: Neovims eigene `gr*`-Defaults bleiben nach Möglichkeit unverändert (`grn` Rename,
`gra` Code Action, `grx` Codelens, `gO` Document Symbols, siehe `:h grr`); nur `grr`/`gri`/`grt`
(Referenzen/Implementation/Type Definition) zeigen stattdessen auf Snacks-Picker statt Quickfix.
`gd`/`gD` (Definition/Declaration) sind eigene Mappings, da Neovim dafür keine Defaults mitliefert.
`<leader>cf`;
Inlay-Hints standardmäßig an (`<leader>uh` schaltet um). `]d`/`[d` sind in Neovim eingebaut.
Diagnostics: `virtual_text` mit Prefix, `severity_sort`.

## 8. Formatieren

- **Automatisch beim Speichern:** Rust, Go, Python. Rust über rust-analyzer (rustfmt), Go über gopls
  (gofumpt) **plus** Import-Organisation (`source.organizeImports`, synchron vor dem Format),
  Python über ruff. Ohne angehängten Server still nichts tun. Umschalten mit `<leader>uf`.
- **Nur manuell** (`<leader>cf`, Normal + Visual): alles andere. Über conform:
  Markdown und YAML mit Prettier; **Helm-Templates nicht formatieren** (`{{ }}` wird zerlegt);
  Dockerfile ohne Formatter; sonst LSP als Fallback.
- Ein gemeinsamer Aufruf für alle Fälle, eine Pattern-Liste zum Pflegen.

## 9. Zusammenarbeit mit KI-Agent im Terminal

- **Pflicht:** Dateien automatisch neu laden, wenn der Agent sie ändert:
  ```lua
  vim.o.autoread = true
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
    callback = function()
      if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
    end,
  })
  ```
- Erstmal kein Plugin. Optional später `coder/claudecode.nvim` (reines Lua, WebSocket-MCP-Protokoll wie die IDE-Erweiterungen,
  Abhängigkeit snacks.nvim). Es gibt viele ähnlich benannte Plugins (z. B. `greggh/claude-code.nvim` nur als Terminal-Toggle);
  einer der Forks warnte vor Problemen mit neueren Claude-Code-Versionen: Kompatibilität mit Svens Version vorher prüfen.
  Für OpenCode existiert ebenfalls ein Neovim-Plugin, Name zuerst recherchieren.

## 10. Prosa/Markdown

Eingebaute Rechtschreibung: `spelllang = { "de", "en" }`, `spell` per `FileType`-Autocmd nur für markdown/text/gitcommit,
dazu `wrap` und `linebreak`. Wörterbücher lädt Neovim beim ersten Mal nach.

## 11. Keymaps (LazyVim-Stil, Leader = Space)

- Suchen: `<leader><space>` Dateien, `<leader>,` Buffer, `<leader>/` Grep, `<leader>:` Command-History,
  `<leader>ff/fb/fg/fr/fc`, `<leader>sg/sw/sd/sh/sk/ss/sr`, `<leader>xx/xX` Diagnostics, `<leader>uC` Colorschemes
- Explorer: `<leader>e`
- Buffer/Fenster: `<S-h>/<S-l>`, `<leader>bd/bo/bb`, `<C-h/j/k/l>`, `<C-Pfeile>` Resize, `<leader>-` und `<leader>|` Splits, `<leader>wd`
- Editieren: `<A-j>/<A-k>` Zeilen verschieben, `<`/`>` behalten Auswahl, `<C-s>` speichern, `<esc>` löscht Suchmarkierung, `<leader>qq` beenden
- LSP: wo Neovim selbst schon ein Mapping mitbringt (`grn/gra/grx/gO`, siehe Abschnitt 7), wird das
  übernommen statt ein eigenes LazyVim-Pendant zu bauen — Prinzip: eingebaute Neovim-Funktionalität
  vor eigenem Code, auch wenn das vom exakten LazyVim-Schema abweicht.
- Toggles: `<leader>uw` Wrap, `us` Spell, `ud` Diagnostics, `uh` Inlay-Hints, `uf` Format-on-save
- Optional: `gsa/gsd/gsr` (mini.surround), `s`/`S` (flash)

## 12. Optionen (aus der Vorlage)

`number` + `relativenumber`, `signcolumn=yes`, `cursorline`, `scrolloff=4`, `wrap=false`, `termguicolors`, `laststatus=3`,
Tabs 2 Spaces (`expandtab`, `shiftround`), `ignorecase`+`smartcase`, `splitright/splitbelow`, `undofile`, `updatetime=200`,
`timeoutlen=300`, `confirm`, `mouse=a`, `clipboard=unnamedplus` (außer SSH), `grepprg=rg --vimgrep`, `list` mit `listchars`,
`smoothscroll`, `jumpoptions=view`.
Autocmds: Yank-Highlight, Splits bei Resize angleichen, letzte Cursorposition wiederherstellen, `q` schließt help/qf/man,
Autoread/checktime, Format on save.

## 13. Vorgehen (Reihenfolge)

1. Vorlage bzw. Grundgerüst mit `NVIM_APPNAME=nvim-slim` starten, Basis prüfen.
2. Auf `vim.pack` umstellen (Lockdatei, PackChanged für Treesitter).
3. Rust und Go mit echten Servern verifizieren (bisher nur mit Attrappen getestet).
4. Python: basedpyright + ruff, Format on save.
5. YAML/Kubernetes (yamlls, SchemaStore) und Dockerfiles (Server + hadolint).
6. Helm (`vim-helm`, `helm_ls`): fummeligster Teil, Filetype-Erkennung und yamlls-Fehler im Template ausprobieren.
7. Markdown/Prosa (Spell, render-markdown, marksman).
8. conform (manuelles Formatieren) und nvim-lint.
9. Feinschliff: Root-Erkennung (LazyVim sucht ab Projekt-Root, Vorlage nur ab cwd), Wünsche aus dem Praxistest.

## 14. Teststrategie (hat in der Vorplanung funktioniert)

Headless mit isolierten XDG-Ordnern (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, ...), `nvim --headless "+lua ..." +qa`:
Plugins laden, Treesitter-Parser, Keymaps vorhanden, `LspAttach` feuern. Für LSP-Ende-zu-Ende dienten Attrappen-Server
(kleines Python-Skript mit JSON-RPC); am echten Rechner stattdessen die echten Server nutzen.

## 15. Ungeprüft / offen

- Rust, Go, Python, Helm, yamlls und Docker wurden nie mit echten Servern getestet.
- `vim.pack`: nur Installation, Versionsbereiche und Lockdatei geprüft.
- Repo-Namen der Nischen-Plugins (siehe Abschnitt 6) beim Installieren verifizieren.
- Ob Arch-Pakete für helm-ls und die Docker-Server existieren oder AUR/npm nötig ist.
- Root-Erkennung für Picker und Plugin-Integration für Claude Code/OpenCode sind noch nicht entschieden.
