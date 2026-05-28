---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions (setup, action parameters, skills invocation, Bedrock/Vertex workflows, upgrading from beta), GitLab CI/CD (quick and manual setup, Bedrock/Vertex OIDC examples, mention-driven triggers), GitHub Enterprise Server (admin setup, feature support table, plugin marketplaces on GHES, developer workflow), managed Code Review (severity levels, review triggers, REVIEW.md customization, pricing, check run output), and Claude Code in Slack (routing modes, session flow, access controls, prerequisites).
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines and collaboration tools.

## Quick Reference

### Integration Overview

| Integration | Trigger mechanism | Runs on | Key doc |
| :--- | :--- | :--- | :--- |
| GitHub Actions | `@claude` in PR/issue comments, or any GitHub event | GitHub-hosted runners | [claude-code-github-actions.md](references/claude-code-github-actions.md) |
| GitLab CI/CD | `@claude` in issue/MR comments, pipeline events | Your GitLab runners | [claude-code-gitlab-ci-cd.md](references/claude-code-gitlab-ci-cd.md) |
| Code Review (managed) | PR open, every push, or `@claude review` comment | Anthropic infrastructure | [claude-code-code-review.md](references/claude-code-code-review.md) |
| GitHub Enterprise Server | Same as GitHub Actions + Code Review | Anthropic infra / GHES runners | [claude-code-github-enterprise-server.md](references/claude-code-github-enterprise-server.md) |
| Slack | `@Claude` mention in channel | Anthropic infra (web session) | [claude-code-slack.md](references/claude-code-slack.md) |

---

### GitHub Actions

#### Quick setup

Run `/install-github-app` inside a Claude Code terminal session. This installs the GitHub App and adds required secrets automatically. (Direct Claude API only — for Bedrock/Vertex, follow manual setup.)

#### Manual setup steps

1. Install the Claude GitHub App: https://github.com/apps/claude
2. Add `ANTHROPIC_API_KEY` as a repository secret
3. Copy the example workflow from `examples/claude.yml` into `.github/workflows/`

#### GitHub App permissions required

| Permission | Access |
| :--- | :--- |
| Contents | Read & write |
| Issues | Read & write |
| Pull requests | Read & write |

#### Claude Code Action v1 parameters

| Parameter | Description | Required |
| :--- | :--- | :--- |
| `prompt` | Plain-text instructions or a skill invocation | No |
| `claude_args` | Any Claude Code CLI arguments | No |
| `plugin_marketplaces` | Newline-separated plugin marketplace Git URLs | No |
| `plugins` | Newline-separated plugin names to install | No |
| `anthropic_api_key` | Claude API key | Yes (direct API) |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock instead of Claude API | No |
| `use_vertex` | Use Google Vertex AI instead of Claude API | No |

Common `claude_args` values: `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--debug`

#### Invoking a skill from a workflow

For a skill in `.claude/skills/`, run `actions/checkout` before the action and pass the skill name as the `prompt`. For a plugin skill, supply `plugin_marketplaces` + `plugins` and pass the namespaced `/plugin-name:skill-name`.

#### Upgrading from beta to v1

| Old beta input | New v1 input |
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

#### Secrets by provider

