ARG TERRAFORM_VERSION=1.6.5
FROM debian:bookworm-slim

ARG TERRAFORM_VERSION
ARG AWSCLI_ZIP_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl unzip gnupg2 wget groff less jq git openssh-client python3 python3-pip \
 && rm -rf /var/lib/apt/lists/*

# Install Terraform binary
RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O /tmp/terraform.zip \
 && unzip /tmp/terraform.zip -d /usr/local/bin \
 && chmod +x /usr/local/bin/terraform \
 && rm -f /tmp/terraform.zip

# Install AWS CLI v2
WORKDIR /tmp
RUN curl -fsSL "${AWSCLI_ZIP_URL}" -o awscliv2.zip \
 && unzip awscliv2.zip \
 && ./aws/install --update \
 && rm -rf /tmp/*

WORKDIR /workspace
ENTRYPOINT []
CMD ["bash"]
