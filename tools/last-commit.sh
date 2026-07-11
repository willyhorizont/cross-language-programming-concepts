#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="2.7.26" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!!
T=$(date "+%d %b %Y @ %I:%M %p")
\. "$HOME/.nvm/nvm.sh"
npm version "$V" --no-git-tag-version
git add .
H="
[Last updated: $T]
version $V:
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
finish update tcl runtime init;
"
M=$(sed -e '/./,$!d' <<< "$M")
M="$H
$M"
awk -v msg="$M" 'BEGIN {print msg; print ""} {print}' "$RD/changelog.txt" > "$RD/changelog.tmp" && mv "$RD/changelog.tmp" "$RD/changelog.txt"
git add .
"$RD/languages/python/run.sh" "$RD/tools/generate-readme.py" 
git add .
git commit -m "$M"
git tag -d "$V" 2>/dev/null
git tag -a "$V" -m "$M"
git push origin main -f
git push origin --tags -f
