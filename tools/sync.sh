#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
rm -rf "$HOME/willyhorizont.github.io/cross-language-programming-concepts"
mkdir -p "$HOME/willyhorizont.github.io/cross-language-programming-concepts/"
cp -r "$RD/." "$HOME/willyhorizont.github.io/cross-language-programming-concepts/"
