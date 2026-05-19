---
name: ci-cd-doc
description: Complete official documentation for integrating Claude Code into CI/CD pipelines and collaboration tools — GitHub Actions (setup, triggers, action parameters, cloud providers, beta upgrade), GitLab CI/CD (pipeline jobs, OIDC/WIF authentication, Bedrock/Vertex examples), automated Code Review (setup, severity levels, REVIEW.md customization, pricing), GitHub Enterprise Server (admin setup, developer workflow, GHES plugin marketplaces), and Claude Code in Slack (routing modes, session flow, access controls).
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD systems, code review workflows, and collaboration platforms.

## Quick Reference

### Integration Overview

| Integration | Trigger | Best for |
| :--- | :--- | :--- |
| GitHub Actions | `@claude` comment, PR events, schedule, web | Custom automation on GitHub repos |
| GitLab CI/CD | `@claude` comment, MR event, manual/web | GitLab pipelines and MR automation |
| Code Review | PR open, every push, or manual `@claude review` | Automated correctness review on GitHub PRs |
| GitHub Enterprise Server | Same as github.com features | Self-hosted GitHub with Claude Code |
| Claude Code in Slack | `@Claude` mention in channel | Kicking off coding tasks from team conversations |

---

### GitHub Actions

#### Quick Setup

Run `/install-github-app` inside Claude to set up the GitHub App and required secrets automatically (github.com only; direct Claude API users only).

#### Manual Setup

1. Install [https://github.com/apps/claude](https://github.com/apps/claude) on your repository
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml) into `.github/workflows/`

#### Action Parameters (v1)

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Instructions for Claude (plain text or skill name) | No* |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `plugin_marketplaces` | Newline-separated list of plugin marketplace Git URLs | No |
| `plugins` | Newline-separated list of plugins to install | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

\* Prompt is optional — when omitted, Claude responds to trigger phrase mentions in issue/PR comments.
\*\* Required for direct Claude API; not needed for Bedrock/Vertex.

#### Common `claude_args` Options

| Arg | Purpose |
| :--- | :--- |
| `--max-turns N` | Maximum conversation turns (default: 10) |
| `--model MODEL_ID` | Model to use (e.g., `claude-sonnet-4-6`) |
| `--mcp-config PATH` | Path to MCP configuration |
| `--allowedTools LIST` | Comma-separated allowed tools |
| `--append-system-prompt TEXT` | Append custom instructions to system prompt |
| `--debug` | Enable debug output |

#### Beta → v1 Migration

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

#### Cloud Provider Secrets

| Provider | Required Secrets |
| :--- | :--- |
| Claude API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `AWS_ROLE_TO_ASSUME`; optional `APP_ID`, `APP_PRIVATE_KEY` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`; optional `APP_ID`, `APP_PRIVATE_KEY` |

Bedrock model IDs include a region prefix (e.g., `us.anthropic.claude-sonnet-4-6`). Vertex model IDs use version suffixes (e.g., `claude-sonnet-4-5@20250929`).

---

### GitLab CI/CD (Beta)

#### Quick Setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (**Settings** → **CI/CD** → **Variables**)
2. Add a `claude` job to `.gitlab-ci.yml` (see example below)
3. Test by running manually from **CI/CD** → **Pipelines**

#### Minimal `.gitlab-ci.yml` Job

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
    - apk update && apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
      --debug
```

#### Cloud Provider Variables

| Provider | Required CI/CD Variables |
| :--- | :--- |
| Claude API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

Both Bedrock (OIDC) and Vertex AI (WIF) use keyless authentication — no static credentials stored.

#### Common Parameters

| Parameter | Description |
| :--- | :--- |
| `AI_FLOW_INPUT` | Prompt/instructions for Claude (set by trigger or pipeline variable) |
| `AI_FLOW_CONTEXT` | Context about the triggering event |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `--max-turns N` | Limit conversation iterations |
| `--permission-mode acceptEdits` | Allow Claude to edit files without confirming each change |

---

### Code Review

#### How It Works

Multi-agent analysis runs on Anthropic infrastructure. Agents examine the diff and surrounding code in parallel, deduplicate findings, rank by severity, and post inline comments. Completes in ~20 minutes on average.

#### Setup (Admin)

1. Go to [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) → Code Review → **Setup**
2. Install the Claude GitHub App (requires Contents, Issues, Pull requests permissions)
3. Select repositories and set **Review Behavior** per repo

#### Review Behavior Options

| Mode | When reviews run |
| :--- | :--- |
| Once after PR creation | Once when a PR opens or is marked ready |
| After every push | On each push to the PR branch (resolves threads when issues are fixed) |
| Manual | Only when `@claude review` is posted as a PR comment |

#### Manual Trigger Commands

| Comment | Effect |
| :--- | :--- |
| `@claude review` | Starts a review and subscribes PR to future push-triggered reviews |
| `@claude review once` | Starts a single review without subscribing to future pushes |

Commands must be top-level PR comments (not inline), posted by a repo owner/member/collaborator, on an open PR.

