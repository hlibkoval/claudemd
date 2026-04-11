---
name: ci-cd-doc
description: Complete official documentation for integrating Claude Code into CI/CD pipelines and team collaboration tools — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, managed Code Review, and Claude in Slack. Covers workflow setup, provider authentication (Claude API, AWS Bedrock, Google Vertex AI), the v1 action parameters, @claude triggers, REVIEW.md customization, and troubleshooting.
user-invocable: false
---

# CI/CD and Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code with CI/CD systems (GitHub Actions, GitLab CI/CD), self-hosted GitHub Enterprise Server, the managed Code Review service, and the Claude in Slack integration.

## Quick Reference

### Integration options

| Integration | Hosted by | Use when |
| --- | --- | --- |
| GitHub Actions (`anthropics/claude-code-action@v1`) | Your GitHub runners | Custom workflows, @claude PR/issue mentions, scheduled jobs |
| GitLab CI/CD | Your GitLab runners | GitLab projects; MR automation (beta, maintained by GitLab) |
| GitHub Enterprise Server (GHES) | Your self-hosted GitHub + Anthropic infra | Self-hosted GitHub repos; web sessions, Code Review, plugin marketplaces |
| Code Review (managed) | Anthropic infrastructure | Automated inline PR reviews without running your own CI |
| Claude in Slack | Slack + Claude Code on the web | Delegating coding tasks from Slack channels |

### GitHub Actions — v1 action parameters

| Parameter | Description | Required |
| --- | --- | --- |
| `prompt` | Instructions for Claude (plain text or a skill name) | No (optional for @claude comment triggers) |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes for direct Claude API |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default `@claude`) | No |
| `use_bedrock` | Route via AWS Bedrock | No |
| `use_vertex` | Route via Google Vertex AI | No |

Common `claude_args` flags: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools` (alias `--allowed-tools`), `--debug`, `--append-system-prompt`, `--disallowedTools`.

### GitHub Actions — beta to v1 migration

| Old Beta Input | New v1 Input |
| --- | --- |
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

Essential v1 upgrade steps: change `@beta` to `@v1`; delete `mode:`; replace `direct_prompt` with `prompt`; move CLI options into `claude_args`.

### GitHub Actions — GitHub App permissions

Contents: Read & write · Issues: Read & write · Pull requests: Read & write. Quick setup via `/install-github-app` in Claude (direct Claude API only); manual setup installs `github.com/apps/claude` and adds `ANTHROPIC_API_KEY` to repo secrets.

### GitHub Actions — Bedrock / Vertex secrets

| Provider | Required secrets |
| --- | --- |
| Claude API (direct) | `ANTHROPIC_API_KEY` (+ optional `APP_ID`, `APP_PRIVATE_KEY` for custom GitHub App) |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME` (via OIDC); `APP_ID`, `APP_PRIVATE_KEY` for custom app. Bedrock model IDs include a region prefix (e.g. `us.anthropic.claude-sonnet-4-6`). |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`; `APP_ID`, `APP_PRIVATE_KEY` for custom app. Env: `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION`, `VERTEX_REGION_CLAUDE_4_5_SONNET`. |

Workflow permissions for cloud providers need `id-token: write` (plus `contents`, `issues`, `pull-requests`).

### GitLab CI/CD — key pieces

- Install Claude Code in the job: `curl -fsSL https://claude.ai/install.sh | bash`
- Invoke via CLI: `claude -p "..." --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab" --debug`
- Masked CI/CD variable: `ANTHROPIC_API_KEY` (Settings -> CI/CD -> Variables)
- Mention-driven triggers: pipe note webhooks to a listener that calls the pipeline trigger API with `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT`
- GitLab API writes: use `CI_JOB_TOKEN` or a Project Access Token stored as `GITLAB_ACCESS_TOKEN` with `api` scope
- Common parameters: `prompt` / `prompt_file`, `max_turns`, `timeout_minutes`; run `claude --help` inside a job to see flags

### GitLab — Bedrock / Vertex variables

