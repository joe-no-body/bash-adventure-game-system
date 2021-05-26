.PHONY: lint
lint:
	shellcheck lib/*.bash

.PHONY: test
test:
	bats test