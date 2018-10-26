include make_env

.PHONY: help pre-build build test e2e qa deploy run shell release clean

help: ## Print this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

pre-build:
	@echo  "Pre-build: Nothing to do..."

build: pre-build  ## Build a Docker image
	@echo  "[$@] Building image as $(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)"
	docker build --tag $(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION) \
		--build-arg HTTP_PROXY=$(HTTP_PROXY) --build-arg HTTPS_PROXY=$(HTTPS_PROXY) \
		--build-arg http_proxy=$(HTTP_PROXY) --build-arg https_proxy=$(HTTPS_PROXY) \
		-f Dockerfile .
	@echo  "[$@] Docker image successfully built as $(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)"


test: ## Run unit test
	@echo "Test: Nothing to do..."

e2e: ## Run integration test
	@echo "E2E: Nothing to do..."

qa: ## Run quality analysis
	@echo "QA: Nothing to do..."

deploy:
	docker tag $(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION) $(DOCKER_REPO)/$(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)
	docker push $(DOCKER_REPO)/$(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)
	@echo  "[$@] Docker image deployed on $(DOCKER_REPO)/$(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)"

run: ## run docker container in foreground
	docker run -d -p $(LOCAL_PORT):80 --rm -v $(VOLUMES) \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_VERSION)

shell: ## shell inside docker container
	docker exec -it $(CONTAINER_NAME) /bin/bash

release:
	@echo "Release: Nothing to do..."

clean:
	docker images -a | grep $(IMAGE_NAMESPACE) | grep $(IMAGE_NAME) | grep $(IMAGE_VERSION) | awk '{print $$3}' | xargs docker rmi