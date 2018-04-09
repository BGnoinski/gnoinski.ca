current_dir = $(shell pwd)
current_container = $(shell docker ps -af name=gnoinski -q)

clean:
	rm -rf output/*
ifneq ($(current_container),)
	docker kill $(current_container)
	docker rm $(current_container)
endif

build:
	docker build -t gnoinski.ca:latest .

dev: clean build
	docker run -td -p 8080:8080 -v $(current_dir):/site --name bengnoinskidev -u $(USER) gnoinski.ca:latest /bin/bash -c '/site/develop_server.sh start 8080 && sleep 1d'

upload:
	aws s3 sync --delete output/ s3://ben.gnoinski.ca
	aws cloudfront create-invalidation --distribution-id EW7T5A29H3R3J --paths '/*'
