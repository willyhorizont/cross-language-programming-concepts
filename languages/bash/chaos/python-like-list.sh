#!/bin/bash

(
    declare -a buah=( "apel" "jeruk" )
    # declare -a buah=( $(echo '["apple", "jeruk"]' | jq -r '.[]') )
    buah+=( "mangga" )
    echo "${buah[1]}"  # Output: jeruk
    echo "${#buah[@]}" # Output: 3
    echo "${buah[@]:1:2}" # Output: jeruk mangga

    for item in "${buah[@]}"; do
        echo "Buah: $item"
    done

    for i in "${!buah[@]}"; do
        echo "Indeks ke-$i berisi buah: ${buah[$i]}"
    done

    for (( i=0; i<total_item; i++ )); do
        echo "Item posisi $i adalah ${buah[$i]}"
    done
)