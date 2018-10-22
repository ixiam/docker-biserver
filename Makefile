#!/usr/bin/make -f

MKFILE_RELPATH := $(shell printf -- '%s' '$(MAKEFILE_LIST)' | sed 's|^\ ||')
MKFILE_ABSPATH := $(shell readlink -f -- '$(MKFILE_RELPATH)')
MKFILE_DIR := $(shell dirname -- '$(MKFILE_ABSPATH)')

BISERVER_VERSION := 8.1.0.0-365
BISERVER_MAVEN_REPO := https://repo.stratebi.com/repository/pentaho-mvn/

DIST_DIR := $(MKFILE_DIR)/dist

DOCKER_IMAGE_NAMESPACE := stratebi
DOCKER_IMAGE_NAME := pentaho-biserver
DOCKER_IMAGE_TAG := $(BISERVER_VERSION)
DOCKER_IMAGE := $(DOCKER_IMAGE_NAMESPACE)/$(DOCKER_IMAGE_NAME)
DOCKER_CONTAINER := $(DOCKER_IMAGE_NAME)
DOCKERFILE := $(MKFILE_DIR)/Dockerfile

.PHONY: all \
	build build-image save-image save-standalone \
	clean clean-image clean-container clean-dist

all: build

build: save-image save-standalone

build-image:
	docker build \
		--tag '$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)' \
		--build-arg BISERVER_VERSION='$(BISERVER_VERSION)' \
		--build-arg BISERVER_MAVEN_REPO='$(BISERVER_MAVEN_REPO)' \
		--file '$(DOCKERFILE)' \
		-- '$(MKFILE_DIR)'

save-image: build-image
	mkdir -p -- '$(DIST_DIR)'
	docker save -- '$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)' | gzip > '$(DIST_DIR)/$(DOCKER_IMAGE_NAME)_$(DOCKER_IMAGE_TAG).tgz'

save-standalone: build-image
	mkdir -p -- '$(DIST_DIR)'
	docker run --rm -- '$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)' /opt/scripts/export.sh > '$(DIST_DIR)/$(DOCKER_IMAGE_NAME)_$(DOCKER_IMAGE_TAG)_standalone.tgz'

clean: clean-image clean-dist

clean-image: clean-container
	-docker rmi -- '$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)'

clean-container:
	-docker stop -- '$(DOCKER_CONTAINER)'
	-docker rm -- '$(DOCKER_CONTAINER)'

clean-dist:
	rm -rf -- '$(DIST_DIR)'
