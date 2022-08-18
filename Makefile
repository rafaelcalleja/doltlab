CURRENT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ENV_FILE ?= .env.local
DOCKER_COMPOSE := ENV_FILE=$(CURRENT_DIR)$(ENV_FILE) docker-compose --env-file $(CURRENT_DIR)$(ENV_FILE)

include $(ENV_FILE)
export

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
	@APP_ENV=$(APP_ENV) $(DOCKER_COMPOSE) up -d

.PHONY: stop
stop:
	@$(DOCKER_COMPOSE) down

.PHONY: clean
clean: stop

.PHONY: destroy
destroy:
	@$(DOCKER_COMPOSE) down --rmi local -v
	@rm iter_token.keys envoy.yaml || true

.PHONY: logs
logs:
	@$(DOCKER_COMPOSE) logs -f

create_envoy_config:
	@docker run -w /src -v $(CURRENT_DIR):/src --rm -e HOST_IP=$(HOST_IP) rafaelcalleja/envsubst:0.0.0 "envsubst '\$$\$${HOST_IP}' < envoy.tmpl" > envoy.yaml

create_token_keys:
	@test -f iter_token.keys || chmod +x ./gentokenenckey; ./gentokenenckey > iter_token.keys
