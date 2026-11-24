# dotfiles

Configuration and setup scripts for my macOS development environment on Apple Silicon.

## Features

- Applications, command-line tools and fonts declared in a single [Brewfile](Brewfile), including Mac App Store apps through `mas`.
- zsh with the [Starship](https://starship.rs) prompt and the [Ghostty](https://ghostty.org) terminal.
- Python managed only by [uv](https://docs.astral.sh/uv/), with `ruff` and `ty` installed as global tools.
- Git defaults, aliases and a global ignore file, with the GitHub CLI as credential helper.
- Configuration files symlinked from `home/`, so every change is tracked in Git.
- Idempotent `make` targets for installing, updating and checking the machine.
- Shell scripts linted with ShellCheck and shfmt, and scanned for secrets with Gitleaks, in CI.

## Requirements

- macOS on Apple Silicon.
- An Apple Account signed in to the App Store, for the apps installed with `mas`.

## Installation

On a new Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/dotnetpy/dotfiles/main/install.sh | bash
```

The script installs the Xcode Command Line Tools and Homebrew, clones this repository to `~/dotfiles` and runs `make install`. If the Command Line Tools are not installed yet, run it again once their installation finishes.

To install from an existing clone:

```bash
git clone https://github.com/dotnetpy/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

## Usage

| Command | Description |
| --- | --- |
| `make install` | Install packages, Python, uv tools and Git hooks, link the configuration and apply macOS preferences |
| `make update` | Upgrade Homebrew packages and uv tools |
| `make link` | Symlink `home/` into `$HOME`, backing up any existing files |
| `make doctor` | Check that every package is installed and every link is in place |
| `make capture` | Report packages and applications installed on this Mac but not declared here |
| `make lint` | Run ShellCheck and shfmt |

Run `make` without arguments to list every target.

## Layout

```
.
├── Brewfile           Homebrew, cask and Mac App Store packages
├── Makefile
├── install.sh         Bootstrap script for a new Mac
├── uv-tools.txt       Global Python tools installed with uv
├── home/              Mirrors $HOME; every file is symlinked to the same path
│   ├── .gitconfig
│   ├── .zprofile
│   ├── .zshrc
│   └── .config/
│       ├── ghostty/config
│       ├── git/ignore
│       ├── starship.toml
│       └── uv/uv.toml
└── scripts/
    ├── capture.sh
    ├── link.sh
    └── macos.sh
```

## After installation

Some steps involve credentials and are done by hand:

1. Sign in to GitHub with `gh auth login`.
2. Create an SSH key for this machine and add it with `gh ssh-key add`.
3. Turn on Settings Sync in VS Code to restore settings and extensions.
4. Sign in to Claude Code by running `claude`, and to the remaining applications.
5. Put secrets and machine-specific settings in `~/.zshrc.local`, which is not tracked.

## Python

Python is installed and run only through uv: `uv.toml` sets `python-preference = "only-managed"`. Command-line tools that are useful everywhere are installed globally with `uv tool install` and listed in `uv-tools.txt`. Libraries are always project dependencies:

```bash
pynew my-api            # uv init my-api && uv add --dev ruff ty pytest
uv add fastapi pydantic
uv run pytest
```

## License

This project is licensed under the terms of the [MIT license](LICENSE).
