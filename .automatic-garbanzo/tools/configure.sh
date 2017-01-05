#!/bin/bash

usage() {
        echo "$0 <owner> <repo>"
        echo
        echo "Installs webhook and automation user to a GH repository"
        echo
        echo "<owner> is the organization or user"
        echo "<repo> is the repository name"
}
if [ "$#" -ne 2 ]
then
        echo "incorrect number of arguments"
        usage
        exit 1
fi

owner=${1}
repo=${2}
base_url="https://api.github.com/repos"

if [ "$USER" == "" ] 
then
        export USER=$(whoami)
        echo "setting username to $USER"
fi
if [ "$PW" != "" ]
then
        credentials="${USER}:${PW}"
        echo "using password from environment variable"
else
        credentials="${USER}"
        echo "prompting for password"
fi

set -x
curl --user ${credentials} \
        -X POST \
        --data @webhook.json \
        ${base_url}/${owner}/${repo}/hooks

curl --user ${credentials} \
        -X PUT \
        --data \
          '{ "permissions": { "admin": false, "push": true, "pull": true }}' \
        ${base_url}/${owner}/${repo}/collaborators/btb-hutch
set +x

