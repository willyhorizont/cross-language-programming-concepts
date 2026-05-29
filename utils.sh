#!/bin/bash

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

check_is_image_available() {
    local IMAGE_WITHOUT_VERSION="${1%%:*}"
    echo "IMAGE_WITHOUT_VERSION: $IMAGE_WITHOUT_VERSION"
    echo "docker.io/library/:"
    docker run -it --rm quay.io/skopeo/stable:v1.22.2 list-tags docker://docker.io/library/$IMAGE_WITHOUT_VERSION
    echo "ghcr.io:"
    docker run -it --rm quay.io/skopeo/stable:v1.22.2 list-tags docker://ghcr.io/$IMAGE_WITHOUT_VERSION
    echo "gcr.io:"
    docker run -it --rm quay.io/skopeo/stable:v1.22.2 list-tags docker://gcr.io/$IMAGE_WITHOUT_VERSION
    echo "quay.io:"
    docker run -it --rm quay.io/skopeo/stable:v1.22.2 list-tags docker://quay.io/$IMAGE_WITHOUT_VERSION
}

if [ "$1" == "print_separator" ]; then
    print_separator
fi

if [ "$1" == "check_is_image_available" ]; then
    check_is_image_available "$2"
fi