| Provider | Variables |
| --- | --- |
| AWS Bedrock (OIDC) | `AWS_ROLE_TO_ASSUME`, `AWS_REGION`; exchange `CI_JOB_JWT_V2` via `aws sts assume-role-with-web-identity` |
| Google Vertex AI (WIF) | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` (e.g. `us-east5`); authenticate with `gcloud auth login --cred-file=` (external_account JSON) |

### Managed Code Review (Team/Enterprise research preview)

Multi-agent service that posts inline PR comments. Not available under Zero Data Retention.

| Review Behavior | When it runs |
| --- | --- |
| Once after PR creation | On PR open or ready-for-review |
| After every push | Each push; auto-resolves threads when fixed |
| Manual | Only when `@claude review` or `@claude review once` is commented |

| Severity marker | Meaning |
| --- | --- |
| Red dot — Important | Bug to fix before merging |
| Yellow dot — Nit | Minor issue |
| Purple dot — Pre-existing | Bug already in the codebase |

| Command | Effect |
| --- | --- |
| `@claude review` | Review now and subscribe the PR to push-triggered reviews |
| `@claude review once` | One-shot review without subscribing |

Manual commands must be top-level PR comments, placed at the start of the comment, by someone with owner/member/collaborator access; PR must be open. Manual runs work on draft PRs.

Customization files Code Review reads:
- `CLAUDE.md` — shared guidance; violations become nit-level findings (applies at every directory level)
- `REVIEW.md` — review-only guidance at repo root; auto-discovered, no config

Check run: **Claude Code Review** always completes with a neutral conclusion (never blocks merges). Parse severity counts from the details text:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Pricing: ~$15-25 per review, billed as extra usage (separate from plan quota). Cap spend at `claude.ai/admin-settings/usage`. Usage dashboard: `claude.ai/analytics/code-review`.

### GitHub Enterprise Server (GHES) support matrix

| Feature | GHES | Notes |
| --- | --- | --- |
| Claude Code on the web | Supported | Admin connects GHES instance once |
| Code Review | Supported | Same behavior as github.com |
| Teleport sessions | Supported | `claude --teleport` |
| Plugin marketplaces | Supported | Use full git URLs, not `owner/repo` shorthand |
| Contribution metrics | Supported | Via webhooks to the analytics dashboard |
| GitHub Actions | Supported | Manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI configured for your GHES host |

GHES GitHub App permissions: Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R). Subscribes to `pull_request`, `issue_comment`, `pull_request_review_comment`, `pull_request_review`, `check_run`.

Add a GHES plugin marketplace:

```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Managed settings allowlist example:

```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

GHES instance must be reachable from Anthropic infrastructure; allowlist Anthropic API IP addresses if firewalled.

### Claude in Slack

| Requirement | Detail |
| --- | --- |
| Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub | Connected with at least one authenticated repository |
| Slack auth | Slack account linked to Claude account via the Claude app |

Routing modes (set in Claude App Home):

| Mode | Behavior |
| --- | --- |
| Code only | All @mentions routed to Claude Code sessions |
| Code + Chat | Intelligent routing; use "Retry as Code" to force a coding session |

- Only works in channels (public or private), not DMs
- Add to a channel with `/invite @Claude`
- Message actions: View Session, Create PR, Retry as Code, Change Repo
- Sessions run under the user's own Claude account and count against their plan limits
- Limitations: GitHub repositories only; one PR per session; rate limits apply per user

### Common `@claude` commands (PRs / issues / MRs)

```text
@claude implement this feature based on the issue description
@claude how should I implement user authentication for this endpoint?
@claude fix the TypeError in the user dashboard component
@claude review
@claude review once
```

Use `@claude` not `/claude`. Claude auto-detects interactive vs automation mode in v1 of the GitHub action.

### Security checklist

- Never commit API keys; use GitHub Secrets or GitLab masked CI/CD variables
- Prefer OIDC / Workload Identity Federation over long-lived cloud keys
- Restrict IAM roles / service accounts to specific repos/refs and minimum permissions
- Review AI-generated PRs / MRs like any contributor; branch protection still applies
- Configure `--max-turns` and job timeouts to contain cost and runaway runs

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — Full setup, v1 parameters, beta migration, Bedrock/Vertex workflows, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — `.gitlab-ci.yml` templates, provider auth, AI_FLOW_* variables, advanced config
- [Code Review](references/claude-code-code-review.md) — Managed multi-agent PR review service, severity levels, `REVIEW.md`, pricing, check-run parsing
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — Admin setup, app permissions, teleport, GHES marketplaces, limitations
- [Claude Code in Slack](references/claude-code-slack.md) — App install, routing modes, channel access, session flow, limitations

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
