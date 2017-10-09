#!/bin/bash
set -e

# Commit author
JAVADOC_AUTHOR="Travis CI"
JAVADOC_EMAIL="travis@travis-ci.org"

# Which remote to push to
REMOTE=$(git config remote.origin.url)
PUSH_REMOTE=${REPO/https:\/\/github.com\//https:\/\/${TRAVIS_GITHUB_TOKEN}@github.com:}
REMOTE_BRANCH="gh-pages"

BUILT_JAVADOC=$(pwd)/build/docs/javadoc
# Tags are prefixed with 'v', remove that
JAVADOC_VERSION="${TRAVIS_TAG:1}"
# Javadoc ends up in <major>.x
JAVADOC_TARGET_DIR="${JAVADOC_VERSION:0:1}.x/javadoc/$JAVADOC_VERSION"
# It also gets added to a common javadoc/
JAVADOC_COMMON_DIR="javadoc"

# Grab the current pages branch, fetching instead of cloning
GH_PAGES_WORKDIR=$(mktemp -d)
pushd $GH_PAGES_WORKDIR
git init
git remote add -t $REMOTE_BRANCH -f origin $REMOTE
git checkout $REMOTE_BRANCH
git config user.name "Travis"
git config user.email "travis@travis-ci.org"

# Copy the javadoc
mkdir -p $JAVADOC_TARGET_DIR
cp -r $BUILT_JAVADOC/* $JAVADOC_TARGET_DIR

# Deploy to the 'javadoc' folder as well
cp -r $BUILT_JAVADOC/* $JAVADOC_COMMON_DIR

git add $JAVADOC_TARGET_DIR $JAVADOC_COMMON_DIR
git commit -m "javadoc: Update to $JAVADOC_VERSION"

# Push silently to prevent token leaking
git push --quiet $PUSH_REMOTE HEAD:gh-pages > /dev/null 2>&1
