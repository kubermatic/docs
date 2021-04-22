CODESPELL_IMAGE ?= quay.io/kubermatic/codespell:1.17.1
CODESPELL_BIN := $(shell which codespell)
DOCKER_BIN := $(shell which docker)

.PHONY: preview
preview:
	docker run -it --name kubermatic-docs --rm \
		-p 1313:1313 \
		-v `pwd`:/docs quay.io/kubermatic/hugo:0.75.1-0 \
		 bash -c 'cd /docs; hugo server -D -F --bind 0.0.0.0'

.PHONY: runbook
runbook:
	./hack/convert-runbook.sh

.PHONY: spellcheck
spellcheck:
ifndef CODESPELL_BIN
	$(error "codespell not available in your environment, use spellcheck-in-docker if you have Docker installed.")
endif
	$(CODESPELL_BIN) \
		-S ./themes,./static,*.css,swagger*.js,swagger.json,*.scss,*.png,*.po,.git,*.jpg,*.woff,*.woff2,*.xml \
		-I ./.codespell.exclude -f

.PHONY: spellcheck-in-docker
spellcheck-in-docker:
ifndef DOCKER_BIN
	$(error "Docker not available in your environment, please install it and retry.")
endif
	$(DOCKER_BIN) run -it -v ${PWD}:/kubermatic -w /kubermatic $(CODESPELL_IMAGE) make spellcheck
