# Roaming Bee Toolbox 🧰

A collection of Docker images and Kubernetes manifests for common debugging and development tools.

## Overview

This repository contains containerized utilities that are frequently needed for debugging, troubleshooting, and development work in Kubernetes environments. Each tool is packaged as a lightweight Docker image that can be deployed as a pod when needed.

## Tools Included

### jq-kcat
A debugging container with:
- **jq**: Command-line JSON processor for parsing and manipulating JSON data
- **kcat** (formerly kafkacat): Generic command-line non-JVM Apache Kafka producer and consumer

Perfect for debugging Kafka topics and processing JSON streams in Kubernetes.

## Repository Structure

```
.
├── README.md
├── jq-kcat/
│   ├── Dockerfile
│   └── pod.yaml
└── [future tools]/
```

## Quick Start

### Building the Image

```bash
# Navigate to the tool directory
cd jq-kcat

# Build the image
docker build -t <your-registry>/jq-kcat:latest .

# Push to your registry
docker push <your-registry>/jq-kcat:latest
```

### Deploying to Kubernetes

```bash
# Update the image reference in pod.yaml to match your registry
kubectl apply -f pod.yaml

# Exec into the pod
kubectl exec -it toolbox-jq-kcat -- /bin/bash
```

## Usage Examples

### Using jq

```bash
# Pretty print JSON
echo '{"name":"toolbox","version":"1.0"}' | jq '.'

# Extract specific field
kubectl get pods -o json | jq '.items[].metadata.name'

# Filter and transform
cat data.json | jq '.[] | select(.status == "active")'
```

### Using kcat

```bash
# List Kafka topics
kcat -b kafka-broker:9092 -L

# Consume from a topic
kcat -b kafka-broker:9092 -t my-topic -C

# Produce to a topic
echo "test message" | kcat -b kafka-broker:9092 -t my-topic -P

# Consume and parse JSON with jq
kcat -b kafka-broker:9092 -t my-topic -C | jq '.'
```

## Configuration

### Environment Variables

The pod manifests support the following environment variables:

- `KAFKA_BROKERS`: Comma-separated list of Kafka broker addresses
- `KAFKA_TOPIC`: Default Kafka topic to work with

### Persistent Storage

To persist data or configuration files, you can mount volumes by modifying the pod.yaml:

```yaml
volumes:
  - name: config
    configMap:
      name: my-config
volumeMounts:
  - name: config
    mountPath: /config
```

## Development

### Adding New Tools

1. Create a new directory for your tool
2. Add a Dockerfile with the required utilities
3. Create a corresponding pod.yaml manifest
4. Update this README with usage instructions

### Best Practices

- Keep images lightweight (use Alpine base when possible)
- Pin specific versions for reproducibility
- Include only essential tools in each image
- Add appropriate labels to images and pods
- Document all environment variables and usage examples

## Contributing

This is a personal toolbox, but feel free to fork and customize for your own needs!

## License

MIT License - Use freely for personal or commercial projects

## Troubleshooting

### Pod won't start
- Check image pull secrets if using a private registry
- Verify the image name and tag are correct
- Check pod logs: `kubectl logs toolbox-jq-kcat`

### Connection issues
- Ensure network policies allow traffic to target services
- Verify service endpoints: `kubectl get endpoints`
- Check DNS resolution from within the pod

## Useful Commands

```bash
# Check if pod is running
kubectl get pod toolbox-jq-kcat

# Get shell access
kubectl exec -it toolbox-jq-kcat -- /bin/bash

# Copy files to/from pod
kubectl cp local-file.json toolbox-jq-kcat:/tmp/file.json
kubectl cp toolbox-jq-kcat:/tmp/output.json ./output.json

# Delete the pod
kubectl delete pod toolbox-jq-kcat
```

## Future Additions

Planned tools to add:
- [ ] curl + httpie for HTTP debugging
- [ ] PostgreSQL client (psql)
- [ ] Redis client (redis-cli)
- [ ] MongoDB client (mongosh)
- [ ] Network tools (netcat, nmap, tcpdump)
- [ ] Git + SSH for repository operations

---

**Note**: Remember to update image references in pod manifests to point to your Docker registry before deploying.
