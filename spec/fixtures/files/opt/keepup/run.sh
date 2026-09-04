#!/usr/bin/env bash

set -e
curl -s -XPUT -H "x-api-token: secret" https://keepup.example.com/package-version -d @/opt/keepup/pkg.json
