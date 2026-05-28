#!/bin/bash

print_separator() {
    printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'
}

if [ "$1" == "print_separator" ]; then
    print_separator
fi
