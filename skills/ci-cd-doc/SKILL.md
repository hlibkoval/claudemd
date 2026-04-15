---
name: ci-cd-doc
description: Complete official documentation for running Claude Code in CI/CD environments - GitHub Actions, GitLab CI/CD, Slack, managed Code Review, and GitHub Enterprise Server.
user-invocable: false
---

# CI/CD Integration Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines and developer collaboration tools.

## Quick Reference

### Integration options at a glance

| Integration | Trigger | Where it runs | Best for |
| --- | --- | --- | --- |
| GitHub Actions | `@claude` mention or workflow event | Your GitHub-hosted runners | Custom GitHub automation |
| GitLab CI/CD (beta) | `@claude` mention, manual, or MR event | Your GitLab runners | Self-hosted GitLab pipelines |
| Slack | `@Claude` mention in a channel | Claude Code on the web | Async tasks, team collaboration |
| Code Review (managed) | PR open, push, or `@claude review` | Anthropic infrastructure | Automated multi-agent PR review |
| GitHub Enterprise Server | Same as github.com features | Anthropic infra + your GHES | Self-hosted GitHub instances |

### GitHub Actions: v1 input parameters

| Parameter | Description | Required |
| --- | --- | --- |
| `prompt` | Plain text instructions or skill name | No (omit for `@claude` reply mode) |
| `claude_args` | Pass-through CLI arguments to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes for direct API |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default `@claude`) | No |
| `use_bedrock` | Route through AWS Bedrock | No |
| `use_vertex` | Route through Google Vertex AI | No |

Common `claude_args` values: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--debug`, `--append-system-prompt`.

### GitHub Actions v1 migration (from beta)

| Old beta input | New v1 input |
| --- | --- |
| `mode` | (removed; auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

Update action ref from `@beta` to `@v1`. Defaults to Sonnet; set `--model claude-opus-4-6` for Opus.

### Quick GitHub Actions setup

1. Open Claude in the terminal and run `/install-github-app` (admin only). It installs the Claude GitHub App and adds `ANTHROPIC_API_KEY` as a repo secret.
2. For manual setup: install [github.com/apps/claude](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` to repo secrets, and copy the workflow from `examples/claude.yml` in `anthropics/claude-code-action`.
3. Test by tagging `@claude` in an issue or PR comment.

Required GitHub App permissions: Contents (R/W), Issues (R/W), Pull requests (R/W).

### GitLab CI/CD: setup essentials

- Add masked CI/CD variable `ANTHROPIC_API_KEY` in Settings to CI/CD to Variables.
- Add a `claude` job to `.gitlab-ci.yml` running `claude -p "$AI_FLOW_INPUT" --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab"`.
- Use `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT` for context payloads from web/API triggers.
- For GitLab API operations use `CI_JOB_TOKEN` or a Project Access Token with `api` scope (store as `GITLAB_ACCESS_TOKEN`).
- Optional: enable a webhook listener for note events to catch `@claude` mentions.

### Cloud provider authentication

| Provider | Auth method | Required secrets |
| --- | --- | --- |
| AWS Bedrock | OIDC with IAM role | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | Workload Identity Federation | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |
| Direct Claude API | API key | `ANTHROPIC_API_KEY` |

For GitHub Actions with cloud providers, also add `APP_ID` and `APP_PRIVATE_KEY` for a custom GitHub App. Bedrock model IDs include a region prefix (e.g., `us.anthropic.claude-sonnet-4-6`).

### Slack integration

Prerequisites: Pro/Max/Team/Enterprise plan with Claude Code, Claude Code on the web enabled, GitHub connected with at least one repo, Slack account linked to Claude.

| Setting | Behavior |
| --- | --- |
| **Code only** routing | All `@Claude` mentions create Claude Code sessions |
| **Code + Chat** routing | Auto-routes by intent; "Retry as Code" flips chat replies to Code |

