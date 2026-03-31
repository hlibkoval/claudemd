---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions (setup via /install-github-app, manual setup, claude-code-action@v1, prompt/claude_args configuration, Bedrock/Vertex workflows, beta-to-GA migration), GitLab CI/CD (beta, .gitlab-ci.yml setup, AI_FLOW_* variables, OIDC auth for Bedrock/Vertex, gitlab-mcp-server), Slack integration (routing modes Code-only and Code+Chat, session flow, repo selection, channel-based access, App Home), automated Code Review (multi-agent PR analysis, severity levels, REVIEW.md customization, check run output, @claude review / @claude review once triggers, pricing, Teams/Enterprise), and GitHub Enterprise Server (GHES admin setup, guided/manual GitHub App creation, web sessions, Code Review, plugin marketplaces with full git URLs, hostPattern allowlisting, teleport sessions, network requirements). Load when discussing GitHub Actions, GitLab CI/CD, claude-code-action, @claude mentions in PRs/issues, automated code review, REVIEW.md, Code Review pricing, Slack integration with Claude Code, GHES setup, CI/CD pipelines, workflow files, anthropic_api_key secret, use_bedrock, use_vertex, claude_args, trigger_phrase, or any CI/CD and integration topic for Claude Code.
user-invocable: false
---

# CI/CD Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack integration, automated Code Review, and GitHub Enterprise Server support.

## Quick Reference

### Integration Overview

| Integration | Status | Trigger | Platform |
|:------------|:-------|:--------|:---------|
| GitHub Actions | GA (v1) | `@claude` in PR/issue comments, or `prompt` param | GitHub / GitHub Enterprise |
| GitLab CI/CD | Beta | `@claude` in MR/issue comments via webhook, or manual/MR pipeline triggers | GitLab |
| Slack | GA | `@Claude` mention in channels | Slack (routes to Claude Code on the web) |
| Code Review | Research preview | PR open, push, or `@claude review` comment | GitHub (Teams/Enterprise only) |
| GitHub Enterprise Server | GA | Same as GitHub Actions / Code Review | Self-hosted GHES instances |

### GitHub Actions Setup

**Quick setup:** Run `/install-github-app` in Claude Code terminal (requires repo admin, direct API only).

**Manual setup:**
1. Install the Claude GitHub App: https://github.com/apps/claude (needs Contents, Issues, Pull requests read/write)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from `examples/claude.yml` into `.github/workflows/`

**Minimal workflow:**

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
          anthropic_api_key: $\{{ secrets.ANTHROPIC_API_KEY }}
```

### GitHub Actions Parameters (v1)

| Parameter | Description | Required |
|:----------|:-----------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No (auto-responds to trigger phrase when omitted) |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

Common `claude_args` values: `--max-turns N`, `--model MODEL`, `--mcp-config PATH`, `--allowedTools TOOLS`, `--append-system-prompt "TEXT"`, `--debug`.

### Beta to GA Migration (GitHub Actions)

| Old Beta Input | New v1 Input |
|:---------------|:-------------|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD Setup

**Quick setup:**
1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add a Claude job to `.gitlab-ci.yml`

**Minimal job:**

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
    - apk update
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

**Mention-driven triggers:** Add a project webhook for "Comments (notes)" events. The listener calls the pipeline trigger API with `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, and `AI_FLOW_EVENT` variables when a comment contains `@claude`.

### Cloud Provider Auth (CI/CD)

| Provider | GitHub Actions | GitLab CI/CD |
|:---------|:--------------|:-------------|
| Claude API | `anthropic_api_key` secret | `ANTHROPIC_API_KEY` CI/CD variable |
| AWS Bedrock | `use_bedrock: "true"` + OIDC via `aws-actions/configure-aws-credentials@v4` | OIDC via `aws sts assume-role-with-web-identity` |
| Google Vertex AI | `use_vertex: "true"` + WIF via `google-github-actions/auth@v2` | WIF via `gcloud auth login --cred-file` |

Both platforms support OIDC/WIF for keyless authentication -- no static credentials stored.

### Slack Integration

| Requirement | Details |
|:------------|:--------|
| Claude Plan | Pro, Max, Teams, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one authenticated repository |
| Slack Authentication | Slack account linked to Claude account |

**Routing modes** (configured in App Home):