#### Severity Levels

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| 🔴 | Important | Bug that should be fixed before merging |
| 🟡 | Nit | Minor issue, worth fixing but not blocking |
| 🟣 | Pre-existing | Bug in codebase not introduced by this PR |

#### Customization Files

| File | Effect |
| :--- | :--- |
| `CLAUDE.md` | General project instructions; newly introduced violations flagged as nits |
| `REVIEW.md` | Review-only instructions injected as highest-priority into every review agent; controls severity, nit volume, skip rules, repo-specific checks |

#### Parsing Severity Programmatically

The last line of the check run Details is machine-readable JSON with counts per severity. Parse with `gh` and jq to gate merges on Important findings.

#### Pricing

Average $15–25 per review, billed via usage credits (separate from plan-included usage). Set a monthly spend cap at [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage).

---

### GitHub Enterprise Server (GHES)

Available for Team and Enterprise plans.

#### Feature Support

| Feature | GHES Support | Notes |
| :--- | :--- | :--- |
| Claude Code on the web | Supported | Admin connects instance once; devs use `claude --remote` as usual |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | `--teleport` works with GHES repos |
| Plugin marketplaces | Supported | Use full git URLs instead of `owner/repo` shorthand |
| Contribution metrics | Supported | Delivered via webhooks to analytics dashboard |
| GitHub Actions | Supported | Requires manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI configured for your GHES host instead |

#### Admin Setup

1. Go to [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) → GitHub Enterprise Server → **Connect**
2. Enter display name and GHES hostname (e.g., `github.example.com`); optionally provide CA cert for private CAs
3. Click **Continue to GitHub Enterprise** — your browser redirects to GHES with a pre-filled app manifest
4. Click **Create GitHub App** on your GHES instance; credentials are stored automatically
5. Install the GitHub App on desired repositories from your GHES instance
6. Return to admin settings to enable Code Review and contribution metrics

#### GitHub App Permissions (GHES)

| Permission | Access | Used for |
| :--- | :--- | :--- |
| Contents | Read and write | Cloning repositories and pushing branches |
| Pull requests | Read and write | Creating PRs and posting review comments |
| Issues | Read and write | Responding to issue mentions |
| Checks | Read and write | Posting Code Review check runs |
| Actions | Read | Reading CI status for auto-fix |
| Repository hooks | Read and write | Receiving webhooks for contribution metrics |
| Metadata | Read | Required by GitHub for all apps |

#### Plugin Marketplaces on GHES

Use full git URLs (the `owner/repo` shorthand always resolves to github.com):

```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
# or
/plugin marketplace add https://github.example.com/platform/claude-plugins.git
```

To allowlist all marketplaces from a GHES instance in managed settings, use `hostPattern` source type.

#### GHES Limitations / Workarounds

- `/install-github-app`: use the admin setup flow on claude.ai instead
- GitHub MCP server: use `gh` CLI configured with `gh auth login --hostname github.example.com`
- GHES instance must be reachable from Anthropic infrastructure (allowlist Anthropic API IP addresses if behind a firewall)

---

### Claude Code in Slack

#### Prerequisites

| Requirement | Details |
| :--- | :--- |
| Claude Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected to Claude Code on the web with at least one repository authenticated |
| Slack Authentication | Slack account linked to Claude account via the Claude app |

#### Setup Steps

1. Workspace admin installs Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Each user connects their Claude account from the Claude App Home tab
3. Connect GitHub at [claude.ai/code](https://claude.ai/code) and authenticate repositories
4. Choose **Routing Mode** in the Claude App Home
5. Invite Claude to channels: `/invite @Claude`

#### Routing Modes

| Mode | Behavior |
| :--- | :--- |
| Code only | All `@Claude` mentions create Claude Code sessions |
| Code + Chat | Claude analyzes each message and routes to Code or Chat; "Retry as Code" button available |

#### Session Flow

1. `@Claude` mention with coding request in a channel (not DMs)
2. Claude detects coding intent and creates a Claude Code session
3. Status updates posted to the Slack thread as work progresses
4. Completion summary posted with `@mention` and action buttons
5. "View Session" opens full transcript; "Create PR" opens a pull request

#### Access Controls

- Claude is not auto-added to channels — admins control access by managing which channels invite Claude
- Each user runs sessions under their own Claude account (usage counts against individual plan limits)
- Users can only access repositories they have personally connected to Claude Code on the web
- Works in public and private channels; does not work in DMs

#### Current Limitations

- GitHub only (no GitLab, Bitbucket, etc.)
- One PR per session
- Rate limits apply per user's individual plan
- Users without Claude Code on the web access receive only standard chat responses

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, skill invocation, cloud provider workflows (Bedrock/Vertex), beta-to-v1 migration, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — quick setup, OIDC/WIF authentication, provider comparison, CI cost guidance, security and governance
- [Code Review](references/claude-code-code-review.md) — how reviews work, severity levels, setup, manual triggers, REVIEW.md customization, pricing, troubleshooting
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, GitHub App permissions, developer workflow, GHES plugin marketplaces, limitations
- [Claude Code in Slack](references/claude-code-slack.md) — routing modes, session flow, access controls, troubleshooting, current limitations

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
