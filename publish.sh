#!/usr/bin/env bash
# Pushes main and moves the v1 tag to point at it in one step -- this is the
# step that gets forgotten under a plain "git push", which is exactly what
# broke a real client integration once already (see README.md's
# "Publishing an update" section for the incident).
#
# Usage: after committing your changes locally, run:
#   ./publish.sh
set -euo pipefail

cd "$(dirname "$0")"

echo "Pushing main..."
git push origin main

echo "Moving v1 -> $(git rev-parse --short main)..."
git tag -f v1 main
git push origin v1 --force

echo "Done. v1 now points at $(git rev-parse --short main) ($(git log -1 --format=%s main))."