| Mode | Behavior |
|:-----|:---------|
| Code only | All `@Claude` mentions route to Claude Code sessions |
| Code + Chat | Claude routes coding tasks to Code, general questions to Chat |

**Session flow:** `@Claude` mention > coding intent detected > session created on claude.ai/code > progress updates in Slack thread > completion summary with "View Session" / "Create PR" buttons.

**Access control:** Channel-based. Claude must be invited with `/invite @Claude`. Works in public and private channels, not in DMs.

### Code Review

**Availability:** Teams and Enterprise plans only (research preview). Not available with Zero Data Retention.

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Review behavior options** (per repository):

| Trigger | When it runs |
|:--------|:------------|
| Once after PR creation | On PR open or marked ready for review |
| After every push | On every push to the PR branch |
| Manual | Only on `@claude review` or `@claude review once` |

**Manual trigger commands:**

| Command | Effect |
|:--------|:-------|
| `@claude review` | Starts review and subscribes PR to push-triggered reviews |
| `@claude review once` | Single review without subscribing to future pushes |

Must be a top-level PR comment (not inline on diff). Requires owner/member/collaborator access.

**Customization files:**
- `CLAUDE.md` -- shared project instructions (violations flagged as nits)
- `REVIEW.md` -- review-only guidance (always-check rules, skip rules, style conventions)

**Check run output:** Machine-readable severity JSON available via:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns `{"normal": N, "nit": N, "pre_existing": N}` where `normal` = Important findings count.

**Pricing:** Token-based, averages $15-25 per review. Billed separately through extra usage. Set spend cap at claude.ai/admin-settings/usage. Monitor at claude.ai/analytics/code-review.

### GitHub Enterprise Server

**Supported features:** Web sessions, Code Review, teleport, plugin marketplaces, contribution metrics, GitHub Actions (manual workflow setup). GitHub MCP server is not supported (use `gh` CLI instead).

**Admin setup:** Guided flow at claude.ai/admin-settings/claude-code > Connect > enter hostname > redirects to GHES to create GitHub App > install on repositories. Alternative manual setup available.

**GitHub App permissions:** Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R).

**Plugin marketplaces on GHES:** Use full git URL instead of `owner/repo` shorthand:

```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Allowlist via managed settings with `hostPattern`:

```json
{
  "strictKnownMarketplaces": [
    {"source": "hostPattern", "hostPattern": "^github\\.example\\.com$"}
  ]
}
```

**Network requirement:** GHES must be reachable from Anthropic infrastructure. Allowlist Anthropic API IP addresses if behind a firewall.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) -- Setup (quick via /install-github-app, manual), v1 action parameters (prompt, claude_args, trigger_phrase, use_bedrock, use_vertex), beta-to-GA migration guide, workflow examples (basic, skills, custom automation, scheduled), AWS Bedrock and Google Vertex AI workflows with OIDC/WIF, custom GitHub App creation, advanced configuration, cost optimization
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- Beta integration maintained by GitLab, .gitlab-ci.yml setup, AI_FLOW_* variables for mention-driven triggers, Claude API / AWS Bedrock OIDC / Google Vertex AI WIF configuration examples, permission-mode acceptEdits, gitlab-mcp-server, security and governance, troubleshooting
- [Claude Code in Slack](references/claude-code-slack.md) -- Slack app setup, routing modes (Code only, Code + Chat), automatic coding intent detection, context gathering from threads/channels, session flow with progress updates, App Home, message actions (View Session, Create PR, Retry as Code, Change Repo), user-level and workspace-level access, channel-based access control, current limitations
- [Code Review](references/claude-code-code-review.md) -- Multi-agent PR analysis, severity levels (Important/Nit/Pre-existing), check run output with machine-readable severity JSON, setup (admin settings, GitHub App, repository selection, review behavior triggers), manual triggers (@claude review, @claude review once), customization via CLAUDE.md and REVIEW.md, analytics dashboard, pricing ($15-25 avg per review), troubleshooting failed/timed-out reviews and missing inline comments
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) -- GHES support for web sessions, Code Review, teleport, plugin marketplaces, contribution metrics; admin setup (guided and manual GitHub App creation, permissions, network requirements); developer workflow (auto-detection from git remote, claude --remote); GHES plugin marketplaces (full git URLs, hostPattern allowlisting, extraKnownMarketplaces); limitations and troubleshooting

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
