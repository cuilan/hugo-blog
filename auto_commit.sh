#!/bin/bash

echo -e "\033[0;32mAuto commit and push to GitHub...\033[0m"

# delete public folder.

# Add changes to git.
git add .

# Commit changes.
msg="auto commit and push by zhangyan on `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

