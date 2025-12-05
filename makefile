# Runs Terraform commands inside container via init_project.sh
# Terraform is in Docker, but the Makefile wraps Docker commands for convenience.
# Makefile for Terraform + Docker project

# Makefile for Terraform + Docker project
# Automatically builds Docker image if missing, then runs Terraform inside container

# Default AWS profile
AWS_PROFILE ?= default

# Docker image name
IMAGE_NAME := terraform-aws-env

# Optional: set AUTO_BUILD=1 to allow automatic image build when missing
# By default we do NOT build automatically to avoid unexpected failures.
AUTO_BUILD ?= 0

# Function to ensure Docker image exists (POSIX sh compatible)
define ensure_docker_image
	@if [ -z "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "Docker image '$(IMAGE_NAME)' not found."; \
		if [ "$$AUTO_BUILD" = "1" ]; then \
			echo "AUTO_BUILD=1 set — building local image..."; \
			./init_project.sh; \
		else \
			echo "Set 'AUTO_BUILD=1' to allow automatic builds, or run 'make build-image' to build manually."; \
			exit 1; \
		fi; \
	else \
		echo "Docker image '$(IMAGE_NAME)' exists."; \
	fi
endef

# Explicit build target: run the project init script to build the image
build-image:
	@echo "Building local Docker image '$(IMAGE_NAME)'..."
	@./init_project.sh

# Terraform initialization
init:
	@$(call ensure_docker_image)
	@echo "Initializing Terraform..."
	./init_project.sh init

# Terraform plan
plan:
	@$(call ensure_docker_image)
	@echo "Running Terraform plan..."
	./init_project.sh plan

# Terraform apply
apply:
	@$(call ensure_docker_image)
	@echo "Applying Terraform configuration..."
	./init_project.sh apply

# Terraform destroy
destroy:
	@$(call ensure_docker_image)
	@echo "Destroying Terraform-managed infrastructure..."
	./init_project.sh destroy

# Quick check: verify Terraform is available inside a container
# - If the local `$(IMAGE_NAME)` image exists, check there.
# - Otherwise use the official HashiCorp Terraform image so we don't need to build the local image.

check-terraform:
	@if [ -z "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "Local image '$(IMAGE_NAME)' not found — using official HashiCorp Terraform image to check..."; \
		docker run --rm hashicorp/terraform:latest terraform -version || docker run --rm hashicorp/terraform:light terraform -version; \
	else \
		echo "Checking Terraform in local image '$(IMAGE_NAME)'..."; \
		docker run --rm $(IMAGE_NAME) terraform -version; \
	fi

# Convenience targets for docker-compose and cleanup
compose-up:
	@echo "Starting compose stack from compose/docker-compose.yml..."
	@docker compose -f compose/docker-compose.yml up -d

compose-down:
	@echo "Stopping compose stack (compose/docker-compose.yml)..."
	@docker compose -f compose/docker-compose.yml down --volumes --remove-orphans || true

clean: compose-down
	@echo "Removing local tooling image '$(IMAGE_NAME)' if present..."
	@if [ -n "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		docker rmi -f $(IMAGE_NAME) || true; \
	fi
	@echo "Pruning unused docker resources (dangling images, stopped containers, networks)..."
	@docker system prune -f || true
	@echo "Verifying no running containers or dangling images remain..."
	@$(MAKE) clean-check


# Check for hanging containers/images. Exits non-zero if anything is found.
clean-check:
	@echo "Checking for running containers..."
	@if [ -n "$$(docker ps -q)" ]; then \
		echo "ERROR: There are running containers:"; \
		docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}'; \
		exit 1; \
	else \
		echo "No running containers."; \
	fi
	@echo "Checking for dangling images..."
	@if [ -n "$$(docker images -f dangling=true -q)" ]; then \
		echo "ERROR: Dangling images exist:"; \
		docker images -f dangling=true; \
		exit 1; \
	else \
		echo "No dangling images."; \
	fi
	@echo "Checking for local tooling image '$(IMAGE_NAME)'..."
	@if [ -n "$$(docker images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "ERROR: Local tooling image '$(IMAGE_NAME)' still present:"; \
		docker images $(IMAGE_NAME); \
		exit 1; \
	else \
		echo "No local tooling image '$(IMAGE_NAME)' present."; \
	fi
	@echo "clean-check: OK"
