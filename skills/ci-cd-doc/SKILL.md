---
name: ci-cd-doc
description: Complete official documentation for integrating Claude Code with CI/CD and team platforms — GitHub Actions, GitLab CI/CD, Slack, managed GitHub Code Review, and GitHub Enterprise Server.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for running Claude Code inside CI/CD pipelines and team tools: GitHub Actions, GitLab CI/CD, Slack, the managed Code Review product, and GitHub Enterprise Server.

## Quick Reference

### Integration matrix

| Integration | Trigger | Where it runs | Auth |
|---|---|---|---|
| GitHub Actions | `@claude` mention, PR/issue events, cron | GitHub-hosted runners | `ANTHROPIC_API_KEY` secret, or Bedrock/Vertex via OIDC |
| GitLab CI/CD (beta) | Manual, MR event, webhook listener on `@claude` notes | Your GitLab runners | `ANTHROPIC_API_KEY` masked variable, or Bedrock/Vertex via OIDC/WIF |
| Slack | `@Claude` mention in a channel | Claude Code on the web (Anthropic infra) | Claude account linked to Slack + GitHub |
| Code Review (research preview) | PR open, every push, or `@claude review` | Anthropic infrastructure | Claude GitHub App installed by admin |
| GitHub Enterprise Server | Same as github.com features | Anthropic infra (GHES must be reachable) | Admin-created GitHub App on GHES |

### GitHub Actions — v1 action inputs

| Parameter | Description | Required |
|---|---|---|
| `prompt` | Instructions for Claude (plain text or a skill name) | No* |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

*Optional for issue/PR comments (responds to trigger phrase); **required only for direct Claude API.

### Beta → v1 migration

| Old beta input | New v1 input |
|---|---|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

Update `@beta` to `@v1` in your workflow. Defaults to Sonnet — set `--model claude-opus-4-6` in `claude_args` to use Opus.

### Common `claude_args` CLI flags

| Flag | Purpose |
|---|---|
| `--max-turns` | Maximum conversation turns (default 10) |
| `--model` | Model to use (e.g. `claude-sonnet-4-6`) |
| `--mcp-config` | Path to MCP configuration |
| `--allowedTools` | Comma-separated allowed tools (alias: `--allowed-tools`) |
| `--append-system-prompt` | Append custom instructions |
| `--debug` | Enable debug output |

### Minimal GitHub Actions workflow

