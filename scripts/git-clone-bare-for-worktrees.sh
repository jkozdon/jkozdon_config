#!/usr/bin/env bash
set -e

# based on https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/

# Examples of call:
# git-clone-bare-for-worktrees git@github.com:name/repo.git
# => Clones to a /repo directory
#
# git-clone-bare-for-worktrees git@github.com:name/repo.git my-repo
# => Clones to a /my-repo directory
#
# git-clone-bare-for-worktrees -b branch-name git@github.com:name/repo.git
# => Clones and checks out the specified branch

# Initialize variables
branch=""
url=""
name=""

# Parse options
while getopts "b:" opt; do
  case $opt in
    b) branch=$OPTARG ;;
    *) echo "Usage: $0 [-b branch] <repository> [directory]" >&2; exit 1 ;;
  esac
done
shift $((OPTIND -1))

# Get the repository URL and directory name
url=$1
basename=${url##*/}
name=${2:-${basename%.*}}

mkdir $name
cd "$name"

# Moves all the administrative git files (a.k.a $GIT_DIR) under .bare directory.
#
# Plan is to create worktrees as siblings of this directory.
# Example targeted structure:
# .bare
# main
# new-awesome-feature
# hotfix-bug-12
# ...
git clone --bare "$url" .bare
echo "gitdir: ./.bare" > .git

# Explicitly sets the remote origin fetch so we can fetch remote branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

# Gets all branches from origin
git fetch origin &> /dev/null

# Determine the branch to checkout
if [ -z "$branch" ]; then
    branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
  echo "No branch specified, defaulting to $branch"
fi

# Create a worktree for the specified or default branch
git worktree add "$branch" "origin/$branch"
