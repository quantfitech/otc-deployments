# OTC Deployments

This repository contains deployment configurations for OTC microservices. Each service has its own directory with deployment manifests, scripts, and documentation.

## Structure

```
otc-deployments/
├── otc-price-service/      # OTC Price Service deployment
│   ├── helm/              # Helm charts and values
│   ├── scripts/           # Deployment scripts
│   └── docs/              # Documentation
└── README.md              # This file
```

## Services

### OTC Price Service
- Description: Service for managing OTC price calculations

## Adding New Services

To add a new service:

1. Create a new directory under `otc-deployments/`
2. Follow the same structure as existing services
3. Update this README with the new service information

## Common Prerequisites

All services require:
- Kubernetes cluster (GKE recommended)
- Helm 3.x
- kubectl configured with cluster access
- Access to the container registry (ghcr.io)

## Support

For support, contact: denis@coinmerce.io 