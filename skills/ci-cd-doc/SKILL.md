---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, automated code review, and Slack integration. Covers setup, authentication (direct API, Amazon Bedrock, Google Vertex AI), workflow configuration, triggers, REVIEW.md customization, and troubleshooting.
user-invocable: false
---

# CI/CD and Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations and platform-specific workflows.

## Quick Reference

### Integration Overview

| Integration | Trigger | What Claude can do |
| :--- | :--- | :--- |
| **GitHub Actions** | `@claude` mention in PR/issue comment, workflow `on:` events | Create PRs, implement features, fix bugs, run custom automation |
| **GitLab CI/CD** | `@claude` mention (via webhook), MR events, manual run | Create MRs, implement code, respond to comments |
| **Code Review** | PR open/push, `@claude review` comment | Post inline findings with severity tags |
| **GitHub Enterprise Server** | Same as github.com features | Web sessions, code review, plugin marketplaces on GHES |
| **Slack** | `@Claude` mention in channels | Delegate coding tasks, create PRs, kick off async sessions |

### GitHub Actions — Action Parameters (v1)

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Instructions for Claude (text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `plugin_marketplaces` | Newline-separated plugin marketplace Git URLs | No |
| `plugins` | Newline-separated plugin names to install | No |
| `anthropic_api_key` | Claude API key | Yes (direct API) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

### GitHub Actions — v1 Minimal Workflow

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

### GitHub Actions — Beta → v1 Breaking Changes

| Old Beta Input | New v1.0 Input |
| :--- | :--- |
| `mode` | *(Removed — auto-detected)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitHub Actions — Common `claude_args` Options

| Arg | Example | Effect |
| :--- | :--- | :--- |
| `--max-turns` | `--max-turns 10` | Limit conversation turns |
| `--model` | `--model claude-sonnet-4-6` | Override model |
| `--allowedTools` | `--allowedTools Bash,Edit` | Restrict tools |
| `--append-system-prompt` | `--append-system-prompt "..."` | Add custom instructions |
| `--mcp-config` | `--mcp-config /path/config.json` | Load MCP config |

### GitLab CI/CD — Minimal Job (Claude API)

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

### GitLab CI/CD — Required Variables by Provider

| Provider | Required CI/CD Variables |
| :--- | :--- |
| Claude API | `ANTHROPIC_API_KEY` (masked) |
| Amazon Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

### Code Review — Severity Levels

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| 🔴 | Important | Bug that should be fixed before merging |
| 🟡 | Nit | Minor issue, worth fixing but not blocking |
| 🟣 | Pre-existing | Bug in codebase not introduced by this PR |

### Code Review — Review Triggers

| Trigger | `@claude review` | `@claude review once` |
| :--- | :--- | :--- |
| Starts a review | Yes | Yes |
| Subscribes PR to future push-triggered reviews | Yes | No |

### Code Review — Review Behaviors (per repo)

| Mode | When reviews run |
| :--- | :--- |
| Once after PR creation | Review on PR open/ready-for-review |
| After every push | Review on each push to the PR branch |
| Manual | Only when `@claude review` or `@claude review once` is commented |

### Code Review — Customization Files

| File | Purpose | Priority |
| :--- | :--- | :--- |
| `CLAUDE.md` | Shared project instructions; violations flagged as nits | Normal |
| `REVIEW.md` | Review-only rules injected as highest-priority instructions | Highest |

Key `REVIEW.md` tuning areas: severity redefinition, nit volume caps, skip rules (paths/branches/categories), repo-specific checks, verification bar, re-review convergence, summary shape.

### Code Review — Parse Severity Counts via CLI

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# Returns: {"normal": 2, "nit": 1, "pre_existing": 0}
```

`normal` = count of Important (🔴) findings.

### GitHub Enterprise Server — Feature Support

| Feature | GHES support | Notes |
| :--- | :--- | :--- |
| Claude Code on the web | Supported | Admin connects GHES instance once |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | Use `--teleport` |
| Plugin marketplaces | Supported | Use full git URLs, not `owner/repo` shorthand |
| Contribution metrics | Supported | Via webhooks to analytics dashboard |
| GitHub Actions | Supported | Manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI configured for your GHES host instead |

### GitHub Enterprise Server — GitHub App Permissions

| Permission | Access | Used for |
| :--- | :--- | :--- |
| Contents | Read and write | Cloning repos, pushing branches |
| Pull requests | Read and write | Creating PRs, posting review comments |
| Issues | Read and write | Responding to issue mentions |
| Checks | Read and write | Posting Code Review check runs |
| Actions | Read | CI status for auto-fix |
| Repository hooks | Read and write | Webhooks for contribution metrics |
| Metadata | Read | Required by GitHub for all apps |

### GitHub Enterprise Server — Marketplace on GHES

```bash
# Use full git URLs (owner/repo shorthand resolves to github.com only)
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
/plugin marketplace add https://github.example.com/platform/claude-plugins.git
```

To allow all GHES marketplaces in managed settings:
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

### Slack Integration — Setup Steps

1. Workspace admin installs Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Each user connects their Claude account via App Home
3. User configures GitHub access at claude.ai/code
4. User selects routing mode (Code only, or Code + Chat)
5. Invite Claude to channels with `/invite @Claude`

### Slack Integration — Routing Modes

| Mode | Behavior |
| :--- | :--- |
| Code only | All @mentions routed to Claude Code sessions |
| Code + Chat | Claude routes to Code or Chat based on detected intent; "Retry as Code" available |

### Slack Integration — Requirements

| Requirement | Details |
| :--- | :--- |
| Claude Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one authenticated repository |
| Slack Authentication | Slack account linked to Claude account |

### Cloud Provider Authentication (GitHub Actions & GitLab)

**Amazon Bedrock:**
- Set up GitHub/GitLab as OIDC identity provider in AWS
- Create IAM role with `AmazonBedrockFullAccess` and trust policy for your repo
- Store `AWS_ROLE_TO_ASSUME` as a secret/variable
- Use `use_bedrock: "true"` (GitHub Actions) or OIDC token exchange (GitLab)
- Model IDs include region prefix: `us.anthropic.claude-sonnet-4-6`

**Google Vertex AI:**
- Enable Vertex AI API, IAM Credentials API, STS API
- Create Workload Identity Pool with GitHub/GitLab OIDC provider
- Create service account with `Vertex AI User` role
- Store `GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_SERVICE_ACCOUNT`
- Use `use_vertex: "true"` (GitHub Actions) or WIF token exchange (GitLab)

### Code Review — Pricing

- Billed by token usage; averages $15–25 per review
- Billed separately via extra usage, not against plan included usage
- Set monthly spend cap at claude.ai/admin-settings/usage
- Monitor at [claude.ai/analytics/code-review](https://claude.ai/analytics/code-review)

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — GitHub Action setup, `@claude` mentions, workflow examples, Bedrock/Vertex configuration, advanced parameters
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — GitLab CI job setup, provider authentication, MR automation, OIDC/WIF examples
- [Code Review](references/claude-code-code-review.md) — automated PR reviews, severity levels, setup, REVIEW.md customization, pricing, usage analytics
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — GHES admin setup, developer workflow, plugin marketplaces on GHES, feature support matrix
- [Claude Code in Slack](references/claude-code-slack.md) — Slack app setup, routing modes, session flow, access controls, troubleshooting

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
