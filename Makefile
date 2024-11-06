build:
	docker build . -t functionapp

run:
	docker run --name functionapp -d functionapp

stop:
	docker container stop functionapp
	docker rm functionapp

shell:
	docker exec -it functionapp /bin/bash
