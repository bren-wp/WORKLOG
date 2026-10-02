#!/usr/bin/env bash
set -euo pipefail

flutter create \
  --org com.brendigo \
  --project-name worklog \
  --platforms android,ios \
  .

flutter pub get
echo "WORKLOG Android/iOS platforme su pripremljene."
