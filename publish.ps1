# Pushes main and moves the v1 tag to point at it in one step -- this is the
# step that gets forgotten under a plain "git push", which is exactly what
# broke a real client integration once already (see README.md's
# "Publishing an update" section for the incident).
#
# Usage: after committing your changes locally, run:
#   .\publish.ps1
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

Write-Host "Pushing main..."
git push origin main

$short = git rev-parse --short main
Write-Host "Moving v1 -> $short..."
git tag -f v1 main
git push origin v1 --force

$msg = git log -1 --format=%s main
Write-Host "Done. v1 now points at $short ($msg)."