Setup steps: install Claude app from Slack Marketplace, connect Claude account from App Home, configure Claude Code on the web, choose routing mode, then `/invite @Claude` to channels (DMs are not supported).

Action buttons in Slack: **View Session**, **Create PR**, **Retry as Code**, **Change Repo**. Sessions count against each user's individual plan; users only see repos they personally connected.

Limitations: GitHub only, one PR per session, channels only (no DMs).

### Code Review (managed service)

Research preview for Team and Enterprise plans. Not available with Zero Data Retention. Multi-agent analysis on Anthropic infrastructure, posts inline PR comments.

| Trigger mode | When reviews run |
| --- | --- |
| Once after PR creation | Single review when PR is opened or marked ready |
| After every push | Review on every push, auto-resolves fixed threads |
| Manual | Only on `@claude review` or `@claude review once` |

| Severity marker | Meaning |
| --- | --- |
| Important (red) | Bug that should block merge |
| Nit (yellow) | Minor issue, non-blocking |
| Pre-existing (purple) | Bug not introduced by this PR |

| Comment command | Effect |
| --- | --- |
| `@claude review` | Start review and subscribe PR to push-triggered reviews |
| `@claude review once` | Single review without subscribing to future pushes |

Findings appear as inline comments, **Files changed** annotations, and the **Claude Code Review** check run (always neutral conclusion - never blocks merge). Parse severity counts from check run output:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Customize via `CLAUDE.md` (project-wide, hierarchical) and `REVIEW.md` (review-only rules at repo root). Pricing: ~$15-25 per review, billed via extra usage separate from your plan.

### GitHub Enterprise Server

Available for Team and Enterprise plans. Admin connects the GHES instance once via guided setup at claude.ai/admin-settings/claude-code; developers need no per-repo config.

| Feature | GHES support |
| --- | --- |
| Claude Code on the web | Supported |
| Code Review | Supported |
| Teleport sessions (`--teleport`) | Supported |
| Plugin marketplaces | Supported (full git URLs only, no `owner/repo` shorthand) |
| Contribution metrics | Supported via webhooks |
| GitHub Actions | Supported (manual workflow setup; `/install-github-app` is github.com only) |
| GitHub MCP server | Not supported (use `gh` CLI configured with `gh auth login --hostname`) |

GitHub App permissions: Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R). Subscribes to `pull_request`, `issue_comment`, `pull_request_review_comment`, `pull_request_review`, `check_run` events. GHES instance must be reachable from Anthropic infrastructure (allowlist Anthropic API IPs).

For GHES marketplaces in managed settings, use `hostPattern` source type to allow all marketplaces from a host:

```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

### Common patterns

- **CLAUDE.md**: Place in repo root to define coding standards, review criteria, and project rules. Read by all CI/CD integrations and code review.
- **Never commit secrets**: Always use GitHub Secrets, GitLab CI/CD masked variables, or cloud OIDC. Prefer OIDC over long-lived keys.
- **Cost controls**: Use `--max-turns`, workflow timeouts, concurrency limits, and specific `@claude` commands to bound usage.
- **Verify CI runs on Claude commits**: Use a GitHub App (not the Actions user) so workflows trigger on Claude's pushes.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) - Setting up and configuring the v1 GitHub Action, including workflows for direct Claude API, AWS Bedrock, and Google Vertex AI.
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) - Beta GitLab CI/CD integration with `.gitlab-ci.yml` examples for Claude API, Bedrock OIDC, and Vertex AI Workload Identity Federation.
- [Claude Code in Slack](references/claude-code-slack.md) - Routing Slack `@Claude` mentions to Claude Code on the web, including setup, routing modes, access controls, and limitations.
- [Code Review](references/claude-code-code-review.md) - Managed multi-agent PR review service with severity tagging, `CLAUDE.md`/`REVIEW.md` customization, manual triggers, and pricing.
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) - Connecting self-hosted GHES instances for web sessions, code review, plugin marketplaces, and contribution metrics.

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
