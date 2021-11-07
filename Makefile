.PHONY: default
default: lint test

.PHONY: lint
lint:
	shellcheck lib/*.bash

.PHONY: test
test:
	bats test