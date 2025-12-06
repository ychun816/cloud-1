This repository previously included `init_project.sh` to install Docker, build a tooling image
and start containers for Terraform/AWS CLI tasks. The Makefile now includes equivalent targets.

Quick commands:

- `make check-docker` — verify Docker CLI is present on the host.
- `make install-docker` — install Docker (uses `sudo`, Ubuntu-based systems).
- `make build-image` — build the `terraform-aws-env` tooling image from `docker/terraform-aws.Dockerfile`.
- `make run` — start an interactive shell inside the tooling image (or run `make run CMD="terraform plan"`).
- `make init|plan|apply|destroy` — run Terraform commands inside ephemeral containers.

Notes:
- Installing Docker via `make install-docker` requires `sudo` and is specific to Debian/Ubuntu.
- If you want the tooling image to include Terraform and AWS CLI permanently, add the installs to `docker/terraform-aws.Dockerfile` and run `make build-image`.
