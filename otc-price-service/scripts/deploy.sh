#!/bin/bash

set -e
s
required_vars=(
    "DB_HOST"
    "DB_USER"
    "DB_PASSWORD"
    "DB_NAME"
    "REDIS_HOST"
    "REDIS_PASSWORD"
    "GITHUB_USERNAME"
    "GITHUB_TOKEN"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

echo "Creating Kubernetes secrets..."
kubectl create secret generic otc-price-service-db-password \
    --from-literal=password="$DB_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret docker-registry ghcr-secret \
    --docker-server=ghcr.io \
    --docker-username="$GITHUB_USERNAME" \
    --docker-password="$GITHUB_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Updating Helm values..."
cat > helm/values-gcp.yaml << EOF
image:
  repository: ghcr.io/quantfitech/otc-price-service
  tag: v1.4.0
  pullPolicy: IfNotPresent

imagePullSecrets:
  - name: ghcr-secret

serviceAccount:
  create: true
  name: otc-price-service

service:
  type: ClusterIP
  port: 8000

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80

env:
  DB_HOST: $DB_HOST
  DB_PORT: 3306
  DB_USER: $DB_USER
  DB_PASSWORD: "{{ .Values.dbPassword }}"
  DB_NAME: $DB_NAME
  REDIS_HOST: $REDIS_HOST
  REDIS_PORT: 6379
  REDIS_PASSWORD: $REDIS_PASSWORD
EOF

echo "Deploying with Helm..."
helm upgrade --install otc-price-service ./helm/otc-price-service -f ./helm/values-gcp.yaml

echo "Deployment completed!"
echo "Check the status with: kubectl get pods" 