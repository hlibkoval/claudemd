---
name: ci-cd-doc
description: Complete official documentation for integrating Claude Code into CI/CD pipelines and collaboration tools — GitHub Actions, GitLab CI/CD, automated code review, GitHub Enterprise Server, and Slack integration.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD workflows, automated code review, and team collaboration tools.

## Quick Reference

### GitHub Actions — Setup

**Quickest path**: run `/install-github-app` inside Claude Code (requires repo admin, direct Claude API only).

**Manual setup:**
1. Install the Claude GitHub App: https://github.com/apps/claude
   - Permissions needed: Contents (R/W), Issues (R/W), Pull requests (R/W)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy `examples/claude.yml` into `.github/workflows/`

**Trigger Claude:** mention `@claude` in any issue or PR comment.

### GitHub Actions — Action Parameters (v1)

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Instructions for Claude (or a skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (direct API) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

**Common `claude_args`:**
- `--max-turns 10` — limit conversation turns
- `--model claude-sonnet-4-6` — specify model
- `--allowedTools Bash,Read,Edit` — restrict tool access
- `--append-system-prompt "..."` — add system instructions
- `--mcp-config /path/to/config.json` — load MCP servers

### GitHub Actions — Workflow Examples

**Basic (responds to `@claude` mentions):**
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

**Automated PR review on every push:**
```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "Review this pull request for code quality, correctness, and security."
    claude_args: "--max-turns 5"
```

### GitHub Actions — Beta to v1 Migration

| Old Beta Input | New v1.0 Input |
| :--- | :--- |
| `mode` | *(Removed — auto-detected)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD — Quick Setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings → CI/CD → Variables)
2. Add a Claude job to `.gitlab-ci.yml`:

```yaml
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
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Context variables** passed via pipeline triggers:
- `AI_FLOW_INPUT` — the task prompt
- `AI_FLOW_CONTEXT` — additional context
- `AI_FLOW_EVENT` — the event type (e.g., note, MR event)

**Trigger Claude:** mention `@claude` in an issue or MR comment (requires a webhook/event listener that triggers the pipeline).

### Cloud Provider Authentication

| Provider | Required Secrets | Method |
| :--- | :--- | :--- |
| Claude API (direct) | `ANTHROPIC_API_KEY` | API key |
| Amazon Bedrock (GitHub Actions) | `AWS_ROLE_TO_ASSUME` | OIDC → IAM role |
| Amazon Bedrock (GitLab CI) | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` | OIDC → IAM role |
| Google Vertex AI (GitHub Actions) | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` | Workload Identity Federation |
| Google Vertex AI (GitLab CI) | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` | Workload Identity Federation |

