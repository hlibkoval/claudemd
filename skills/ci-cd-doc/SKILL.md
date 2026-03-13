---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions (anthropics/claude-code-action@v1, @claude mentions, prompt/claude_args parameters, Bedrock/Vertex workflows, /install-github-app setup, beta-to-v1 migration), GitLab CI/CD (beta, .gitlab-ci.yml jobs, AI_FLOW_* variables, OIDC auth for Bedrock/Vertex, GitLab MCP server, permission-mode acceptEdits), Slack integration (Claude Code in Slack, routing modes code-only/code+chat, session flow, channel-based access, @Claude mentions, repository selection, View Session/Create PR actions), and Code Review (managed multi-agent PR analysis, severity levels, REVIEW.md customization, review triggers once/every-push/manual, @claude review command, pricing $15-25 avg per review, Teams/Enterprise only). Load when discussing GitHub Actions for Claude Code, GitLab CI/CD for Claude Code, Slack integration, automated code review, PR review bots, @claude mentions in PRs/issues, claude-code-action, CI/CD automation with Claude, REVIEW.md, or managed code review service.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations: GitHub Actions, GitLab CI/CD, Slack, and the managed Code Review service.

## Quick Reference

### GitHub Actions

#### Setup

Quickest path: run `/install-github-app` in the Claude Code terminal. Manual alternative: install the [Claude GitHub App](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` as a repository secret, copy the workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml).

#### Action Parameters (v1)

| Parameter | Description | Required |
|:----------|:-----------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

#### Common `claude_args` Values

| Argument | Purpose |
|:---------|:--------|
| `--max-turns N` | Maximum conversation turns (default: 10) |
| `--model <id>` | Model to use (e.g. `claude-sonnet-4-6`) |
| `--mcp-config <path>` | Path to MCP configuration |
| `--allowed-tools <list>` | Comma-separated list of allowed tools |
| `--append-system-prompt <text>` | Add custom instructions |
| `--debug` | Enable debug output |

#### Beta to v1 Migration

| Old Beta Input | New v1 Input |
|:---------------|:-------------|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

#### Basic Workflow

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

#### Bedrock/Vertex Workflows

Both require a custom GitHub App (recommended) with Contents, Issues, and Pull Requests read/write permissions. Use `actions/create-github-app-token@v2` to generate tokens.

**Bedrock secrets:** `AWS_ROLE_TO_ASSUME`, `APP_ID`, `APP_PRIVATE_KEY`
**Vertex secrets:** `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `APP_ID`, `APP_PRIVATE_KEY`

Key action inputs for cloud providers:

| Provider | Action input | Model ID format |
|:---------|:------------|:----------------|
| Bedrock | `use_bedrock: "true"` | `us.anthropic.claude-sonnet-4-6` |
| Vertex AI | `use_vertex: "true"` | `claude-sonnet-4@20250514` |

### GitLab CI/CD (Beta)

#### Quick Setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add a Claude job to `.gitlab-ci.yml`

#### Minimal Job

```yaml
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
      -p "${AI_FLOW_INPUT:-'Review this MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

#### Key Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_API_KEY` | Claude API key (masked CI/CD variable) |
| `AI_FLOW_INPUT` | Prompt/instructions passed from trigger |
| `AI_FLOW_CONTEXT` | Context (MR URL, issue URL) from trigger |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `GITLAB_ACCESS_TOKEN` | Project Access Token with `api` scope (optional, for GitLab API operations) |

#### Cloud Provider Auth (GitLab)

| Provider | Required CI/CD Variables |
|:---------|:------------------------|
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

Both use OIDC for keyless authentication: Bedrock via `aws sts assume-role-with-web-identity`, Vertex via Workload Identity Federation.

### Slack Integration

#### Prerequisites

| Requirement | Details |
|:------------|:--------|
| Claude Plan | Pro, Max, Teams, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one authenticated repository |
| Slack Auth | Slack account linked to Claude account via the Claude app |

#### Setup Steps

1. Install the Claude app from the [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Connect your Claude account in the App Home tab
3. Configure Claude Code on the web at [claude.ai/code](https://claude.ai/code)
4. Choose routing mode (Code only or Code + Chat)
5. Invite Claude to channels: `/invite @Claude`

#### Routing Modes

| Mode | Behavior |
|:-----|:---------|
| Code only | All @mentions route to Claude Code sessions |
| Code + Chat | Intelligent routing between Claude Code (coding) and Claude Chat (general) |

#### Session Flow

1. @mention Claude with a coding request in a channel
2. Claude detects coding intent and creates a Claude Code session on the web
3. Status updates posted to your Slack thread
4. Completion summary with action buttons: View Session, Create PR, Change Repo

Works in public and private channels only (not DMs).

### Code Review (Managed Service)

Available for Teams and Enterprise subscriptions. Not available with Zero Data Retention.

#### How It Works

Multiple agents analyze the diff and surrounding code in parallel on Anthropic infrastructure. Results are deduplicated, ranked by severity, and posted as inline PR comments. Average completion time: ~20 minutes.

#### Setup

1. Go to [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) (requires admin)
2. Install the Claude GitHub App
3. Select repositories to enable
4. Set review triggers per repo

#### Review Triggers

| Trigger | Behavior |
|:--------|:---------|
| Once after PR creation | Runs when a PR is opened or marked ready |
| After every push | Runs on every push; auto-resolves fixed issues |
| Manual | Only when someone comments `@claude review` |

Commenting `@claude review` on any PR starts a review and opts that PR into push-triggered reviews going forward.

#### Severity Levels

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Normal | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in the codebase not introduced by this PR |

#### Customization Files

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project instructions; violations flagged as nits |
| `REVIEW.md` | Code review only | Review-specific rules, skip patterns, style guidelines |

#### Pricing

Reviews average $15-25 per review, scaling with PR size and complexity. Billed separately through extra usage, not against plan limits. Set spend caps at [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage).

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) -- claude-code-action@v1 setup (quick and manual), action parameters, claude_args passthrough, Bedrock/Vertex workflows with OIDC, beta-to-v1 migration, custom GitHub App creation, @claude trigger, cost optimization, troubleshooting
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- .gitlab-ci.yml job configuration, AI_FLOW_* variables, mention-driven triggers, Bedrock OIDC and Vertex WIF job examples, GitLab MCP server, permission-mode acceptEdits, security and governance, troubleshooting
- [Claude Code in Slack](references/claude-code-slack.md) -- setup and authentication, routing modes (code only, code+chat), session flow and lifecycle, context gathering from threads/channels, action buttons (View Session, Create PR, Change Repo), channel-based access control, limitations (GitHub only, one PR per session)
- [Code Review](references/claude-code-code-review.md) -- managed multi-agent PR review, setup and repository selection, review triggers (once/every-push/manual), @claude review command, severity levels, CLAUDE.md and REVIEW.md customization, analytics dashboard, pricing and billing, Teams/Enterprise only

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
