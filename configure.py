#!/usr/bin/env python3
"""Generate a minimal machine-specific install.sh for this dotfiles repository."""
from __future__ import annotations

import argparse
import os
import shlex
import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PKG_FILE = ROOT / "pkgs.toml"
OUTPUT = ROOT / "install.sh"

# Directory mappings: recursively copy their contents.
DIRS = {
    "bin": "~/.local/bin",
    "config": "~/.config",
    "walls": "~/.local/share/wallpapers",
    "scripts": "~/.local/bin/scripts",
}

# File mappings: copy only explicitly selected files.
FILES = {
    "home/.bashrc": "~/.bashrc",
    "home/.bash_profile": "~/.bash_profile",
    "home/.profile": "~/.profile",
}

MANAGERS = {
    "arch": "pacman", "cachyos": "pacman", "manjaro": "pacman",
    "endeavouros": "pacman", "void": "xbps", "debian": "apt",
    "ubuntu": "apt", "linuxmint": "apt", "fedora": "dnf",
    "alpine": "apk", "opensuse": "zypper", "opensuse-leap": "zypper",
    "opensuse-tumbleweed": "zypper", "suse": "zypper",
}


def detect_manager() -> str | None:
    try:
        data = {}
        for line in Path("/etc/os-release").read_text().splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                data[key] = value.strip().strip('"')
    except OSError:
        return None

    for name in [data.get("ID", ""), *data.get("ID_LIKE", "").split()]:
        manager = MANAGERS.get(name.lower())
        if manager:
            return manager

    return None


def read_packages(manager: str) -> list[str]:
    try:
        config = tomllib.loads(PKG_FILE.read_text())
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise SystemExit(f"configure: cannot read {PKG_FILE.name}: {exc}")

    common = config.get("common", {}).get("packages", [])
    specific = config.get(manager, {}).get("packages", [])
    packages = common + specific

    if not all(isinstance(pkg, str) and pkg.strip() for pkg in packages):
        raise SystemExit("configure: package entries must be non-empty strings")

    return list(dict.fromkeys(packages))


def package_commands(manager: str, packages: list[str]) -> list[list[str]]:
    if not packages:
        return []

    commands = {
        "pacman": [["sudo", "pacman", "-S", "--needed", "--noconfirm", *packages]],
        "xbps": [["sudo", "xbps-install", "-Sy", *packages]],
        "apt": [
            ["sudo", "apt-get", "update"],
            ["sudo", "apt-get", "install", "-y", *packages],
        ],
        "dnf": [["sudo", "dnf", "install", "-y", *packages]],
        "apk": [["sudo", "apk", "add", *packages]],
        "zypper": [["sudo", "zypper", "install", "-y", *packages]],
    }

    return commands[manager]


def expand_destination(destination: str) -> str:
    return destination.replace("~", "$HOME", 1) if destination.startswith("~") else destination


def generate(manager: str, packages: list[str], verbose: bool = False) -> str:
    repo = shlex.quote(str(ROOT))

    pkg_cmds = package_commands(manager, packages)
    pkg_lines = [
        "run " + " ".join(shlex.quote(arg) for arg in command)
        for command in pkg_cmds
    ]

    copy_lines = []

    # Directory mappings.
    for source, destination in DIRS.items():
        src = f"$REPO/{source}"
        dst = expand_destination(destination)

        copy_lines.extend([
            f'if [[ -d "{src}" ]]; then',
            f'    run mkdir -p "{dst}"',
            f'    run cp -a "{src}/." "{dst}/"',
            'else',
            f'    log "Skipping missing source directory: {src}"',
            'fi',
        ])

    # Individual file mappings.
    for source, destination in FILES.items():
        src = f"$REPO/{source}"
        dst = expand_destination(destination)
        parent = os.path.dirname(dst) or "."

        copy_lines.extend([
            f'if [[ -f "{src}" ]]; then',
            f'    run mkdir -p "{parent}"',
            f'    run cp -a "{src}" "{dst}"',
            'else',
            f'    printf "Error: missing source file: %s\\n" "{src}" >&2',
            '    exit 1',
            'fi',
        ])

    return f'''#!/usr/bin/env bash
set -euo pipefail

REPO={repo}
VERBOSE=0
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        -v|--verbose) VERBOSE=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            printf 'Usage: %s [--verbose] [--dry-run]\\n' "$0"
            exit 0
            ;;
        *) printf 'Unknown option: %s\\n' "$arg" >&2; exit 2 ;;
    esac
done

log() {{ [[ "$VERBOSE" -eq 1 ]] && printf '%s\\n' "$*"; }}

run() {{
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf '[dry-run] %s\\n' "$*"
    elif [[ "$VERBOSE" -eq 1 ]]; then
        printf '$ %s\\n' "$*"
        "$@"
    else
        "$@"
    fi
}}

printf 'Installing packages...\\n'
if [[ {str(bool(packages)).lower()} == true ]]; then
{os.linesep.join(pkg_lines)}
else
    log 'No packages selected.'
fi

printf 'Installing dotfiles...\\n'
{os.linesep.join(copy_lines)}

printf 'Done.\\n'
'''


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Configure and generate a minimal dotfiles installer"
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="show configuration details",
    )
    parser.add_argument(
        "--manager",
        choices=sorted(set(MANAGERS.values())),
        help="override detected package manager",
    )

    args = parser.parse_args()
    manager = args.manager or detect_manager()

    if not manager:
        parser.error("could not detect supported package manager; use --manager")

    packages = read_packages(manager)
    script = generate(manager, packages)

    OUTPUT.write_text(script)
    OUTPUT.chmod(0o755)

    print(f"Configured for {manager}; generated install.sh.")

    if args.verbose:
        print(f"Packages ({len(packages)}): {' '.join(packages) if packages else '(none)'}")

        print("Directory mappings:")
        for src, dst in DIRS.items():
            print(f"  {src}/ -> {dst}")

        print("File mappings:")
        for src, dst in FILES.items():
            print(f"  {src} -> {dst}")

        print(f"Generated: {OUTPUT}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
