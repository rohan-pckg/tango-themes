# Changelog

All notable changes to the Tango Neovim theme collection are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
the project uses [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-10-08

First release: the three themes, collected into a single repository with shared
documentation and validation tooling.

### Added

- `colors/tango.lua` — the Neovim colorscheme, packaged at the repository root
  so plugin managers install it without extra configuration.
- `sublime-text/Tango Neovim.sublime-color-scheme` — the Sublime Text color
  scheme (280 rules). Works with the stock `Adaptive.sublime-theme` UI via the
  `--background` / `--foreground` / `--panel` variable contract.
- `sublime-merge/Theme - Merge/` — the Sublime Merge UI theme, plus the Merge
  color scheme and widget color schemes.
- `sublime-merge/user-settings/` — the Preferences, Diff, File Mode, Git Output
  and Commit Message settings files that point Merge's views at the color
  scheme.
- `docs/palette.md` — the canonical palette and the Emacs → Neovim face map.
- `scripts/check-colors.py` — palette integrity checker, wired into CI.
- GitHub issue templates and a validation workflow.

### Fixed (Neovim)

- Removed two dead self-links, `link("@comment", "@comment")` and
  `link("@string", "@string")`, that left both groups with an unresolved link
  target. Harmless in practice because the following `hl()` call overwrote
  them, but they were misleading.
- Added `vim.o.termguicolors = true`. The palette is entirely 24-bit hex, so
  without it every color was silently ignored and the scheme fell back to the
  terminal's colors.
- Added highlight groups that previously fell through to Neovim's defaults:
  `NormalNC`, `TermCursor`, `TermCursorNC`, `StatusLineTerm`,
  `StatusLineTermNC`, `Conceal`, `QuickFixLine`, `MsgArea`, `CmpGhostText` and
  `SnippetTabstop`. All use existing palette values.
- Documented the four palette entries that the scheme does not currently use
  (`blue_darker`, `brown`, `gold`, `coral`) rather than silently dropping them.

### Fixed (Sublime Text)

- `shadow_width` and `selection_border_width` were strings (`"8"`, `"0"`) where
  Sublime expects numbers. Restored to integers; no visual change.

### Repository

- Removed backup artifacts (`*.bak`, `*.bak-20260923-*`) from the shipped files.
- Documented that Package Control is Sublime Text-only, and what a separate
  Package-Control-ready repository would need
  ([`docs/package-control.md`](docs/package-control.md)).

### Color integrity

Verified unchanged across this release: 81 unique color values before and
after, with 0 added, 0 removed and 0 changed.
