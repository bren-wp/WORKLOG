#!/usr/bin/env bash
set -euo pipefail

flutter create \
  --org com.brendigo \
  --project-name worklog \
  --platforms android,ios \
  .

python3 tool/configure_platforms.py
flutter pub get
echo "WORKLOG Android/iOS platforme su pripremljene."
