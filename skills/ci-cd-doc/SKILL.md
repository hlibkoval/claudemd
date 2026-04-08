---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations, automated code review, and Slack integration. Covers GitHub Actions (claude-code-action@v1, action parameters, prompt, claude_args, trigger_phrase, @claude mentions, beta-to-v1 migration, breaking changes), GitLab CI/CD (beta, .gitlab-ci.yml job setup, AI_FLOW_INPUT/AI_FLOW_CONTEXT variables, gitlab-mcp-server, permission-mode acceptEdits, allowedTools), Slack integration (Code + Chat routing, @Claude mentions, session flow, repository selection, routing modes, channel-based access, App Home, view session, create PR), Code Review (multi-agent PR analysis, severity levels important/nit/pre-existing, @claude review, @claude review once, REVIEW.md, check run output, manual/automatic triggers, review behavior modes, pricing $15-25/review), GitHub Enterprise Server (GHES admin setup, GitHub App manifest, guided setup, manual setup, plugin marketplaces on GHES, hostPattern allowlisting, teleport, network requirements), AWS Bedrock provider (OIDC authentication, role assumption, model ID format us.anthropic.claude-*), Google Vertex AI provider (Workload Identity Federation, service account, CLOUD_ML_REGION), custom GitHub App creation, security considerations, CI cost optimization, and CLAUDE.md/REVIEW.md configuration for reviews. Load when discussing GitHub Actions, claude-code-action, GitLab CI/CD, .gitlab-ci.yml, Slack integration, Claude Code in Slack, code review, PR review, automated review, @claude review, REVIEW.md, GitHub Enterprise Server, GHES, CI/CD setup, Bedrock CI/CD, Vertex AI CI/CD, CI costs, review severity, review pricing, or any CI/CD and integration topic for Claude Code.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations (GitHub Actions, GitLab CI/CD), automated code review, Slack integration, and GitHub Enterprise Server support.

## Quick Reference

### GitHub Actions (`claude-code-action@v1`)

| Parameter | Description | Required |
|:----------|:-----------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

**Common `claude_args` flags:** `--max-turns N`, `--model <model>`, `--mcp-config <path>`, `--allowedTools <tools>`, `--append-system-prompt "<text>"`, `--debug`

#### Quick Setup

Run `/install-github-app` inside Claude Code, or manually:
1. Install the Claude GitHub App: https://github.com/apps/claude
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)

#### Beta to v1 Migration

| Old Beta Input | New v1 Input |
|:---------------|:-------------|
| `mode` | *(Removed -- auto-detected)* |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD (Beta)

| Key Concept | Details |
|:------------|:--------|
| Job image | `node:24-alpine3.21` |
| Install Claude | `curl -fsSL https://claude.ai/install.sh \| bash` |
| Permission mode | `--permission-mode acceptEdits` |
| Allowed tools | `--allowedTools "Bash Read Edit Write mcp__gitlab"` |
| API key variable | `ANTHROPIC_API_KEY` (masked CI/CD variable) |
| Context variables | `AI_FLOW_INPUT`, `AI_FLOW_CONTEXT`, `AI_FLOW_EVENT` |
| GitLab MCP server | `/bin/gitlab-mcp-server` (optional, started in job) |
| Trigger rules | `$CI_PIPELINE_SOURCE == "web"` or `"merge_request_event"` |

#### GitLab Provider Authentication

| Provider | Required CI/CD Variables |
|:---------|:------------------------|
| Claude API | `ANTHROPIC_API_KEY` |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

### Slack Integration

| Requirement | Details |
|:------------|:--------|
| Claude Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one repo authenticated |
| Slack Auth | Slack account linked to Claude account |

#### Routing Modes

| Mode | Behavior |
|:-----|:---------|
| **Code only** | All @mentions route to Claude Code sessions |
| **Code + Chat** | Intelligent routing between Claude Code and Claude Chat |

#### Session Flow

1. @mention Claude with a coding request
2. Claude detects coding intent
3. Claude Code session created on claude.ai/code
4. Status updates posted to Slack thread
5. Completion summary with action buttons (View Session, Create PR, Retry as Code, Change Repo)

