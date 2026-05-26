---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD and platform integrations — GitHub Actions (setup, action parameters, cloud provider workflows, beta-to-v1 migration), GitLab CI/CD (job configuration, OIDC authentication), automated Code Review (severity levels, REVIEW.md customization, triggers, pricing), GitHub Enterprise Server (admin setup, GHES feature support matrix, plugin marketplaces), and Slack integration (routing modes, session flow, prerequisites).
user-invocable: false
---

# CI/CD & Platform Integrations Documentation

This skill provides the complete official documentation for Claude Code integrations with GitHub Actions, GitLab CI/CD, Code Review, GitHub Enterprise Server, and Slack.

## Quick Reference

### GitHub Actions — Action Parameters (v1)

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Instructions for Claude (plain text or a skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `plugin_marketplaces` | Newline-separated list of plugin marketplace Git URLs | No |
| `plugins` | Newline-separated list of plugin names to install | No |
| `anthropic_api_key` | Claude API key | Yes (direct API only) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

Common `claude_args` options: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--disallowedTools`, `--debug`

### GitHub Actions — Beta to v1 Migration

| Old Beta Input | New v1.0 Input |
| :--- | :--- |
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitHub Actions — Quick Setup

Run `/install-github-app` inside Claude Code (direct Claude API only). For Bedrock/Vertex, use manual setup. Install the GitHub App from https://github.com/apps/claude, add `ANTHROPIC_API_KEY` as a repository secret, and copy the example workflow to `.github/workflows/`.

### GitLab CI/CD — Job Configuration

Minimal `.gitlab-ci.yml` job structure:
- Image: `node:24-alpine3.21`
- Install Claude: `curl -fsSL https://claude.ai/install.sh | bash`
- Run with: `claude -p "${AI_FLOW_INPUT:-'...'}" --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab"`
- Required CI/CD variable: `ANTHROPIC_API_KEY` (masked)
- Context vars passed by triggers: `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT`

### GitLab CI/CD — Cloud Providers

| Provider | Auth method | Required CI/CD variables |
| :--- | :--- | :--- |
| Claude API | API key | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | OIDC → IAM role | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | Workload Identity Federation | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

### Code Review — Severity Levels

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| Red circle | Important | A bug that should be fixed before merging |
| Yellow circle | Nit | A minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | A bug that exists in the codebase but was not introduced by this PR |

### Code Review — Trigger Modes

| Mode | When reviews run |
| :--- | :--- |
| Once after PR creation | Runs once when PR opens or is marked ready |
| After every push | Runs on every push to the PR branch |
| Manual | Only when `@claude review` or `@claude review once` is commented |

Manual trigger commands (top-level PR comment only):
- `@claude review` — starts review and subscribes PR to future push-triggered reviews
- `@claude review once` — single review without subscribing to future pushes

### Code Review — REVIEW.md Customization

Place `REVIEW.md` at repository root. Contents are injected verbatim as highest-priority instructions into every review agent. Can tune:
- Severity definitions (what counts as Important vs. Nit)
- Nit volume cap (e.g., "report at most five nits")
- Skip rules (paths, branch patterns, finding categories)
- Repo-specific checks (e.g., "new API routes must have an integration test")
- Verification bar (evidence required before posting findings)
- Re-review convergence behavior
- Summary shape

`CLAUDE.md` is also read; violations introduced by the PR are flagged as nits.

### Code Review — Pricing & Analytics

Average cost: $15–25 per review, billed via usage credits separate from plan usage. Set a monthly spend cap at `claude.ai/admin-settings/usage`. Monitor at `claude.ai/analytics/code-review`.

### Code Review — Check Run Output

Parse machine-readable severity counts from the check run details (last line):
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```
Returns JSON: `{"normal": 2, "nit": 1, "pre_existing": 0}` — `normal` = Important findings count.

### GitHub Enterprise Server — Feature Support

| Feature | GHES support | Notes |
| :--- | :--- | :--- |
| Claude Code on the web | Supported | Admin connects once; developers use `claude --remote` as usual |
| Code Review | Supported | Same as github.com |
| Claude Security | Supported | Public beta, Enterprise plans |
| Teleport sessions | Supported | `claude --teleport` |
| Plugin marketplaces | Supported | Use full git URLs instead of `owner/repo` shorthand |
| Contribution metrics | Supported | Via webhooks to analytics dashboard |
| GitHub Actions | Supported | Manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI configured for GHES host instead |

### GitHub Enterprise Server — Plugin Marketplaces

Full git URL required (not `owner/repo` shorthand):
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Allowlist all GHES marketplaces in managed settings via `hostPattern` source type:
```json
{ "strictKnownMarketplaces": [{ "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }] }
```

### Slack Integration — Routing Modes

| Mode | Behavior |
| :--- | :--- |
| Code only | All @Claude mentions route to Claude Code sessions |
| Code + Chat | Claude intelligently routes between Claude Code and Claude Chat based on message type |

Session flow: @mention → intent detection → Claude Code session on claude.ai/code → Slack progress updates → completion with "View Session" / "Create PR" buttons.

### Slack Integration — Prerequisites

| Requirement | Details |
| :--- | :--- |
| Claude Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected to Claude Code on the web with at least one repository authenticated |
| Slack Authentication | Slack account linked to Claude account via the Claude app |

Limitations: GitHub only, one PR per session, only works in channels (not DMs), requires Claude Code on the web access.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, beta-to-v1 migration, Bedrock/Vertex workflows, skills invocation, security and cost guidance
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — job configuration, OIDC authentication for Bedrock and Vertex AI, configuration examples, best practices
- [Code Review](references/claude-code-code-review.md) — automated PR reviews, severity levels, setup, manual triggers, REVIEW.md customization, pricing, troubleshooting
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, feature support matrix, GHES plugin marketplaces, developer workflow, limitations
- [Claude Code in Slack](references/claude-code-slack.md) — setup steps, routing modes, session flow, access controls, best practices, limitations

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
