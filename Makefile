.PHONY: default
default: lint test

.PHONY: lint
lint:
	shellcheck lib/*.bash

.PHONY: test
test:
	node_modules/bats/bin/bats test

.PHONY: run
run:
	bash ./game/main.sh
