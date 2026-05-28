#!/bin/bash

clear_docker_cache() {
    sudo docker rm -f local-cache
    sudo rm -rf /var/lib/docker-cache
}

print_docker_cache(){
    echo "docker-cache:"
    sudo ls -l /var/lib/docker-cache/docker/registry/v2/repositories/ 2>/dev/null || echo "null"
}

echo "setup docker cache"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo docker run -d -p 127.0.0.1:5000:5000 \
  --name local-cache \
  -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
  -v /var/lib/docker-cache:/var/lib/registry \
  --restart always \
  registry:2

sudo cat "$DIR/daemon.json" | sudo tee /etc/docker/daemon.json > /dev/null

sudo systemctl restart docker