```yaml
name: Claude Code
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

Fastest setup: run `/install-github-app` in the terminal (admin-only, Claude API users only).

### GitHub Actions — Bedrock / Vertex secrets

| Provider | Required secrets |
|---|---|
| Claude API | `ANTHROPIC_API_KEY` (+ optional `APP_ID`, `APP_PRIVATE_KEY` for a custom app) |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `APP_ID`, `APP_PRIVATE_KEY`; set `use_bedrock: "true"` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `APP_ID`, `APP_PRIVATE_KEY`; set `use_vertex: "true"` |

Bedrock model IDs include a region prefix (e.g. `us.anthropic.claude-sonnet-4-6`). For Vertex, set `CLOUD_ML_REGION` and `VERTEX_REGION_CLAUDE_4_5_SONNET`.

### GitLab CI/CD — minimal job

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk update && apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

Set `ANTHROPIC_API_KEY` as a masked CI/CD variable. Use `CI_JOB_TOKEN` (or a Project Access Token with `api` scope stored as `GITLAB_ACCESS_TOKEN`) for GitLab API operations. `AI_FLOW_INPUT` / `AI_FLOW_CONTEXT` / `AI_FLOW_EVENT` carry the mention payload when triggered via webhook.

### GitLab CI/CD — provider variables

| Provider | Required CI/CD variables |
|---|---|
| Claude API | `ANTHROPIC_API_KEY` |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` (via `sts assume-role-with-web-identity` using `CI_JOB_JWT_V2`) |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` (via WIF) |

### Slack

| Prereq | Details |
|---|---|
| Claude plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled and have a GitHub repo connected |
| Slack account | Linked to your Claude account via the Claude app |

| Routing mode | Behavior |
|---|---|
| **Code only** | All `@Claude` mentions route to Claude Code sessions |
| **Code + Chat** | Claude auto-routes between Code and Chat based on intent; "Retry as Code" button available |

Slack integration works in channels only (public or private), not DMs. Add Claude with `/invite @Claude`. Message actions: **View Session**, **Create PR**, **Retry as Code**, **Change Repo**. Each session creates one PR max; uses the individual user's plan limits.

### Code Review (managed, research preview)

Team and Enterprise only; not available with Zero Data Retention.

| Review Behavior | When reviews run |
|---|---|
| **Once after PR creation** | Once when the PR is opened or marked ready |
| **After every push** | On every push; auto-resolves fixed threads |
| **Manual** | Only when someone comments `@claude review` or `@claude review once` |

| Severity marker | Meaning |
|---|---|
| Red circle | Important — a bug that should be fixed before merging |
| Yellow circle | Nit — minor, worth fixing but not blocking |
| Purple circle | Pre-existing — bug that existed before this PR |

| Manual trigger | What it does |
|---|---|
| `@claude review` | Starts a review and subscribes the PR to push-triggered reviews |
| `@claude review once` | Single review without subscribing to future pushes |

Post as a top-level PR comment (not inline), at the start of the comment; caller needs owner/member/collaborator access. Check run is always neutral — never blocks merge. Parse severity counts from the last line of the check-run Details text:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns JSON like `{"normal": 2, "nit": 1, "pre_existing": 0}` (`normal` = Important count).

### Code Review — customization files

| File | Scope | Influence |
|---|---|---|
| `CLAUDE.md` | All Claude Code tasks (also read hierarchically) | New violations flagged as nits |
| `REVIEW.md` | Review-only | Injected as highest-priority system prompt in every agent |

`REVIEW.md` uses plain markdown — `@` imports are not expanded. Use it to redefine Important, cap nit volume, skip paths/categories, add repo-specific checks, set verification bars, tune re-review convergence, and shape the summary.

Pricing: ~$15–25 per review, billed as extra usage (separate from plan allotments). Set a spend cap at `claude.ai/admin-settings/usage`. The **Re-run** button in the Checks tab does NOT retrigger Code Review — comment `@claude review once` or push a new commit.

### GitHub Enterprise Server feature support

| Feature | GHES | Notes |
|---|---|---|
| Claude Code on the web | Supported | Admin connects instance once; `claude --remote` works as usual |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | `claude --teleport` between web and terminal |
| Plugin marketplaces | Supported | Use full git URL, not `owner/repo` shorthand |
| Contribution metrics | Supported | Webhook-delivered |
| GitHub Actions | Supported | Manual workflow setup only; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use the `gh` CLI configured for your GHES host instead |

### GHES GitHub App permissions

| Permission | Access | Used for |
|---|---|---|
| Contents | Read & write | Cloning and pushing branches |
| Pull requests | Read & write | Creating PRs and review comments |
| Issues | Read & write | Responding to issue mentions |
| Checks | Read & write | Posting Code Review check runs |
| Actions | Read | Reading CI status for auto-fix |
| Repository hooks | Read & write | Receiving webhooks for contribution metrics |
| Metadata | Read | Required by GitHub |

Events subscribed: `pull_request`, `issue_comment`, `pull_request_review_comment`, `pull_request_review`, `check_run`. GHES instance must be reachable from Anthropic infrastructure — allowlist Anthropic API IPs in any firewall.

### GHES plugin marketplaces

```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Allowlist via managed settings using a host pattern:

```json
{
  "strictKnownMarketplaces": [
    {
      "source": "hostPattern",
      "hostPattern": "^github\\.example\\.com$"
    }
  ]
}
```

### Troubleshooting checklist

| Symptom | Likely cause |
|---|---|
| `@claude` not responding (Actions) | App not installed, workflows disabled, secret missing, or comment uses `/claude` instead of `@claude` |
| CI not running on Claude's commits | Using Actions user token instead of GitHub App |
| GitLab job can't write comments/MRs | `CI_JOB_TOKEN` lacks scope, `mcp__gitlab` missing from `--allowedTools`, or MR context unavailable |
| Code Review failed/timed out | Comment `@claude review once` — the Checks tab Re-run button does not retrigger Code Review |
| Code Review didn't run | Monthly spend cap reached — raise at `claude.ai/admin-settings/usage` |
| Findings missing from diff | Check the check-run Details table, Files-changed annotations, and "Additional findings" in the review body |
| GHES session fails to clone | Instance not reachable from Anthropic infra, or hostname mismatch in admin settings |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — Running Claude in GitHub Actions: quick and manual setup, v1 action inputs, beta-to-v1 migration, Bedrock/Vertex workflows via OIDC/WIF, example workflows, cost controls, and troubleshooting.
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — Beta GitLab integration maintained by GitLab: `.gitlab-ci.yml` job template, `AI_FLOW_*` webhook variables, Bedrock and Vertex examples, provider abstraction, security and governance.
- [Claude Code in Slack](references/claude-code-slack.md) — Delegating coding tasks from Slack channels: routing modes, context gathering, session flow, message actions, access control, and limitations.
- [Code Review](references/claude-code-code-review.md) — Managed PR review product: multi-agent analysis, severity levels, review triggers, `@claude review` commands, `CLAUDE.md` and `REVIEW.md` customization, check-run parsing, pricing, and spend caps.
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — Connecting a self-hosted GHES instance: guided and manual admin setup, GitHub App permissions, supported features, plugin marketplace URLs, managed-settings allowlists, and limitations.

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
