# Runs Terraform commands inside container via init_project.sh
# Terraform is in Docker, but the Makefile wraps Docker commands for convenience.
# Makefile for Terraform + Docker project

# Makefile for Terraform + Docker project
# Automatically builds Docker image if missing, then runs Terraform inside container

# Default AWS profile
AWS_PROFILE ?= default

# Docker image name
IMAGE_NAME := terraform-aws-env

# Function to ensure Docker image exists
define ensure_docker_image
	@if [[ "$$(docker images -q $(IMAGE_NAME) 2> /dev/null)" == "" ]]; then \
		echo "Docker image '$(IMAGE_NAME)' not found. Building..."; \
		./init_project.sh; \
	else \
		echo "Docker image '$(IMAGE_NAME)' exists."; \
	fi
endef

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
