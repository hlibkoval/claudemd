---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, Slack, automated Code Review, and GitHub Enterprise Server support.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations and external platform connections.

## Quick Reference

### Integration overview

| Integration          | What it does                                                       | Status            | Trigger                            |
| :------------------- | :----------------------------------------------------------------- | :---------------- | :--------------------------------- |
| **GitHub Actions**   | Run Claude in GitHub Actions workflows; respond to `@claude` in PRs/issues | GA (v1)           | `@claude` mention, PR events, schedule, manual |
| **GitLab CI/CD**     | Run Claude in GitLab CI jobs; respond to `@claude` in MRs/issues  | Beta              | `@claude` mention, MR events, web/API trigger |
| **Code Review**      | Multi-agent automated PR review posted as inline comments          | Research preview  | PR open, push, or `@claude review` |
| **Slack**            | Delegate coding tasks from Slack to Claude Code on the web         | Available         | `@Claude` mention in channels      |
| **GitHub Enterprise Server** | Connect self-hosted GHES instances for web sessions, review, plugins | Team/Enterprise   | Same as github.com features        |

### GitHub Actions (v1) setup

**Quick setup**: Run `/install-github-app` in the Claude Code terminal.

**Manual setup**:
1. Install the Claude GitHub App: https://github.com/apps/claude
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from `examples/claude.yml` into `.github/workflows/`

**Action parameters**:

| Parameter           | Description                                        | Required |
| :------------------ | :------------------------------------------------- | :------- |
| `prompt`            | Instructions for Claude (text or skill name)       | No       |
| `claude_args`       | CLI arguments passed to Claude Code                | No       |
| `anthropic_api_key` | Claude API key                                     | Yes*     |
| `github_token`      | GitHub token for API access                        | No       |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)          | No       |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API              | No       |
| `use_vertex`        | Use Google Vertex AI instead of Claude API         | No       |

*Required for direct Claude API only; not needed for Bedrock/Vertex.

**Common `claude_args` flags**: `--max-turns N`, `--model <model>`, `--mcp-config <path>`, `--allowedTools <tools>`, `--debug`

**Beta to v1 migration**:

| Old beta input        | New v1 input                          |
| :-------------------- | :------------------------------------ |
| `mode`                | *(Removed — auto-detected)*          |
| `direct_prompt`       | `prompt`                              |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |
| `claude_env`          | `settings` JSON format                |

### GitLab CI/CD setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add a Claude job to `.gitlab-ci.yml` using `node:24-alpine3.21` image
3. Install Claude CLI in `before_script`: `curl -fsSL https://claude.ai/install.sh | bash`
4. Run `claude -p "..." --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab"`

**Key variables**: `AI_FLOW_INPUT` (prompt from trigger), `AI_FLOW_CONTEXT` (thread context), `AI_FLOW_EVENT` (event type)

### Code Review

**Availability**: Team and Enterprise plans. Not available with Zero Data Retention.

**Setup**: Admin enables at `claude.ai/admin-settings/claude-code` > Code Review > install Claude GitHub App > select repos > set triggers.

**Review triggers**:

| Trigger                    | When reviews run                                         | Cost       |
| :------------------------- | :------------------------------------------------------- | :--------- |
| Once after PR creation     | PR opened or marked ready for review                     | 1x per PR  |
| After every push           | Every push to the PR branch                              | Nx per PR  |
| Manual                     | Only on `@claude review` or `@claude review once`        | On demand  |

**Manual commands**:

| Command               | Effect                                                    |
| :-------------------- | :-------------------------------------------------------- |
| `@claude review`      | Start review + subscribe PR to push-triggered reviews     |
| `@claude review once` | Single review, no subscription to future pushes           |

Both must be posted as top-level PR comments (not inline on a diff line).

**Severity levels**:

| Marker | Severity     | Meaning                                          |
| :----- | :----------- | :----------------------------------------------- |
| Red    | Important    | Bug that should be fixed before merging          |
| Yellow | Nit          | Minor issue, worth fixing but not blocking       |
| Purple | Pre-existing | Bug in codebase but not introduced by this PR    |

