# Dotfiles installer

```
                                         _       _    __ _ _
                                      __| | ___ | |_ / _(_) | ___  ___
                                     / _` |/ _ \| __| |_| | |/ _ \/ __|
                                    | (_| | (_) | |_|  _| | |  __/\__ \
                                     \__,_|\___/ \__|_| |_|_|\___||___/

```

A small, copy-based dotfiles installer. `configure.py` selects a package manager
and generates a machine-specific `install.sh`.

The generated installer contains only that package manager's package command and
the configured directory copies.


## Configure and install

```sh
./configure.py                # detect package manager and generate install.sh
./configure.py --verbose      # show selected packages and directory mappings
./configure.py --manager xbps # override detection
./install.sh --dry-run        # preview commands
./install.sh                  # install packages and copy files
./install.sh --verbose        # show copy/package commands
```

`install.sh` is generated and ignored by Git. Regenerate it after editing
`pkgs.toml` or the `DIRS` mapping in `configure.py`.

## Packages

Edit `pkgs.toml`. Packages in `[common]` are installed on all supported
managers. The selected manager's section adds packages to the common list.
Supported managers: `pacman`, `xbps`, `apt`, `dnf`, `apk`, `zypper`.


## Directory mappings

Edit `DIRS` in `configure.py`. Defaults:

- `bin/` -> `~/.local/bin/`
- `config/` -> `~/.config/`
- `wallpapers/` -> `~/Pictures/wallpapers/`
- `scripts/` -> `~/.local/share/dotfiles/scripts/`

Files are copied using `cp -a`; there are no symlinks. Existing destination
files are updated, and unrelated destination files are left untouched.
