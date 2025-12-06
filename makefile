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
			echo "Set 'AUTO_BUILD=1' to allow automatic builds, or run 'make build-env' to build manually."; \
			exit 1; \
		fi; \
	else \
		echo "Docker image '$(IMAGE_NAME)' exists."; \
	fi
endef

# Default target: run check-env
.DEFAULT_GOAL := check-env

# Check environment: Docker present and running, and Terraform+AWS CLI available in tooling image (or official images)
check-env:
	@echo "Checking Docker availability..."
	@if command -v docker >/dev/null 2>&1; then \
		if docker info >/dev/null 2>&1; then \
			echo "Docker daemon is running"; \
			echo "== Current running containers =="; \
			docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\n' || true; \
		else \
			echo "Docker CLI found but daemon is not running or not accessible (try 'systemctl start docker' or check permissions)"; exit 1; \
		fi; \
	else \
		echo "Docker is not installed. Install Docker or run 'make build-env' if you have a script to install it."; exit 1; \
	fi

	@echo "Checking Terraform in tooling image or official image..."
	@if [ -n "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "Terraform version (from $(IMAGE_NAME)):"; \
		docker run --rm $(IMAGE_NAME) terraform -version || (echo "ERROR: terraform not available in $(IMAGE_NAME)\n" && exit 1); \
	else \
		echo "Terraform version (from official hashicorp/terraform image):"; \
		docker run --rm hashicorp/terraform:latest terraform -version || (echo "ERROR: terraform not available in official image" && exit 1); \
		echo ""; \
	fi

	@echo "Checking AWS CLI in tooling image or official image..."
	@if [ -n "$$($(docker) images -q $(IMAGE_NAME) 2> /dev/null)" ]; then \
		echo "AWS CLI version (from $(IMAGE_NAME)):"; \
		docker run --rm $(IMAGE_NAME) --version || (echo "ERROR: aws CLI not available in $(IMAGE_NAME)" && exit 1); \
	else \
		echo "AWS CLI version (from official amazon/aws-cli image):"; \
		docker run --rm amazon/aws-cli --version || (echo "ERROR: aws CLI not available in official image" && exit 1); \
	fi

# help | commands check
help:
	@echo "MAKE COMMANDS | Available targets: "
	@echo ""
	@echo "  check-env         Ensure Docker is installed and running with Terraform & AWS CLI installed"
	@echo "  init-env          Build the local Docker image '$(IMAGE_NAME)'"
	@echo "  tf-init           Initialize Terraform"
	@echo "  tf-plan           Run Terraform plan"
	@echo "  tf-apply          Apply Terraform configuration"
	@echo "  tf-destroy        Destroy Terraform-managed infrastructure"
	@echo "  compose-up        Start docker-compose stack (compose/docker-compose.yml)"
	@echo "  compose-down      Stop docker-compose stack (compose/docker-compose.yml)"
	@echo "  clean             Remove local Docker image and prune unused resources"
	@echo "  clean-check       Check for running containers, dangling images, or local images"
	@echo ""

# Explicit build target: run the project init script to build the image
init-env:
	@echo "Building local Docker image '$(IMAGE_NAME)'..."
	@./init_env.sh

# Terraform initialization
tf-init:
	@$(call ensure_docker_image)
	@echo "Initializing Terraform..."
	./init_env.sh init

# Terraform plan
tf-plan:
	@$(call ensure_docker_image)
	@echo "Running Terraform plan..."
	./init_env.sh plan

# Terraform apply
tf-apply:
	@$(call ensure_docker_image)
	@echo "Applying Terraform configuration..."
	./init_env.sh apply

# Terraform destroy
tf-destroy:
	@$(call ensure_docker_image)
	@echo "Destroying Terraform-managed infrastructure..."
	./init_env.sh destroy

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

# Consolidated clean target: stop compose, remove tooling image, prune and verify
clean: compose-down
	@echo "Removing local tooling image '$(IMAGE_NAME)' if present..."
	@ids="$$(docker images -q $(IMAGE_NAME) 2> /dev/null || true)"; \
	if [ -n "$$ids" ]; then \
		echo "Found image ids: $$ids"; \
		for id in $$ids; do \
			echo "Removing $$id..."; \
			docker rmi -f $$id || true; \
		done; \
		# small retry in case Docker needs a moment to release layers; \
		sleep 1; \
		ids2="$$(docker images -q $(IMAGE_NAME) 2> /dev/null || true)"; \
		if [ -n "$$ids2" ]; then \
			echo "Retry removing remaining images: $$ids2"; \
			for id in $$ids2; do docker rmi -f $$id || true; done; \
		fi; \
	else \
		echo "No local tooling image '$(IMAGE_NAME)' present."; \
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
	@echo "\nclean-check: OK\n"


#############
# Build the tooling image (context is the 'docker' directory)
# docker build -t terraform-aws-env -f docker/terraform-aws.Dockerfile docker

# # Verify versions in the rebuilt image
# docker run --rm terraform-aws-env terraform --version
# docker run --rm terraform-aws-env aws --version
#############