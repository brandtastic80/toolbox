# Quick Start Guide

## Build & Deploy jq-kcat Toolbox

### Option 1: Using the build script (Recommended)

```bash
# Build, push, and update pod.yaml in one command
./build.sh docker.io/brandtastic80 latest push

# Then deploy
kubectl apply -f jq-kcat/pod.yaml
```

### Option 2: Manual steps

```bash
# 1. Create Buildx
docker buildx create --name multiplatform-builder --use

# 2. Build and push multi-platform image
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t docker.io/brandtastic80/jq-kcat:latest \
  --push .

# 3. Update pod.yaml
# Edit jq-kcat/pod.yaml and replace:
#   <your-registry>/jq-kcat:latest
# with:
#   docker.io/brandtastic80/jq-kcat:latest

# 4. Deploy to Kubernetes
kubectl apply -f jq-kcat/pod.yaml

# 5. Exec into the pod
kubectl exec -it toolbox-jq-kcat -- /bin/bash
```

## Common Use Cases

### 1. Debug Kafka Messages

```bash
# Inside the pod:
# List topics
kcat -b kafka-broker:9092 -L

# Consume and format JSON
kcat -b kafka-broker:9092 -t my-topic -C -o end -c 10 | jq '.'

# Filter specific events
kcat -b kafka-broker:9092 -t my-topic -C | jq 'select(.status == "error")'
```

### 2. Process Kubernetes JSON Output

```bash
# From outside the pod:
kubectl get pods -o json | kubectl exec -i toolbox-jq-kcat -- jq '.items[].metadata.name'

# Inside the pod:
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, status: .status.conditions[-1].type}'
```

### 3. Copy Files for Processing

```bash
# Copy JSON file to pod
kubectl cp data.json toolbox-jq-kcat:/workspace/data.json

# Process inside pod
kubectl exec -it toolbox-jq-kcat -- jq '.[] | select(.active == true)' /workspace/data.json

# Copy results back
kubectl cp toolbox-jq-kcat:/workspace/output.json ./output.json
```

## Cleanup

```bash
# Delete the pod
kubectl delete pod toolbox-jq-kcat

# Or delete using the manifest
kubectl delete -f jq-kcat/pod.yaml
```

## Tips

- The pod uses `restartPolicy: Never` so it won't restart if it exits
- Resource limits are set conservatively - adjust in pod.yaml if needed
- Use `kubectl logs toolbox-jq-kcat` if the pod fails to start
- Set `KAFKA_BROKERS` env var in pod.yaml to avoid typing it repeatedly
