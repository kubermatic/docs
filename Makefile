CODESPELL_IMAGE ?= quay.io/kubermatic/build:go-1.21-node-18-6
CODESPELL_BIN := $(shell which codespell)
DOCKER_BIN := $(shell which docker)

.PHONY: preview
preview:
	$(DOCKER_BIN) run -it --rm \
		--name kubermatic-docs \
		-p 1313:1313 \
		-w /docs \
		-v `pwd`:/docs quay.io/kubermatic/hugo:0.119.0-0 \
		hugo server -D -F --bind 0.0.0.0

.PHONY: runbook
runbook:
	./hack/convert-runbook.sh

.PHONY: spellcheck
spellcheck:
ifndef CODESPELL_BIN
	$(error "codespell not available in your environment, use spellcheck-in-docker if you have Docker installed.")
endif
	$(CODESPELL_BIN) \
		-S ./themes,./static,*.min.js,*.css,swagger*.js,swagger.json,*.scss,*.png,*.po,.git,*.jpg,*.woff,*.woff2,*.xml \
		-I ./.codespell.exclude -f

.PHONY: spellcheck-in-docker
spellcheck-in-docker:
ifndef DOCKER_BIN
	$(error "Docker not available in your environment, please install it and retry.")
endif
	$(DOCKER_BIN) run -it -v ${PWD}:/kubermatic -w /kubermatic $(CODESPELL_IMAGE) make spellcheck
