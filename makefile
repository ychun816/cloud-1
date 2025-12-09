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

# Default target: run local tool checks
.DEFAULT_GOAL := check-tools

# Check environment: Docker present and running, and Terraform+AWS CLI available in tooling image (or official images)
check-tools:
	@echo "Checking local tools (Ansible, Terraform, AWS CLI)..."
	@need_setup=0; \
	echo "\n[Ansible]"; \
	if command -v ansible >/dev/null 2>&1; then \
		ansible --version | head -n 1; \
	else \
		echo "Ansible not found on PATH."; \
		need_setup=1; \
	fi; \
	echo "\n[Terraform]"; \
	if command -v terraform >/dev/null 2>&1; then \
		terraform -version | head -n 1; \
	else \
		echo "Terraform not found on PATH."; \
		need_setup=1; \
	fi; \
	echo "\n[AWS CLI]"; \
	if command -v aws >/dev/null 2>&1; then \
		aws --version; \
	else \
		echo "AWS CLI not found on PATH."; \
		need_setup=1; \
	fi; \
	if [ "$$need_setup" -ne 0 ]; then \
		echo "\nOne or more tools are missing. Attempting to install via 'make setup-tools'..."; \
		$(MAKE) setup-tools || exit 1; \
		echo "\nRe-checking tools after setup..."; \
		missing=0; \
		command -v ansible >/dev/null 2>&1 || { echo "Ansible still missing."; missing=1; }; \
		command -v terraform >/dev/null 2>&1 || { echo "Terraform still missing."; missing=1; }; \
		command -v aws >/dev/null 2>&1 || { echo "AWS CLI still missing."; missing=1; }; \
		if [ "$$missing" -ne 0 ]; then \
			echo "\nERROR: Some tools are still missing after setup. See logs above for details."; \
			exit 1; \
		fi; \
	fi; \
	echo "\n[Optional] Verifying AWS credentials (sts:get-caller-identity)"; \
	aws sts get-caller-identity 2>/dev/null || echo "Note: AWS credentials not configured or invalid. Run 'aws configure' if needed."

# help | commands check
help:
	@echo "MAKE COMMANDS | Available targets: "
	@echo ""
	@echo "  check-tools       Check Ansible, Terraform & AWS CLI; auto-setup if missing"
	@echo "  setup-tools       Install Ansible, then install Terraform & AWS CLI via Ansible"
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
# init-env:
# 	@echo "Building local Docker image '$(IMAGE_NAME)'..."
# 	@./init_env.sh

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


# Install local tools using Ansible (macOS)
setup-tools:
	@echo "Ensuring Ansible is installed (via Homebrew, pipx, or pip3)..."
	@if command -v ansible >/dev/null 2>&1; then \
		echo "Ansible already installed."; \
	else \
		if command -v brew >/dev/null 2>&1; then \
			echo "Installing Ansible via Homebrew..."; \
			brew update >/dev/null 2>&1 || true; \
			brew install ansible || { echo "Failed to install Ansible with Homebrew"; exit 1; }; \
		elif command -v pipx >/dev/null 2>&1; then \
			echo "Installing Ansible via pipx..."; \
			pipx install ansible || { echo "Failed to install Ansible with pipx"; exit 1; }; \
		elif command -v pip3 >/dev/null 2>&1; then \
			echo "Installing Ansible via pip3 --user..."; \
			pip3 install --user ansible || { echo "Failed to install Ansible with pip3"; exit 1; }; \
			echo "NOTE: You may need to add the user base bin dir to PATH (e.g., \
				  $$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)') )/bin)."; \
		else \
			echo "ERROR: Could not find Homebrew, pipx, or pip3 to install Ansible."; \
			echo "Please install Homebrew first: /bin/bash -c \"$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
			exit 1; \
		fi; \
	fi; \
	echo "Ensuring required Ansible collections are present..."; \
	ag_bin=ansible-galaxy; \
	if ! command -v $$ag_bin >/dev/null 2>&1; then \
		user_bin_dir="$$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)'))/bin"; \
		[ -x "$$user_bin_dir/ansible-galaxy" ] && ag_bin="$$user_bin_dir/ansible-galaxy"; \
	fi; \
	"$$ag_bin" collection install community.general || true; \
	echo "Running Ansible playbook to install Terraform & AWS CLI..."; \
	pb_bin=ansible-playbook; \
	if ! command -v $$pb_bin >/dev/null 2>&1; then \
		user_bin_dir="$$($$(/usr/bin/env python3 -c 'import site,sys;sys.stdout.write(site.USER_BASE)'))/bin"; \
		[ -x "$$user_bin_dir/ansible-playbook" ] && pb_bin="$$user_bin_dir/ansible-playbook"; \
	fi; \
	ANSIBLE_CONFIG=$(CURDIR)/ansible/ansible.cfg "$$pb_bin" $(CURDIR)/ansible/tools.yml

.PHONY: check-tools help tf-init tf-plan tf-apply tf-destroy check-terraform compose-up compose-down clean clean-check setup-tools


#############
# Build the tooling image (context is the 'docker' directory)
# docker build -t terraform-aws-env -f docker/terraform-aws.Dockerfile docker

# # Verify versions in the rebuilt image
# docker run --rm terraform-aws-env terraform --version
# docker run --rm terraform-aws-env aws --version
#############