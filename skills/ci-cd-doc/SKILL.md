---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, Slack, automated Code Review, and GitHub Enterprise Server support.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations, automated code review, Slack, and GitHub Enterprise Server.

## Quick Reference

### Integration overview

| Integration               | Status             | Trigger                                 | Platform     |
| :------------------------ | :----------------- | :-------------------------------------- | :----------- |
| GitHub Actions            | GA (v1)            | `@claude` in PR/issue comments, or any GitHub event with `prompt` | GitHub       |
| GitLab CI/CD              | Beta               | `@claude` in MR/issue comments, web/API triggers, MR events | GitLab       |
| Slack                     | GA                 | `@Claude` mention in channels           | Slack        |
| Code Review               | Research preview   | PR open, every push, or `@claude review` | GitHub       |
| GitHub Enterprise Server  | GA                 | Same as github.com features             | Self-hosted GHES |

### GitHub Actions (claude-code-action)

**Quick setup**: Run `/install-github-app` in Claude Code terminal, or manually install the [Claude GitHub App](https://github.com/apps/claude) and add `ANTHROPIC_API_KEY` as a repository secret.

**Action**: `anthropics/claude-code-action@v1`

| Parameter           | Description                                              | Required |
| :------------------ | :------------------------------------------------------- | :------- |
| `prompt`            | Instructions for Claude (plain text or skill name)       | No       |
| `claude_args`       | CLI arguments passed to Claude Code                      | No       |
| `anthropic_api_key` | Claude API key                                           | Yes*     |
| `github_token`      | GitHub token for API access                              | No       |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)               | No       |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API                    | No       |
| `use_vertex`        | Use Google Vertex AI instead of Claude API               | No       |

*Required for direct Claude API; not for Bedrock/Vertex.

**Common `claude_args`**: `--max-turns 5`, `--model claude-sonnet-4-6`, `--mcp-config /path/to/config.json`, `--allowedTools`, `--debug`

**Minimal workflow**:

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

**Beta to v1 migration**:

| Old Beta Input        | New v1 Input                        |
| :-------------------- | :---------------------------------- |
| `mode`                | *(Removed -- auto-detected)*       |
| `direct_prompt`       | `prompt`                            |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`          |
| `model`               | `claude_args: --model`              |
| `allowed_tools`       | `claude_args: --allowedTools`       |
| `claude_env`          | `settings` JSON format              |

### GitLab CI/CD

**Quick setup**: Add `ANTHROPIC_API_KEY` as a masked CI/CD variable, then add a Claude job to `.gitlab-ci.yml`.

**Minimal job**:

```yaml
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
    - claude -p "${AI_FLOW_INPUT:-'Review this MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Key variables**: `AI_FLOW_INPUT` (prompt from trigger), `AI_FLOW_CONTEXT` (context payload), `AI_FLOW_EVENT` (event type).

### Code Review

**Availability**: Team and Enterprise plans. Not available with Zero Data Retention.

**How it works**: Multi-agent analysis runs on Anthropic infrastructure. Agents examine the diff and surrounding code in parallel, verify findings against actual code behavior, deduplicate, and post inline comments on the PR.

**Review triggers** (per-repo setting):

| Trigger                    | Behavior                                        |
| :------------------------- | :---------------------------------------------- |
| Once after PR creation     | Runs once when PR opens or is marked ready      |
| After every push           | Runs on each push, auto-resolves fixed issues   |
| Manual                     | Only on `@claude review` / `@claude review once` |

**Manual commands** (top-level PR comments only):

| Command               | Effect                                                    |
| :--------------------- | :-------------------------------------------------------- |
| `@claude review`      | Start review + subscribe PR to push-triggered reviews     |
| `@claude review once` | Single review, no subscription to future pushes           |

**Severity levels**:

| Marker | Severity     | Meaning                                              |
| :----- | :----------- | :--------------------------------------------------- |
| Red    | Important    | Bug that should be fixed before merging              |
| Yellow | Nit          | Minor issue, worth fixing but not blocking           |
| Purple | Pre-existing | Bug in codebase, not introduced by this PR           |

**Customization files**:

