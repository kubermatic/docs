all: build preview

build:
	docker build -t kubermatic-docs .

preview:
	docker run --rm --interactive --tty -p=8000:8000 --volume $$PWD:/app kubermatic-docs preview 0.0.0.0:8000

deploy:
	docker run --rm --interactive --tty -p=8000:8000 --volume $$PWD:/app --volume $$HOME/.ssh:/root/.ssh --volume $$HOME/.gitconfig:/root/.gitconfig kubermatic-docs deploy

clean:
	rm -rf .couscous
