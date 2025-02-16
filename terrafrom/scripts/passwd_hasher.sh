#!/bin/bash

password=$1
salt=$2
if [ -z "$password" ]; then
    echo "Usage: $0 <password> <salt>"
  exit 1
fi

# Generate hash from salt and password
hash=$(openssl passwd -6 -salt ${salt} ${password})

# Output the hash in JSON format so it can be used in Terraform
jq -n --arg hash "${hash}" '{"hashed_password":$hash}'
