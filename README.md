# Dotfiles installer

A small, copy-based dotfiles installer. `configure.py` selects a package manager
and generates a machine-specific `install.sh`.

The generated installer contains only that package manager's package command and
the configured directory and file copies.

## Configure and install

```sh
./configure.py                # detect package manager and generate install.sh
./configure.py --verbose      # show selected packages and mappings
./configure.py --manager xbps # override detection
./install.sh --dry-run        # preview commands
./install.sh                  # install packages and copy files
./install.sh --verbose        # show copy/package commands
```

`install.sh` is generated and ignored by Git. Regenerate it after editing
`pkgs.toml`, `DIRS`, or `FILES` in `configure.py`.

## Packages

Edit `pkgs.toml`. Packages in `[common]` are installed on all supported
managers. The selected manager's section adds packages to the common list.

Supported managers: `pacman`, `xbps`, `apt`, `dnf`, `apk`, `zypper`.

## Directory mappings

Edit `DIRS` in `configure.py`.

Directories are copied recursively using `cp -a`. Only explicitly mapped
directories are considered.

## File mappings

Edit `FILES` in `configure.py` to install individual files.

Example:

```python
FILES = {
    "home/.bashrc": "~/.bashrc",
    "home/.bash_profile": "~/.bash_profile",
    "home/.profile": "~/.profile",
}
```

Individual files are copied using `cp -a`. Their destination parent
directories are created automatically.

Missing mapped source files stop installation with an error.

Existing destination files are updated. Unrelated destination files
are left untouched.

## Check installed configuration

Compare repository files against their installed copies without modifying
anything.

```sh
./check.py    # show changed mappings
./check.py -v # show detailed differences
```

Detected differences:

- `[CHANGED]` - file contents or symlink target differ.
- `[MISSING]` - file or directory is absent from the installation.
- `[EXTRA]` - installed file or directory no longer exists in the repository.
- `[TYPE MISMATCH]` - file/directory/symlink types differ.
- `[CHANGED DIR]` - directory containing differences.
- `[CHANGED FILE]` - individual file mapping containing differences.
