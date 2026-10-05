#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="2.10.9" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!!
T=$(date "+%d %b %Y @ %I:%M %p")
cd "$RD" || exit

LID="javascript-or-typescript"
IMG=$("$RD/tools/utils.sh" --get-docker-image $LID 2>/dev/null)

python3 "$RD/tools/npm-version.py" "$V" "$RD"

H="
[Last updated: $T][version: $V]
"
H=$(sed -e '/./,$!d' <<< "$H")
# ! DON'T FORGET TO CHANGE COMMIT MESSAGE BEFORE RUNNING !!!!
M="
update base-runner.sh, add c syntax highlighter;
update languages.json, update c syntax highlighter;
update .vscode settings.json, update c syntax highlighter;
update c, replace Xl* to var macro;
"
M=$(sed -e '/./,$!d' <<< "$M")
M="$H
$M"
touch "$RD/changelog.txt" && awk -v msg="$M" 'BEGIN {print msg; print ""} {print}' "$RD/changelog.txt" > "$RD/changelog.tmp" && mv "$RD/changelog.tmp" "$RD/changelog.txt"
python3 "$RD/tools/generate-readme.py"
git add changelog.txt
git add package-lock.json
git add package.json
git add .
git commit -m "$M"
git tag -d "$V" 2>/dev/null
git tag -a "$V" -m "$M"
git push origin main
git push origin --tags

sudo -p "$L
Enter password to stop docker container: " systemctl stop --no-block docker.service containerd.service 2>/dev/null
