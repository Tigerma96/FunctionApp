build:
	docker build . -t functionapp

run:
	pwsh -c '.\scripts\runDockerContainer.ps1'

stop:
	docker container stop functionapp
	docker rm functionapp

shell:
	docker exec -it functionapp /bin/bash

format:
	black . --line-length 79
	isort .

lint:
	flake8 .

initialize:
	pip install -r build-dependencies.txt
	pip install black
	pip install isort
	pip install flake8
	pip install flake8-annotations
