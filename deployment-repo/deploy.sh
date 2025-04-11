#!/bin/bash
set -e

# Transfer files and setup directory
scp -o StrictHostKeyChecking=no -i "$SSH_PRIVATE_KEY" \
  docker-compose.yml \
  ubuntu@13.229.251.210:"$PROJECT_DIR/"

ssh -o StrictHostKeyChecking=no -i "$SSH_PRIVATE_KEY" ubuntu@13.229.251.210 "
  set -e
  cd $PROJECT_DIR
  mkdir -p letsencrypt
  touch letsencrypt/acme.json
  chmod 600 letsencrypt/acme.json

  # Deploy Traefik first
  docker compose up -d --no-deps traefik

  # Deploy apps if their variables exist
  if [ -n \"${IMAGE_NAME_APP1:-}\" ] && [ -n \"${IMAGE_TAG_APP1:-}\" ]; then
    echo \"${CI_REGISTRY_PASSWORD_APP1:-}\" | docker login -u \"${CI_REGISTRY_USER_APP1:-}\" --password-stdin \"${CI_REGISTRY:-}\"
    docker pull \"${IMAGE_NAME_APP1}:${IMAGE_TAG_APP1}\" || true
    IMAGE_NAME_APP1=\"${IMAGE_NAME_APP1}\" IMAGE_TAG_APP1=\"${IMAGE_TAG_APP1}\" \
      docker compose up -d --no-deps app1
  fi

  if [ -n \"${IMAGE_NAME_APP2:-}\" ] && [ -n \"${IMAGE_TAG_APP2:-}\" ]; then
    echo \"${CI_REGISTRY_PASSWORD_APP2:-}\" | docker login -u \"${CI_REGISTRY_USER_APP2:-}\" --password-stdin \"${CI_REGISTRY:-}\"
    docker pull \"${IMAGE_NAME_APP2}:${IMAGE_TAG_APP2}\" || true
    IMAGE_NAME_APP2=\"${IMAGE_NAME_APP2}\" IMAGE_TAG_APP2=\"${IMAGE_TAG_APP2}\" \
      docker compose up -d --no-deps app2
  fi

  docker image prune -af
"