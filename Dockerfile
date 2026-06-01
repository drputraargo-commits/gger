FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    aws-cli \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir \
    boto3 \
    tensorflow==2.13.0 \
    torch==2.0.0 \
    sagemaker

# Copy scripts
COPY scripts/ /opt/scripts/
COPY src/ /opt/src/

# Set permissions
RUN chmod +x /opt/scripts/*.sh

WORKDIR /opt/app

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
