---
name: ci-cd-doc
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for Claude Code integrations with CI/CD platforms and collaboration tools — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, automated Code Review, and Claude Code in Slack.

## Quick Reference

### GitHub Actions

**Setup options:**
- Quick: run `/install-github-app` in Claude terminal (Claude API only)
- Manual: install [https://github.com/apps/claude](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` secret, copy workflow from examples

**Action parameters (v1):**

| Parameter             | Description                                                        | Required  |
| :-------------------- | :----------------------------------------------------------------- | :-------- |
| `prompt`              | Instructions or skill invocation (plain text or `/skill-name`)    | No        |
| `claude_args`         | CLI arguments passed through to Claude Code                        | No        |
| `plugin_marketplaces` | Newline-separated plugin marketplace git URLs                      | No        |
| `plugins`             | Newline-separated plugin names to install before execution         | No        |
| `anthropic_api_key`   | Claude API key (required for direct API; not used with Bedrock/Vertex) | Conditional |
| `github_token`        | GitHub token for API access                                        | No        |
| `trigger_phrase`      | Custom trigger phrase (default: `@claude`)                         | No        |
| `use_bedrock`         | Use Amazon Bedrock instead of Claude API                           | No        |
| `use_vertex`          | Use Google Vertex AI instead of Claude API                         | No        |

**Common `claude_args` flags:**

| Flag               | Description                                |
| :----------------- | :----------------------------------------- |
| `--max-turns`      | Maximum conversation turns (default: 10)   |
| `--model`          | Model to use                               |
| `--mcp-config`     | Path to MCP configuration                  |
| `--allowedTools`   | Comma-separated allowed tools list         |
| `--debug`          | Enable debug output                        |

**Beta → v1 breaking changes:**

| Old Beta Input        | New v1.0 Input                        |
| :-------------------- | :------------------------------------ |
| `mode`                | *(Removed — auto-detected)*           |
| `direct_prompt`       | `prompt`                              |
| `override_prompt`     | `prompt` with GitHub variables        |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |
| `disallowed_tools`    | `claude_args: --disallowedTools`      |
| `claude_env`          | `settings` JSON format                |

**Cloud provider secrets:**

| Provider          | Required Secrets                                                   |
| :---------------- | :----------------------------------------------------------------- |
| Claude API        | `ANTHROPIC_API_KEY`                                               |
| Amazon Bedrock    | `AWS_ROLE_TO_ASSUME`, plus optional `APP_ID` / `APP_PRIVATE_KEY`  |
| Google Vertex AI  | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`, plus optional `APP_ID` / `APP_PRIVATE_KEY` |

Bedrock model IDs include a region prefix, e.g. `us.anthropic.claude-sonnet-4-6`.

---

### GitLab CI/CD (Beta)

**Setup:**
1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings → CI/CD → Variables)
2. Add a Claude job to `.gitlab-ci.yml` using `node:24-alpine3.21`; install Claude via `curl -fsSL https://claude.ai/install.sh | bash`

**Key job variables:**

| Variable         | Purpose                                                       |
| :--------------- | :------------------------------------------------------------ |
| `AI_FLOW_INPUT`  | Prompt / instruction for Claude (set by event listener)       |
| `AI_FLOW_CONTEXT` | Context payload from trigger                                 |
| `AI_FLOW_EVENT`  | Event name that triggered the job                             |
| `AWS_ROLE_TO_ASSUME` | IAM role ARN (Bedrock)                                   |
| `AWS_REGION`     | Bedrock region                                                |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | WIF provider resource name (Vertex AI)    |
| `GCP_SERVICE_ACCOUNT` | Service account email (Vertex AI)                        |
| `CLOUD_ML_REGION` | Vertex AI region (e.g. `us-east5`)                          |

**Trigger phrase:** `@claude` in issue or MR comments; requires a webhook/listener to call the pipeline trigger API.

**Recommended script invocation:**
```
claude -p "${AI_FLOW_INPUT:-'default task'}" \
  --permission-mode acceptEdits \
  --allowedTools "Bash Read Edit Write mcp__gitlab" \
  --debug
```

---

### Code Review (Team & Enterprise, research preview)

**Trigger modes (per repo):**

| Mode                   | When reviews run                                                |
| :--------------------- | :-------------------------------------------------------------- |
| Once after PR creation | On PR open / ready-for-review                                  |
| After every push       | Every push to the PR branch                                    |
| Manual                 | Only on explicit `@claude review` or `@claude review once` comment |

**Manual trigger commands (top-level PR comment only):**

| Command               | Effect                                                              |
| :-------------------- | :------------------------------------------------------------------ |
| `@claude review`      | Runs review; subscribes PR to push-triggered reviews going forward  |
| `@claude review once` | Runs a single review without subscribing to future pushes           |

**Severity levels:**

| Marker | Level       | Meaning                                                    |
| :----- | :---------- | :--------------------------------------------------------- |
| Red circle    | Important   | A bug that should be fixed before merging             |
| Yellow circle | Nit         | Minor issue, worth fixing but not blocking             |
| Purple circle | Pre-existing | Bug in codebase not introduced by this PR            |

**Customization files:**

| File        | Scope                  | Priority                |
| :---------- | :--------------------- | :---------------------- |
| `CLAUDE.md` | All Claude Code tasks  | Violations flagged as nits |
| `REVIEW.md` | Code Review only       | Highest — injected directly into every agent |

`REVIEW.md` can tune: severity definitions, nit volume cap, skip rules (paths, branches, categories), repo-specific checks, verification bar, re-review convergence, and summary shape.

**Parse severity counts from check run output:**
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
```
Returns `{"normal": N, "nit": N, "pre_existing": N}` — `normal` holds Important count.

**Pricing:** ~$15–25 per review; billed via usage credits, separate from plan usage. Set a monthly spend cap at `claude.ai/admin-settings/usage`.

**Local review:** use the `/code-review` command in any Claude Code session. Pass `--comment` to post inline PR comments, `--fix` to apply findings. `/code-review ultra --fix` runs the cloud-based ultrareview.

---

### GitHub Enterprise Server (Team & Enterprise)

**Feature support:**

| Feature              | GHES support    | Notes                                                      |
| :------------------- | :-------------- | :--------------------------------------------------------- |
| Claude Code on web   | Supported       | Admin connects once; `claude --remote` auto-detects GHES  |
| Code Review          | Supported       | Same as github.com                                        |
| Claude Security      | Supported       | Public beta for Enterprise at `claude.ai/security`        |
| Teleport sessions    | Supported       | `--teleport` works with GHES repos                        |
| Plugin marketplaces  | Supported       | Use full git URLs instead of `owner/repo` shorthand       |
| GitHub Actions       | Supported       | Manual workflow setup only; `/install-github-app` is github.com only |
| GitHub MCP server    | Not supported   | Use `gh` CLI configured for GHES host instead             |

**GitHub App permissions required:**

| Permission       | Access         | Used for                                  |
| :--------------- | :------------- | :---------------------------------------- |
| Contents         | Read and write | Cloning repos, pushing branches           |
| Pull requests    | Read and write | Creating PRs, posting review comments     |
| Issues           | Read and write | Responding to issue mentions              |
| Checks           | Read and write | Posting Code Review check runs            |
| Actions          | Read           | Reading CI status for auto-fix            |
| Repository hooks | Read and write | Webhooks for contribution metrics         |
| Metadata         | Read           | Required by GitHub for all apps           |

**GHES plugin marketplace (full git URL required):**
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
# or
/plugin marketplace add https://github.example.com/platform/claude-plugins.git
```

**Allowlist GHES in managed settings** using `hostPattern`:
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

**Network:** GHES must be reachable from Anthropic infrastructure; allowlist Anthropic API IP addresses if behind a firewall.

---

### Claude Code in Slack

**Requirements:**

| Requirement          | Details                                                                    |
| :------------------- | :------------------------------------------------------------------------- |
| Claude Plan          | Pro, Max, Team, or Enterprise with Claude Code access                      |
| Claude Code on web   | Must be enabled at `claude.ai/code`                                        |
| GitHub account       | Connected to Claude Code on web with at least one authenticated repository |
| Slack authentication | Slack account linked to Claude account via the Claude app                  |

**Routing modes:**

| Mode        | Behavior                                                                        |
| :---------- | :------------------------------------------------------------------------------ |
| Code only   | All @mentions go to Claude Code sessions                                        |
| Code + Chat | Claude routes each message to Code (coding tasks) or Chat (general questions)   |

**Session flow:** mention `@Claude` → coding intent detected → Code session created on `claude.ai/code` → status updates posted in thread → completion summary with "View Session" and "Create PR" buttons.

**Limitations:**
- Works in channels only (public and private); not in DMs
- GitHub repositories only (no GitLab)
- One PR per session
- Rate limits apply per user's Claude plan

**Channel setup:** invite with `/invite @Claude` — Claude only responds in channels where it has been added.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — Setup, action parameters, cloud provider workflows (Bedrock/Vertex), beta-to-v1 migration, security, and cost optimization
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — Setup, CI/CD job examples for Claude API, Bedrock (OIDC), and Vertex AI (WIF), best practices
- [Code Review](references/claude-code-code-review.md) — Severity levels, trigger modes, CLAUDE.md and REVIEW.md customization, pricing, local review with /code-review, troubleshooting
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — Admin setup, feature support table, GitHub App permissions, GHES plugin marketplaces, managed settings, network requirements
- [Claude Code in Slack](references/claude-code-slack.md) — Setup steps, routing modes, session flow, access controls, best practices, troubleshooting

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
