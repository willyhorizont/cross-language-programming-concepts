#!/bin/bash

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

check_is_image_available() {
    local $IMAGE_WITHOUT_VERSION=$1
    docker run -it --rm quay.io/skopeo/stable list-tags docker://ghcr.io/$IMAGE_WITHOUT_VERSION
    docker run -it --rm quay.io/skopeo/stable list-tags docker://gcr.io/$IMAGE_WITHOUT_VERSION
    docker run -it --rm quay.io/skopeo/stable list-tags docker://quay.io/$IMAGE_WITHOUT_VERSION
}

if [ "$1" == "print_separator" ]; then
    print_separator
fi
