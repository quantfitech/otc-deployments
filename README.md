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


# Helm notes:

create/update the repo index

    $ helm repo index fantastic-charts/ --url https://fantastic-charts.storage.googleapis.com

create a repo and push it to an OCI registry repository

    $ helm create demo
    Creating demo

    $ helm package demo
    Successfully packaged chart and saved it to: /tmp/demo-0.1.0.tgz

    $ echo "mypass" | helm registry login r.example.com -u myuser --password-stdin
    Login Succeeded

    $ helm push demo-0.1.0.tgz oci://r.example.com/myuser
    Pushed: r.example.com/myuser/demo:0.1.0
    Digest: sha256:7ed393daf1ffc94803c08ffcbecb798fa58e786bebffbab02da5458f68d0ecb0
