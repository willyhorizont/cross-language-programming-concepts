#!/bin/bash

SD=$(dirname "$(realpath "$0")")
RD=$(realpath "$SD/..")
V="2.10.4" # ! DON'T FORGET TO CHANGE VERSION BEFORE RUNNING !!!!
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
add willyhorizont/c/gcc:16.1.0-trixie Dockerfile;
update languages.json, add willyhorizont/c/gcc:16.1.0-trixie docker image;
update some runner.sh, add start docker before docker build;
update runner.c, add lgc; add docker build;
update cross-language-features.c, replace manual memory management with boehm garbage collector gc.h;
update xl.h, replace manual memory management with boehm garbage collector gc.h;
move old runner.c to archieved;
move old cross-language-features.c to archieved;
move old xl.h to archieved;
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
