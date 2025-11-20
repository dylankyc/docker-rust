# Axum Example Makefile
# Multi-architecture Docker build commands

# Configuration
IMAGE_NAME = dylandylandy/axum-helloworld
VERSION ?= latest
PLATFORMS = linux/amd64,linux/arm64

# Default target
.PHONY: help
help:
	@echo "Axum Example Build Commands"
	@echo "============================"
	@echo ""
	@echo "Multi-Architecture Builds:"
	@echo "  make build-multiarch          - Build for AMD64 and ARM64, push to registry"
	@echo "  make build-multiarch-zstd     - Build with ZSTD support for both architectures"
	@echo "  make build-version VERSION=v1.0.0 - Build specific version for both architectures"
	@echo ""
	@echo "Single Architecture Builds:"
	@echo "  make build-local              - Build for current architecture only"
	@echo "  make build-amd64              - Build for AMD64 only"
	@echo "  make build-arm64              - Build for ARM64 only"
	@echo ""
	@echo "Development:"
	@echo "  make run                      - Run application locally with Cargo"
	@echo "  make test                     - Run tests"
	@echo "  make clean                    - Clean build artifacts"
	@echo ""
	@echo "Verification:"
	@echo "  make verify-manifest          - Verify multi-arch manifest"
	@echo "  make test-image               - Test the built Docker image"

# Multi-architecture builds (recommended)
.PHONY: build-multiarch
build-multiarch:
	@echo "Building multi-architecture image for $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):latest \
		--push .
	@echo "✅ Multi-arch build complete!"
	@echo "Users can now run: docker run --rm -p 9999:9999 $(IMAGE_NAME):latest"

# Multi-architecture with ZSTD support
.PHONY: build-multiarch-zstd
build-multiarch-zstd:
	@echo "Building multi-architecture image with ZSTD support..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-f Dockerfile.zstd-system \
		-t $(IMAGE_NAME):$(VERSION)-zstd \
		-t $(IMAGE_NAME):latest-zstd \
		--push .
	@echo "✅ Multi-arch ZSTD build complete!"

# Build specific version
.PHONY: build-version
build-version:
	@echo "Building version $(VERSION) for $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(VERSION) \
		--push .

# Single architecture builds
.PHONY: build-local
build-local:
	@echo "Building for current architecture only..."
	docker build -t $(IMAGE_NAME):local .

.PHONY: build-amd64
build-amd64:
	@echo "Building for AMD64 only..."
	docker buildx build \
		--platform linux/amd64 \
		-t $(IMAGE_NAME):amd64 \
		--push .

.PHONY: build-arm64  
build-arm64:
	@echo "Building for ARM64 only..."
	docker buildx build \
		--platform linux/arm64 \
		-t $(IMAGE_NAME):arm64 \
		--push .

# Setup buildx (run once)
.PHONY: setup-buildx
setup-buildx:
	@echo "Setting up Docker buildx for multi-architecture builds..."
	-docker buildx create --name multiarch_builder --use --bootstrap
	docker buildx inspect --bootstrap
	@echo "✅ Buildx setup complete!"

# Development commands
.PHONY: run
run:
	@echo "Running application locally..."
	cargo run --bin hello-world

.PHONY: test
test:
	@echo "Running tests..."
	cargo test

.PHONY: check
check:
	@echo "Checking code..."
	cargo check
	cargo clippy -- -D warnings
	cargo fmt --check

# Verification commands
.PHONY: verify-manifest
verify-manifest:
	@echo "Verifying multi-architecture manifest..."
	docker buildx imagetools inspect $(IMAGE_NAME):latest

.PHONY: test-image
test-image:
	@echo "Testing Docker image..."
	@echo "Starting container on port 9999..."
	@echo "Test with: curl http://localhost:9999"
	docker run --rm -p 9999:9999 $(IMAGE_NAME):latest

# Cleanup
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	cargo clean
	-docker rmi $(IMAGE_NAME):local 2>/dev/null || true
	@echo "✅ Cleanup complete!"

# Alternative using build script
.PHONY: build-script
build-script:
	@echo "Using build script..."
	./build-multiarch.sh

.PHONY: build-script-zstd
build-script-zstd:
	@echo "Using build script with ZSTD..."
	./build-multiarch.sh --zstd --version $(VERSION)

# Quick commands (aliases)
.PHONY: build push
build: build-multiarch
push: build-multiarch

# Show current configuration
.PHONY: info
info:
	@echo "Configuration:"
	@echo "  IMAGE_NAME: $(IMAGE_NAME)"
	@echo "  VERSION: $(VERSION)"
	@echo "  PLATFORMS: $(PLATFORMS)"
	@echo ""
	@echo "Docker buildx status:"
	@docker buildx ls 2>/dev/null || echo "  Buildx not set up. Run 'make setup-buildx'"