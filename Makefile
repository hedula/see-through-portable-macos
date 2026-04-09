# Convenience targets — same as ./run.sh
.PHONY: run setup brew-python help

help:
	@echo "Targets:"
	@echo "  make run   — start See-through (./run.sh)"
	@echo "  make setup — install Python 3.12 via Homebrew (brew bundle)"
	@echo ""
	@echo "Quick install (Terminal):"
	@echo "  brew bundle && make run"

run:
	@chmod +x run.sh See-through.command 2>/dev/null || true
	@./run.sh

setup: brew-python

brew-python:
	brew bundle install --no-upgrade
