---
name: CI/CD Integrations
description: Reference documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD pipelines, and Slack-based coding workflows. Use when setting up automated code reviews, PR creation, issue-to-MR workflows, cloud provider authentication (AWS Bedrock, Google Vertex AI), or configuring triggers and permissions.
user-invocable: false
---

# CI/CD Integrations Documentation

This skill covers Claude Code's integrations with GitHub Actions, GitLab CI/CD, and Slack for automated development workflows.

## Integration Overview

| Integration | Trigger | Output | Status |
|:------------|:--------|:-------|:-------|
| GitHub Actions | `@claude` in PR/issue comments, PR events, schedules | Commits, PRs, comments | GA (v1) |
| GitLab CI/CD | `@claude` in MR/issue comments, pipeline events | Commits, MRs, comments | Beta |
| Slack | `@Claude` mention in channels | Claude Code web sessions, PRs | GA |

## GitHub Actions

### Quick Setup

1. Run `/install-github-app` in Claude Code terminal, OR
2. Install the [Claude GitHub App](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` secret, copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)

### Basic Workflow

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

### Action Parameters

| Parameter | Description | Required |
|:----------|:------------|:---------|
| `prompt` | Instructions or skill (e.g. `/review`) | No |
| `claude_args` | CLI arguments passed through | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

### Common `claude_args`

```yaml
claude_args: "--max-turns 5 --model claude-sonnet-4-5-20250929 --append-system-prompt 'Follow standards'"
```

- `--max-turns`: Max conversation turns (default: 10)
- `--model`: Model to use
- `--mcp-config`: Path to MCP configuration
- `--allowed-tools`: Comma-separated allowed tools
- `--append-system-prompt`: Custom instructions

### Beta to v1 Migration

| Beta Input | v1 Input |
|:-----------|:---------|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `claude_env` | `settings` JSON format |

## GitLab CI/CD

### Quick Setup

1. Add `ANTHROPIC_API_KEY` as masked CI/CD variable (Settings > CI/CD > Variables)
2. Add Claude job to `.gitlab-ci.yml`

### Basic Job

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
      -p "${AI_FLOW_INPUT:-'Review and suggest improvements'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

### Key Differences from GitHub Actions

- Uses `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT` variables for context
- Installs Claude CLI via `curl -fsSL https://claude.ai/install.sh | bash`
- Uses `--permission-mode acceptEdits` and `--allowedTools` flags directly
- Optional GitLab MCP server: `/bin/gitlab-mcp-server`
- Mention-driven triggers require a webhook listener for note events

## Cloud Provider Authentication

Both GitHub Actions and GitLab CI/CD support AWS Bedrock and Google Vertex AI as alternatives to the direct Claude API.

### AWS Bedrock

| Item | GitHub Actions | GitLab CI/CD |
|:-----|:---------------|:-------------|
| Auth method | OIDC via `aws-actions/configure-aws-credentials@v4` | OIDC token exchange via `aws sts assume-role-with-web-identity` |
| Required secrets | `AWS_ROLE_TO_ASSUME` | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Action flag | `use_bedrock: "true"` | N/A (env vars set in before_script) |
| Model ID format | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | Same |

### Google Vertex AI

| Item | GitHub Actions | GitLab CI/CD |
|:-----|:---------------|:-------------|
| Auth method | `google-github-actions/auth@v2` with WIF | `gcloud auth login --cred-file` with WIF JSON |
| Required secrets | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` | Same, plus `CLOUD_ML_REGION` |
| Action flag | `use_vertex: "true"` | N/A (env vars set in before_script) |
| Env vars | `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION` | `CLOUD_ML_REGION` |

## Slack Integration

### Prerequisites

- Claude Pro, Max, Teams, or Enterprise plan with Claude Code access
- Claude Code on the web enabled
- GitHub account connected with at least one repository
- Slack account linked to Claude account

### Setup

1. Install Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Connect Claude account in App Home tab
3. Configure Claude Code on the web at [claude.ai/code](https://claude.ai/code)
4. Choose routing mode: **Code only** or **Code + Chat**
5. Invite Claude to channels: `/invite @Claude`

### Session Flow

1. `@Claude` mention with coding request in a channel
2. Claude detects coding intent and creates a web session
3. Status updates posted to Slack thread
4. Completion summary with "View Session" and "Create PR" buttons

### Limitations

- GitHub repositories only
- One PR per session
- Channels only (no DMs)
- Individual plan rate limits apply

## Best Practices

- **CLAUDE.md**: Define coding standards and project rules at the repo root
- **Security**: Never commit API keys; use GitHub Secrets or GitLab CI/CD masked variables
- **Cost control**: Set `--max-turns`, job timeouts, and concurrency limits
- **Prompts**: Use specific `@claude` commands to reduce unnecessary API calls

## Full Documentation

- [GitHub Actions](references/claude-code-github-actions.md) — setup, workflows, action parameters, cloud providers, troubleshooting
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — setup, job examples, cloud providers, security and governance
- [Slack Integration](references/claude-code-slack.md) — setup, routing modes, session flow, access control

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Slack: https://code.claude.com/docs/en/claude-code-slack.md
