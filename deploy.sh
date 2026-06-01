#!/bin/bash

set -e

echo "🚀 Building and Deploying SageMaker Compilation Job"

# Variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
REPOSITORY_NAME="sagemaker-neo-compilation"
IMAGE_TAG="latest"
ROLE_NAME="SageMakerNeoRole"

# Build Docker image
echo "📦 Building Docker image..."
docker build -t $REPOSITORY_NAME:$IMAGE_TAG .

# Create ECR repository
echo "📂 Creating ECR repository..."
aws ecr create-repository \
    --repository-name $REPOSITORY_NAME \
    --region $AWS_REGION || echo "Repository already exists"

# Push to ECR
echo "📤 Pushing image to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker tag $REPOSITORY_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG

echo "✅ Image pushed successfully!"
echo "Image URI: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG"
