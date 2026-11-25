#!/usr/bin/env python3
"""Read-only comparison of repository directories and installed copies."""
import argparse
import sys
from pathlib import Path

from configure import ROOT, DIRS, FILES


def compare_file(source: Path, destination: Path, relative: Path,
                 verbose: bool = False) -> bool:
    if not source.exists() and not source.is_symlink():
        if verbose:
            print(f"  [MISSING SOURCE] {relative}")
        return True

    if not destination.exists() and not destination.is_symlink():
        if verbose:
            print(f"  [MISSING] {relative}")
        return True

    if source.is_symlink() or destination.is_symlink():
        if not (source.is_symlink() and destination.is_symlink()):
            if verbose:
                print(f"  [TYPE MISMATCH] {relative}")
            return True

        if source.readlink() != destination.readlink():
            if verbose:
                print(f"  [CHANGED] {relative}")
            return True

        return False

    if source.is_file() != destination.is_file():
        if verbose:
            print(f"  [TYPE MISMATCH] {relative}")
        return True

    if not source.is_file():
        if verbose:
            print(f"  [TYPE MISMATCH] {relative}")
        return True

    if source.read_bytes() != destination.read_bytes():
        if verbose:
            print(f"  [CHANGED] {relative}")
        return True

    return False


def compare_dir(source: Path, destination: Path, relative: Path,
                verbose: bool = False) -> bool:
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

        if src.is_symlink() or dst.is_symlink():
            if not (src.is_symlink() and dst.is_symlink()):
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
            if compare_dir(src, dst, rel, verbose):
                changed = True
            continue

        if src.is_file() and src.read_bytes() != dst.read_bytes():
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
        help="show detailed file-level differences",
    )
    args = parser.parse_args()

    differences = 0

    for source, destination in DIRS.items():
        src = ROOT / source
        dst = Path(destination).expanduser()

        changed = compare_dir(src, dst, Path(source), args.verbose)

        if changed:
            differences += 1
            if not args.verbose:
                print(f"[CHANGED] {source}/ -> {dst}")
            else:
                print(f"[CHANGED DIR] {source}/ -> {dst}")
        elif args.verbose:
            print(f"[OK] {source}/")

    for source, destination in FILES.items():
        src = ROOT / source
        dst = Path(destination).expanduser()

        changed = compare_file(src, dst, Path(source), args.verbose)

        if changed:
            differences += 1
            if not args.verbose:
                print(f"[CHANGED] {source} -> {dst}")
            else:
                print(f"[CHANGED FILE] {source} -> {dst}")
        elif args.verbose:
            print(f"[OK] {source}")

    if args.verbose:
        print(f"\n{differences} mapping(s) with differences.")

    return 1 if differences else 0


if __name__ == "__main__":
    sys.exit(main())
