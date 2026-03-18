---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations — GitHub Actions (claude-code-action setup, @claude trigger, workflow configuration, prompt/claude_args parameters, Bedrock/Vertex provider support, beta-to-v1 migration, action parameters reference), GitLab CI/CD (beta .gitlab-ci.yml setup, AI_FLOW_* variables, OIDC authentication for Bedrock/Vertex, GitLab MCP server, mention-driven triggers), Claude Code in Slack (routing modes Code-only vs Code+Chat, session flow from Slack to claude.ai/code, repository selection, channel-based access control, prerequisites and authentication), and Code Review (managed multi-agent PR review service for Teams/Enterprise, severity levels, REVIEW.md customization, review triggers once/every-push/manual, @claude review command, pricing, analytics dashboard). Also covers shared topics: CLAUDE.md for CI behavior, security best practices, cost optimization, and enterprise cloud provider authentication (AWS Bedrock OIDC, Google Vertex AI Workload Identity Federation). Load when discussing GitHub Actions for Claude, GitLab CI/CD integration, Claude in Slack, automated code review, PR review automation, @claude mentions in PRs/issues, claude-code-action, CI/CD setup, review triggers, REVIEW.md, or running Claude in CI pipelines.
user-invocable: false
---

# CI/CD Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines, chat platforms, and automated code review.

## Quick Reference

Claude Code offers four integration paths for automation beyond the CLI:

| Integration | Platform | Trigger | Runs on |
|:------------|:---------|:--------|:--------|
| **GitHub Actions** | GitHub | `@claude` mention or any GH event | GitHub-hosted runners |
| **GitLab CI/CD** | GitLab | MR events, `@claude` mentions, web/API triggers | Your GitLab runners |
| **Slack** | Slack | `@Claude` mention in channels | Claude Code on the web |
| **Code Review** | GitHub | PR open, push, or `@claude review` | Anthropic infrastructure |

### GitHub Actions

The `anthropics/claude-code-action@v1` action runs Claude Code in GitHub Actions workflows. Claude responds to `@claude` mentions in PRs/issues and can run custom prompts on any GitHub event.

**Quick setup:** Run `/install-github-app` in Claude Code, or manually install the [Claude GitHub App](https://github.com/apps/claude) and add `ANTHROPIC_API_KEY` as a repository secret.

**Key action parameters (v1):**

| Parameter | Description | Required |
|:----------|:------------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed through (e.g., `--max-turns 5 --model claude-sonnet-4-6`) | No |
| `anthropic_api_key` | API key (use `${{ secrets.ANTHROPIC_API_KEY }}`) | Yes (direct API) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

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

**Beta to v1 migration:** Replace `@beta` with `@v1`, remove `mode`, rename `direct_prompt` to `prompt`, and move `max_turns`/`model`/`custom_instructions` into `claude_args`.

### GitLab CI/CD

GitLab integration runs Claude Code in CI jobs via `.gitlab-ci.yml`. Currently in beta, maintained by GitLab.

**Quick setup:** Add `ANTHROPIC_API_KEY` as a masked CI/CD variable, then add a Claude job to `.gitlab-ci.yml`:

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
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Key variables for triggered pipelines:** `AI_FLOW_INPUT` (prompt), `AI_FLOW_CONTEXT` (context reference), `AI_FLOW_EVENT` (event type).

**Mention-driven triggers:** Add a project webhook for note events that calls the pipeline trigger API with `AI_FLOW_*` variables when a comment contains `@claude`.

### Claude Code in Slack

Delegates coding tasks from Slack to Claude Code on the web. Requires Pro/Max/Teams/Enterprise plan with Claude Code access and a connected GitHub account.

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| **Code only** | All `@Claude` mentions route to Claude Code sessions |
| **Code + Chat** | Claude intelligently routes between Code and Chat based on message content |

**Session flow:** `@Claude` mention in channel -> intent detection -> Claude Code session on claude.ai/code -> progress updates in Slack thread -> completion summary with "View Session" / "Create PR" buttons.

**Access model:** Channel-based. Claude must be invited to each channel with `/invite @Claude`. Works in public and private channels, not in DMs.

**Prerequisites:** Claude plan with Code access, Claude Code on the web enabled, GitHub account connected, Slack account linked to Claude.

### Code Review

Managed service that posts inline findings on GitHub PRs. Available for Teams and Enterprise (not available with Zero Data Retention). Multiple specialized agents analyze diffs in parallel on Anthropic infrastructure.

**Severity levels:**

| Marker | Level | Meaning |
|:-------|:------|:--------|
| Red circle | Normal | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Review triggers (per-repo):**

| Trigger | When reviews run |
|:--------|:-----------------|
| Once after PR creation | When PR is opened or marked ready for review |
| After every push | On every push to the PR branch |
| Manual | Only when someone comments `@claude review` |

**Customization files:**

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project conventions; violations flagged as nits |
| `REVIEW.md` | Code Review only | Review-specific rules, style guidelines, skip patterns |

**Setup:** Admin enables at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), installs the Claude GitHub App, selects repositories, and sets review triggers.

