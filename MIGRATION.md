# Migration: lazy.nvim → vim.pack

Branch: `migrate/vim-pack`. Goal: drop `lazy.nvim`, move all plugins to Neovim's
built-in `vim.pack`, adopt the new kickstart sectioned `init.lua` structure,
modernize where safe, and **preserve all existing functionality + shortcuts**.

Neovim 0.12.2 (has `vim.pack`). Eager loading accepted (no declarative
lazy-loading); relies on `vim.loader.enable()` bytecode cache.

## How the new system works

- `init.lua` — numbered `do…end` SECTION blocks. Each section calls
  `vim.pack.add{ 'https://github.com/owner/repo' }` then `require(x).setup{}`.
- `lua/custom/plugins/init.lua` — a **loader** that `require()`s every sibling
  `.lua` file. Each custom file is now *imperative* (runs `vim.pack.add` +
  setup + keymaps) instead of `return {spec}`.
- Build steps run from one `PackChanged` autocmd in init.lua Section 2.
- `vim.pack` does **no** dependency resolution → every dependency is listed
  explicitly. `keys=`/`cmd=` lazy stubs become explicit `vim.keymap.set` /
  `nvim_create_user_command`.

## Conversion recipe (per custom file)

```
return { 'owner/repo', dependencies={...}, ft=..., keys={...}, build=..., opts={...} }
```
becomes
```
vim.pack.add { 'https://github.com/dep/one', 'https://github.com/owner/repo' }
require('repo').setup { ... }          -- from opts/config
vim.keymap.set(...)                    -- from each keys= entry
-- build= → add a branch to the PackChanged hook in init.lua
-- ft=/event= → eager load (accepted); FileType-gate only if needed for correctness
```

## Decisions made

- **Treesitter migrated to the `main` branch** (done as a follow-up after the
  base migration was verified). See "Treesitter main-branch migration" below for
  the API changes and the one-time `vim.pack.update()` step required to switch.
- **Picker = snacks** (not Telescope). Telescope kept only as an orgmode/swift
  dependency.
- **Colorscheme**: dynamic macOS/Linux theme detector (carbonfox/dayfox via
  nightfox) ported to Section 3; full theme list kept in `themes.lua`.
- **netcoredbg path**: resolved via `nvim_get_runtime_file` (the old hardcoded
  `…/lazy/…` path breaks under vim.pack).
- **mason registries** (mason-org + crashdummyy) consolidated into Section 5.

## Issues found in the existing config (preserved as-is unless noted)

- `monaspace.lua` uses `enable = false` (typo for `enabled`) → currently
  **enabled**. Preserved as enabled. Flag for your review.
- Duplicate Neogit config (one in old `custom/plugins/init.lua`, one in
  `neogit.lua`). Consolidated onto `neogit.lua` (the codediff version).
- `roslyn.nvim` `opts` (broad_search/filewatching) were never applied by lazy
  (config fn present → no auto-setup). Preserved faithfully (not applied).
- `easy-dotnet` `terminal` action calls `require('toggleterm')` but toggleterm
  is disabled — only errors if that action is invoked. Pre-existing; preserved.
- `netcore.lua` (kickstart.plugins.netcore) is unused. Left as-is.

## Checklist

### Foundation
- [ ] init.lua Section 1 — options/keymaps/autocmds/diagnostics
- [ ] init.lua Section 2 — PackChanged build hooks

### Base (init.lua sections)
- [ ] S3 guess-indent, gitsigns(base), which-key, todo-comments, mini.nvim, colorscheme
- [ ] S5 LSP (mason + registries, LspAttach, servers, mason-tool-installer)
- [ ] S6 conform (formatting)
- [ ] S7 blink.cmp + LuaSnip + lazydev + blink.compat + sources
- [ ] S8 treesitter (master branch + textobjects)

### kickstart/plugins (user-customized — convert, don't replace)
- [ ] autopairs
- [ ] gitsigns (recommended keymaps)
- [ ] debug (.NET DAP + dapui + virtual-text)

