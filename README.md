# myco-bundled-action

Bundled, distributable build of the Myco PR Reviewer agent, packaged as a GitHub composite action.

This repo exists so pilot clients can consume the reviewer with a single line in their own
workflow — `uses: AbhishikaAgarwal/myco-bundled-action@v1` — without ever checking out or
seeing the private source (that lives in the `Zenith` repo). `dist/index.js` here is a
built artifact (via `@vercel/ncc`), not source to edit directly — make changes in `Zenith`
and re-publish here.

## Access

This repo is private. Each pilot client's CI needs read access to it — invite their GitHub
account/org as a collaborator (Settings → Collaborators) before they wire up the workflow
below, or their job will fail to resolve the `uses:` reference.

## Usage

```yaml
name: Myco PR Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  issues: write   # only needed if you use ticket_provider: github-issues

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: AbhishikaAgarwal/myco-bundled-action@v1
        with:
          pr_link: ${{ github.event.pull_request.html_url }}
          litellm_api_key: ${{ secrets.LLM_API_KEY }}
          # litellm_base_url defaults to https://api.openai.com/v1 — override if you're
          # using a different OpenAI-compatible provider or a LiteLLM proxy.
          # litellm_model defaults to gpt-4.1.
```

Bringing a raw Anthropic key instead of an OpenAI-compatible one? Set `llm_provider: anthropic`:

```yaml
      - uses: AbhishikaAgarwal/myco-bundled-action@v1
        with:
          pr_link: ${{ github.event.pull_request.html_url }}
          llm_provider: anthropic
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          # anthropic_model is optional — falls back to a sensible default.
```

(A raw Gemini key doesn't need this — Gemini has its own OpenAI-compatible endpoint, so it already works through the default `llm_provider: openai` path via `litellm_base_url`.)

`github_token` defaults to the workflow's automatic `secrets.GITHUB_TOKEN`, which is enough
for reviewing PRs in the same repo the workflow runs in (posting comments, and — if
`ticket_provider: github-issues` — filing issues there too). No GitHub App or extra token is
needed for the common case.

## Inputs

See [`action.yml`](./action.yml) for the full, current list with defaults — this is a summary.

| Input | Required | Default | Notes |
|---|---|---|---|
| `pr_link` | yes | — | Full PR (or compare) URL to review |
| `llm_provider` | no | `openai` | `openai` (any OpenAI-compatible endpoint) or `anthropic` (native Anthropic key) |
| `litellm_api_key` | if `llm_provider: openai` | — | Your LLM provider's API key |
| `litellm_base_url` | no | `https://api.openai.com/v1` | Any OpenAI-compatible endpoint |
| `litellm_model` | no | `gpt-4.1` | |
| `anthropic_api_key` | if `llm_provider: anthropic` | — | Native Anthropic API key |
| `anthropic_model` | no | — | Only used with `llm_provider: anthropic` |
| `validator_model` | no | same as the main model | Optional cheaper/faster model for the validator pass |
| `github_token` | no | `${{ github.token }}` | Only override for cross-repo scenarios |
| `min_severity` | no | `P3` | Lowest severity reported |
| `post_github_comments` | no | `true` | |
| `validate_findings` | no | `true` | Second-pass CONFIRMED/FALSE_POSITIVE/UNCERTAIN check |
| `ci_gate` | no | `true` | Fail the job on a merge-blocking confirmed finding |
| `gate_min_severity` | no | `P1` | Severity threshold for the gate |
| `ticket_provider` | no | — | `jira`, `github-issues`, or `dry-run` |
| `create_tickets_for` | no | `merge-blocking` | or `all-confirmed` |
| `metrics_endpoint` / `metrics_api_key` / `client_id` | no | — | Opt-in cross-client metrics reporting (counts + finding titles only — never file paths, root cause, fix text, or code) |

Jira-specific inputs (`jira_base_url`, `jira_email`, `jira_token`, `jira_project`,
`jira_issue_type`, `jira_labels`, `jira_assignee_account_id`) and GitHub-Issues-specific
inputs (`github_issue_labels`, `ticket_github_repo`) are only needed when using that ticket
provider.

## Publishing an update

From the `Zenith` repo:

```bash
npx @vercel/ncc build src/index.ts -o dist
```

Copy the resulting `dist/index.js` here, update `action.yml` if any input/env mapping
changed, commit, and tag a new version (e.g. `v1`, moved forward, or `v1.1`) so pinned
consumers pick it up deliberately.