**Pricing:** Token-based, averages $15-25 per review. Billed as extra usage, separate from plan allowance. "After every push" multiplies cost by number of pushes.

### Enterprise Cloud Providers (Bedrock and Vertex AI)

Both GitHub Actions and GitLab CI/CD support AWS Bedrock and Google Vertex AI as alternatives to the direct Claude API.

**AWS Bedrock setup:**

| Requirement | Details |
|:------------|:--------|
| OIDC provider | GitHub/GitLab as identity provider in AWS IAM |
| IAM role | Bedrock permissions, trust policy for repo |
| Model ID format | Region-prefixed (e.g., `us.anthropic.claude-sonnet-4-6`) |
| Secrets | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |

**Google Vertex AI setup:**

| Requirement | Details |
|:------------|:--------|
| APIs | IAM Credentials, STS, Vertex AI enabled |
| Workload Identity Federation | Pool + provider for GitHub/GitLab OIDC |
| Service account | Vertex AI User role |
| Secrets | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` |

### Shared Best Practices

- Use `CLAUDE.md` at the repository root to define coding standards Claude follows in CI
- Never commit API keys; always use repository secrets / masked CI/CD variables
- Configure appropriate `--max-turns` and job timeouts to control cost and runtime
- Use OIDC/Workload Identity Federation for cloud providers (no long-lived keys)
- Review Claude's PRs/MRs like any other contributor

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) -- setup (quick via /install-github-app and manual), GitHub App permissions, action parameters (prompt, claude_args, anthropic_api_key, github_token, trigger_phrase, use_bedrock, use_vertex), basic workflow, skills in workflows, custom automation with prompts, beta-to-v1 migration (breaking changes reference table, before/after examples), CLAUDE.md configuration, security considerations, CI cost optimization, AWS Bedrock workflow (OIDC, IAM role, model ID format), Google Vertex AI workflow (Workload Identity Federation, service account), custom GitHub App creation, advanced configuration, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- beta status, quick setup (.gitlab-ci.yml job, ANTHROPIC_API_KEY variable), manual setup for production, AI_FLOW_* variables for triggered pipelines, mention-driven triggers via webhooks, AWS Bedrock job (OIDC token exchange, IAM role), Google Vertex AI job (Workload Identity Federation, gcloud auth), configuration examples, CLAUDE.md configuration, security and governance, CI costs, advanced configuration, troubleshooting
- [Claude Code in Slack](references/claude-code-slack.md) -- prerequisites (plan, Claude Code on web, GitHub, Slack auth), setup steps (install app, connect account, configure routing mode, add to channels), routing modes (Code only, Code + Chat), automatic detection and context gathering, session flow, UI elements (App Home, message actions, repository selection), user-level and workspace-level access, channel-based access control, best practices, troubleshooting, current limitations (GitHub only, one PR per session, rate limits)
- [Code Review](references/claude-code-code-review.md) -- research preview for Teams/Enterprise, multi-agent analysis, severity levels (normal/nit/pre-existing), setup (admin settings, GitHub App, repository selection, review triggers), manually triggering reviews (@claude review), customizing reviews (CLAUDE.md, REVIEW.md with examples), usage analytics dashboard, pricing ($15-25 average per review, extra usage billing, cost by trigger mode), related resources

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
