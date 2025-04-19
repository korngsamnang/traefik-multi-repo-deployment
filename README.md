# Multi-Repo Node.js Deployment with GitLab CI/CD and Traefik

![Traefik](https://img.shields.io/badge/Traefik-2.10-blue)
![Node.js](https://img.shields.io/badge/Node.js-22-green)
![GitLab CI/CD](https://img.shields.io/badge/GitLab_CI/CD-✓-orange)

This repository demonstrates a pattern for deploying multiple Node.js applications to a server using GitLab CI/CD pipelines, with Traefik as a reverse proxy and HTTPS terminator.

## 📌 Overview

The solution consists of:

-   Separate repositories for each Node.js application (app-1, app-2)
-   A central deployment repository that orchestrates the infrastructure
-   Automated CI/CD pipelines for building and deploying applications
-   Traefik reverse proxy with automatic Let's Encrypt SSL certificates

### Key Features

-   **Independent deployments** - Each app can be updated independently
-   **Zero-downtime deployments** - Containers are updated without service interruption
-   **Automatic HTTPS** - Traefik handles SSL certificate generation and renewal
-   **CI/CD automation** - GitLab pipelines handle the entire deployment process
-   **Multi-repo architecture** - Applications can be developed and deployed separately

## 🏗️ Repository Structure

```
└── 📁traefik-multi-repo-deployment
    └── 📁app-1
        └── .gitlab-ci.yml
        └── Dockerfile
        └── index.js
        └── package.json
    └── 📁app-2
        └── .gitlab-ci.yml
        └── Dockerfile
        └── index.js
        └── package.json
    └── 📁deployment-repo
        └── .gitlab-ci.yml
        └── deploy.sh
        └── docker-compose.yml
```

## 🚀 How It Works

1. **Application Build Phase**:

    - When code is pushed to app-1 or app-2, GitLab CI:
        - Builds a Docker image
        - Pushes it to the container registry
        - Triggers the deployment pipeline

2. **Deployment Phase**:

    - The deployment repository receives the trigger with image details
    - Connects to the server via SSH
    - Updates the relevant application container using docker-compose
    - Traefik automatically routes traffic to the updated container

3. **Traefik Configuration**:
    - Acts as reverse proxy and load balancer
    - Automatically obtains and renews Let's Encrypt certificates
    - Routes traffic based on hostname (app1.example.com, app2.example.com)
    - Enables HTTP/2 and response compression

## ⚙️ Setup Instructions

### Prerequisites

-   GitLab account with CI/CD enabled
-   Server with Docker and Docker Compose installed
-   SSH access to the server
-   Domain names pointing to your server (e.g., app1.example.com, app2.example.com)

### 1. Configure Application Repositories

For each application (app-1, app-2):

1. Update the `.gitlab-ci.yml` with your registry details
2. Ensure the `Dockerfile` matches your application requirements
3. Set these CI/CD variables in GitLab:

    - `CI_REGISTRY_USER` - Container registry username
    - `CI_REGISTRY_PASSWORD` - Container registry password
    - `CI_REGISTRY` - Container registry URL
    - `CI_JOB_TOKEN` - GitLab job token to trigger deployment pipeline on the deployment repository
    - `CI_PROJECT_ID` - Project ID for the deployment repository

### 2. Configure Deployment Repository

-   Update `docker-compose.yml` with your:
    -   Domain names
    -   Let's Encrypt email
-   Set these CI/CD variables:
    -   `SSH_PRIVATE_KEY` - Private key for server access
    -   `PROJECT_DIR` - Deployment directory on server
    -   `CI_REGISTRY_USER_APP1`, `CI_REGISTRY_PASSWORD_APP1` - Registry credentials for app1
    -   `CI_REGISTRY_USER_APP2`, `CI_REGISTRY_PASSWORD_APP2` - Registry credentials for app2

### 3. Server Preparation

Ensure your server has:

-   Docker and Docker Compose installed
-   Ports 80 and 443 open
-   The project directory created (`/home/ubuntu/my-app` by default)

## 🔧 Customizing for Your Projects

1. **Adding More Applications**:

    - Duplicate the app-1 structure for new applications
    - Add a new service in `docker-compose.yml` with appropriate labels
    - Update the deployment triggers

2. **Environment Variables**:

    - Add environment variables to the `docker-compose.yml` services
    - Or use separate `.env` files for each environment

3. **Different Hostnames**:
    - Update the `traefik.http.routers.*.rule` labels in `docker-compose.yml`

## 🛠️ Troubleshooting

-   **SSL Certificate Issues**:

    -   Verify your domain points to the server
    -   Check Traefik logs: `docker logs traefik`
    -   Ensure `acme.json` has correct permissions (600)

-   **Deployment Failures**:

    -   Check GitLab pipeline logs
    -   Verify registry credentials are correct
    -   Ensure the SSH key has proper server access

-   **Application Not Reachable**:
    -   Verify containers are running: `docker ps`
    -   Check Traefik detected the services: `docker exec traefik traefik health`

## 🙏 Acknowledgements

-   Traefik for the excellent reverse proxy solution
-   GitLab for CI/CD infrastructure
-   Let's Encrypt for free SSL certificates
