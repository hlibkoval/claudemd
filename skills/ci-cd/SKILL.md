---
name: ci-cd
description: Reference documentation for Claude Code CI/CD integrations -- GitHub Actions (@claude mentions, workflow setup, action parameters, AWS Bedrock and Google Vertex AI), GitLab CI/CD (pipeline configuration, provider abstraction, OIDC authentication), and Claude Code in Slack (routing modes, session flow, repository selection, channel access control).
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines and messaging platforms.

## Quick Reference

Claude Code integrates with GitHub Actions, GitLab CI/CD, and Slack to automate code tasks triggered by comments, events, or schedules.

### GitHub Actions

**Quick setup**: Run `/install-github-app` in Claude Code terminal (requires repo admin access).

**Basic workflow (responds to `@claude` mentions):**

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

**Action parameters (v1):**

| Parameter           | Description                                              | Required |
|:--------------------|:---------------------------------------------------------|:---------|
| `prompt`            | Instructions for Claude (text or skill like `/review`)  | No*      |
| `claude_args`       | CLI arguments passed to Claude Code                     | No       |
| `anthropic_api_key` | Claude API key                                          | Yes**    |
| `github_token`      | GitHub token for API access                             | No       |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)              | No       |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API                   | No       |
| `use_vertex`        | Use Google Vertex AI instead of Claude API              | No       |

*Omit prompt to respond to trigger phrase in comments.
**Not required for Bedrock/Vertex.

**Common `claude_args`:**
- `--max-turns 10` — limit conversation turns
- `--model claude-sonnet-4-6` — set model
- `--mcp-config /path/to/config.json` — MCP config
- `--allowedTools Bash,Read,Edit` — restrict tools

**Beta to v1 migration:**

| Old Beta Input        | New v1.0 Input                        |
|:----------------------|:--------------------------------------|
| `mode`                | (removed, auto-detected)              |
| `direct_prompt`       | `prompt`                              |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |

### GitLab CI/CD

**Quick setup** — add to `.gitlab-ci.yml` and set `ANTHROPIC_API_KEY` as a masked CI/CD variable:

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
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Provider secrets by platform:**

| Provider          | Required CI/CD Variables                                          |
|:------------------|:------------------------------------------------------------------|
| Claude API        | `ANTHROPIC_API_KEY`                                               |
| AWS Bedrock       | `AWS_ROLE_TO_ASSUME`, `AWS_REGION`                                |
| Google Vertex AI  | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

Both Bedrock and Vertex use keyless OIDC/Workload Identity Federation — no long-lived credentials stored.

### Claude Code in Slack

**Prerequisites:** Claude Pro/Max/Teams/Enterprise plan, Claude Code on the web enabled, GitHub account connected, Slack account linked.

**Setup steps:**
1. Workspace admin installs Claude app from Slack Marketplace
2. Each user connects their Claude account in App Home
3. Configure at least one GitHub repo in claude.ai/code
4. Invite Claude to channels with `/invite @Claude`

**Routing modes:**

| Mode          | Behavior                                                    |
|:--------------|:------------------------------------------------------------|
| Code only     | All @mentions routed to Claude Code sessions                |
| Code + Chat   | Claude auto-detects whether task needs code or chat         |

**Session flow:** @mention → intent detection → session created on claude.ai/code → status updates in thread → "View Session" / "Create PR" buttons on completion.

**Current limitations:** GitHub only, one PR per session, no DM support, web access required.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, workflow examples, AWS Bedrock and Vertex AI, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — pipeline configuration, provider abstraction, OIDC auth, Bedrock/Vertex examples
- [Claude Code in Slack](references/claude-code-slack.md) — routing modes, session flow, access control, best practices

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
