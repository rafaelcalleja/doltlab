CURRENT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

VERSION ?= v0.5.9
RELEASE_URL := https://doltlab-releases.s3.amazonaws.com/linux/amd64/doltlab-$(VERSION).zip

ENV_FILE ?= .env.local
DOCKER_COMPOSE := ENV_FILE=$(CURRENT_DIR)$(ENV_FILE) docker-compose -f docker-compose.yaml -f docker-compose.dev.yaml --env-file $(CURRENT_DIR)$(ENV_FILE)
MYSQL_SERVER ?= 3306

include $(ENV_FILE)
export

IMG_REPO ?= rafaelcalleja
IMG_TAG ?= v0.41.5
IMG_NAME ?= dolt

.PHONY: all
all: build
	$(DOCKER_COMPOSE) up -d -V

.PHONY: build
build: deps

.PHONY: deps
deps: create_envoy_config create_token_keys
	@$(DOCKER_COMPOSE) build

.PHONY: start
start:
	@$(DOCKER_COMPOSE) up -d

.PHONY: stop
stop:
	@$(DOCKER_COMPOSE) down

.PHONY: clean
clean: stop

.PHONY: destroy
destroy:
	@$(DOCKER_COMPOSE) down --rmi local -v
	@rm -f *_iter_token.keys envoy.yaml || true

.PHONY: logs
logs:
	@$(DOCKER_COMPOSE) logs -f

create_envoy_config:
	@docker run -w /src -v $(CURRENT_DIR):/src --rm -e HOST_IP=$(HOST_IP) rafaelcalleja/envsubst:0.0.0 "envsubst '\$$\$${HOST_IP}' < envoy.tmpl" > envoy.yaml

create_token_keys:
	@test -f doltlabfileserviceapi_iter_token.keys || chmod +x ./gentokenenckey; ./gentokenenckey > doltlabfileserviceapi_iter_token.keys
	@test -f doltlabapi_iter_token.keys || chmod +x ./gentokenenckey; ./gentokenenckey > doltlabapi_iter_token.keys
	@test -f doltlabremoteapi_iter_token.keys || chmod +x ./gentokenenckey; ./gentokenenckey > doltlabremoteapi_iter_token.keys

image:
	docker build -t $(IMG_REPO)/$(IMG_NAME):$(IMG_TAG) -f Dockerfile \
	--build-arg VERSION=$(IMG_TAG) \
	.
push:
	docker push $(IMG_REPO)/$(IMG_NAME):$(IMG_TAG)

upgrade:
	curl -L $(RELEASE_URL) -o doltlab-latest.zip
	unzip -o doltlab-latest.zip -d .
	rm doltlab-latest.zip
