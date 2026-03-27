---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack integration, and automated Code Review. Covers GitHub Actions setup (quick setup via /install-github-app, manual setup, Claude GitHub App installation, workflow YAML configuration, action parameters prompt/claude_args/anthropic_api_key/trigger_phrase/use_bedrock/use_vertex, @claude mention triggers, upgrading from beta to v1, breaking changes reference), GitLab CI/CD setup (quick setup with .gitlab-ci.yml, manual setup for production, AI_FLOW_INPUT/AI_FLOW_CONTEXT/AI_FLOW_EVENT variables, --permission-mode acceptEdits, gitlab-mcp-server, Project Access Token with api scope), Claude Code in Slack (routing modes Code only vs Code+Chat, @Claude mention in channels, session flow with progress updates, App Home connection, repository selection, Retry as Code/Change Repo/Create PR/View Session actions, channel-based access control), automated Code Review (research preview for Teams/Enterprise, multi-agent analysis with severity levels Important/Nit/Pre-existing, review triggers once-after-creation/after-every-push/manual, @claude review and @claude review once commands, REVIEW.md customization, check run output with machine-readable severity JSON, pricing $15-25 per review), enterprise cloud provider workflows for both platforms (AWS Bedrock OIDC with GitHub/GitLab, Google Vertex AI Workload Identity Federation with GitHub/GitLab, custom GitHub App creation), CLAUDE.md configuration for all integrations, cost optimization (max-turns, timeouts, concurrency controls), and troubleshooting. Load when discussing Claude Code GitHub Actions, GitLab CI/CD, Slack integration, code review automation, @claude mentions, CI/CD workflows, automated PR review, merge request automation, claude-code-action, anthropics/claude-code-action, GitHub App setup, /install-github-app, claude_args, trigger_phrase, AI_FLOW_INPUT, REVIEW.md, @claude review, Code Review severity, review behavior configuration, CI/CD cost optimization, or any CI/CD and integration topic for Claude Code.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack, and automated Code Review.

## Quick Reference

### Integration Overview

| Integration | Platform | Trigger | Status |
|:------------|:---------|:--------|:-------|
| **GitHub Actions** | GitHub | `@claude` in PR/issue comments, custom prompts | GA (v1) |
| **GitLab CI/CD** | GitLab | `@claude` in MR/issue comments, pipeline triggers | Beta |
| **Slack** | Slack + GitHub | `@Claude` mention in channels | GA |
| **Code Review** | GitHub | PR open, push, or `@claude review` | Research preview |

### GitHub Actions

**Quick setup:** Run `/install-github-app` in the Claude Code terminal. Requires repo admin.

