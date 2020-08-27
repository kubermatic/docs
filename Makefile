preview:
	docker run -it --name kubermatic-docs --rm \
		-p 1313:1313 \
		-v `pwd`:/docs quay.io/kubermatic/hugo:0.71.1-0 \
		 bash -c 'cd docs; hugo server -D -F --bind 0.0.0.0'

runbook:
	./hack/convert-runbook.sh
