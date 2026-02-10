#!/bin/bash

# Build and push script for jq-kcat toolbox
# Usage: ./build.sh <registry> [tag]
#
# Examples:
#   ./build.sh docker.io/myusername
#   ./build.sh ghcr.io/myusername v1.0
#   ./build.sh myregistry.azurecr.io

set -e

# Check if registry is provided
if [ -z "$1" ]; then
    echo "Error: Registry not specified"
    echo "Usage: $0 <registry> [tag]"
    echo ""
    echo "Examples:"
    echo "  $0 docker.io/myusername"
    echo "  $0 ghcr.io/myusername v1.0"
    exit 1
fi

REGISTRY="$1"
TAG="${2:-latest}"
IMAGE_NAME="jq-kcat"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "========================================="
echo "Building Docker Image"
echo "========================================="
echo "Image: ${FULL_IMAGE}"
echo ""

# Build the image
docker build -t "${FULL_IMAGE}" -f jq-kcat/Dockerfile jq-kcat/

echo ""
echo "========================================="
echo "Build Complete!"
echo "========================================="
echo ""
echo "To push to registry, run:"
echo "  docker push ${FULL_IMAGE}"
echo ""
echo "To update pod.yaml, run:"
echo "  sed -i 's|<your-registry>/jq-kcat:latest|${FULL_IMAGE}|g' jq-kcat/pod.yaml"
echo ""
echo "Or run this script with push option:"
echo "  $0 $1 $TAG push"

# If third argument is "push", push the image
if [ "$3" == "push" ]; then
    echo ""
    echo "========================================="
    echo "Pushing to Registry"
    echo "========================================="
    docker push "${FULL_IMAGE}"
    
    echo ""
    echo "========================================="
    echo "Updating pod.yaml"
    echo "========================================="
    # Update the pod.yaml with the correct image
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|<your-registry>/jq-kcat:latest|${FULL_IMAGE}|g" jq-kcat/pod.yaml
    else
        # Linux
        sed -i "s|<your-registry>/jq-kcat:latest|${FULL_IMAGE}|g" jq-kcat/pod.yaml
    fi
    
    echo ""
    echo "========================================="
    echo "Ready to Deploy!"
    echo "========================================="
    echo "Deploy to Kubernetes with:"
    echo "  kubectl apply -f jq-kcat/pod.yaml"
    echo ""
fi
