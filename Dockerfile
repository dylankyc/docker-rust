# Multi-stage build for Axum application
FROM rust:1.90.0 AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files
COPY Cargo.toml Cargo.lock ./

# Create dummy source files for dependency caching
RUN mkdir -p src/bin && \
    echo "fn main() {}" > src/bin/helloworld.rs && \
    echo "pub fn lib() {}" > src/lib.rs

# Build dependencies
RUN cargo build --release

# Remove dummy files
RUN rm -rf src

# Copy actual source code
COPY src/ src/

# Build the application
RUN touch src/bin/helloworld.rs && \
    touch src/lib.rs && \
    cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary
COPY --from=builder /app/target/release/helloworld /app/server

# Create non-root user for security
RUN useradd -r -u 1000 appuser && \
    chown appuser:appuser /app/server

USER appuser

# Expose port
EXPOSE 9999

# Set entrypoint
ENTRYPOINT ["/app/server"]