| File         | Scope                   | Priority                      | Effect                                  |
| :----------- | :---------------------- | :---------------------------- | :-------------------------------------- |
| `CLAUDE.md`  | All Claude Code tasks   | Project context               | New violations flagged as nits          |
| `REVIEW.md`  | Code Review only        | Highest (system prompt level) | Override severity, skip rules, add checks |

**REVIEW.md tuning areas**: severity calibration, nit volume caps, skip rules (paths/branches/categories), repo-specific checks, verification bar, re-review convergence, summary shape.

**Pricing**: ~$15-25 per review on average, billed separately through extra usage. Scales with PR size and complexity. Set a monthly spend cap at `claude.ai/admin-settings/usage`.

**Check run output**: The Claude Code Review check run shows a severity table and annotations in the Files changed tab. Parse machine-readable severity counts from the check run details:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

### Slack integration

**Prerequisites**: Pro/Max/Team/Enterprise plan, Claude Code on the web access, connected GitHub account, Slack authentication linked to Claude account.

**Routing modes**: **Code only** (all mentions go to Claude Code sessions) or **Code + Chat** (intelligent routing between Claude Code and Claude Chat).

**Session flow**: `@Claude` mention in channel -> coding intent detected -> session created on claude.ai/code -> progress updates posted in Slack thread -> completion with summary and action buttons (View Session, Create PR, Retry as Code, Change Repo).

**Key constraints**: works in channels only (not DMs), GitHub only (no GitLab), one PR per session, uses individual user's plan rate limits.

### GitHub Enterprise Server

**Availability**: Team and Enterprise plans.

**Feature support on GHES**:

| Feature                | Supported |
| :--------------------- | :-------- |
| Claude Code on the web | Yes       |
| Code Review            | Yes       |
| Teleport sessions      | Yes       |
| Plugin marketplaces    | Yes (use full git URLs) |
| Contribution metrics   | Yes       |
| GitHub Actions         | Yes (manual workflow setup) |
| GitHub MCP server      | No        |

**Admin setup**: Connect once at `claude.ai/admin-settings/claude-code` via guided GitHub App manifest flow. Requires GHES instance reachable from Anthropic infrastructure (allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses)).

**Developer workflow**: No config needed after admin setup. `claude --remote` auto-detects GHES host from git remote. Teleport with `claude --teleport`.

**GHES plugin marketplaces**: Use full git URLs (`git@github.example.com:org/repo.git`), not `owner/repo` shorthand. Allowlist via `hostPattern` in managed settings.

### Cloud provider authentication (GitHub Actions and GitLab CI/CD)

Both GitHub Actions and GitLab CI/CD support AWS Bedrock and Google Vertex AI as alternatives to the direct Claude API:

| Provider        | Auth method                     | Required secrets/variables                           |
| :-------------- | :------------------------------ | :--------------------------------------------------- |
| Claude API      | API key                         | `ANTHROPIC_API_KEY`                                  |
| AWS Bedrock     | OIDC -> IAM role                | `AWS_ROLE_TO_ASSUME`, `AWS_REGION`                   |
| Google Vertex   | Workload Identity Federation    | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` |

**Bedrock model IDs** use region prefixes: `us.anthropic.claude-sonnet-4-6`

### Cost optimization tips

- Use specific `@claude` commands to reduce unnecessary API calls
- Set `--max-turns` to prevent excessive iterations
- Set workflow/job timeouts to avoid runaway runs
- Use concurrency controls to limit parallel runs
- Keep `CLAUDE.md` concise and focused to reduce token usage
- For Code Review: choose Manual trigger for high-traffic repos

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup (quick and manual), action parameters, cloud provider workflows (Bedrock, Vertex), configuration examples, upgrading from beta, troubleshooting, and best practices.
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — setup (quick and production), CI/CD job examples for Claude API / Bedrock / Vertex, mention-driven triggers, configuration, security, and troubleshooting.
- [Claude Code in Slack](references/claude-code-slack.md) — setup, routing modes, session flow, context gathering, UI elements, access and permissions, and troubleshooting.
- [Code Review](references/claude-code-code-review.md) — how reviews work, severity levels, setup, manual triggers, customization with CLAUDE.md and REVIEW.md, check run output, pricing, analytics, and troubleshooting.
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, GitHub App permissions, developer workflow, plugin marketplaces on GHES, network requirements, limitations, and troubleshooting.

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
