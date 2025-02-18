BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH = $(shell git show --format="%h" HEAD | head -1)
VERSION ?= latest

.PHONY: all server server-nls client client-vnc client-nls thin-client thin-client-nls crs rac-gui gitsync oscript oscript-utils runner

all: server client thin-client crs

yard:
	docker build \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg ONESCRIPT_PACKAGES="yard" \
		-t ${DOCKER_REGISTRY_URL}/oscript-downloader:yard \
		-f oscript/Dockerfile \
		"."	
server:
	make yard

	docker build \
		--build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
   		--build-arg DOWNLOADER_IMAGE=${DOCKER_REGISTRY_URL}/oscript-downloader:yard \
		-t ${DOCKER_REGISTRY_URL}/onec-server:${ONEC_VERSION} \
		-f server/Dockerfile \
		"."
	
	# docker tag ${DOCKER_REGISTRY_URL}/onec-server:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-server:latest

edt:
	docker build \
		--build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg EDT_VERSION="${EDT_VERSION}" \
		--build-arg DOWNLOADER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		--build-arg DOWNLOADER_IMAGE=oscript-downloader \
		--build-arg DOWNLOADER_TAG=latest \
		-t ${DOCKER_REGISTRY_URL}/edt:${EDT_VERSION} \
		-f edt/Dockerfile \
		.

server-nls:
	docker build --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg nls_enabled=true \
		-t ${DOCKER_REGISTRY_URL}/onec-server-nls:${ONEC_VERSION} \
		-f server/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-server-nls:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-server-nls:latest

client:
	make yard

	docker build \
		--build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg DOWNLOADER_IMAGE=${DOCKER_REGISTRY_URL}/oscript-downloader:yard \
		-t ${DOCKER_REGISTRY_URL}/onec-client:${ONEC_VERSION} \
		-f client/Dockerfile .
	
	# docker tag ${DOCKER_REGISTRY_URL}/onec-client:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-client:latest

client-vnc:
	docker build --build-arg DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/onec-client-vnc:${ONEC_VERSION} \
		-f client-vnc/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-client-vnc:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-client-vnc:latest

client-nls:
	docker build --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg nls_enabled=true \
		-t ${DOCKER_REGISTRY_URL}/onec-client-nls:${ONEC_VERSION} \
		-f client/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-client-nls:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-client-nls:latest

thin-client:
	docker build --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/onec-thin-client:${ONEC_VERSION} \
		-f thin-client/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-thin-client:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-thin-client:latest

thin-client-nls:
	docker build --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		--build-arg nls_enabled=true \
		-t ${DOCKER_REGISTRY_URL}/onec-thin-client-nls:${ONEC_VERSION} \
		-f thin-client/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-thin-client-nls:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-thin-client-nls:latest

crs:
	docker build --build-arg ONEC_USERNAME=${ONEC_USERNAME} \
		--build-arg ONEC_PASSWORD=${ONEC_PASSWORD} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/onec-crs:${ONEC_VERSION} \
		-f crs/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-crs:${ONEC_VERSION} ${DOCKER_REGISTRY_URL}/onec-crs:latest

rac-gui:
	docker build --build-arg DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/onec-rac-gui:${ONEC_VERSION}-1.0.1 \
		-f rac-gui/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/onec-rac-gui:${ONEC_VERSION}-1.0.1 ${DOCKER_REGISTRY_URL}/onec-rac-gui:latest

gitsync:
	docker build --build-arg DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		--build-arg ONEC_VERSION=${ONEC_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/gitsync:3.0.0 \
		-f gitsync/Dockerfile .
	docker tag ${DOCKER_REGISTRY_URL}/gitsync:3.0.0 ${DOCKER_REGISTRY_URL}/gitsync:latest

oscript:
	docker build \
		--build-arg ONESCRIPT_VERSION=${ONESCRIPT_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/oscript:${ONESCRIPT_VERSION} \
		-f oscript/Dockerfile .

oscript-utils:
	docker build --build-arg DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL} \
		-t ${DOCKER_REGISTRY_URL}/oscript-utils:latest \
		-f oscript-utils/Dockerfile .

runner:
	make client

	docker build \
		--build-arg BASE_IMAGE=${DOCKER_REGISTRY_URL}/onec-client:${ONEC_VERSION} \
		--build-arg ONESCRIPT_VERSION=${ONESCRIPT_VERSION} \
		-t ${DOCKER_REGISTRY_URL}/vanessa-runner:2.2.22 \
		-f vanessa-runner/Dockerfile \
		"."
