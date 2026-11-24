SHELL := /bin/bash
export PATH := $(HOME)/.local/bin:$(PATH)
.DEFAULT_GOAL := help

BREWFILE := $(CURDIR)/Brewfile
SHELL_FILES := install.sh $(wildcard scripts/*.sh)

.PHONY: help install bundle python tools hooks link macos update capture lint doctor

help: ## Show available targets
	@awk 'BEGIN { FS = ":.*## " } /^[a-z]+:.*## / { printf "  %-8s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

install: bundle python tools hooks link macos ## Set up this Mac

bundle: ## Install Homebrew and Mac App Store packages
	brew bundle --file=$(BREWFILE)

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
