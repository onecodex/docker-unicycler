#!/bin/bash

set -euo pipefail

image=$(cat IMAGE)

docker build --tag ${image} .
