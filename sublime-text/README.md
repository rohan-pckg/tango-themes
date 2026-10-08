# Sublime Text theme

One file. That is the whole theme.

```text
Tango Neovim.sublime-color-scheme
```

Copy it into Sublime Text's `Packages/User/` folder, then pick it from
**Preferences → Color Scheme… → Tango Neovim**.

## Why there is no `.sublime-theme`

The stock `Adaptive.sublime-theme` already draws the tabs, sidebar and panels.
Sublime Text 4 lets a color scheme publish CSS variables that the UI theme
consumes, so this scheme declares:

```json
"--background": "var(bg)",
"--foreground": "var(fg)",
"--panel":     "var(bg_dark)",
"--muted":     "var(grey)",
"--link":      "var(blue_named)",
"--error":     "var(red)",
"--warning":   "var(orange)",
"--success":   "var(green)",
"--border":    "var(grey)"
```

`Adaptive` reads those directly, which is why the UI matches the code without a
single UI-theme rule. Keeping the color scheme and the UI theme separate is
deliberate: it means OS-level light/dark switching, other UI themes and future
Sublime UI changes all keep working.

`popup_css` is also set, so the hover popups (definition preview, LSP
tooltips, inline errors) are themed through the same variables.

## Structure of the file

| Key | Contents |
|---|---|
| `variables` | The Tango palette, plus the `--*` contract above |
| `globals` |Background, caret, gutter, selection, find highlight, rulers, indent guides, brackets, shadows |
| `rules` | 280 rules, ordered comments → constants → strings → keywords → storage → entities → variables → punctuation → markup → diff → git gutter → search → invalid → messages → SublimeLinter → LSP, then language-specific rules |

Language-specific rules cover HTML, CSS, Python, JavaScript, TypeScript, shell,
Rust and Go. Generic rules cover everything else.

## Notes

- `lualine_bg` and the unused palette entries (`blue_darker`, `cyan_light`,
  `fg_dim`, `green_dark`, `magenta`, `terminal_bright_cyan`, `white`) exist for
  parity with the other implementations. Removing them would break nothing, but
  keeping them means the three themes stay comparable — see
  [`../docs/palette.md`](../docs/palette.md).
- `font_style: ""` appears on several rules. That is a valid value and means
  "explicitly no font style"; it clears bold/italic inherited from a broader
  rule.
