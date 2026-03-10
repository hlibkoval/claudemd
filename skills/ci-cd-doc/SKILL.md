---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations and automated workflows -- GitHub Actions setup (quick/manual, @claude triggers, action parameters, claude_args, Bedrock/Vertex workflows, beta-to-v1 migration), GitLab CI/CD (pipeline jobs, AI_FLOW variables, MR automation, OIDC authentication), Slack integration (routing modes, session flow, repository selection, channel access), and Code Review (multi-agent PR analysis, severity levels, REVIEW.md customization, pricing, analytics). Load when discussing CI/CD pipelines, GitHub Actions, GitLab CI, automated code review, Slack coding integration, PR automation, or @claude triggers.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code's CI/CD integrations: GitHub Actions, GitLab CI/CD, Slack, and automated Code Review.

## Quick Reference

### GitHub Actions

Trigger Claude via `@claude` in PR/issue comments, or run automated prompts on any GitHub event. Uses `anthropics/claude-code-action@v1`.

**Setup options:**

| Method | Steps |
|:-------|:------|
| Quick (CLI) | Run `/install-github-app` in Claude Code terminal |
| Manual | Install [Claude GitHub App](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` secret, copy workflow YAML |

**Action parameters (v1):**

| Parameter | Description | Required |
|:----------|:------------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

**Common `claude_args`:** `--max-turns`, `--model`, `--mcp-config`, `--allowed-tools`, `--append-system-prompt`, `--debug`

**Beta to v1 migration:**

| Old (beta) | New (v1) |
|:-----------|:---------|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `claude_env` | `settings` JSON format |

**Basic workflow:**

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

### GitLab CI/CD

Run Claude in GitLab CI jobs via the Claude CLI. Currently in beta (maintained by GitLab).

**Quick setup:**

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add a Claude job to `.gitlab-ci.yml` using `node:24-alpine3.21` image
3. Install Claude CLI via `curl -fsSL https://claude.ai/install.sh | bash`

**Key variables:**

| Variable | Purpose |
|:---------|:--------|
| `AI_FLOW_INPUT` | Prompt content from trigger context |
| `AI_FLOW_CONTEXT` | Context identifier (MR, issue, etc.) |
| `AI_FLOW_EVENT` | Event type that triggered the pipeline |
| `ANTHROPIC_API_KEY` | API key (masked CI/CD variable) |
| `GITLAB_ACCESS_TOKEN` | Project Access Token with `api` scope (optional) |

**Common CLI flags in GitLab jobs:** `-p "<prompt>"`, `--permission-mode acceptEdits`, `--allowedTools "Bash Read Edit Write mcp__gitlab"`, `--debug`

**Trigger patterns:**

| Trigger | Rule |
|:--------|:-----|
| Manual run | `$CI_PIPELINE_SOURCE == "web"` |
| MR events | `$CI_PIPELINE_SOURCE == "merge_request_event"` |
| Comment mentions | Webhook listener + pipeline trigger API with `AI_FLOW_*` variables |

### Cloud Provider Authentication (GitHub Actions & GitLab)

Both platforms support AWS Bedrock and Google Vertex AI via OIDC/WIF (no static keys).

**AWS Bedrock:**

| Item | Value |
|:-----|:------|
| Auth method | OIDC identity provider + IAM role |
| Required secrets | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Model ID format | `us.anthropic.claude-sonnet-4-6` (region prefix) |
| GitHub action flag | `use_bedrock: "true"` |

**Google Vertex AI:**

| Item | Value |
|:-----|:------|
| Auth method | Workload Identity Federation |
| Required secrets | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` |
| Region variable | `CLOUD_ML_REGION` (e.g., `us-east5`) |
| GitHub action flag | `use_vertex: "true"` |
| Model ID format | `claude-sonnet-4@20250514` |

### Slack Integration

Mention `@Claude` in Slack channels to create Claude Code sessions on the web. Requires Pro/Max/Teams/Enterprise with Claude Code access.

**Prerequisites:**

| Requirement | Details |
|:------------|:--------|
| Claude Plan | Pro, Max, Teams, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one authenticated repository |
| Slack Auth | Slack account linked to Claude account via Claude app |

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| Code only | All @mentions route to Claude Code sessions |
| Code + Chat | Intelligent routing between Claude Code and Claude Chat |

**Session flow:** @mention -> intent detection -> session creation on claude.ai/code -> progress updates in Slack thread -> completion summary with action buttons (View Session, Create PR, Retry as Code, Change Repo)

**Access model:** Channel-based. Claude must be invited to channels via `/invite @Claude`. Works in public and private channels. Does not work in DMs.

**Limitations:** GitHub only, one PR per session, individual rate limits apply, requires Claude Code on the web access.

### Code Review

Automated multi-agent PR analysis. Available for Teams and Enterprise (not compatible with ZDR). Reviews run on Anthropic infrastructure.

**Setup:** Admin enables at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), installs Claude GitHub App, selects repositories.

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Normal | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Review triggers:**

| Trigger | Behavior | Cost |
|:--------|:---------|:-----|
| After PR creation only | Runs once when PR opens or is marked ready | Lower |
| After every push | Runs on each push, auto-resolves fixed issues | Higher (multiplied by pushes) |

**Customization files:**

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project standards; violations flagged as nits |
| `REVIEW.md` | Code review only | Review-specific rules (always-check, style, skip) |

**Pricing:** Token-based, averaging $15-25 per review. Scales with PR size and complexity. Billed on Anthropic invoice regardless of provider. Spend cap configurable at [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage).

**Analytics:** [claude.ai/analytics/code-review](https://claude.ai/analytics/code-review) -- PRs reviewed, weekly cost, feedback/resolution counts, per-repo breakdown.

### Best Practices (All Integrations)

- Use `CLAUDE.md` to define project standards Claude follows during CI/CD runs
- Never commit API keys; always use repository/CI secrets
- Set `--max-turns` and job timeouts to prevent runaway runs
- Use OIDC/WIF authentication over static keys for cloud providers
- Review Claude's outputs (PRs, MRs, comments) before merging

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) -- setup (quick/manual), action parameters, claude_args, workflow examples, beta-to-v1 migration, Bedrock/Vertex workflows, custom GitHub App, troubleshooting, cost optimization
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- pipeline job setup, AI_FLOW variables, MR automation, OIDC authentication for Bedrock/Vertex, configuration examples, security and governance, troubleshooting
- [Slack integration](references/claude-code-slack.md) -- setup steps, routing modes, session flow, repository selection, channel-based access, UI elements, limitations, troubleshooting
- [Code Review](references/claude-code-code-review.md) -- multi-agent analysis, severity levels, setup steps, review triggers, CLAUDE.md and REVIEW.md customization, pricing, analytics dashboard

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Slack integration: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