### custom/plugins (convert return-spec → imperative)
- [ ] init.lua → loader; split out copilot, oil
- [ ] snacks (picker + all keymaps)  - [ ] themes  - [ ] neogit  - [ ] sidekick
- [ ] easy-dotnet  - [ ] dadbod  - [ ] obsidian  - [ ] orgmode  - [ ] trouble
- [ ] fff  - [ ] octo  - [ ] kulala  - [ ] render-markdown  - [ ] nvim-surround
- [ ] nvim-origami  - [ ] multicursors  - [ ] pipeline  - [ ] codediff
- [ ] swift  - [ ] zen-mode  - [ ] mcphub  - [ ] likec4  - [ ] jj
- [ ] typst-preview  - [ ] monaspace(enabled)  - [ ] smart-splits(disabled)
- [ ] neoscroll(disabled)  - [ ] nvim-dbee(disabled)  - [ ] avante(disabled)
- [ ] claude-code(disabled)  - [ ] codecompanion(disabled)  - [ ] toggleterm(disabled)
- [ ] custom/lsp/roslyn

### Disabled plugins
Files for genuinely-disabled plugins (`avante`, `claude-code`, `codecompanion`,
`neoscroll`, `nvim-dbee`, `smart-splits`, `toggleterm`) are **left as their
original `return {spec}` tables**. Under the new loader these are inert no-ops
(requiring them returns a table; nothing is added/loaded). To re-enable one,
convert it to `vim.pack.add{…}` + setup like the others.

### Cleanup
- [x] Remove lazy bootstrap; keep snippets loader + db_secrets
- [x] luajit syntax-check every file (all compile)
- [ ] Runtime test checklist (user) — see below

## STATUS: conversion complete, pending first-launch verification

Every file compiles (`luajit` parse check). What I could **not** verify here:
runtime behaviour, because this sandbox can't access `~/.local/share/nvim`, so
Neovim can't actually install plugins. **The first launch must happen on your
machine.**

### First launch
`vim.pack` installs all plugins **synchronously on first start**, so the first
`nvim` will be slow and may look frozen — let it finish. Build hooks then fire:
treesitter parser compilation, LuaSnip `make`, fff binary download, pipeline
`make`, and `npm install -g` for mcphub + likec4. (These are the same builds
lazy ran via `build=`.)

```sh
# from a normal shell, in a scratch dir:
nvim
# watch :messages and the vim.pack window; then run:
:checkhealth
```

### Things to verify (the shortcuts that must still work)
- Picker: `<leader>sf` `<leader>sg` `<leader><leader>` (snacks)
- LSP nav: `grr` `gri` `grd` `gd` `gO` `gW` `grt`; `grn` `gra` `grD` `<leader>th` `<leader>tl`
- .NET: open a `.cs` file → roslyn attaches, codelens; `<leader>tt` test runner,
  `<leader>mb` build, `<leader>ms` secrets; F5 debug
- Completion: copilot ghost text + menu, `<CR>` accept; sql/csproj sources
- Git: `<leader>gg` neogit; `<leader>hs/hp/hb`, `<leader>gn/gp`
- AI: `<C-,>` sidekick, `<Tab>` NES, `<leader>aa`/`ac`/`af`
- Misc: `<leader>e` oil, `<leader>ff` fff, `<leader>xx` trouble, `<leader>ci` pipeline,
  obsidian `<leader>n*`, kulala `<leader>R*`, `<leader>f` format, folding, theme follows OS
- `:Lazy` should no longer exist; `:checkhealth vim.pack` shows installed plugins

### Fixes applied during testing
- **init.lua:492 `MasonToolsInstall` aborted init** (`E492: Not an editor
  command`). mason-tool-installer registers that command on `VimEnter`, which is
  *after* the eagerly-loaded LSP section. Because init aborted there, Sections
  6–9 never ran — that's why the custom plugins showed as installed-but-"not
  active" in `:checkhealth vim.pack`. Fixed by deferring the trigger to a
  `VimEnter` autocmd wrapped in `pcall`.
- **Custom loader hardened**: each `custom/plugins/*.lua` is now `require`d under
  `pcall`, so one broken plugin reports itself (notify) instead of aborting the
  rest.

## Treesitter main-branch migration

Section 8 now targets the `main` branch (full rewrite, no module system):
- Parsers: `require('nvim-treesitter').install{...}` + auto-install on FileType.
- Highlight/fold/indent: enabled per-buffer via `vim.treesitter.start` in a
  FileType autocmd (replaces `configs.setup{ highlight/indent }` and the old
  `has_parser` folding autocmd).
