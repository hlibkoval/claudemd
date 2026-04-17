---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, Slack integration, automated Code Review, and GitHub Enterprise Server support.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations including GitHub Actions, GitLab CI/CD, Slack, automated Code Review, and GitHub Enterprise Server.

## Quick Reference

### Integration overview

| Integration | Trigger | Platform | Status |
| :---------- | :------ | :------- | :----- |
| **GitHub Actions** | `@claude` in PR/issue comments, or custom `prompt` | GitHub (github.com + GHES) | GA (v1) |
| **GitLab CI/CD** | `@claude` in MR/issue comments, or manual/pipeline triggers | GitLab (self-hosted or SaaS) | Beta |
| **Code Review** | PR open, push, or `@claude review` | GitHub (managed by Anthropic) | Research preview |
| **Slack** | `@Claude` mention in channels | Slack workspace | GA |
| **GitHub Enterprise Server** | Same as github.com features | Self-hosted GHES | GA |

### GitHub Actions (claude-code-action)

Setup: run `/install-github-app` in the CLI, or manually install [github.com/apps/claude](https://github.com/apps/claude) + add `ANTHROPIC_API_KEY` secret + copy the workflow file.

Action: `anthropics/claude-code-action@v1`

| Parameter | Description | Required |
| :-------- | :---------- | :------- |
| `prompt` | Instructions for Claude (text or skill name) | No |
| `claude_args` | CLI arguments passed through to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

Common `claude_args` flags: `--max-turns N`, `--model <model>`, `--mcp-config <path>`, `--allowedTools <list>`, `--append-system-prompt "<text>"`, `--debug`.

#### Beta to v1 migration

| Old (beta) | New (v1) |
| :--------- | :------- |
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `claude_env` | `settings` JSON format |

#### Minimal workflow

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

Setup: add `ANTHROPIC_API_KEY` as a masked CI/CD variable, then add a Claude job to `.gitlab-ci.yml`.

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_API_KEY` | Claude API key (masked, protected) |
| `AI_FLOW_INPUT` | Prompt/instructions from trigger context |
| `AI_FLOW_CONTEXT` | MR/issue context from trigger |
| `AI_FLOW_EVENT` | Event type from trigger |
| `GITLAB_ACCESS_TOKEN` | PAT with `api` scope (if not using `CI_JOB_TOKEN`) |

Key flags: `--permission-mode acceptEdits`, `--allowedTools "Bash Read Edit Write mcp__gitlab"`.

Image: `node:24-alpine3.21` (install `git curl bash` via apk, then `curl -fsSL https://claude.ai/install.sh | bash`).

#### Minimal .gitlab-ci.yml

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
    - claude -p "${AI_FLOW_INPUT:-'Review this MR'}" --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab"
```

### Cloud provider authentication (both platforms)

| Provider | Auth method | Key secrets |
| :------- | :---------- | :---------- |
| **AWS Bedrock** | OIDC role assumption | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| **Google Vertex AI** | Workload Identity Federation | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

Model ID formats: Bedrock uses region prefix (e.g., `us.anthropic.claude-sonnet-4-6`); Vertex uses version suffix (e.g., `claude-sonnet-4-5@20250929`).

For both GitHub Actions and GitLab, a custom GitHub/GitLab App is recommended when using Bedrock or Vertex (use `actions/create-github-app-token@v2` for GitHub).

### Code Review (managed service)

Availability: Team and Enterprise plans. Not available with Zero Data Retention.

Setup: admin enables at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), installs the Claude GitHub App, selects repos, sets trigger behavior.

| Review behavior | When it runs |
| :-------------- | :----------- |
| Once after PR creation | PR opened or marked ready |
| After every push | Every push to PR branch |
| Manual | Only on `@claude review` or `@claude review once` |

| Severity | Marker | Meaning |
| :------- | :----- | :------ |
| Important | Red circle | Bug that should be fixed before merging |
| Nit | Yellow circle | Minor issue, not blocking |
| Pre-existing | Purple circle | Bug exists but not introduced by this PR |

Manual trigger commands (top-level PR comments only):
- `@claude review` -- starts review and subscribes PR to push-triggered reviews
- `@claude review once` -- single review, no subscription

Customization files:
- **CLAUDE.md** -- project context; violations flagged as nits
- **REVIEW.md** -- review-only instructions injected as highest priority; controls severity definitions, nit caps, skip rules, repo-specific checks, verification bar, re-review convergence, summary shape

Check run output: findings appear in the **Claude Code Review** check run Details, as annotations in Files changed, and as inline review comments. Machine-readable severity JSON available via `gh api`.

Pricing: ~$15-25 per review (scales with PR size); billed as extra usage, separate from plan.

### Slack integration

Prerequisites: Pro/Max/Team/Enterprise plan, Claude Code on the web enabled, GitHub connected, Slack account linked.

Setup: install Claude app from Slack Marketplace, connect Claude account in App Home, configure routing mode.

| Routing mode | Behavior |
| :----------- | :------- |
| Code only | All mentions route to Claude Code sessions |
| Code + Chat | Intelligent routing between Code and Chat |

Flow: `@Claude` mention in channel -> coding intent detected -> Claude Code web session created -> status updates in Slack thread -> completion summary with action buttons (View Session, Create PR, Retry as Code, Change Repo).

Limitations: channels only (no DMs), GitHub only, one PR per session, requires Claude Code on the web access.

### GitHub Enterprise Server (GHES)

Availability: Team and Enterprise plans.

| Feature | GHES support |
| :------ | :----------- |
| Claude Code on the web | Supported |
| Code Review | Supported |
| Teleport sessions | Supported |
| Plugin marketplaces | Supported (use full git URL) |
| GitHub Actions | Supported (manual workflow setup) |
| GitHub MCP server | Not supported (use `gh` CLI instead) |

Admin setup: connect GHES instance once at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) via guided manifest flow or manual app creation.

Developer workflow: no config needed -- `claude --remote` auto-detects GHES host from git remote.

GHES marketplace: use full git URL (`git@github.example.com:org/repo.git`); allowlist with `hostPattern` in managed settings; pre-register with `extraKnownMarketplaces`.

Network: GHES must be reachable from Anthropic infrastructure; allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Cost considerations

| Cost type | GitHub Actions | GitLab CI/CD | Code Review |
| :-------- | :------------- | :----------- | :---------- |
| Compute | GitHub Actions minutes | GitLab runner time | Included (Anthropic infra) |
| API tokens | Per-task usage | Per-task usage | ~$15-25 per review |
| Optimization | `--max-turns`, timeouts, concurrency | `max_turns`, job timeouts, caching | Trigger mode, `@claude review once` |

### Security best practices (all integrations)

- Never commit API keys; use repository/CI secrets
- Use OIDC (Bedrock/Vertex) over static credentials
- Limit action/job permissions to minimum required
- Review Claude's changes before merging
- Use `CLAUDE.md` to define project standards

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) -- Setup (quick and manual), upgrading from beta to v1, example workflows, action parameters, `claude_args` passthrough, AWS Bedrock and Google Vertex AI configuration with OIDC/WIF, custom GitHub Apps, troubleshooting, cost optimization, and CLAUDE.md customization.
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- Setup (quick and production), `.gitlab-ci.yml` examples for Claude API / Bedrock / Vertex, event-driven orchestration, sandboxed execution, `AI_FLOW_*` variables, mention-driven triggers, common parameters, troubleshooting, and security governance.
- [Slack](references/claude-code-slack.md) -- Setup (install app, connect accounts, choose routing mode), automatic coding intent detection, context gathering from threads and channels, session flow, UI elements (App Home, action buttons), access and permissions (user-level, workspace-level, channel-based), best practices, and troubleshooting.
- [Code Review](references/claude-code-code-review.md) -- How multi-agent review works, severity levels, rating and replying to findings, check run output with machine-readable severity JSON, setup and repository configuration, manual trigger commands (`@claude review` / `@claude review once`), customization via CLAUDE.md and REVIEW.md (severity, nit caps, skip rules, repo-specific checks, verification bar), analytics dashboard, pricing, and troubleshooting.
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) -- Feature support matrix, admin setup (guided manifest and manual), GitHub App permissions, network requirements, developer workflow with `claude --remote`, teleport sessions, plugin marketplaces on GHES (full git URLs, `hostPattern` allowlisting, `extraKnownMarketplaces`), limitations, and troubleshooting.

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
