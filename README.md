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
- The App Management permission for your terminal (System Settings > Privacy & Security > App Management). Without it macOS blocks Homebrew from changing apps in `/Applications`, and casks such as `1password` fail with `Operation not permitted`. The install script opens this setting for you.

## Installation

On a new Mac, run this one command. Nothing else is needed first: a new Mac has no Git, and the script installs it.

```bash
curl -fsSL https://raw.githubusercontent.com/dotnetpy/dotfiles/main/install.sh | bash
```

The script:

1. Installs the Xcode Command Line Tools (which provide `git` and `make`) and waits for the installation to finish.
2. Installs Homebrew.
3. Clones this repository to `~/dotfiles` over HTTPS, so no SSH key is needed.
4. Opens the App Management setting and waits while you turn it on for your terminal.
5. Runs `make install`.

It is safe to run again. `make install` runs every step even if one fails, then reports the failure, so a single broken package does not leave the rest of the Mac unconfigured.

On a Mac that already has Git (the Command Line Tools), you can also install from a clone:

```bash
git clone https://github.com/dotnetpy/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

### Troubleshooting

- **`Operation not permitted` on an app in `/Applications`**: run `make permissions`, turn on your terminal, reopen it and run `make install` again. If the app was left in `/Applications` but Homebrew no longer manages it, reinstall it over the existing copy with `brew install --cask --force <name>`.

## Usage

| Command | Description |
| --- | --- |
| `make install` | Install packages, Python, uv tools and Git hooks, link the configuration and apply macOS preferences |
| `make update` | Upgrade Homebrew packages and uv tools |
| `make link` | Symlink `home/` into `$HOME`, backing up any existing files |
| `make doctor` | Check that every package is installed and every link is in place |
| `make capture` | Report packages and applications installed on this Mac but not declared here |
| `make permissions` | Open the App Management setting that Homebrew needs |
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
