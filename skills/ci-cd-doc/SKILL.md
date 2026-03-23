---
name: ci-cd-doc
description: Complete documentation for Claude Code CI/CD integrations -- GitHub Actions (claude-code-action@v1, action parameters prompt/claude_args/anthropic_api_key/trigger_phrase/use_bedrock/use_vertex/github_token, @claude mention triggers, quick setup via /install-github-app, manual setup with Claude GitHub App installation and ANTHROPIC_API_KEY secret, workflow YAML for issue_comment/pull_request_review_comment events, custom automation with prompt parameter, CLI passthrough via claude_args --max-turns/--model/--mcp-config/--allowedTools, Bedrock workflow with OIDC and aws-actions/configure-aws-credentials, Vertex AI workflow with Workload Identity Federation and google-github-actions/auth, custom GitHub App with actions/create-github-app-token, beta-to-v1 migration breaking changes mode/direct_prompt/override_prompt/custom_instructions/max_turns/model/allowed_tools/disallowed_tools/claude_env to settings, CLAUDE.md for project standards), GitLab CI/CD (beta, .gitlab-ci.yml job configuration, node:24-alpine3.21 image, claude CLI install via curl, --permission-mode acceptEdits, --allowedTools Bash Read Edit Write mcp__gitlab, AI_FLOW_INPUT/AI_FLOW_CONTEXT/AI_FLOW_EVENT variables, CI_JOB_TOKEN/GITLAB_ACCESS_TOKEN for API operations, mention-driven triggers via webhooks, Bedrock OIDC with AWS_ROLE_TO_ASSUME and sts assume-role-with-web-identity, Vertex AI WIF with GCP_WORKLOAD_IDENTITY_PROVIDER/GCP_SERVICE_ACCOUNT/CLOUD_ML_REGION, MR creation from issues), Claude Code in Slack (routing coding tasks from Slack channels to Claude Code on the web, Code only vs Code+Chat routing modes, @Claude mention triggers, automatic repository selection, session flow with progress updates, View Session/Create PR/Retry as Code/Change Repo actions, prerequisites Pro/Max/Teams/Enterprise plan with Claude Code access and GitHub connected, channel-based access control via /invite @Claude, context gathering from threads and channels, GitHub only limitation), Code Review (research preview for Teams/Enterprise, multi-agent PR analysis posting inline comments, severity levels Normal/Nit/Pre-existing, review triggers Once after PR creation/After every push/Manual, @claude review manual trigger, CLAUDE.md and REVIEW.md customization files, Claude GitHub App setup via admin settings, analytics dashboard at claude.ai/analytics/code-review, pricing $15-25 average per review billed as extra usage, auto-resolving threads on fix). Load when discussing GitHub Actions for Claude Code, GitLab CI/CD for Claude Code, claude-code-action, @claude mentions in PRs or issues, CI/CD integration, automated code review, Code Review setup, REVIEW.md, PR review triggers, Slack integration for Claude Code, Claude Code in Slack, routing mode Code only vs Code+Chat, automated PR creation, MR creation from issues, Bedrock/Vertex workflows in CI, GitHub App installation, /install-github-app, claude_args, trigger_phrase, AI_FLOW_INPUT, code review pricing, review severity levels, or any CI/CD and automation topic for Claude Code.
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations -- GitHub Actions, GitLab CI/CD, Slack integration, and automated Code Review.

## Quick Reference

### Integration Overview

| Integration | Platform | Status | Trigger |
|:------------|:---------|:-------|:--------|
| GitHub Actions | GitHub | GA (v1) | `@claude` in PR/issue comments, or `prompt` parameter |
| GitLab CI/CD | GitLab | Beta | `@claude` via webhooks, or manual/MR pipeline triggers |
| Slack | Slack | GA | `@Claude` mention in channels |
| Code Review | GitHub | Research preview | PR open, every push, or `@claude review` comment |

### GitHub Actions Setup

**Quick setup:** Run `/install-github-app` in Claude Code terminal (requires repo admin).