| Provider | Secrets needed |
| :--- | :--- |
| Direct Claude API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock (OIDC) | `AWS_ROLE_TO_ASSUME`; set `use_bedrock: "true"` |
| Google Vertex AI (WIF) | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`; set `use_vertex: "true"` |
| Custom GitHub App | `APP_ID`, `APP_PRIVATE_KEY` |

Bedrock model IDs include a region prefix, e.g. `us.anthropic.claude-sonnet-4-6`.

---

### GitLab CI/CD

#### Quick setup

1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable under **Settings → CI/CD → Variables**
2. Add a `claude` stage to `.gitlab-ci.yml` (see reference for full snippet)
3. Test by running the job manually from **CI/CD → Pipelines**

Core script pattern:

```yaml
- curl -fsSL https://claude.ai/install.sh | bash
- claude -p "${AI_FLOW_INPUT:-'Your default prompt'}" --permission-mode acceptEdits --allowedTools "Bash Read Edit Write mcp__gitlab"
```

#### Context variables

| Variable | Source |
| :--- | :--- |
| `AI_FLOW_INPUT` | Prompt text from your mention/trigger payload |
| `AI_FLOW_CONTEXT` | Thread or issue context |
| `AI_FLOW_EVENT` | Event type (e.g. `note`, `merge_request`) |

#### Mention-driven triggers

Use a project webhook (Notes event) pointing to an event listener. When a comment contains `@claude`, the listener calls the pipeline trigger API with `AI_FLOW_*` variables set.

#### Secrets by provider

| Provider | Required CI/CD variables |
| :--- | :--- |
| Claude API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `AWS_ROLE_TO_ASSUME`, `AWS_REGION` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, `CLOUD_ML_REGION` |

Both cloud providers use OIDC/Workload Identity Federation — no static keys stored.

---

### Managed Code Review

Available for Team and Enterprise plans. Not available with Zero Data Retention.

#### Review triggers

| Mode | When it runs |
| :--- | :--- |
| Once after PR creation | Once when a PR opens or is marked ready |
| After every push | On every push to the PR branch |
| Manual | Only when someone comments `@claude review` or `@claude review once` |

#### Manual trigger commands

| Command | Effect |
| :--- | :--- |
| `@claude review` | Starts a review and subscribes PR to future push-triggered reviews |
| `@claude review once` | One-off review, no future push subscription |

Both commands require a top-level PR comment (not inline), with the command at the start. Requires owner/member/collaborator access. Works on draft PRs when triggered manually.

#### Severity levels

| Marker | Severity | Meaning |
| :--- | :--- | :--- |
| Red circle | Important | Bug to fix before merging |
| Yellow circle | Nit | Minor issue, not blocking |
| Purple circle | Pre-existing | Bug not introduced by this PR |

#### Check run output

The **Claude Code Review** check always completes with a neutral conclusion (never blocks merges). Parse severity counts from the last line of check run Details text using `gh` + `jq`; the `normal` key holds Important finding counts.

#### Customization files

| File | Scope | Influence |
| :--- | :--- | :--- |
| `CLAUDE.md` | All Claude Code tasks | Violations flagged as nits; Claude also flags if PR makes CLAUDE.md outdated |
| `REVIEW.md` (repo root) | Code Review only | Injected as highest-priority instruction into every review agent; plain markdown, `@` imports not expanded |

`REVIEW.md` tunable controls: severity redefinition, nit volume cap, skip rules (paths/branches/categories), repo-specific checks, verification bar, re-review convergence, summary shape.

#### Pricing

Each review averages $15–25 USD, billed via usage credits, separate from plan included usage. Set a monthly spend cap at claude.ai/admin-settings/usage.

#### Retrigger a failed review

Comment `@claude review once` on the PR. The GitHub **Re-run** button does not retrigger Code Review.

---

### GitHub Enterprise Server (GHES)

Available for Team and Enterprise plans.

#### Supported features

| Feature | Support |
| :--- | :--- |
| Claude Code on the web | Supported |
| Code Review | Supported |
| Claude Security | Supported (Enterprise, public beta) |
| Teleport sessions | Supported |
| Plugin marketplaces | Supported (use full git URLs, not `owner/repo` shorthand) |
| Contribution metrics | Supported |
| GitHub Actions | Supported (manual workflow setup; `/install-github-app` is github.com only) |
| GitHub MCP server | Not supported — use `gh` CLI configured for your GHES host instead |

#### Admin setup (guided flow)

1. Go to claude.ai/admin-settings/claude-code → GitHub Enterprise Server section
2. Click **Connect**, enter display name and GHES hostname (optionally paste CA cert)
3. Click **Continue to GitHub Enterprise** — browser redirects to GHES with pre-filled app manifest
4. Click **Create GitHub App** on GHES; credentials stored automatically
5. Install the app on repositories from the GHES GitHub App page
6. Return to admin settings to enable Code Review, Claude Security, and contribution metrics

#### GHES GitHub App permissions

| Permission | Access | Used for |
| :--- | :--- | :--- |
| Contents | Read & write | Cloning repos, pushing branches |
| Pull requests | Read & write | Creating PRs, posting review comments |
| Issues | Read & write | Responding to issue mentions |
| Checks | Read & write | Posting Code Review check runs |
| Actions | Read | Reading CI status for auto-fix |
| Repository hooks | Read & write | Contribution metrics webhooks |
| Metadata | Read | Required by GitHub for all apps |

#### Network requirement

GHES must be reachable from Anthropic infrastructure. Allowlist Anthropic API IP addresses in your firewall.

#### Plugin marketplaces on GHES

Use full git URLs (not `owner/repo` shorthand):

```
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

To allowlist all marketplaces from a GHES host in managed settings, use `"source": "hostPattern"` with the hostname regex in `strictKnownMarketplaces`.

---

### Claude Code in Slack

#### Prerequisites

| Requirement | Details |
| :--- | :--- |
| Claude plan | Pro, Max, Team, or Enterprise with Claude Code access |
| Claude Code on the web | Must be enabled |
| GitHub account | Connected to Claude Code on the web, at least one repo authenticated |
| Slack authentication | Slack account linked to Claude account via the Claude app |

#### Setup steps

1. Workspace admin installs the Claude app from the Slack App Marketplace
2. Each user connects their Claude account via the Claude App Home tab
3. Configure Claude Code on the web at claude.ai/code and connect GitHub
4. Choose **Routing Mode** in App Home: **Code only** or **Code + Chat**
5. Invite Claude to channels with `/invite @Claude` (not added automatically)

#### Routing modes

| Mode | Behavior |
| :--- | :--- |
| Code only | All `@Claude` mentions go to Claude Code sessions |
| Code + Chat | Claude analyzes each message and routes to Code or Chat; "Retry as Code" available |

#### Session flow

`@mention` → coding intent detected → Claude Code session created on claude.ai/code → Slack thread receives progress updates → completion summary with **View Session** and **Create PR** buttons.

Works in public and private channels only (not DMs).

#### Access model

- Each user runs sessions under their own Claude account and plan limits
- Users can only access repositories they've personally connected
- Workspace admins control app installation; channel membership gates access
- Sessions from Slack are visible to the organization (Team/Enterprise)

#### Current limitations

- GitHub only (no GitLab)
- One PR per session
- Requires Claude Code on the web access
- Rate limits apply per individual plan

---

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) — setup, action parameters, skill invocation, Bedrock/Vertex workflows, upgrading from beta
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — quick and manual setup, mention-driven triggers, Bedrock/Vertex OIDC examples, best practices
- [Code Review](references/claude-code-code-review.md) — how reviews work, setup, manual triggers, REVIEW.md customization, pricing, troubleshooting, local `/code-review` command
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — feature support, admin setup, GHES GitHub App permissions, developer workflow, plugin marketplaces, limitations
- [Claude Code in Slack](references/claude-code-slack.md) — prerequisites, setup, routing modes, session flow, access controls, best practices, troubleshooting

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
