# Tango Neovim

**A single Tango palette, three editors.** One dark color scheme derived from
the Emacs *tangotango* theme, implemented natively for Neovim, Sublime Text and
Sublime Merge. Every implementation uses the exact same hex values, so a
screenshot in one editor looks like the next.

| Editor | Where it lives | Install method |
|---|---|---|
| Neovim | [`colors/tango.lua`](colors/tango.lua) | plugin manager (lazy.nvim, packer, vim-plug) or manual copy |
| Sublime Text | [`sublime-text/`](sublime-text/) | copy the `.sublime-color-scheme` into `Packages/User/` |
| Sublime Merge | [`sublime-merge/`](sublime-merge/) | copy `Theme - Merge/` into `Packages/` |

## Previews

No screenshots are included in this repository. If you would like to add one,
put it in `docs/screenshots/` and link it here — please use a real capture of
the theme in use, not a mock-up.

## Installation

### Neovim

The repository root is the plugin root, so `colors/tango.lua` is picked up
automatically. Requires Neovim 0.9+ (0.10+ recommended for full `@lsp.*`
semantic-token support). The scheme is dark-only and enables `termguicolors`
itself.

**lazy.nvim**

```lua
{
  "rohan-pckg/tango-themes",
  lazy = false,       -- colorschemes must be available at startup
  priority = 1000,    -- load before every other plugin
},
```

**packer.nvim**

```lua
use {
  "rohan-pckg/tango-themes",
  config = function() vim.cmd.colorscheme("tango") end,
}
```

**vim-plug**

```vim
Plug 'rohan-pckg/tango-themes'
colorscheme tango
```

**Manual**

```sh
git clone https://github.com/rohan-pckg/tango-themes ~/.local/share/nvim/lazy/tango-themes
```

```sh
# or just the colorscheme file, into a conventional plugin directory
mkdir -p ~/.config/nvim/colors
cp colors/tango.lua ~/.config/nvim/colors/tango.lua
```

### Sublime Text

Sublime Text only needs the color scheme — the theme drives the stock
`Adaptive.sublime-theme` UI through the `--background` / `--foreground` /
`--panel` variables, so there is intentionally no `.sublime-theme` file here.

```text
Copy sublime-text/Tango Neovim.sublime-color-scheme
  into  <Sublime Text config>/Packages/User/
```

Then select it: **Preferences → Color Scheme… → Tango Neovim**, or add this to
your `Packages/User/Preferences.sublime-settings`:

```json
{
  "color_scheme": "Tango Neovim.sublime-color-scheme"
}
```

### Sublime Merge

Sublime Merge has no package repository, so installation is a file copy. The
folder **must** be named `Theme - Merge` — that is the name of the theme
package Sublime Merge ships with, and a folder of that name overrides it while
the bundled PNG textures keep resolving from the original package.

```sh
# 1. Theme package (overrides the bundled "Theme - Merge")
cp -r "sublime-merge/Theme - Merge" "<Sublime Merge config>/Packages/"

# 2. User settings (points every Merge view at the color scheme)
cp sublime-merge/user-settings/*.sublime-settings "<Sublime Merge config>/Packages/User/"
```

Restart Sublime Merge, then **Preferences → Theme → Merge** (it is already the
default theme name, so simply confirm it is selected).

## Usage

| Editor | Activate the theme |
|---|---|
| Neovim | `:colorscheme tango` (or `vim.cmd.colorscheme("tango")`) |
| Sublime Text | **Preferences → Color Scheme… → Tango Neovim** |
| Sublime Merge | **Preferences → Theme → Merge** |

The Neovim scheme is dark-only: it sets `background=dark` and enables
`termguicolors`.

## Theme philosophy

The Tango palette predates this repository — it comes from the Tango Desktop
Project by way of Julien Barnier's Emacs *tangotango* theme, with X11 named
colors resolved to their standard hex equivalents. This repository is not a
port of any existing Vim/Neovim Tango plugin; the Neovim implementation was
written directly from the Emacs face definitions, and the Sublime
implementations were written to match it.

The rule the repository is maintained by: **same palette, same design, three
editors.** Nothing is recolored to suit a particular editor. See
[`docs/palette.md`](docs/palette.md) for the canonical palette and the
Emacs→Neovim face mapping.

## Repository layout

```text
tango-themes/
├── colors/
│   └── tango.lua                    # Neovim colorscheme (plugin root)
├── sublime-text/
│   └── Tango Neovim.sublime-color-scheme
├── sublime-merge/
│   ├── Theme - Merge/               # drop into sublime-merge's Packages/
│   │   ├── Merge.sublime-theme      #   UI rules (extends Merge Dark Base)
│   │   ├── Merge Base.sublime-theme #   recolorized base layer
│   │   ├── Merge Dark Base.sublime-theme
│   │   ├── Tango Neovim.sublime-color-scheme
│   │   └── Widget - Merge*.hidden-color-scheme
│   ├── user-settings/               # drop into sublime-merge's Packages/User/
│   └── README.md
├── docs/
│   ├── palette.md                   # canonical palette + face mapping
│   └── package-control.md           # how to publish to Package Control
├── scripts/
│   └── check-colors.py              # palette integrity checker
└── .github/                         # issue templates + CI validation
```

**User files** are everything under `colors/`, `sublime-text/`,
`sublime-merge/Theme - Merge/` and `sublime-merge/user-settings/`.
**Development files** are `docs/`, `scripts/` and `.github/`.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md). The three rules that matter most:

1. Edit the palette in one place per theme. The Neovim palette lives in the
   `local c = { ... }` table at the top of `colors/tango.lua`; the Sublime
   schemes use a `"variables"` object.
2. When you add or change a color in one theme, change it in all three.
3. Run `python3 scripts/check-colors.py --diff <old> <new>` (or just
   `python3 scripts/check-colors.py .`) before opening a pull request. The CI
   workflow does this for you and will fail on any palette drift.

## License

[MIT](LICENSE). Note that the design derives from the GPL-licensed Emacs
*tangotango* theme; the implementations here are the repository author's own.