- Textobjects: rewritten to the `nvim-treesitter-textobjects` `main` API —
  `setup{ select, move }` + explicit keymaps via
  `require('nvim-treesitter-textobjects.select').select_textobject(...)` and
  `.move.goto_*(...)`. All `af/if/ac/ic/as` and `]m/[m/]]/[[/]M/[M/][/[]/]o/]s/]z`
  maps preserved.

**Behaviour changes (unavoidable on `main`):**
- `lsp_interop` / `peek_definition_code` was **removed** upstream → `<leader>df`
  / `<leader>dF` are gone. (Can be re-implemented manually if needed.)
- `incremental_selection` module removed → now Neovim 0.12's **built-in**
  `an`/`in`/`]n`/`[n`. To free `an`/`in`, **mini.ai**'s `around_next`/
  `inside_next` were remapped to `aa`/`ii` (Section 3). Old `gnn`/`grc`/`grm`
  incsel maps are gone.
- `matchup` treesitter module dropped (vim-matchup is disabled anyway; `%`
  falls back to built-in matchit).

**One-time switch step:** `vim.pack.add{ version='main' }` does NOT move an
already-installed plugin off `master` (`:h vim.pack.add`). Section 8's main-API
calls are wrapped in `pcall`; if treesitter is still on master they no-op with a
notification. To actually switch: `:lua vim.pack.update()` → review → `:write`
to confirm → restart. Parsers recompile once on the main branch.

## Lazy-loading (vim.pack)

Startup was ~3.6 s because everything loaded eagerly. Added a small lazy-loader,
`lua/custom/lazy.lua`, that registers a plugin to install + configure on first
use instead of at startup. `vim.pack` has no native lazy-loading; the helper
wraps `vim.pack.add` behind FileType / command / keymap / event triggers
(`cmd`/`keys` stubs are removed on first fire and the action replayed; `ft`
re-fires FileType so the plugin attaches to the triggering buffer).

Deferred plugins and their triggers:

| Plugin | Trigger | ~saved |
|---|---|---:|
| pipeline | `:Pipeline` / `<leader>ci` | 660 ms |
| neogit | `:Neogit` / `<leader>gg` | 380 ms |
| kulala | `ft=http,rest` | 290 ms |
| debug (dap/dapui/mason-nvim-dap) | `<F5>` / `<leader>b` | 195 ms |
| octo | `:Octo` | 130 ms |
| obsidian | `:Obsidian` / `ft=markdown` (keymaps eager) | 80 ms |
| easy-dotnet | `ft=cs,fs,fsproj,csproj,sln,slnx` | 70 ms |
| multicursors | `MC*` cmds / `<Leader>,` | 30 ms |
| mcphub | `:MCPHub` | 17 ms |
| render-markdown | `ft=markdown` | 8 ms |
| typst-preview | `ft=typst` | 6 ms |
| trouble | `:Trouble` (+ `<leader>x*`/`cs`/`cl`) | 5 ms |
| zen-mode | `:ZenMode` | 3 ms |

Kept **eager** (startup-critical or cheap): snacks, blink, LSP/mason,
treesitter, gitsigns, which-key, mini, todo-comments, guess-indent, themes/
nightfox, conform, lazydev, luasnip, copilot (sidekick NES dep — left eager),
nvim-surround, nvim-origami, autopairs, fff, swift, jj, codediff, and **oil**
(must be eager — it hijacks directory buffers; lazy-loading it breaks
`nvim <dir>`).

netrw is left enabled as a lightweight fallback; oil hijacks directory buffers
as the primary file explorer.

Result (measured): total startup **3.6 s → ~0.83 s** (`first screen update`
827 ms → ~0 ms), a ~4.3× improvement. Remaining eager costs of note: gitsigns
plugin (~120 ms), copilot (~64 ms, kept eager for sidekick NES),
vim._core.defaults (~62 ms, core).

### Rollback
`git checkout main` restores the lazy.nvim config (lazy's plugin dir is
untouched; vim.pack installs to a separate `site/pack/core/opt`).
