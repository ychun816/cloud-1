#!/bin/bash
set -e  # Exit immediately if a command fails

# 1. Installs Docker if missing.
# 2. Builds a Docker image with Terraform + AWS CLI (Dockerfile assumed in project root).
# 3. Runs any Terraform command passed as arguments (init, plan, apply, destroy).
# 4. AWS credentials are safely mounted read-only.

# ------------------------------
# Configuration
# ------------------------------
IMAGE_NAME="terraform-aws-env"        # Docker image name
AWS_PROFILE="${AWS_PROFILE:-default}" # AWS profile to use if not set

# ------------------------------
# 1. Check if Docker is installed
# ------------------------------
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    
    # Update packages and install prerequisites
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker GPG key and repository
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine and plugins
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "Docker installed successfully!"
else
    echo "Docker is already installed."
fi

# ------------------------------
# 2. Build Docker image if it doesn't exist
# ------------------------------
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Building Docker image '$IMAGE_NAME'..."

    # Search for a Dockerfile in common locations (repo root, compose/, conf/)
    DOCKERFILE_PATH="$(find . -maxdepth 4 -type f -name Dockerfile | grep -E "(^\./compose/|^\./conf/|^\./)" | head -n 1 || true)"

    if [[ -n "$DOCKERFILE_PATH" ]]; then
        echo "Found Dockerfile at: $DOCKERFILE_PATH"

        # If the Dockerfile references files in a top-level `tools/` directory
        # (e.g. "COPY ./tools/..."), we must use the repository root as the
        # build context so those files are available. Otherwise use the
        # Dockerfile directory as the build context for a smaller build.
        if grep -E '(^|[[:space:]])(COPY|ADD)[[:space:]]+(\./|/)?tools/' "$DOCKERFILE_PATH" >/dev/null 2>&1; then
            BUILD_CONTEXT="."
            echo "Dockerfile copies files from top-level 'tools/' — using repo root as build context."
        else
            BUILD_CONTEXT="$(dirname "$DOCKERFILE_PATH")"
            echo "Building with context: $BUILD_CONTEXT"
        fi

        docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$BUILD_CONTEXT"
    else
        echo "No Dockerfile found in repository (searched up to depth 4)."
        echo "Creating a minimal fallback Dockerfile to produce a tiny image."
        tmpdir=$(mktemp -d)
        cat > "$tmpdir/Dockerfile" <<'EOF'
FROM alpine:3.18
CMD ["/bin/sh"]
EOF
        docker build -t "$IMAGE_NAME" "$tmpdir"
        rm -rf "$tmpdir"
    fi
else
    echo "Docker image '$IMAGE_NAME' already exists."
fi

# ------------------------------
# 3. Run Terraform inside the container
# ------------------------------
docker run -it --rm \
    -v "$PWD":/workspace \
    -v ~/.aws:/root/.aws:ro \
    -e AWS_PROFILE="$AWS_PROFILE" \
    $IMAGE_NAME "$@"


# NOTES ### 
# -v ~/.aws:/root/.aws:ro makes the .aws folder read-only inside the container.
# Terraform and AWS CLI inside the container can read the credentials to authenticate, but they cannot modify or delete your local credentials.
# No secrets are baked into the Docker image itself.

# Best practices when using read-only mounts
# Never commit credentials into your project or Dockerfile.
# Use AWS profiles or temporary credentials if possible.
# Ensure the container runs trusted code only. If you run arbitrary containers, even read-only mounts could be misused to read secrets.
# Prefer environment variables for CI/CD pipelines, so credentials don’t have to be mounted at all.