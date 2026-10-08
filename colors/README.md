# Neovim theme

```text
../../colors/tango.lua
```

One file, no runtime dependencies, no Lua module to require. Install it as a
plugin repository (the repository root is the plugin root, so `colors/` is
already on the runtimepath) or copy the file into `~/.config/nvim/colors/`.

```lua
-- lazy.nvim
{ "rohan-pckg/tango-themes", lazy = false, priority = 1000 }
```

```vim
:colorscheme tango
```

Requires Neovim 0.9+; 0.10+ recommended for full `@lsp.*` semantic-token
coverage. Dark only. `termguicolors` is enabled by the theme itself, because
the whole palette is 24-bit hex.

## Structure of the file

| Section | Contents |
|---|---|
| 1 | Centralized palette (`local c = { … }`) — 30 entries, every color the scheme uses |
| 2 | Core UI: Normal, floats, cursor, sign/fold columns, line numbers, statusline, tabline, pmenu, search, folds, messages, spell, diagnostics, diffs |
| 3 | Classic Vim syntax, mapped from the Emacs `font-lock-*` faces |
| 4 | Treesitter `@*` groups |
| 5 | LSP semantic tokens (`@lsp.type.*`, `@lsp.mod.*`, `@lsp.typemod.*`) plus the legacy `LspReference*` / `LspInlayHint` groups |
| 6 | Plugin groups for the plugins this config actually runs |
| — | Terminal palette (`vim.g.terminal_color_0 … 15`) |

## Plugin coverage

Telescope, fzf-lua, nvim-cmp (with lspkind kinds), which-key, Neo-tree,
Gitsigns, Lazy, Mason, Trouble, todo-comments, Hop, Bufferline, mini.icons,
nvim-web-devicons, netrw.

Coverage is deliberately limited to plugins that are in use. Noice, Notify,
Dressing, blink.cmp, indent-blankline, DAP and test UIs are **not** covered —
they are not installed here, and adding groups for them would be guesswork.

## Palette entries not used by any highlight

`blue_darker`, `brown`, `gold` and `coral` are declared but unreferenced. They
come from the source palette and are kept so the three editor implementations
stay comparable. See [`../docs/palette.md`](../docs/palette.md).
