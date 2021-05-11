DOCKER_COMPOSE_YML = docker/docker-compose.yml

.PHONY: build stop start clean

build:
	docker-compose -f $(DOCKER_COMPOSE_YML) build

stop:
	docker-compose -f $(DOCKER_COMPOSE_YML) rm -sf

start:
	docker-compose -f $(DOCKER_COMPOSE_YML) up

clean:
	docker-compose -f $(DOCKER_COMPOSE_YML) down --rmi all --volumes

