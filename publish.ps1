# Pushes main and moves the v1 tag to point at it in one step -- this is the
# step that gets forgotten under a plain "git push", which is exactly what
# broke a real client integration once already (see README.md's
# "Publishing an update" section for the incident).
#
# Deliberately does NOT set $ErrorActionPreference = "Stop". git writes its
# normal, successful progress output (e.g. "To https://github.com/...") to
# stderr -- that's documented git behavior, not an error -- and PowerShell
# treats ANY stderr text from a native command as a terminating error under
# "Stop", regardless of exit code. That combination is almost certainly why
# this script failed the first time even though the underlying git commands
# themselves worked fine when run directly. Exit codes are checked
# explicitly below instead, which is the actual signal that matters.
#
# Usage: after committing your changes locally, run:
#   .\publish.ps1

function Invoke-Git {
    param([Parameter(Mandatory)][string[]]$GitArgs)
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed (exit code $LASTEXITCODE)"
    }
}

Set-Location $PSScriptRoot

Write-Host "Pushing main..."
Invoke-Git -GitArgs @("push", "origin", "main")

$short = git rev-parse --short main
Write-Host "Moving v1 -> $short..."
Invoke-Git -GitArgs @("tag", "-f", "v1", "main")
Invoke-Git -GitArgs @("push", "origin", "v1", "--force")

$msg = git log -1 --format=%s main
Write-Host "Done. v1 now points at $short ($msg)."
