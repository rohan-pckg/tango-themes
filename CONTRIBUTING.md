# Contributing to Tango Neovim

Thanks for helping out. This is a color scheme, so the bar for changes is
narrow and strict.

## The one rule that matters

> **Do not change the palette.**

The Tango hex values are intentional. Bug reports about contrast, taste or
"this green feels wrong" are not actionable — the palette comes from the Tango
Desktop Project and the Emacs *tangotango* theme, and matching it across three
editors is the whole point of the repository.

Every issue that *looks* like a color problem is almost always an
implementation problem: a missing highlight group, a group that still resolves
to a default, a typo in a scope name, or a broken variable reference. Fix those
using the palette that already exists.

## What is welcome

- **Missing highlight groups / scopes.** If something renders in default
  Neovim or Sublime colors, that is a real bug. Add the group using an existing
  palette value and explain which entry you picked.
- **Broken or invalid syntax.** Dead links, undefined `var()` references,
  invalid scopes, deprecated keys.
- **New plugin coverage**, but only for plugins that are actually in use — this
  repository does not theme plugins nobody runs.
- **Documentation fixes**, including screenshots.

## What is not welcome

- New colors. If you genuinely need a color that does not exist, open an issue
  first and make the case; a maintainer has to agree before it lands.
- Redesigns, alternative variants, or a light version.
- Reformatting-only changes to the large `.sublime-theme` files — the diff
  becomes unreviewable.

## Local checks

```sh
# Palette integrity — must report added: 0, removed: 0
python3 scripts/check-colors.py --diff <old-copy> <new-copy>

# Neovim: must load with no errors
nvim --headless -u /dev/null \
  --cmd "set rtp+=colors/.." \
  -c 'colorscheme tango' -c 'qa!'

# Sublime Text / Merge JSON validity
python3 -c "import json;json.load(open('sublime-text/Tango Neovim.sublime-color-scheme'))"
```

CI runs all of the above on every pull request.

## Style

- **Neovim:** keep the centralized `local c = { ... }` palette table, keep
  groups in the existing numbered sections, and keep comments pointing at the
  Emacs face they came from.
- **Sublime:** keep the `"variables"` object, and keep rules in the existing
  thematic order (comments → constants → strings → keywords → …).
- Two-space indent in Lua and JSON, matching the files already present.

## Commits and releases

- Conventional-commit style helps (`fix(neovim): …`, `docs: …`), but is not
  enforced.
- Releases are tagged with semantic versions (`v1.0.0`). The changelog is
  maintained by hand in [`CHANGELOG.md`](CHANGELOG.md).

## License

By contributing you agree that your contributions are licensed under the
repository's [MIT license](LICENSE).
