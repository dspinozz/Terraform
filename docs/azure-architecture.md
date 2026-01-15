# Azure Architecture

## Overview

The Azure infrastructure demonstrates cloud adaptability by hosting the mortgage-calculator application on Azure Container Apps, showcasing the ability to work with multiple cloud providers.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Azure Subscription                                │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    Resource Group: portfolio-dev-rg                  │   │
│   │                                                                     │   │
│   │   ┌─────────────────────────────────────────────────────────────┐   │   │
│   │   │               Container Apps Environment                     │   │   │
│   │   │                                                             │   │   │
│   │   │   ┌─────────────────────────────────────────────────────┐   │   │   │
│   │   │   │            mortgage-calculator                       │   │   │   │
│   │   │   │                                                     │   │   │   │
│   │   │   │   Container: Python/Flask                           │   │   │   │
│   │   │   │   CPU: 0.25 cores                                   │   │   │   │
│   │   │   │   Memory: 0.5Gi                                     │   │   │   │
│   │   │   │   Port: 8080                                        │   │   │   │
│   │   │   │                                                     │   │   │   │
│   │   │   │   Scaling: 0-3 replicas                             │   │   │   │
│   │   │   │   Scale trigger: HTTP (50 concurrent)               │   │   │   │
│   │   │   │                                                     │   │   │   │
│   │   │   └─────────────────────────────────────────────────────┘   │   │   │
│   │   │                                                             │   │   │
│   │   │   ┌─────────────────────────────────────────────────────┐   │   │   │
│   │   │   │         Log Analytics Workspace                      │   │   │   │
│   │   │   │         (Container logs & metrics)                   │   │   │   │
│   │   │   └─────────────────────────────────────────────────────┘   │   │   │
│   │   │                                                             │   │   │
│   │   └─────────────────────────────────────────────────────────────┘   │   │
│   │                                                                     │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     │ HTTPS
                                     ▼
                    https://mortgage-calculator.xxx.azurecontainerapps.io
```

## Component Details

### Resource Group

| Property | Value |
|----------|-------|
| Name | portfolio-dev-rg |
| Location | East US |
| Purpose | Contains all Azure resources for the project |

### Container Apps Environment

| Property | Value |
|----------|-------|
| Name | mortgage-calculator-env |
| Type | Consumption |
| Logging | Log Analytics Workspace |

### Container App

| Property | Value |
|----------|-------|
| Name | mortgage-calculator |
| Image | ghcr.io/dspinozz/mortgage-calculator:latest |
| CPU | 0.25 cores |
| Memory | 0.5Gi |
| Ingress | External (HTTPS) |
| Min Replicas | 0 (scale to zero) |
| Max Replicas | 3 |

## Scaling Configuration

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Auto-Scaling                                      │
│                                                                             │
│   Trigger: HTTP concurrent requests                                         │
│   Threshold: 50 requests                                                    │
│                                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                  │
│   │  0 replicas │ ──► │  1 replica  │ ──► │  3 replicas │                  │
│   │   (idle)    │     │  (normal)   │     │   (peak)    │                  │
│   └─────────────┘     └─────────────┘     └─────────────┘                  │
│                                                                             │
│   Scale to zero when:                                                       │
│   - No HTTP requests for 5 minutes                                          │
│                                                                             │
│   Scale up when:                                                            │
│   - Concurrent requests > 50 per replica                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Networking

Container Apps handles networking automatically:

- **Ingress**: Managed HTTPS with automatic TLS
- **Domain**: Auto-generated `*.azurecontainerapps.io`
- **Custom Domain**: Optional (not configured by default)

```
Internet ──► Azure Front Door ──► Container App Ingress ──► Container
                                        │
                                   HTTPS + TLS
                                   (managed)
```

## Health Probes

| Probe Type | Path | Interval | Timeout |
|------------|------|----------|---------|
| Liveness | /health | 10s | 5s |
| Readiness | /health | 10s | 5s |

## Logging

All logs are sent to Log Analytics Workspace:

```kusto
// Query container logs
ContainerAppConsoleLogs
| where ContainerAppName_s == "mortgage-calculator"
| order by TimeGenerated desc
| take 100

// Query HTTP requests
ContainerAppSystemLogs
| where Category == "IngressLogs"
| order by TimeGenerated desc
```

## Cost Analysis

### Consumption-based Pricing

| Resource | Metric | Free Tier | Cost After |
|----------|--------|-----------|------------|
| vCPU | per second | 180,000 sec/month | $0.000024/sec |
| Memory | per GiB-second | 360,000 GiB-sec/month | $0.000003/sec |
| Requests | per million | 2 million/month | $0.40/million |

### Estimated Costs

| Scenario | Monthly Cost |
|----------|-------------|
| Dev (scale to zero, low traffic) | ~$0-5 |
| Moderate traffic (1 replica average) | ~$10-15 |
| Production (1-3 replicas) | ~$15-30 |

## Why Azure Container Apps?

### Comparison with AWS ECS

| Feature | AWS ECS | Azure Container Apps |
|---------|---------|---------------------|
| Scaling | Manual/Auto | Built-in, scale to zero |
| Pricing | Per-hour | Per-second, consumption |
| Networking | VPC required | Managed |
| Load balancing | ALB required | Built-in |
| Complexity | Higher | Lower |

### Benefits for Portfolio

1. **Demonstrates adaptability**: Shows ability to work with multiple clouds
2. **Simple deployment**: Less infrastructure to manage
3. **Cost-effective**: Scale to zero for demos
4. **Modern platform**: Serverless containers

## Azure vs AWS Summary

| Aspect | AWS (Primary) | Azure (Secondary) |
|--------|--------------|-------------------|
| Projects | 5 applications | 1 application |
| Services | ECS, ALB, VPC, Amplify | Container Apps |
| Complexity | Full control | Managed platform |
| Purpose | Deep expertise | Adaptability signal |
