#!/bin/bash
set -e

# Add node_modules/.bin to PATH
export PATH=$PATH:./node_modules/.bin

#### Running build - ####
export COMMIT_ID=$(git log --pretty="%h" --no-merges -1)
export COMMIT_DATE="$(git log --date=format:'%Y-%m-%d %H:%M:%S' --pretty="%cd" --no-merges -1)"

##### Print Environment Variables #####
printenv

rm -rf ./out

npm run build
