#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")

shopt -s globstar

for file in "$RD/languages"/**/run.sh; do
    if [ -f "$file" ]; then
        mv "$file" "$(dirname "$file")/runner.sh"
        echo "Sukses rename: $file -> runner.sh"
    fi
done