**Customization files**:
- `CLAUDE.md` — project instructions; newly introduced violations flagged as nits
- `REVIEW.md` — review-only instructions injected as highest priority into every review agent. Tune severity definitions, nit caps, skip rules, repo-specific checks, and summary format.

**Pricing**: averages $15-25 per review, billed separately through extra usage.

### Slack integration

**Requirements**: Pro/Max/Team/Enterprise plan, Claude Code on the web access, connected GitHub account, Slack authentication.

**Setup**:
1. Admin installs Claude app from Slack App Marketplace
2. Each user connects their Claude account via the App Home tab
3. Configure routing mode: **Code only** or **Code + Chat**
4. Invite Claude to channels: `/invite @Claude`

**Session flow**: `@Claude` mention > coding intent detected > Claude Code web session created > progress updates in Slack > completion summary with "View Session" and "Create PR" buttons.

**Limitations**: GitHub only, one PR per session, rate limits apply, channels only (not DMs), web access required.

### GitHub Enterprise Server

**Feature support**:

| Feature              | Supported | Notes                                        |
| :------------------- | :-------- | :------------------------------------------- |
| Web sessions         | Yes       | Admin connects GHES once; developers use as usual |
| Code Review          | Yes       | Same as github.com                           |
| Teleport sessions    | Yes       | `--teleport` works with GHES repos           |
| Plugin marketplaces  | Yes       | Use full git URLs instead of `owner/repo`    |
| Contribution metrics | Yes       | Via webhooks to analytics dashboard          |
| GitHub Actions       | Yes       | Manual workflow setup only                   |
| GitHub MCP server    | No        | Use `gh` CLI configured for GHES instead     |

**Admin setup**: `claude.ai/admin-settings/claude-code` > GitHub Enterprise Server > Connect > enter hostname > create GitHub App via manifest > install on repos.

**Plugin marketplace on GHES**: `/plugin marketplace add git@github.example.com:org/repo.git` (full URL required). Use `hostPattern` in managed settings to allowlist GHES marketplaces.

### Cloud provider authentication (GitHub Actions + GitLab)

Both GitHub Actions and GitLab CI/CD support AWS Bedrock and Google Vertex AI as alternatives to the direct Claude API.

**AWS Bedrock requirements**: AWS account with Bedrock access, OIDC identity provider for GitHub/GitLab, IAM role with Bedrock permissions. Secrets: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`.

**Google Vertex AI requirements**: GCP project with Vertex AI API enabled, Workload Identity Federation configured, dedicated service account. Secrets: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`.

### Best practices (all integrations)

- Create a `CLAUDE.md` to define coding standards and project rules
- Never commit API keys; use repository/CI secrets and OIDC where possible
- Set appropriate `--max-turns` and job timeouts to control costs
- Review Claude's PRs/MRs like any other contributor's code

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — full guide to setup (quick and manual), action parameters, `claude_args` passthrough, example workflows (basic, code review, scheduled), beta-to-v1 migration, AWS Bedrock and Google Vertex AI configuration, custom GitHub Apps, cost considerations, and troubleshooting.
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — full guide to setup (quick and production), `.gitlab-ci.yml` job configuration, `AI_FLOW_*` variables, AWS Bedrock and Google Vertex AI OIDC workflows, example jobs, security and governance, cost optimization, and troubleshooting.
- [Claude Code in Slack](references/claude-code-slack.md) — setup flow, routing modes (Code only vs Code + Chat), automatic coding intent detection, context gathering from threads and channels, session lifecycle, UI elements (View Session, Create PR, Retry as Code, Change Repo), access and permissions, and troubleshooting.
- [Code Review](references/claude-code-code-review.md) — how multi-agent reviews work, severity levels, check run output with machine-readable severity counts, setup and trigger configuration, manual triggering with `@claude review` and `@claude review once`, customizing reviews with `CLAUDE.md` and `REVIEW.md`, analytics dashboard, pricing, and troubleshooting.
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — feature support table, admin setup (guided and manual), GitHub App permissions, network requirements, developer workflow with `--remote` and `--teleport`, plugin marketplaces on GHES (full git URLs, `hostPattern` allowlisting, `extraKnownMarketplaces`), limitations, and troubleshooting.

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
