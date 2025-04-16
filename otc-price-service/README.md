# OTC Price Service Deployment

This repository contains the deployment configuration for the OTC Price Service.

## Prerequisites

- Kubernetes cluster (GKE recommended)
- Helm 3.x
- kubectl configured with cluster access
- Access to the container registry (ghcr.io)
- MySQL database instance
- Redis instance

## Configuration

### Environment Variables

The following environment variables need to be configured in `helm/values-gcp.yaml`:

```yaml
env:
  DB_HOST: <mysql-host>
  DB_PORT: 3306
  DB_USER: <mysql-user>
  DB_PASSWORD: <mysql-password>
  DB_NAME: otcdb
  REDIS_HOST: <redis-host>
  REDIS_PORT: 6379
  REDIS_PASSWORD: <redis-password>
```

### Secrets

Create the following Kubernetes secrets:

```bash
kubectl create secret generic otc-db-password --from-literal=password=<mysql-password>
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
helm upgrade --install otc-price-service ./helm/otc-price-service -f ./helm/values-gcp.yaml
```

### Using deploy.sh Script

The repository includes a deployment script (`scripts/deploy.sh`) that automates the deployment process. To use it:

1. Set the required environment variables:
```bash
export DB_HOST="<mysql-host>"
export DB_USER="<mysql-user>"
export DB_PASSWORD="<mysql-password>"
export DB_NAME="otcdb"
export REDIS_HOST="<redis-host>"
export REDIS_PASSWORD="<redis-password>"
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

## Support

For support, contact: denis@coinmerce.io 