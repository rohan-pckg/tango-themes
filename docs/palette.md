# The Tango palette

This file is the single source of truth for the palette. Every implementation
in this repository must use these exact values.

## Origin

Julien Barnier's Emacs *tangotango* theme (`tangotango-theme.el`), itself
derived from `color-theme-tango.el`, which in turn comes from the Tango Desktop
Project. X11 named colors used by the Emacs file are resolved to their standard
hex equivalents and marked below.

The Neovim implementation was written **directly from the Emacs `.el` file** —
it is not a port of any existing Vim/Neovim Tango plugin.

The one deliberate deviation: the Emacs source uses `#2e3434` for the default
background. This repository uses `#1e1e1e` instead, and derives the surrounding
grays from it. Everything else is verbatim.

## Core tones

| Role | Hex | Emacs face |
|---|---|---|
| Background | `#1e1e1e` | `default` background (Emacs: `#2e3434`) |
| Float / popup background | `#171717` | `org-block-background` |
| Mode-line background | `#141414` | `mode-line` background |
| Cursor line | `#282828` | derived |
| Selection | `#483D8B` | `region` (X11 "dark slate blue") |
| Foreground | `#eeeeec` | `default` foreground |
| Mode-line foreground | `#bbbbbc` | `mode-line` |
| Comment / context | `#888a85` | `font-lock-comment-face` |
| Mode-line-inactive background | `#5f625d` | `mode-line-inactive` |
| Border / delimiter | `#babdb6` | Tango aluminium |

## Accents

| Role | Hex | Emacs face |
|---|---|---|
| Function | `#edd400` | `font-lock-function-name-face` |
| Cursor | `#fce94f` | `cursor` background |
| Warning | `#f57900` | `font-lock-warning-face` |
| Search (lazy / match) background | `#e9b96e` | `lazy-highlight`, `match` |
| Constant / type | `#8ae234` | `font-lock-constant-face`, `font-lock-type-face` |
| Show-paren-match background | `#73d216` | `show-paren-match` |
| Keyword / builtin | `#729fcf` | `font-lock-keyword-face`, `font-lock-builtin-face` |
| Selection highlight | `#3465a4` | Tango sky-blue dark |
| Deepest sky blue | `#204a87` | Tango sky-blue darkest |
| Link | `#1E90FF` | `link` (X11 "dodger blue") |
| String | `#ad7fa8` | `font-lock-string-face` |
| Paren-mismatch background | `#ad7fa8` | `show-paren-mismatch` |
| Error / terminal red | `#ef2929` | `term-color-red` |
| Variable | `#FF6347` | `font-lock-variable-name-face` (X11 "tomato") |
| Search / match foreground | `#2e3436` | `isearch`, `match`, `show-paren-*` |

## Supporting tones

| Role | Hex | Source |
|---|---|---|
| Terminal green | `#6ac214` | `term-color-green` |
| Terminal cyan | `#34e2e2` | Tango light sky-blue |
| Terminal bright cyan | `#8cc4ff` | derived |
| Terminal magenta | `#CD00CD` | X11 "magenta3" |
| Terminal bright white | `#ffffff` | derived |
| Statusline background (Lualine) | `#242424` | Lualine config, not a Tango accent |

## Declared but currently unused

These are part of the source palette and are kept for completeness, but no
highlight group or Sublime rule references them:

- `#204a87` — Tango sky-blue darkest (`blue_darker`)
- `#8B4513` — X11 "saddle brown" (`brown`)
- `#FFD700` — X11 "gold"
- `#FF7F50` — X11 "coral"

## Terminal palette

| Index | Hex | Name |
|---|---|---|
| 0 | `#141414` | black |
| 1 | `#ef2929` | red |
| 2 | `#6ac214` | green |
| 3 | `#edd400` | yellow |
| 4 | `#1E90FF` | blue |
| 5 | `#ad7fa8` | magenta |
| 6 | `#34e2e2` | cyan |
| 7 | `#eeeeec` | white |
| 8 | `#5f625d` | bright black |
| 9 | `#FF6347` | bright red |
| 10 | `#8ae234` | bright green |
| 11 | `#fce94f` | bright yellow |
| 12 | `#729fcf` | bright blue |
| 13 | `#CD00CD` | bright magenta |
| 14 | `#8cc4ff` | bright cyan |
| 15 | `#ffffff` | bright white |

## Emacs → Neovim mapping notes

- **Bold** follows the Emacs faces: functions, keywords, types, declarations.
- **Italic** follows the Emacs faces: strings, documentation comments, inlay
  hints.
- Treesitter variables stay on the foreground color. Only special roles
  (`@variable.parameter`, `@variable.member`, `@variable.builtin`) take color,
  which keeps the restrained feel of the Emacs original.
- `@constructor` shares the "callable" yellow with `@function` rather than
  piling onto `@type`'s green.
- `@tag.attribute` is orange rather than green, so markup does not read as
  all-green next to `@tag`'s blue.
- Emacs-only faces with no Neovim equivalent (Gnus mail faces, org-mode
  heading heights, widget and minibuffer styling, `header-line` boxes) were not
  ported one-to-one; only their hue roles were carried over.

## Where non-palette values still appear

A small number of stock Sublime values were deliberately left untouched in the
Sublime Merge theme, because the repository's own rules already override the
affected elements:

- `"black"` and `"white` literals in `Merge Base.sublime-theme`
  (`tab_close_button` tints) — overridden by `Merge.sublime-theme`.
- `[64, 64, 177, 10]` as `line_selection_color` in `Merge Base.sublime-theme` —
  overridden by `rgba(72,61,139,0.85)` in `Merge.sublime-theme`.
- The 17-color `kelly_colors` blame palette in `Merge.sublime-theme`, which
  only applies when the `kelly_colors` setting is turned on.

Changing these is not a color change *today*, but it is a latent trap. If you
touch them, remove the override that protects them first.
