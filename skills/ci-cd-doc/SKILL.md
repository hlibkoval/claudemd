---
name: ci-cd-doc
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code into CI/CD pipelines, code review workflows, and team communication tools.

## Quick Reference

### GitHub Actions

**Action:** `anthropics/claude-code-action@v1`

| Input | Description | Required |
|---|---|---|
| `prompt` | Instructions for Claude (text or skill name) | No* |
| `claude_args` | CLI arguments passed to Claude Code | No |
| `anthropic_api_key` | Claude API key | Yes** |
| `github_token` | GitHub token for API access | No |
| `trigger_phrase` | Custom trigger phrase (default: `@claude`) | No |
| `use_bedrock` | Use Amazon Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |
| `plugin_marketplaces` | Newline-separated plugin marketplace Git URLs | No |
| `plugins` | Newline-separated plugin names to install | No |

\* Omit for interactive mode (responds to `@claude` mentions); required for automation mode  
\*\* Not required for Bedrock/Vertex

**Setup:** Run `/install-github-app` in Claude terminal (direct API users only), or install manually from [github.com/apps/claude](https://github.com/apps/claude).

**Common `claude_args`:** `--max-turns`, `--model`, `--mcp-config`, `--allowedTools`, `--disallowedTools`, `--debug`

**Beta → v1.0 migration:**

| Old Beta Input | New v1.0 |
|---|---|
| `mode` | Removed (auto-detected) |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

**Cloud provider secrets:**

| Provider | Required Secrets |
|---|---|
| Claude API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `AWS_ROLE_TO_ASSUME` (+ `APP_ID`, `APP_PRIVATE_KEY` for custom app) |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` (+ same app secrets) |

---

### GitLab CI/CD (Beta)

**Install:** `curl -fsSL https://claude.ai/install.sh | bash` in job `before_script`

**Key CI/CD variables:**

| Variable | Description |
|---|---|
| `ANTHROPIC_API_KEY` | Claude API key (masked) |
| `AI_FLOW_INPUT` | Prompt/instructions passed to Claude |
| `AI_FLOW_CONTEXT` | Context payload from event listener |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `AWS_ROLE_TO_ASSUME` | IAM role ARN for Bedrock |
| `AWS_REGION` | AWS region for Bedrock |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full WIF provider resource name |
| `GCP_SERVICE_ACCOUNT` | Service account email for Vertex AI |
| `CLOUD_ML_REGION` | Vertex AI region (e.g., `us-east5`) |

**Typical job invocation:**
```yaml
script:
  - /bin/gitlab-mcp-server || true
  - >
    claude
    -p "${AI_FLOW_INPUT:-'Review this MR'}"
    --permission-mode acceptEdits
    --allowedTools "Bash Read Edit Write mcp__gitlab"
```

---

### Code Review (Team/Enterprise, research preview)

**Severity levels:**

| Marker | Severity | Meaning |
|---|---|---|
| Red circle | Important | Bug to fix before merging |
| Yellow circle | Nit | Minor issue, not blocking |
| Purple circle | Pre-existing | Bug not introduced by this PR |

**Review trigger modes:**

| Mode | Behavior |
|---|---|
| Once after PR creation | Runs once on open/ready-for-review |
| After every push | Re-runs on each push; auto-resolves fixed threads |
| Manual | Only on `@claude review` or `@claude review once` comment |

**Manual trigger commands (top-level PR comment only):**

| Command | Effect |
|---|---|
| `@claude review` | Starts review + subscribes PR to push-triggered reviews |
| `@claude review once` | Single review, no push subscription |

**Customization files:**
- `CLAUDE.md` — project-wide context; violations flagged as nits
- `REVIEW.md` — review-only instructions injected as highest-priority into every review agent; controls severity, nit caps, skip rules, repo-specific checks

**Pricing:** ~$15–25 per review, billed separately via usage credits (not plan-included usage). Set a monthly spend cap at `claude.ai/admin-settings/usage`.

**Local review:** Run `/code-review` in any Claude Code session to review the current diff without the GitHub App. Pass `--comment` to post inline PR comments, or `--fix` to apply findings. Use `/code-review ultra --fix` to run ultrareview in the cloud.

---

### Claude Code in Slack

**Requirements:** Pro/Max/Team/Enterprise with Claude Code access, Claude Code on the web enabled, GitHub connected, Slack account linked to Claude account.

**Setup:** Install Claude app from Slack App Marketplace → connect Claude account in App Home → invite with `/invite @Claude` in channels.

**Routing modes:**

| Mode | Behavior |
|---|---|
| Code only | All @mentions route to Claude Code sessions |
| Code + Chat | Claude routes between Code and Chat based on detected intent |

**Key limitations:** GitHub only; works in channels (not DMs); one PR per session; sessions use individual user's plan limits.

**Action buttons:** View Session, Create PR, Retry as Code, Change Repo.

---

### GitHub Enterprise Server (Team/Enterprise)

**Supported features:**

| Feature | GHES Support |
|---|---|
| Claude Code on the web | Supported |
| Code Review | Supported |
| Claude Security | Supported (Enterprise, public beta) |
| Teleport sessions | Supported |
| Plugin marketplaces | Supported (use full git URLs) |
| GitHub Actions | Supported (manual workflow setup only) |
| GitHub MCP server | Not supported |

**Admin setup:** `claude.ai/admin-settings/claude-code` → GitHub Enterprise Server → Connect → enter hostname → create GitHub App via redirect → install app on repositories.

**GitHub App permissions needed:** Contents (R/W), Pull requests (R/W), Issues (R/W), Checks (R/W), Actions (R), Repository hooks (R/W), Metadata (R).

**Developer workflow:** Clone repo from GHES → run `claude --remote "..."` — Claude auto-detects GHES host from git remote.

**GHES plugin marketplaces:** Use full git URLs (not `owner/repo` shorthand):
```
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

**Allowlist GHES in managed settings** via `hostPattern` source type in `strictKnownMarketplaces`.

**Network:** GHES must be reachable from Anthropic infrastructure; allowlist Anthropic API IP addresses if behind a firewall.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — Set up and configure the `@claude` GitHub Action for PR automation and CI workflows
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — Integrate Claude Code into GitLab pipelines with `@claude` mention-driven jobs (beta)
- [Claude Code in Slack](references/claude-code-slack.md) — Delegate coding tasks from Slack by mentioning `@Claude` in channels
- [Code Review](references/claude-code-code-review.md) — Automated PR reviews with inline findings, severity levels, and customization via REVIEW.md
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — Connect Claude Code to self-hosted GHES instances for web sessions and code review

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
