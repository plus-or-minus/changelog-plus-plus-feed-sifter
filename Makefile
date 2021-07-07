P="\\033[34m[+]\\033[0m"

setup:
	@echo "$(P) setup"
	bundle

run:
	@echo "$(P) run"
	ruby main.rb

test:
	@echo "$(P) test"
	echo "not implemented"

lint:
	@echo "$(P) lint"
	bundle exec rubocop

.PHONY: run test lint
