#!/usr/bin/env bash

PROJECT_ROOT=$(realpath "$(dirname "$0")/../../..")
TF_DIR="terraform"
ls "${PROJECT_ROOT}/${TF_DIR}"
# terraform -chdir="${TF_DIR}" plan