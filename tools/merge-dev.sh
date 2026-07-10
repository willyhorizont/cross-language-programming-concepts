# ! make sure run this command after finish running last-commit.dev.sh !!!!
git switch main
git pull origin main
git merge dev
git push origin main

git branch -d dev
git push origin --delete dev
