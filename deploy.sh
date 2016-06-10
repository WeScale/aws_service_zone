#!/usr/bin/env bash

VAR_YAML_FILE=$1

if [ -z "$VAR_YAML_FILE" ]; then
    echo "Usage: deploy.sh \$PATH_TO_VAR_YAML_FILE"
    exit 1
fi

ansible-playbook ansible/deploy.yml -e@$1
