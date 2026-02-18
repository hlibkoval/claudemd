---
name: ci-cd
description: Reference documentation for integrating Claude Code into CI/CD pipelines and team workflows. Use when setting up Claude Code in GitHub Actions, GitLab CI/CD, or Slack; configuring @claude triggers; using AWS Bedrock or Google Vertex AI in CI; managing secrets, permissions, and workflow parameters.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for Claude Code CI/CD and team integrations.

## Quick Reference

### GitHub Actions

Setup via Claude Code terminal: `/install-github-app`

Manual: install the [Claude GitHub app](https://github.com/apps/claude) + add `ANTHROPIC_API_KEY` secret + copy workflow file.

#### Action Parameters (v1)

| Parameter           | Description                                              | Required |
|:--------------------|:---------------------------------------------------------|:---------|
| `anthropic_api_key` | Claude API key                                           | Yes*     |
| `prompt`            | Instructions or skill command (e.g., `/review`)          | No       |
| `claude_args`       | CLI flags passed through (e.g., `--max-turns 5`)         | No       |
| `github_token`      | GitHub token for API access                              | No       |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)               | No       |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API                    | No       |
| `use_vertex`        | Use Google Vertex AI instead of Claude API               | No       |

*Not required when using Bedrock/Vertex

#### Minimal Workflow

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

#### Beta → v1 Migration

| Old Beta Input        | New v1 Input                          |
|:----------------------|:--------------------------------------|
| `mode`                | *(removed — auto-detected)*           |
| `direct_prompt`       | `prompt`                              |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |

### GitLab CI/CD (Beta)

Add `ANTHROPIC_API_KEY` as a masked CI/CD variable, then add a job:

```yaml
claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude -p "${AI_FLOW_INPUT:-'Review and implement requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

### Cloud Provider Secrets

| Provider        | Required Secrets / Variables                                        |
|:----------------|:--------------------------------------------------------------------|
| Claude API      | `ANTHROPIC_API_KEY`                                                 |
| AWS Bedrock     | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` (OIDC — no static keys)         |
| Google Vertex   | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`             |

Bedrock model IDs use a region prefix: `us.anthropic.claude-sonnet-4-6`

Vertex model IDs use a version suffix: `claude-sonnet-4@20250514`

### Slack Integration

**Prerequisites:** Pro/Max/Teams/Enterprise plan with Claude Code access, Claude Code on the web enabled, GitHub repo connected, Slack account linked to Claude account.

**Setup:** Install Claude from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4) → connect Claude account in App Home → invite to channels with `/invite @Claude`.

| Routing Mode   | Behavior                                                      |
|:---------------|:--------------------------------------------------------------|
| Code only      | All @mentions routed to Claude Code sessions                  |
| Code + Chat    | Claude auto-routes: coding tasks → Code, other → Chat         |

**Limitations:** GitHub only, channels only (no DMs), one PR per session, rate limits per user plan.

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) — setup, workflow examples, Bedrock/Vertex integration, action parameters, and migration from beta
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — setup, .gitlab-ci.yml examples, Bedrock/Vertex OIDC configuration, AI_FLOW variables
- [Slack Integration](references/claude-code-slack.md) — setup, routing modes, session flow, access controls, and limitations

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Slack: https://code.claude.com/docs/en/slack.md