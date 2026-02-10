FROM alpine:3.19

# Metadata
LABEL maintainer="Personal Toolbox"
LABEL description="Debugging container with jq and kcat (kafkacat)"
LABEL version="1.0"

# Install dependencies and tools
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    kcat \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Create a non-root user
RUN addgroup -g 1000 toolbox && \
    adduser -D -u 1000 -G toolbox toolbox

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER toolbox

# Default command - keep container running
CMD ["/bin/bash", "-c", "tail -f /dev/null"]