**Bedrock model ID format:** include region prefix, e.g., `us.anthropic.claude-sonnet-4-6`
**Custom GitHub App secrets** (when not using Anthropic's app): `APP_ID`, `APP_PRIVATE_KEY`

### Code Review (Managed Service)

Available for Team and Enterprise plans. Not available with Zero Data Retention.

**Setup:** go to claude.ai/admin-settings/claude-code → Code Review → Setup.

**Review trigger modes per repository:**

| Mode | Behavior |
| :--- | :--- |
| Once after PR creation | Single review when PR opens or is marked ready |
| After every push | Review on each push; auto-resolves threads when issues are fixed |
| Manual | Only runs when `@claude review` is commented on the PR |

**Manual trigger commands (top-level PR comment only):**

| Command | What it does |
| :--- | :--- |
| `@claude review` | Starts review and subscribes PR to push-triggered reviews |
| `@claude review once` | Single review; does not subscribe to future pushes |

**Severity levels:**

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| 🔴 | Important | Bug that should be fixed before merging |
| 🟡 | Nit | Minor issue, worth fixing but not blocking |
| 🟣 | Pre-existing | Bug in codebase not introduced by this PR |

**Parse severity from check run (for CI gating):**
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# Returns e.g. {"normal": 2, "nit": 1, "pre_existing": 0}
# "normal" = count of Important findings
```

**Customization files:**
- `CLAUDE.md` — project-wide instructions; violations flagged as nits
- `REVIEW.md` — review-only instructions, highest priority; injected verbatim into every review agent

**Pricing:** ~$15–25 per review; billed separately via extra usage.

**Retrigger failed review:** comment `@claude review once` (the Re-run button in GitHub Checks does not work).

### GitHub Enterprise Server (GHES)

Available for Team and Enterprise plans. Admin connects the GHES instance once; no per-developer configuration needed.

**Setup:** claude.ai/admin-settings/claude-code → GitHub Enterprise Server → Connect.
- Enter display name and GHES hostname (e.g., `github.example.com`)
- Optionally paste CA certificate for private CAs
- GitHub App is created via manifest redirect; install it on desired repositories

**GitHub App permissions:**

| Permission | Access | Used for |
| :--- | :--- | :--- |
| Contents | Read & write | Cloning repos, pushing branches |
| Pull requests | Read & write | Creating PRs, posting review comments |
| Issues | Read & write | Responding to issue mentions |
| Checks | Read & write | Posting Code Review check runs |
| Actions | Read | Reading CI status for auto-fix |
| Repository hooks | Read & write | Webhooks for contribution metrics |
| Metadata | Read | Required by GitHub for all apps |

**Feature support matrix:**

| Feature | GHES support | Notes |
| :--- | :--- | :--- |
| Claude Code on the web | Supported | Use `claude --remote` as normal |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | `--teleport` flag |
| Plugin marketplaces | Supported | Use full git URLs instead of `owner/repo` |
| Contribution metrics | Supported | Via webhooks |
| GitHub Actions | Supported | Manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI with `gh auth login --hostname github.example.com` |

**GHES marketplace URLs (full git URL required):**
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
/plugin marketplace add https://github.example.com/platform/claude-plugins.git
```

**Allowlist GHES in managed settings:**
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

**Network requirement:** your GHES instance must be reachable from Anthropic infrastructure. Allowlist Anthropic API IP addresses if behind a firewall.

### Claude Code in Slack

**Prerequisites:** Pro/Max/Team/Enterprise with Claude Code access; Claude Code on the web enabled; GitHub account connected; Slack account linked to Claude account.

**Setup:**
1. Workspace admin installs Claude app from Slack Marketplace
2. Each user connects their Claude account via the App Home tab
3. Configure GitHub connection at claude.ai/code
4. Choose routing mode in App Home

**Routing modes:**

| Mode | Behavior |
| :--- | :--- |
| Code only | All @mentions routed to Claude Code sessions |
| Code + Chat | Claude intelligently routes between Claude Code and Chat |

**Usage:** mention `@Claude` in any channel where Claude has been invited (`/invite @Claude`).
- Claude gathers context from the thread or recent channel messages
- Works in public and private channels only (not DMs)
- Each session runs under the individual user's Claude account

**Session actions:** View Session, Create PR, Retry as Code, Change Repo.

**Current limitations:** GitHub only; one PR per session; rate limits apply per individual user plan.

### Security Best Practices (All Integrations)

- Never hardcode API keys in workflow files — always use secrets/CI variables
- Use OIDC-based authentication for Bedrock and Vertex AI (avoids long-lived credentials)
- Use specific `@claude` commands to limit unnecessary API calls
- Set `--max-turns` to prevent runaway jobs
- Configure workflow-level timeouts
- Add a `CLAUDE.md` to define project standards Claude should follow

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, workflow examples, cloud provider integration, troubleshooting, and advanced configuration
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — setup, GitLab job examples, Bedrock/Vertex AI integration, best practices, and security guidance
- [Code Review](references/claude-code-code-review.md) — automated PR reviews, severity levels, setup, manual triggers, REVIEW.md customization, pricing, and troubleshooting
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, GitHub App permissions, developer workflow, GHES plugin marketplaces, and limitations
- [Claude Code in Slack](references/claude-code-slack.md) — setup, routing modes, session flow, permissions model, and best practices

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