#### Access Control

- Works in public and private channels only (not DMs)
- Must `/invite @Claude` to each channel
- Each user runs sessions under their own account and rate limits
- Users can only access repos they have personally connected

### Code Review (Research Preview)

| Aspect | Details |
|:-------|:--------|
| Availability | Team and Enterprise plans (not with Zero Data Retention) |
| Average cost | $15-25 per review (billed as extra usage) |
| Average duration | ~20 minutes |
| GitHub App permissions | Contents (R/W), Issues (R/W), Pull requests (R/W) |

#### Severity Levels

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

#### Review Behavior Modes

| Mode | When reviews run |
|:-----|:-----------------|
| Once after PR creation | When PR is opened or marked ready |
| After every push | On each push to the PR branch |
| Manual | Only when `@claude review` or `@claude review once` is commented |

#### Manual Trigger Commands

| Command | Effect |
|:--------|:-------|
| `@claude review` | Starts review and subscribes PR to push-triggered reviews |
| `@claude review once` | Single review without subscribing to future pushes |

Both must be posted as top-level PR comments (not inline). Works on draft PRs.

#### Customization Files

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project instructions; violations flagged as nits |
| `REVIEW.md` | Code Review only | Review-specific rules (style, always-check, skip patterns) |

#### Check Run Machine-Readable Output

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns: `{"normal": N, "nit": N, "pre_existing": N}` -- `normal` = Important findings count.

### GitHub Enterprise Server (GHES)

| Feature | GHES Support |
|:--------|:-------------|
| Claude Code on the web | Supported |
| Code Review | Supported |
| Teleport sessions | Supported |
| Plugin marketplaces | Supported (use full git URL) |
| Contribution metrics | Supported |
| GitHub Actions | Supported (manual workflow setup) |
| GitHub MCP server | Not supported |

#### Admin Setup

1. Open claude.ai/admin-settings/claude-code, find GitHub Enterprise Server section
2. Click Connect, enter display name and GHES hostname
3. Create GitHub App via guided redirect (or manual setup)
4. Install app on target repositories/organizations
5. Enable Code Review and contribution metrics

#### Plugin Marketplaces on GHES

Use full git URL instead of `owner/repo` shorthand:
```
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

Allowlist via managed settings with `hostPattern`:
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

#### Network Requirements

GHES instance must be reachable from Anthropic infrastructure. Allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses) if behind a firewall.

### Cloud Provider Authentication (GitHub Actions)

#### AWS Bedrock

| Item | Details |
|:-----|:--------|
| Auth method | GitHub OIDC to assume IAM role |
| Required secrets | `AWS_ROLE_TO_ASSUME`, `APP_ID`, `APP_PRIVATE_KEY` |
| Model ID format | `us.anthropic.claude-sonnet-4-6` (region prefix) |
| Action param | `use_bedrock: "true"` |

#### Google Vertex AI

| Item | Details |
|:-----|:--------|
| Auth method | Workload Identity Federation |
| Required secrets | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `APP_ID`, `APP_PRIVATE_KEY` |
| Env vars | `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION` |
| Action param | `use_vertex: "true"` |

### CI Cost Optimization

- Use specific `@claude` commands to reduce unnecessary API calls
- Set `--max-turns` to prevent excessive iterations
- Set workflow/job-level timeouts
- Use concurrency controls to limit parallel runs
- Choose appropriate review trigger mode (Manual is cheapest)

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) -- Setup, configuration, action parameters, beta-to-v1 migration, Bedrock/Vertex workflows, best practices
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- Job setup, provider authentication, OIDC configuration, .gitlab-ci.yml examples, troubleshooting
- [Slack Integration](references/claude-code-slack.md) -- Setup, routing modes, session flow, access control, channel-based permissions, troubleshooting
- [Code Review](references/claude-code-code-review.md) -- Multi-agent PR review, severity levels, triggers, REVIEW.md customization, check run output, pricing
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) -- Admin setup, GitHub App manifest, developer workflow, plugin marketplaces, network requirements

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Slack Integration: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
