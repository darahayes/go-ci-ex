APP_NAME = go-ci-ex
REGISTRY_ORG = darahayes

# The entry point to the application
ENTRYPOINT = main.go

# Name of the binary that will be built
BINARY ?= go-ci-ex

# This is where the linux binary will be placed
BINARY_LINUX_64 = ./dist/linux_amd64/$(BINARY)

RELEASE_TAG ?= $(CIRCLE_TAG)
DOCKER_LATEST_TAG = $(REGISTRY_ORG)/$(APP_NAME):latest
DOCKER_MASTER_TAG = $(REGISTRY_ORG)/$(APP_NAME):master
DOCKER_RELEASE_TAG = $(REGISTRY_ORG)/$(APP_NAME):$(RELEASE_TAG)

.PHONY: setup
setup:
	dep ensure

.PHONY: test
test:
	@echo Running tests:
	go test -v -race -cover

.PHONY: build
build: setup
	go build -o $(BINARY) $(ENTRYPOINT)

.PHONY: build_linux
build_linux: setup
	env GOOS=linux GOARCH=amd64 go build -o $(BINARY_LINUX_64) $(ENTRYPOINT)

.PHONY: docker_build
docker_build: build_linux
	docker build -t $(DOCKER_LATEST_TAG) --build-arg BINARY=$(BINARY_LINUX_64) .

.PHONY: docker_build_release
docker_build_release:
	docker build -t $(DOCKER_LATEST_TAG) -t $(DOCKER_RELEASE_TAG) --build-arg BINARY=$(BINARY_LINUX_64) .

.PHONY: docker_build_master
docker_build_master:
	docker build -t $(DOCKER_MASTER_TAG) --build-arg BINARY=$(BINARY_LINUX_64) .

.PHONY: docker_push_release
docker_push_release:
	@docker login --username $(DOCKERHUB_USERNAME) --password $(DOCKERHUB_PASSWORD)
	docker push $(DOCKER_LATEST_TAG)
	docker push $(DOCKER_RELEASE_TAG)
	
.PHONY: docker_push_master
docker_push_master:
	@docker login -u $(DOCKERHUB_USERNAME) -p $(DOCKERHUB_PASSWORD)
	docker push $(DOCKER_MASTER_TAG)