**Manual setup:**
1. Install the [Claude GitHub App](https://github.com/apps/claude) (permissions: Contents, Issues, Pull requests -- all Read & Write)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) into `.github/workflows/`

**Action parameters (v1):**

| Parameter | Description | Required |
|:----------|:-----------|:---------|
| `prompt` | Instructions for Claude (text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (direct API) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

**Common claude_args:**

| Argument | Purpose |
|:---------|:--------|
| `--max-turns N` | Maximum conversation turns (default: 10) |
| `--model NAME` | Model to use (e.g., `claude-sonnet-4-6`) |
| `--mcp-config PATH` | Path to MCP configuration |
| `--allowedTools LIST` | Comma-separated allowed tools |
| `--append-system-prompt TEXT` | Custom system instructions |
| `--debug` | Enable debug output |

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

**Beta to v1 migration:**

| Old (beta) | New (v1) |
|:-----------|:---------|
| `mode` | Removed -- auto-detected |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD

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
  variables:
    GIT_STRATEGY: fetch
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

**Key variables for mention-driven triggers:**

| Variable | Purpose |
|:---------|:--------|
| `AI_FLOW_INPUT` | The user's prompt/request text |
| `AI_FLOW_CONTEXT` | Context reference (e.g., MR or issue) |
| `AI_FLOW_EVENT` | The triggering event type |

**Production setup additions:**
- Use `CI_JOB_TOKEN` or a Project Access Token with `api` scope for GitLab API operations
- Add a project webhook for "Comments (notes)" to trigger pipelines on `@claude` mentions
- Store `GITLAB_ACCESS_TOKEN` as a masked variable if using a PAT

### Claude Code in Slack

**Prerequisites:** Pro/Max/Teams/Enterprise plan with Claude Code access, Claude Code on the Web enabled, GitHub account connected with at least one repository.

**Setup:**
1. Install the [Claude app from Slack Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Connect your Claude account in the App Home tab
3. Configure Claude Code on the Web at [claude.ai/code](https://claude.ai/code)
4. Choose routing mode (Code only or Code+Chat)
5. Invite Claude to channels with `/invite @Claude`

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| **Code only** | All @mentions route to Claude Code sessions |
| **Code + Chat** | Intelligent routing between Claude Code and Claude Chat |

**Session flow:** @mention > detection > session creation on claude.ai/code > progress updates in Slack > completion with summary and action buttons

**Actions:** View Session, Create PR, Retry as Code, Change Repo

**Limitations:** GitHub only, one PR per session, rate limits apply, requires Claude Code on the Web access, works in channels only (not DMs).

### Automated Code Review

**Availability:** Research preview for Teams and Enterprise subscriptions (not available with ZDR).

**How it works:** Multiple specialized agents analyze the diff and surrounding code in parallel, verify findings against actual code behavior, deduplicate and rank by severity, then post as inline comments.

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in the codebase not introduced by this PR |

**Review triggers:**

| Trigger | Behavior |
|:--------|:---------|
| Once after PR creation | Review on PR open or marked ready |
| After every push | Review on each push; auto-resolves fixed issues |
| Manual | Reviews only on `@claude review` or `@claude review once` |

**Manual trigger commands:**

| Command | Behavior |
|:--------|:---------|
| `@claude review` | Start review + subscribe to push-triggered reviews |
| `@claude review once` | Single review, no subscription to future pushes |

Must be posted as a top-level PR comment by an owner/member/collaborator on an open PR.

**Customization files:**

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project standards; violations flagged as nits |
| `REVIEW.md` | Code review only | Review-specific rules (always-check, style, skip) |

**Check run output:** The Claude Code Review check run includes machine-readable severity counts:

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```

Returns: `{"normal": N, "nit": N, "pre_existing": N}` where `normal` = Important findings count.

The check run always completes with a neutral conclusion -- it never blocks merging.

**Pricing:** $15-25 average per review, scaling with PR size and complexity. Billed separately through extra usage, not against plan limits.

### Enterprise Cloud Provider Workflows

Both GitHub Actions and GitLab CI/CD support AWS Bedrock and Google Vertex AI via OIDC/Workload Identity Federation (no static keys).

**GitHub Actions -- required secrets by provider:**

| Provider | Secrets |
|:---------|:--------|
| Claude API | `ANTHROPIC_API_KEY` |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `APP_ID`, `APP_PRIVATE_KEY` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `APP_ID`, `APP_PRIVATE_KEY` |

**GitLab CI/CD -- required CI/CD variables by provider:**

| Provider | Variables |
|:---------|:----------|
| Claude API | `ANTHROPIC_API_KEY` |
| AWS Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

**GitHub Actions permissions block (for cloud providers):**

```yaml
permissions:
  contents: write
  pull-requests: write
  issues: write
  id-token: write
```

**Custom GitHub App (recommended for Bedrock/Vertex):** Create at [github.com/settings/apps/new](https://github.com/settings/apps/new) with Contents, Issues, Pull requests (Read & Write). Use `actions/create-github-app-token@v2` in workflows to generate tokens.

### Cost Optimization

| Strategy | Platform |
|:---------|:---------|
| Set `--max-turns` in `claude_args` | GitHub Actions |
| Set job timeouts | Both |
| Use concurrency controls | Both |
| Use specific `@claude` commands | Both |
| Choose Manual review trigger for high-traffic repos | Code Review |
| Use `@claude review once` for one-off reviews | Code Review |

### Troubleshooting

| Issue | Solution |
|:------|:---------|
| Claude not responding to @claude | Verify GitHub App installed, workflows enabled, API key in secrets, comment uses `@claude` not `/claude` |
| CI not running on Claude's commits | Use GitHub App or custom app (not Actions user); check workflow triggers |
| Authentication errors | Verify API key validity; for Bedrock/Vertex check OIDC/WIF config, secret names, region, model availability |
| GitLab job can't write comments/open MRs | Check `CI_JOB_TOKEN` permissions or use PAT with `api` scope; verify `mcp__gitlab` in `--allowedTools` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) -- setup (quick via /install-github-app and manual), Claude GitHub App permissions, workflow YAML configuration, action parameters (prompt, claude_args, anthropic_api_key, github_token, trigger_phrase, use_bedrock, use_vertex), common claude_args (--max-turns, --model, --mcp-config, --allowedTools, --debug), @claude mention triggers, beta to v1 migration (breaking changes for mode/direct_prompt/override_prompt/custom_instructions/max_turns/model/allowed_tools/claude_env), example use cases (basic workflow, code review, daily report, custom automation), AWS Bedrock and Google Vertex AI workflows with OIDC/WIF, custom GitHub App creation for enterprise, CLAUDE.md configuration, security considerations, CI costs, performance optimization
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- setup (quick and manual/production), .gitlab-ci.yml job configuration, AI_FLOW_INPUT/AI_FLOW_CONTEXT/AI_FLOW_EVENT variables, --permission-mode acceptEdits, gitlab-mcp-server, mention-driven triggers via webhooks, Project Access Token configuration, example use cases (issues to MRs, implementation help, bug fixes), AWS Bedrock OIDC job example with temporary credential exchange, Google Vertex AI Workload Identity Federation job example, provider-specific CI/CD variables, CLAUDE.md configuration, security and governance (isolated containers, MR-based review, branch protection, workspace-scoped permissions), CI costs and optimization, troubleshooting
- [Claude Code in Slack](references/claude-code-slack.md) -- setup (Slack App Marketplace installation, Claude account connection, Claude Code on Web configuration, routing mode selection, channel invitations), routing modes (Code only vs Code+Chat, Retry as Code), automatic coding intent detection, context gathering from threads and channels, session flow (initiation, detection, creation, progress updates, completion), UI elements (App Home, View Session, Create PR, Retry as Code, Change Repo), repository selection, user-level access (per-account sessions, plan rate limits, personal repo access), workspace-level access (admin installation, Enterprise Grid distribution), channel-based access control (/invite @Claude, channel membership gating), troubleshooting (sessions not starting, repo not showing, wrong repo, auth errors, session expiration), limitations (GitHub only, one PR per session, rate limits, Web access required, channels only)
- [Automated Code Review](references/claude-code-code-review.md) -- multi-agent analysis architecture, severity levels (Important/Nit/Pre-existing with emoji markers), check run output (Details link summary, annotations in Files changed tab, machine-readable severity JSON via gh api), neutral conclusion (never blocks merging), what Code Review checks (correctness focus by default), setup (admin settings, GitHub App installation, repository selection, review behavior configuration), review triggers (once after PR creation, after every push, manual), manual trigger commands (@claude review with push subscription, @claude review once without), trigger requirements (top-level comment, owner/member/collaborator, open PR, draft PR support for manual), customization via CLAUDE.md (violations as nits, bidirectional doc staleness detection, hierarchical directory support) and REVIEW.md (review-only rules, always-check/style/skip sections), usage analytics dashboard (PRs reviewed, weekly cost, feedback/auto-resolved, repo breakdown), pricing ($15-25 average, token-based, scales with PR size/complexity, billed as extra usage, trigger affects total cost, spend cap configuration)

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Automated Code Review: https://code.claude.com/docs/en/code-review.md
