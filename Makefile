SHELL := /bin/bash
export PATH := $(HOME)/.local/bin:$(PATH)
.DEFAULT_GOAL := help

BREWFILE := $(CURDIR)/Brewfile
SHELL_FILES := install.sh $(wildcard scripts/*.sh)

APP_MANAGEMENT_URL := x-apple.systempreferences:com.apple.preference.security?Privacy_AppBundles

.PHONY: help install bundle python tools hooks link macos update capture lint doctor permissions

help: ## Show available targets
	@awk 'BEGIN { FS = ":.*## " } /^[a-z]+:.*## / { printf "  %-11s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# Runs every step even if one fails, so a single broken package does not
# leave the shell, Python and links unconfigured. Fails at the end if any
# step failed.
install: ## Set up this Mac
	@$(MAKE) --no-print-directory --keep-going link bundle python tools hooks macos || { \
		printf '\nerror: some steps failed (see above); fix them and run make install again\n' >&2; \
		exit 1; \
	}

bundle: ## Install Homebrew and Mac App Store packages
	@brew bundle --file=$(BREWFILE) || { \
		printf '\n%s\n%s\n' \
			'hint: "Operation not permitted" on an app means the terminal lacks the App Management permission.' \
			'      Run make permissions, turn on your terminal, reopen it and run make install again.' >&2; \
		exit 1; \
	}

permissions: ## Open the App Management settings Homebrew needs
	open "$(APP_MANAGEMENT_URL)"

python: ## Install the latest Python with uv
	uv python install

tools: ## Install global Python tools with uv
	grep -v '^$$' uv-tools.txt | xargs -n 1 uv tool install

hooks: ## Install the pre-commit hooks for this repository
	pre-commit install

link: ## Symlink home/ into $HOME
	bash scripts/link.sh

macos: ## Apply macOS preferences
	bash scripts/macos.sh

update: ## Upgrade packages and tools
	brew update
	brew upgrade
	brew bundle --file=$(BREWFILE)
	brew cleanup
	uv tool upgrade --all

capture: ## Report what is installed but not declared
	bash scripts/capture.sh

lint: ## Lint the shell scripts
	shellcheck -x $(SHELL_FILES)
	shfmt -d -i 2 -ci $(SHELL_FILES)

doctor: ## Check packages and symlinks
	brew bundle check --file=$(BREWFILE) --verbose
	bash scripts/link.sh --check
