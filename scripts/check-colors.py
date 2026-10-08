#!/usr/bin/env python3
"""Color integrity checker for the Tango theme repository.

Usage:
    check-colors.py <path>            scan a theme tree and print its color inventory
    check-colors.py --diff A B       compare two inventories

Exit code is non-zero when colors were added or removed between two inventories,
which is what the CI workflow and release checklist use to guarantee the palette
never drifts.
"""
import os
import re
import sys

# Directories that hold documentation, tooling and metadata rather than theme
# sources. Their contents are ignored by the inventory.
SKIP_DIRS = {
    ".git",
    ".github",
    "docs",
    "scripts",
    "__pycache__",
    "node_modules",
}

# Only files that a Sublime product or Neovim can actually load as a theme.
THEME_SUFFIXES = (".sublime-color-scheme", ".sublime-theme", ".sublime-settings",
                  ".hidden-color-scheme", ".lua")

HEX_RE = re.compile(r"#[0-9a-fA-F]{3,8}\b")
RGB_RE = re.compile(r"\b(?:rgba?|hsla?)\([^)\n]*\)", re.I)


def inventory(root):
    """Return {relative_path: sorted list of color literals}."""
    found = {}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in sorted(filenames):
            if not name.endswith(THEME_SUFFIXES):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            try:
                text = open(path, encoding="utf-8").read()
            except (OSError, UnicodeDecodeError):
                continue
            colors = set()
            for match in HEX_RE.findall(text):
                colors.add(match.lower())
            for match in RGB_RE.findall(text):
                colors.add(" ".join(match.split()).lower())
            if colors:
                found[rel] = sorted(colors)
    return found


def flatten(inv):
    out = set()
    for colors in inv.values():
        out |= set(colors)
    return out


def render(inv):
    lines = []
    for path in sorted(inv):
        lines.append(f"{path}:")
        for color in inv[path]:
            lines.append(f"  {color}")
    lines.append(f"unique colors: {len(flatten(inv))}")
    return "\n".join(lines)


def main(argv):
    if len(argv) == 4 and argv[1] == "--diff":
        a, b = inventory(argv[2]), inventory(argv[3])
        flat_a, flat_b = flatten(a), flatten(b)
        added = sorted(flat_b - flat_a)
        removed = sorted(flat_a - flat_b)
        print(f"files scanned: {len(a)} -> {len(b)}")
        print(f"colors before : {len(flat_a)}")
        print(f"colors after  : {len(flat_b)}")
        print(f"added         : {len(added)}")
        print(f"removed       : {len(removed)}")
        if added:
            print("  ADDED:   " + " ".join(added))
        if removed:
            print("  REMOVED: " + " ".join(removed))
        for path in sorted(set(a) | set(b)):
            old, new = set(a.get(path, [])), set(b.get(path, []))
            if old != new:
                gained = sorted(new - old)
                lost = sorted(old - new)
                print(f"CHANGED {path}")
                if gained:
                    print(f"  + {', '.join(gained)}")
                if lost:
                    print(f"  - {', '.join(lost)}")
        return 1 if (added or removed) else 0

    root = argv[1] if len(argv) > 1 else "."
    inv = inventory(root)
    print(render(inv))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
