---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, automated code review, and Slack integration.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations.

## Quick Reference

### Integration Overview

| Integration | Trigger | Use case |
| :--- | :--- | :--- |
| GitHub Actions | `@claude` mentions in issues/PRs, scheduled, or any GitHub event | Custom automation, implementing features, fixing bugs, code review in your own CI |
| GitLab CI/CD | `@claude` mentions (via webhook) or pipeline events | MR creation, bug fixes, implementation in GitLab pipelines |
| Code Review | PR open/push/manual `@claude review` | Automated PR review with inline comments, severity-tagged findings |
| GitHub Enterprise Server | Same as github.com features | GHES-hosted repos with web sessions, code review, plugin marketplaces |
| Slack | `@Claude` mention in a channel | Delegate coding tasks from Slack; creates Claude Code on-the-web sessions |

---

### GitHub Actions

#### Setup

- **Quick setup**: Run `/install-github-app` in Claude Code terminal (direct API users only).
- **Manual setup**: Install the [Claude GitHub App](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` secret, copy the example workflow to `.github/workflows/`.

#### Action Parameters (v1.0)

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Instructions for Claude (plain text or a skill invocation) | No* |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `plugin_marketplaces` | Newline-separated plugin marketplace Git URLs | No |
| `plugins` | Newline-separated plugin names to install | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

\*Prompt is optional — when omitted for issue/PR comments, Claude responds to trigger phrase
\*\*Required for direct Claude API; not needed for Bedrock/Vertex

#### Common `claude_args` CLI Options

| Flag | Purpose |
| :--- | :--- |
| `--max-turns` | Maximum conversation turns |
| `--model` | Model to use (e.g. `claude-sonnet-4-6`) |
| `--mcp-config` | Path to MCP configuration |
| `--allowedTools` | Comma-separated list of allowed tools |
| `--append-system-prompt` | Append custom instructions to system prompt |
| `--debug` | Enable debug output |

#### Beta → v1.0 Migration

| Old Beta Input | New v1.0 Input |
| :--- | :--- |
| `mode` | Removed — auto-detected |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

#### Cloud Provider Authentication (Bedrock & Vertex)

**Amazon Bedrock** — Required secrets: `AWS_ROLE_TO_ASSUME`. Uses GitHub OIDC; set `use_bedrock: "true"` and pass model with region prefix (e.g. `us.anthropic.claude-sonnet-4-6`).

**Google Vertex AI** — Required secrets: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`. Uses Workload Identity Federation; set `use_vertex: "true"`.

For both providers, a custom GitHub App (with contents/issues/pull-requests read+write) is recommended over the default `GITHUB_TOKEN`.

---

### GitLab CI/CD

> Currently in beta. Maintained by GitLab.

#### Quick Setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings → CI/CD → Variables).
2. Add a Claude job to `.gitlab-ci.yml` (see reference for full example).

#### Key CI/CD Variables

| Variable | Used for |
| :--- | :--- |
| `ANTHROPIC_API_KEY` | Claude API authentication |
| `AI_FLOW_INPUT` | Prompt passed in from webhook/trigger |
| `AI_FLOW_CONTEXT` | Additional context from triggering event |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `AWS_ROLE_TO_ASSUME` | Bedrock — IAM role ARN |
| `AWS_REGION` | Bedrock — region |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Vertex AI — WIF provider resource name |
| `GCP_SERVICE_ACCOUNT` | Vertex AI — service account email |
| `CLOUD_ML_REGION` | Vertex AI — region (e.g. `us-east5`) |

#### Mention-Driven Triggers

Set up a project webhook for "Comments (notes)" events, have the listener call the pipeline trigger API with `AI_FLOW_INPUT` and `AI_FLOW_CONTEXT` variables when a comment contains `@claude`.

#### Recommended Flags in Script

```
--permission-mode acceptEdits
--allowedTools "Bash Read Edit Write mcp__gitlab"
```

---

### Code Review (Managed Service)

> Research preview; requires Team or Enterprise subscription. Not available with Zero Data Retention.

#### How It Works

Multiple specialized agents analyze the PR diff in parallel on Anthropic infrastructure, then findings are deduplicated, ranked by severity, and posted as inline PR comments. A **Claude Code Review** check run appears alongside your CI checks.

#### Review Trigger Modes (per repo)

| Mode | When reviews run |
| :--- | :--- |
| Once after PR creation | Once on PR open or mark-ready |
| After every push | On every push to the PR branch |
| Manual | Only when `@claude review` or `@claude review once` is commented |

#### Manual Trigger Commands

| Command | Effect |
| :--- | :--- |
| `@claude review` | Starts a review and subscribes PR to push-triggered reviews |
| `@claude review once` | Starts a single review without subscribing to future pushes |

Commands must be top-level PR comments (not inline), put at the start of the comment, by a user with owner/member/collaborator access on an open PR.

#### Severity Levels

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| Red circle | Important | Bug that should be fixed before merging |
| Yellow circle | Nit | Minor issue; not blocking |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR |

#### Customizing Reviews

- **`CLAUDE.md`**: Project-wide instructions; violations introduced by the PR are flagged as nits.
- **`REVIEW.md`** (repo root): Injected as highest-priority instruction into every review agent. Use to override severity definitions, cap nit volume, skip paths/branches/categories, add repo-specific checks, set verification bars, and shape summary format.

#### Pricing

Average $15–25 per review, scaling with PR size and complexity. Billed via usage credits, separately from plan included usage. Set a monthly spend cap at `claude.ai/admin-settings/usage`.

#### Check Run Output

Parse severity counts from the machine-readable last line of check run Details output using `gh` and jq. The `normal` key holds Important finding counts.

---

### GitHub Enterprise Server (GHES)

> Requires Team or Enterprise plan.

#### Feature Support

| Feature | GHES support | Notes |
| :--- | :--- | :--- |
| Claude Code on the web | Supported | Admin connects once; developers use `--remote` as usual |
| Code Review | Supported | Same as github.com |
| Teleport sessions | Supported | `--teleport` works with GHES repos |
| Plugin marketplaces | Supported | Use full git URLs instead of `owner/repo` shorthand |
| Contribution metrics | Supported | Delivered via webhooks |
| GitHub Actions | Supported | Requires manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server | Not supported | Use `gh` CLI configured for your GHES host instead |

#### Admin Setup (Guided)

1. Go to `claude.ai/admin-settings/claude-code`, find the GitHub Enterprise Server section.
2. Click **Connect**, enter display name and GHES hostname (and optional CA cert for self-signed TLS).
3. Click **Continue to GitHub Enterprise** — browser redirects to GHES with pre-filled app manifest.
4. Review and click **Create GitHub App** on GHES; credentials stored automatically.
5. Install the app on target repositories from the GitHub App settings page on GHES.
6. Enable Code Review and contribution metrics from admin settings as usual.

#### GitHub App Permissions Required

Contents (read/write), Pull requests (read/write), Issues (read/write), Checks (read/write), Actions (read), Repository hooks (read/write), Metadata (read).

#### Developer Workflow

No per-developer configuration needed once admin setup is complete. Clone the GHES repo normally; Claude detects the GHES host from the git remote automatically.

```bash
git clone git@github.example.com:org/repo.git
cd repo
claude --remote "Your task here"
```

#### GHES Plugin Marketplaces

Use full git URLs (not `owner/repo` shorthand):
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

To allowlist in managed settings, use the `hostPattern` source type with a `strictKnownMarketplaces` entry.

---

### Slack Integration

#### Prerequisites

| Requirement | Details |
| :--- | :--- |
| Claude Plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub Account | Connected with at least one repo authenticated in Claude Code on the web |
| Slack Authentication | Slack account linked to Claude account via the Claude app |

#### Routing Modes

| Mode | Behavior |
| :--- | :--- |
| Code only | All @mentions routed to Claude Code sessions |
| Code + Chat | Claude intelligently routes between Code (coding tasks) and Chat (everything else) |

#### Session Flow

1. Mention `@Claude` with a coding request in a channel.
2. Claude detects coding intent and creates a Claude Code on-the-web session.
3. Claude posts status updates to the Slack thread.
4. On completion: use **View Session** to see full transcript, **Create PR** to open a pull request, **Change Repo** to switch repositories, or **Retry as Code** if it defaulted to Chat.

#### Key Limitations

- Works in channels only (public or private), not DMs.
- GitHub only (no GitLab support).
- One PR per session.
- Sessions run under each individual user's account and plan limits.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, use cases, cloud provider workflows, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — setup, configuration examples, cloud provider jobs, best practices
- [Code Review](references/claude-code-code-review.md) — how reviews work, setup, severity levels, customization with REVIEW.md, pricing, troubleshooting
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, feature support, developer workflow, plugin marketplaces, limitations
- [Claude Code in Slack](references/claude-code-slack.md) — setup, routing modes, session flow, access control, troubleshooting

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
