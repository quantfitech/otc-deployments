# OTC API Service Deployment

This repository contains the deployment configuration for the OTC API Service.

## Prerequisites

- Kubernetes cluster (GKE recommended)
- Helm 3.x
- kubectl configured with cluster access
- Access to the container registry (ghcr.io)
- PostgreSQL database instance
- Redis instance (for caching)

## Configuration

### Environment Variables

The following environment variables need to be configured in `helm/values-gcp.yaml`:

```yaml
env:
  DB_HOST: <postgres-host>
  DB_PORT: 5432
  DB_USER: <postgres-user>
  DB_PASSWORD: <postgres-password>
  DB_NAME: otcapi
  REDIS_HOST: <redis-host>
  REDIS_PORT: 6379
  REDIS_PASSWORD: <redis-password>
  JWT_SECRET: <jwt-secret>
  API_KEY: <api-key>
```

### Secrets

Create the following Kubernetes secrets:

```bash
kubectl create secret generic otc-api-db-password --from-literal=password=<postgres-password>
kubectl create secret generic otc-api-jwt-secret --from-literal=secret=<jwt-secret>
kubectl create secret generic otc-api-key --from-literal=key=<api-key>
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<github-username> \
  --docker-password=<github-token>
```

## Deployment

### Manual Deployment

1. Update the values in `helm/values-gcp.yaml` with your configuration
2. Deploy using Helm:

```bash
helm upgrade --install otc-api ./helm/otc-api -f ./helm/values-gcp.yaml
```

### Using deploy.sh Script

The repository includes a deployment script (`scripts/deploy.sh`) that automates the deployment process. To use it:

1. Set the required environment variables:
```bash
export DB_HOST="<postgres-host>"
export DB_USER="<postgres-user>"
export DB_PASSWORD="<postgres-password>"
export DB_NAME="otcapi"
export REDIS_HOST="<redis-host>"
export REDIS_PASSWORD="<redis-password>"
export JWT_SECRET="<jwt-secret>"
export API_KEY="<api-key>"
export GITHUB_USERNAME="<github-username>"
export GITHUB_TOKEN="<github-token>"
```

2. Make the script executable:
```bash
chmod +x scripts/deploy.sh
```

3. Run the deployment script:
```bash
./scripts/deploy.sh
```

The script will:
- Validate all required environment variables
- Create necessary Kubernetes secrets
- Generate the Helm values file
- Deploy the service using Helm
- Show deployment status

## Verification

Check the deployment status:

```bash
kubectl get pods
kubectl get services
```

## Troubleshooting

Common issues and solutions:

1. Image pull errors:
   - Verify the container registry credentials
   - Check if the image tag exists

2. Database connection issues:
   - Verify database credentials
   - Check network connectivity between cluster and database

3. Redis connection issues:
   - Verify Redis credentials
   - Check network connectivity between cluster and Redis

4. API authentication issues:
   - Verify JWT secret and API key
   - Check if the secrets are properly mounted

## Support

For support, contact: denis@coinmerce.io 