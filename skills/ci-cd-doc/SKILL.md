---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack integration, automated Code Review, and GitHub Enterprise Server. Covers GitHub Actions setup (quick via /install-github-app, manual workflow), action parameters (prompt, claude_args, anthropic_api_key, trigger_phrase, use_bedrock, use_vertex), v1 migration from beta (breaking changes reference), @claude mention triggers, AWS Bedrock and Google Vertex AI workflows (OIDC, Workload Identity Federation), custom GitHub Apps, claude_args passthrough (--max-turns, --model, --allowedTools, --mcp-config); GitLab CI/CD setup (.gitlab-ci.yml, AI_FLOW_* variables, --permission-mode acceptEdits), GitLab MCP server, OIDC auth for Bedrock/Vertex from GitLab, Project Access Tokens; Slack integration (Code only vs Code + Chat routing, @Claude mentions, session flow, auto-detection, context gathering from threads/channels, repository selection, View Session / Create PR / Retry as Code / Change Repo actions, channel-based access control); Code Review (research preview, multi-agent analysis, severity levels -- Important/Nit/Pre-existing, check run output with severity table and annotations, CLAUDE.md and REVIEW.md customization, review triggers -- once after creation / after every push / manual, @claude review and @claude review once commands, pricing $15-25 avg per review, analytics dashboard); GitHub Enterprise Server (GHES admin setup via guided manifest or manual, GitHub App permissions, network requirements, developer workflow with --remote and /teleport, plugin marketplaces on GHES with full git URLs, hostPattern and extraKnownMarketplaces managed settings, GHES limitations). Load when discussing GitHub Actions, GitLab CI/CD, CI/CD integration, Claude Code Action, @claude mentions, code review, automated PR review, REVIEW.md, Slack integration, Claude in Slack, GitHub Enterprise Server, GHES, claude-code-action, use_bedrock, use_vertex, CI workflows, or any CI/CD-related topic for Claude Code.
user-invocable: false
---

# CI/CD Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines, Slack, automated code review, and GitHub Enterprise Server.

## Quick Reference

### GitHub Actions

| Parameter | Description | Required |
|:----------|:------------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No* |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

\*Optional -- when omitted for issue/PR comments, Claude responds to trigger phrase
\*\*Required for direct Claude API, not for Bedrock/Vertex

**Quick setup:** Run `/install-github-app` in Claude Code terminal (requires repo admin).

**Manual setup:**
1. Install the Claude GitHub app: https://github.com/apps/claude
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)

**Common `claude_args` flags:**

| Flag | Purpose |
|:-----|:--------|
| `--max-turns N` | Maximum conversation turns (default: 10) |
| `--model MODEL` | Model to use (e.g., `claude-sonnet-4-6`, `claude-opus-4-6`) |
| `--mcp-config PATH` | Path to MCP configuration |
| `--allowedTools "T1,T2"` | Comma-separated allowed tools |
| `--append-system-prompt "..."` | Add custom instructions |
| `--debug` | Enable debug output |

### v1 Migration from Beta

| Old Beta Input | New v1.0 Input |
|:---------------|:---------------|
| `mode` | *(Removed -- auto-detected)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD

**Status:** Beta (maintained by GitLab)

**Quick setup:**
1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add Claude job to `.gitlab-ci.yml`

**Key GitLab variables:**

| Variable | Purpose |
|:---------|:--------|
| `AI_FLOW_INPUT` | Prompt/instructions from trigger |
| `AI_FLOW_CONTEXT` | Context payload (MR/issue URL) |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `ANTHROPIC_API_KEY` | Claude API key (masked CI/CD variable) |
| `GITLAB_ACCESS_TOKEN` | Project Access Token with `api` scope (optional) |

**Typical job flags:**

```
claude -p "${AI_FLOW_INPUT}" --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab" --debug
```

### Cloud Provider Authentication (GitHub Actions)

**AWS Bedrock:**
- Configure GitHub as OIDC identity provider in AWS
- Create IAM role with Bedrock permissions trusting GitHub Actions
- Required secret: `AWS_ROLE_TO_ASSUME`
- Model ID format includes region prefix: `us.anthropic.claude-sonnet-4-6`

**Google Vertex AI:**
- Configure Workload Identity Federation for GitHub
- Create service account with Vertex AI User role
- Required secrets: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`
- Set `CLOUD_ML_REGION` env var (e.g., `us-east5`)

### Cloud Provider Authentication (GitLab CI/CD)

**AWS Bedrock:**
- Configure GitLab as OIDC identity provider in AWS
- Required CI/CD variables: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`
- Exchange GitLab OIDC token for AWS credentials via `aws sts assume-role-with-web-identity`

