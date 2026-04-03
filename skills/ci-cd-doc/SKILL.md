---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack integration, automated Code Review, and GitHub Enterprise Server support. Covers GitHub Actions setup (quick via /install-github-app and manual), action parameters (prompt, claude_args, anthropic_api_key, github_token, trigger_phrase, use_bedrock, use_vertex), v1 GA migration from beta (mode removal, prompt rename, claude_args consolidation), workflow examples (basic @claude mention, code review, daily report, custom automation), AWS Bedrock and Google Vertex AI authentication (OIDC, Workload Identity Federation, IAM roles, service accounts), GitLab CI/CD setup (quick .gitlab-ci.yml job, manual production setup), GitLab provider configuration (Claude API, Bedrock OIDC, Vertex WIF), GitLab CI/CD variables (ANTHROPIC_API_KEY, AWS_ROLE_TO_ASSUME, GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_SERVICE_ACCOUNT), Claude Code in Slack (automatic coding intent detection, routing modes Code-only and Code+Chat, session flow, context gathering from threads and channels, repository selection, action buttons View Session/Create PR/Retry as Code/Change Repo), Slack prerequisites (Pro/Max/Team/Enterprise plan, Claude Code on web, GitHub account, Slack auth), Slack channel-based access control, automated Code Review (multi-agent PR analysis, severity levels Important/Nit/Pre-existing, check run output, severity table, machine-readable JSON, CLAUDE.md and REVIEW.md customization, review triggers once/every-push/manual, @claude review and @claude review once commands, pricing $15-25 average per review), GitHub Enterprise Server (GHES admin setup via guided or manual flow, GitHub App permissions, developer workflow with claude --remote, teleport sessions, plugin marketplaces on GHES with full git URLs, hostPattern allowlisting, network requirements). Load when discussing GitHub Actions for Claude Code, GitLab CI/CD integration, Claude Code in Slack, automated code review, Code Review setup, REVIEW.md, @claude review, GitHub Enterprise Server, GHES, claude-code-action, CI/CD workflows, Bedrock/Vertex in CI, PR automation, or any CI/CD-related topic for Claude Code.
user-invocable: false
---

# CI/CD Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack, automated Code Review, and GitHub Enterprise Server.

## Quick Reference

### Integration Overview

| Integration | Platform | Trigger | Status |
|:------------|:---------|:--------|:-------|
| GitHub Actions | GitHub | `@claude` mention, PR/issue events, cron | GA (v1) |
| GitLab CI/CD | GitLab | `@claude` mention, MR events, web/API triggers | Beta |
| Slack | Slack | `@Claude` mention in channels | GA |
| Code Review | GitHub | PR open, push, `@claude review` | Research Preview (Team/Enterprise) |
| GitHub Enterprise Server | Self-hosted GitHub | Same as GitHub Actions + Code Review | GA (Team/Enterprise) |

### GitHub Actions -- Action Parameters (v1)

| Parameter | Description | Required |
|:----------|:-----------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

Common `claude_args` flags: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--debug`

### GitHub Actions -- Beta to GA Migration

| Old Beta Input | New v1 Input |
|:---------------|:-------------|
| `mode` | *(Removed -- auto-detected)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitHub Actions -- Basic Workflow

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

### GitLab CI/CD -- Basic Job

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
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes and suggest improvements'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

### GitLab CI/CD Variables by Provider

| Provider | Required Variables |
|:---------|:------------------|
| Claude API | `ANTHROPIC_API_KEY` (masked) |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

### Cloud Provider Authentication (GitHub Actions)

| Provider | Auth Method | Key Secrets |
|:---------|:-----------|:------------|
| Claude API | API key | `ANTHROPIC_API_KEY` |
| AWS Bedrock | OIDC role assumption | `AWS_ROLE_TO_ASSUME`, `APP_ID`, `APP_PRIVATE_KEY` |
| Google Vertex AI | Workload Identity Federation | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `APP_ID`, `APP_PRIVATE_KEY` |

Required GitHub App permissions: Contents (R/W), Issues (R/W), Pull requests (R/W). For Bedrock/Vertex, also `id-token: write` workflow permission.

### Slack Integration

| Requirement | Details |
|:------------|:--------|
| Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled at claude.ai/code |
| GitHub | At least one repository connected |
| Slack auth | Slack account linked to Claude account |

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| Code only | All mentions routed to Claude Code sessions |
| Code + Chat | Intelligent routing between Claude Code (coding) and Claude Chat (general) |

**Session flow:** Mention `@Claude` in a channel -> intent detection -> session created on claude.ai/code -> progress updates in thread -> completion summary with action buttons (View Session, Create PR, Retry as Code, Change Repo).

**Limitations:** GitHub only, one PR per session, rate limits per user plan, channels only (no DMs), web access required.

### Automated Code Review

**Availability:** Team and Enterprise plans (research preview). Not available with Zero Data Retention.

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Review triggers:**

| Trigger | Behavior |
|:--------|:---------|
| Once after PR creation | Reviews when PR opened or marked ready |
| After every push | Reviews on each push; auto-resolves fixed issues |
| Manual | Only via `@claude review` or `@claude review once` |

**Manual commands:**

| Command | Effect |
|:--------|:-------|
| `@claude review` | Starts review + subscribes PR to push-triggered reviews |
| `@claude review once` | Single review, no subscription to future pushes |

**Customization files:** `CLAUDE.md` (shared project instructions, violations flagged as nits) and `REVIEW.md` (review-only rules at repo root).

**Check run output:** Machine-readable severity JSON available via `gh api`:
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

**Pricing:** $15-25 average per review, billed as extra usage (not against plan limits).

### GitHub Enterprise Server (GHES)

**Supported features:**

| Feature | GHES Support | Notes |
|:--------|:-------------|:------|
| Claude Code on the web | Supported | Admin connects once; developers use `claude --remote` |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | `/teleport` works with GHES repos |
| Plugin marketplaces | Supported | Use full git URLs instead of `owner/repo` |
| Contribution metrics | Supported | Via webhooks to analytics dashboard |
| GitHub Actions | Supported | Manual workflow setup only |
| GitHub MCP server | Not supported | Use `gh` CLI instead |

**Admin setup:** Guided flow at claude.ai/admin-settings/claude-code generates a GitHub App manifest and redirects to GHES to create the app. Alternative manual setup available.

**GitHub App permissions:** Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R).

**Plugin marketplaces on GHES:** Use full git URLs:
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Allowlist via managed settings with `hostPattern`:
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

**Network requirement:** GHES must be reachable from Anthropic infrastructure. Allowlist Anthropic API IP addresses if behind a firewall.

### Security Best Practices (All Platforms)

- Never commit API keys -- use GitHub Secrets or GitLab CI/CD masked variables
- Use OIDC/WIF for Bedrock and Vertex (no static keys)
- Limit action/job permissions to minimum required
- Review Claude's PRs/MRs before merging
- Set appropriate `--max-turns` and timeouts to control costs

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) -- Setup, configuration, workflow examples, Bedrock/Vertex integration, troubleshooting
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- Setup, CI job configuration, Bedrock/Vertex OIDC, enterprise providers
- [Claude Code in Slack](references/claude-code-slack.md) -- Slack app setup, routing modes, session flow, access control
- [Code Review](references/claude-code-code-review.md) -- Automated PR analysis, severity levels, review triggers, REVIEW.md, pricing
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) -- GHES admin setup, developer workflow, plugin marketplaces, network requirements

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
