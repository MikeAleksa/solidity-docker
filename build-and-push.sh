#!/bin/bash

GO_VERSION=1.17
GETH_VERSION=1.10.15
SOLIDITY_VERSION=0.8.11

echo "Building and pushing multi-arch solidity-dev container..."
echo "GO_VERSION: $GO_VERSION"
echo "GETH_VERSION: $GETH_VERSION"
echo "SOLIDITY_VERSION: $SOLIDITY_VERSION"

docker buildx build \
    --build-arg GO_VERSION=$GO_VERSION \
    --build-arg GETH_VERSION=$GETH_VERSION \
    --build-arg SOLIDITY_VERSION=$SOLIDITY_VERSION \
    --platform linux/amd64,linux/arm64 \
    --push \
    -t mtaleksa/solidity-dev:latest \
    -t mtaleksa/solidity-dev:$GO_VERSION-$GETH_VERSION-$SOLIDITY_VERSION \
    .