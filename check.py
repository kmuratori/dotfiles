#!/usr/bin/env python3
"""Read-only comparison of repository directories and installed copies."""
import argparse
import sys
from pathlib import Path

from configure import ROOT, DIRS


def compare(source: Path, destination: Path, relative: Path,
            verbose: bool = False) -> bool:
    """Compare directory contents recursively."""
    if not source.exists() or not source.is_dir():
        if verbose:
            print(f"  [MISSING SOURCE] {relative}")
        return True

    if not destination.exists() or not destination.is_dir():
        if verbose:
            print(f"  [MISSING] {relative}")
        return True

    changed = False

    source_entries = {p.name: p for p in source.iterdir()}
    destination_entries = {p.name: p for p in destination.iterdir()}

    for name in sorted(source_entries.keys() | destination_entries.keys()):
        src = source_entries.get(name)
        dst = destination_entries.get(name)
        rel = relative / name

        if src is None:
            changed = True
            if verbose:
                print(f"  [EXTRA] {rel}")
            continue

        if dst is None:
            changed = True
            if verbose:
                print(f"  [MISSING] {rel}")
            continue

        src_link = src.is_symlink()
        dst_link = dst.is_symlink()

        if src_link or dst_link:
            if not (src_link and dst_link):
                changed = True
                if verbose:
                    print(f"  [TYPE MISMATCH] {rel}")
            elif src.readlink() != dst.readlink():
                changed = True
                if verbose:
                    print(f"  [CHANGED] {rel}")
            continue

        if src.is_dir() != dst.is_dir():
            changed = True
            if verbose:
                print(f"  [TYPE MISMATCH] {rel}")
            continue

        if src.is_dir():
            if compare(src, dst, rel, verbose):
                changed = True
            continue

        if src.is_file():
            if src.read_bytes() != dst.read_bytes():
                changed = True
                if verbose:
                    print(f"  [CHANGED] {rel}")

    return changed


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Check installed dotfiles without modifying them."
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="show detailed file-level differences"
    )
    args = parser.parse_args()

    differences = 0

    for source, destination in DIRS.items():
        src = ROOT / source
        dst = Path(destination).expanduser()

        changed = compare(src, dst, Path(source), args.verbose)

        if changed:
            differences += 1
            if not args.verbose:
                print(f"[CHANGED] {source}/ -> {dst}")
            else:
                print(f"[CHANGED DIR] {source}/ -> {dst}")
        elif args.verbose:
            print(f"[OK] {source}/")

    if args.verbose:
        print(f"\n{differences} director{'y' if differences == 1 else 'ies'} "
              f"with differences.")

    return 1 if differences else 0


if __name__ == "__main__":
    sys.exit(main())