**Manual setup:**
1. Install the [Claude GitHub App](https://github.com/apps/claude) (needs Contents, Issues, Pull requests read & write)
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow YAML into `.github/workflows/`

### GitHub Actions Parameters (v1)

| Parameter | Description | Required |
|:----------|:------------|:---------|
| `prompt` | Instructions for Claude (plain text or skill name) | No |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes (not for Bedrock/Vertex) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

Common `claude_args` values: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--disallowedTools`, `--append-system-prompt`, `--debug`.

### GitHub Actions Beta-to-v1 Migration

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

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings > CI/CD > Variables)
2. Add a Claude job to `.gitlab-ci.yml` using `node:24-alpine3.21` image
3. Install Claude CLI via `curl -fsSL https://claude.ai/install.sh | bash`
4. Run `claude -p` with `--permission-mode acceptEdits` and `--allowedTools "Bash Read Edit Write mcp__gitlab"`

**Key variables for GitLab triggers:**

| Variable | Purpose |
|:---------|:--------|
| `AI_FLOW_INPUT` | The user's instruction/prompt |
| `AI_FLOW_CONTEXT` | Context payload (MR/issue reference) |
| `AI_FLOW_EVENT` | Event type that triggered the pipeline |
| `CI_JOB_TOKEN` | Default token for GitLab API operations |
| `GITLAB_ACCESS_TOKEN` | Project Access Token with `api` scope (alternative) |

### Cloud Provider Authentication in CI/CD

| Provider | GitHub Actions | GitLab CI/CD |
|:---------|:---------------|:-------------|
| Claude API | `anthropic_api_key` input | `ANTHROPIC_API_KEY` CI/CD variable |
| AWS Bedrock | `use_bedrock: "true"` + `aws-actions/configure-aws-credentials` via OIDC | `AWS_ROLE_TO_ASSUME` + `aws sts assume-role-with-web-identity` via OIDC |
| Google Vertex AI | `use_vertex: "true"` + `google-github-actions/auth` via WIF | `GCP_WORKLOAD_IDENTITY_PROVIDER` + `GCP_SERVICE_ACCOUNT` + `gcloud auth login --cred-file` |

**Required secrets for Bedrock (both platforms):** `AWS_ROLE_TO_ASSUME` (IAM role ARN), `AWS_REGION`

**Required secrets for Vertex AI (both platforms):** `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION`

**Custom GitHub App (recommended for 3P providers):** Create at github.com/settings/apps/new with Contents, Issues, Pull requests read & write permissions. Use `actions/create-github-app-token` to generate tokens. Store `APP_ID` and `APP_PRIVATE_KEY` as secrets.

### Claude Code in Slack

**Prerequisites:** Pro/Max/Teams/Enterprise plan with Claude Code access, Claude Code on the web enabled, GitHub account connected with at least one repository.

**Routing modes** (configured in App Home):

| Mode | Behavior |
|:-----|:---------|
| Code only | All @Claude mentions route to Claude Code sessions |
| Code + Chat | Claude analyzes each message and routes to Claude Code (coding tasks) or Claude Chat (writing, analysis, general questions) |

**Session flow:** @mention Claude > coding intent detected > Claude Code session created on claude.ai/code > progress updates in Slack thread > completion summary with View Session / Create PR buttons.

**Access control:** Claude must be invited to channels via `/invite @Claude`. Works in public and private channels, not in DMs. Each user runs sessions under their own Claude account and plan limits.

### Code Review

**Availability:** Research preview for Teams and Enterprise subscriptions (not available with Zero Data Retention).

**Setup:** Admin enables at claude.ai/admin-settings/claude-code > install Claude GitHub App > select repositories > set review triggers.

**Review triggers:**

| Trigger | When it runs | Cost impact |
|:--------|:-------------|:------------|
| Once after PR creation | PR opened or marked ready | One review per PR |
| After every push | Every push to PR branch | Multiplied by push count |
| Manual | Only on `@claude review` comment | On demand |

Commenting `@claude review` opts any PR into push-triggered reviews going forward, regardless of configured trigger.

**Severity levels:**

| Marker | Level | Meaning |
|:-------|:------|:--------|
| Red circle | Normal | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue, worth fixing but not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

**Customization files:**

| File | Scope | Purpose |
|:-----|:------|:--------|
| `CLAUDE.md` | All Claude Code tasks | Project conventions; violations flagged as nit-level findings |
| `REVIEW.md` | Code Review only | Review-specific rules (style guidelines, always-check rules, skip rules) |

**Pricing:** $15-25 average per review, billed as extra usage (separate from plan usage). Scales with PR size and complexity. Set spend cap at claude.ai/admin-settings/usage. Monitor at claude.ai/analytics/code-review.

**Analytics dashboard** (claude.ai/analytics/code-review): PRs reviewed daily, weekly cost, auto-resolved feedback count, per-repo breakdown.

### Troubleshooting

| Issue | Resolution |
|:------|:-----------|
| Claude not responding to @claude | Verify GitHub App installed, workflows enabled, API key in secrets, comment uses `@claude` not `/claude` |
| CI not running on Claude's commits | Use GitHub App or custom app (not Actions user), check workflow triggers, verify app permissions |
| GitLab job can't write comments/open MRs | Ensure `CI_JOB_TOKEN` has sufficient permissions or use PAT with `api` scope, check `mcp__gitlab` in `--allowedTools` |
| Authentication errors (API) | Confirm API key is valid and unexpired |
| Authentication errors (Bedrock/Vertex) | Verify OIDC/WIF configuration, role impersonation, secret names, region and model availability |
| Code Review not appearing | Confirm repository listed in admin settings, Claude GitHub App has access, PR is not a draft (for manual trigger) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) -- quick setup via /install-github-app, manual setup (Claude GitHub App, ANTHROPIC_API_KEY secret, workflow YAML), action parameters (prompt, claude_args, anthropic_api_key, github_token, trigger_phrase, use_bedrock, use_vertex), CLI passthrough via claude_args (--max-turns, --model, --mcp-config, --allowedTools, --debug), basic workflow for issue_comment/pull_request_review_comment, custom automation with prompt, Bedrock workflow with OIDC (aws-actions/configure-aws-credentials, AWS_ROLE_TO_ASSUME), Vertex AI workflow with WIF (google-github-actions/auth, GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_SERVICE_ACCOUNT), custom GitHub App creation (actions/create-github-app-token), beta-to-v1 migration (breaking changes for mode, direct_prompt, custom_instructions, max_turns, model, allowed_tools, claude_env), CLAUDE.md for project standards, security best practices, CI cost optimization
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) -- beta integration maintained by GitLab, .gitlab-ci.yml job configuration (node:24-alpine3.21 image, claude CLI install), --permission-mode acceptEdits, --allowedTools Bash Read Edit Write mcp__gitlab, AI_FLOW_INPUT/AI_FLOW_CONTEXT/AI_FLOW_EVENT trigger variables, CI_JOB_TOKEN and GITLAB_ACCESS_TOKEN for API operations, mention-driven triggers via webhooks, Bedrock OIDC setup (AWS_ROLE_TO_ASSUME, sts assume-role-with-web-identity), Vertex AI WIF setup (GCP_WORKLOAD_IDENTITY_PROVIDER, GCP_SERVICE_ACCOUNT, CLOUD_ML_REGION), MR creation from issues, security and governance, cost optimization
- [Claude Code in Slack](references/claude-code-slack.md) -- routing coding tasks from Slack to Claude Code on the web, Code only vs Code+Chat routing modes, @Claude mention triggers in channels, automatic repository selection, session flow (initiation, detection, session creation, progress updates, completion), View Session/Create PR/Retry as Code/Change Repo actions, prerequisites (Pro/Max/Teams/Enterprise with Claude Code access, GitHub connected), channel-based access control (/invite @Claude), context gathering from threads and channels, App Home settings, GitHub-only limitation, troubleshooting (sessions not starting, repository not showing, authentication errors)
- [Code Review](references/claude-code-code-review.md) -- research preview for Teams/Enterprise, multi-agent PR analysis with inline comments, severity levels (Normal/Nit/Pre-existing with extended reasoning), review triggers (Once after PR creation, After every push, Manual), @claude review manual trigger and push opt-in, CLAUDE.md and REVIEW.md customization, Claude GitHub App setup via admin settings, analytics dashboard (PRs reviewed, weekly cost, feedback, per-repo breakdown), pricing ($15-25 average billed as extra usage with spend cap), auto-resolving threads, related resources (Plugins code-review plugin for local reviews, GitHub Actions, GitLab CI/CD)

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
