#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="2.7.2" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!!
T=$(date "+%d %b %Y @ %I:%M %p")
npm version "$V" --no-git-tag-version
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
[Last updated: $T]
version $V:
completely remove language specific extension
no install all, no partial install, no custom built, all done
no syntax highlighter, no icon theme
move sudo commands to create setup-environtment.sh
"
M=$(sed -e '/./,$!d' <<< "$M")
awk -v msg="$M" 'BEGIN {print msg; print ""} {print}' "$RD/changelog.txt" > "$RD/changelog.tmp" && mv "$RD/changelog.tmp" "$RD/changelog.txt"
"$RD/languages/python/run.sh" "$RD/tools/generate-readme.py" 
git add .
git commit -m "$M"
git tag -d "$V" 2>/dev/null
git tag -a "$V" -m "$M"
git push origin main -f
git push origin --tags -f
