# Sublime Merge theme

Two parts: the UI theme and the color scheme.

```text
Theme - Merge/                        <- copy into  <Sublime Merge config>/Packages/
├── Merge.sublime-theme              <- UI rules; extends "Merge Dark Base"
├── Merge Base.sublime-theme         <- recolorized base layer (238 variables)
├── Merge Dark Base.sublime-theme    <- recolorized dark layer (222 variables)
├── Tango Neovim.sublime-color-scheme
├── Widget - Merge.hidden-color-scheme
├── Widget - Merge Dark.hidden-color-scheme
├── Widget - Merge.sublime-settings
└── Widget - Merge Dark.sublime-settings

user-settings/                        <- copy into  <Sublime Merge config>/Packages/User/
├── Preferences.sublime-settings
├── Diff - Merge.sublime-settings
├── Diff - Merge Dark.sublime-settings
├── File Mode - Merge.sublime-settings
├── File Mode - Merge Dark.sublime-settings
├── Git Output - Merge.sublime-settings
├── Git Output - Merge Dark.sublime-settings
├── Commit Message - Merge.sublime-settings
├── Commit Message - Merge Dark.sublime-settings
├── Commit Message (Read Only) - Merge.sublime-settings
└── Commit Message (Read Only) - Merge Dark.sublime-settings
```

```sh
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/sublime-merge"

cp -r "Theme - Merge" "$CONFIG/Packages/"
cp user-settings/*.sublime-settings "$CONFIG/Packages/User/"
```

Restart Sublime Merge. **Preferences → Theme → Merge**.

## The folder name is load-bearing

`Theme - Merge` is the name of the theme package Sublime Merge ships with. A
folder of that name in `Packages/` overrides it, while the PNG textures it
references (`Theme - Merge/icon_more.png`, `tab_close.png`, the scrollbars, the
loading spinners, …) still resolve from the bundled
`Theme - Merge.sublime-package`. That is why this theme ships no images.

Renaming the folder — `Tango - Merge`, for example — puts it earlier in
Sublime's package load order, so the bundled `Merge.sublime-theme` wins and
users get the stock light UI. Do not rename it.

## Why three `.sublime-theme` files

Sublime Merge themes inherit through an `extends` key:

```json
{ "extends": "Merge Dark Base.sublime-theme", "variables": { … }, "rules": [ … ] }
```

- `Merge Base.sublime-theme` is the base layer, derived from the stock
  `Merge.sublime-theme` with every variable recolored to the Tango palette
  (238 variables).
- `Merge Dark Base.sublime-theme` is the dark layer, derived from the stock
  `Merge Dark.sublime-theme` (222 variables). It overrides the light grays the
  base still carries, and adds the dark scrollbars, `dark_content` flags, blame
  colors and diff selection colors.
- `Merge.sublime-theme` is what Sublime Merge actually loads. It extends the
  dark base and holds the rules that must win: `dark_content: true`,
  `dark_scroll_*` textures, `#1e1e1e` panel tints, the blame palette and
  `line_selection_color`.

Keeping the base files separate means a future palette change is a
find-and-replace in the `variables` blocks rather than a rewrite of 1000 rules.

## Color scheme duplication

The Merge color scheme is **not** the same file as the Sublime Text one. It has
the same 39 variables and the same palette, but its globals are inlined rather
than referencing `var()`, and its `rules` block is a different, Merge-specific
scope set: 286 rules instead of 280, with unions that cover
`diff.unmerged`, `diff.conflict`, `diff.context` and `diff.selected` — scopes
Sublime Text's syntax definitions never emit but Merge's diff views do.

Do not merge the two files. See [`../docs/palette.md`](../docs/palette.md).

## Widgets

`Widget - Merge*.hidden-color-scheme` themes the text areas inside Merge's
panels (commit message, git output, file mode, diff text). The `.hidden-`
prefix keeps them out of the color scheme picker — they are referenced only by
the adjacent `Widget - Merge*.sublime-settings`.
