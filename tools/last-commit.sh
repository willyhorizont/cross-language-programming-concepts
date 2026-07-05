#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="2.7.0"
T=$(date "+%d %b %Y @ %I:%M %p")
M="
[Last updated: $T]
version $V:
BIG repo restructure;
move language-specific-extensions-installer to github.com/willyhorizont/auto-install-vscode-extensions-for-opened-file;
update utils.sh, add install_auto_install_vscode_extensions_for_opened_file_vscode_extension;
cp last-commit.txt las-commit.sh

"
M=$(sed -e '/./,$!d' <<< "$M")
awk -v msg="$M" 'BEGIN {print msg; print ""} {print}' "$RD/changelog.txt" > "$RD/changelog.tmp" && mv "$RD/changelog.tmp" "$RD/changelog.txt"
python3 "$RD/tools/generate-readme.py"
npm version "$V" --no-git-tag-version
git add .
git commit -m "$M"
git tag -d "$V" 2>/dev/null
git tag -a "$V" -m "$M"
git push origin main -f
git push origin --tags -f