**Google Vertex AI:**
- Configure Workload Identity Federation for GitLab
- Required CI/CD variables: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`
- Authenticate via `gcloud auth login --cred-file` with external account config

### Claude Code in Slack

**Prerequisites:** Pro/Max/Teams/Enterprise plan, Claude Code on the web access, GitHub account connected, Slack account linked to Claude

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| Code only | All @mentions route to Claude Code sessions |
| Code + Chat | Intelligent routing between Code (dev tasks) and Chat (general questions) |

**Session flow:** @mention > coding intent detection > session created on claude.ai/code > progress updates in Slack > completion summary with action buttons

**Action buttons:**

| Button | Function |
|:-------|:---------|
| View Session | Opens full session in browser |
| Create PR | Creates pull request from session changes |
| Retry as Code | Re-routes a chat response to Claude Code |
| Change Repo | Selects a different repository |

**Limitations:** GitHub only, one PR per session, rate limits apply, channels only (no DMs), web access required

### Code Review

**Status:** Research preview (Teams and Enterprise only, not available with Zero Data Retention)

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Review triggers (per repo):**

| Trigger | Behavior |
|:--------|:---------|
| Once after PR creation | Reviews when PR is opened or marked ready |
| After every push | Reviews on each push; auto-resolves fixed findings |
| Manual | Reviews only on `@claude review` or `@claude review once` |

**Manual commands:**

| Command | Effect |
|:--------|:-------|
| `@claude review` | Starts review and subscribes PR to push-triggered reviews |
| `@claude review once` | Single review without subscribing to future pushes |

**Customization files:**
- `CLAUDE.md` -- shared project instructions (also used for interactive sessions)
- `REVIEW.md` -- review-only guidance (always check, style, skip rules)

**Check run output:** Findings appear in the Claude Code Review check run Details (severity table), Files changed tab (annotations), and as inline review comments. The check run never blocks merging (neutral conclusion).

**Machine-readable severity (from check run):**

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns: `{"normal": N, "nit": N, "pre_existing": N}`

**Pricing:** $15-25 average per review, billed via extra usage, scales with PR size and complexity. Monitor at claude.ai/analytics/code-review.

### GitHub Enterprise Server (GHES)

**Availability:** Teams and Enterprise plans

**Feature support:**

| Feature | GHES Support |
|:--------|:-------------|
| Claude Code on the web | Supported |
| Code Review | Supported |
| Teleport sessions | Supported |
| Plugin marketplaces | Supported (use full git URLs) |
| Contribution metrics | Supported |
| GitHub Actions | Supported (manual workflow setup) |
| GitHub MCP server | Not supported (use `gh` CLI instead) |

**Admin setup:** claude.ai/admin-settings/claude-code > GitHub Enterprise Server > Connect > enter hostname > guided app manifest creation on GHES instance > install app on repos

**GitHub App permissions required:** Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R)

**Plugin marketplaces on GHES:** Use full git URLs instead of `owner/repo` shorthand:

```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

**Allowlist GHES marketplaces in managed settings:**

```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

**Network requirement:** GHES instance must be reachable from Anthropic infrastructure. Allowlist Anthropic API IP addresses if behind a firewall.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) -- GitHub Actions setup (quick and manual), action parameters, v1 migration from beta, basic workflow and custom automation examples, AWS Bedrock and Google Vertex AI workflows with OIDC, custom GitHub App creation, claude_args passthrough, CLAUDE.md configuration, security and cost optimization
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- GitLab CI/CD integration (beta), .gitlab-ci.yml job setup, AI_FLOW_* variables, mention-driven triggers, AWS Bedrock OIDC and Google Vertex AI WIF from GitLab, configuration examples, security and governance, cost optimization
- [Claude Code in Slack](references/claude-code-slack.md) -- Slack integration setup, routing modes (Code only / Code + Chat), automatic coding intent detection, context gathering from threads and channels, session flow and action buttons, repository selection, user and workspace access controls, channel-based access model, troubleshooting
- [Code Review](references/claude-code-code-review.md) -- Automated multi-agent PR review (research preview), severity levels, check run output with severity table and annotations, setup and repository configuration, manual triggers (@claude review / @claude review once), CLAUDE.md and REVIEW.md customization, analytics dashboard, pricing, troubleshooting
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) -- GHES support for web sessions, code review, teleport, and plugin marketplaces; admin setup (guided manifest and manual), GitHub App permissions, network requirements, developer workflow, plugin marketplaces with full git URLs, managed settings for GHES marketplaces, limitations and workarounds

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
