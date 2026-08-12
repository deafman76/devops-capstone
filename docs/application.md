# Application Runtime Contract

## Team Member 1 — Presentation Web App

This document defines the runtime contract for the presentation application and NGINX reverse proxy.

## 1. Application

The application is a static presentation SPA served by NGINX.

Application files:

- `app/index.html` — main presentation
- `app/health.html` — health endpoint
- `app/version.json` — build and deployment metadata

### Dockerfile

`docker/Dockerfile`

### Build context

Build from the repository root:

```bash
docker build -f docker/Dockerfile -t <image-tag> .
