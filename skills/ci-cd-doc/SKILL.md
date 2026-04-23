---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, Slack integration, and automated Code Review.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for Claude Code CI/CD and platform integrations.

## Quick Reference

### GitHub Actions

The `anthropics/claude-code-action@v1` action brings AI automation to GitHub workflows via `@claude` mentions or scheduled prompts.

**Minimal workflow (responds to @claude mentions):**

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

**Automation workflow (runs with a prompt):**

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    prompt: "Review this pull request for correctness and security"
    claude_args: "--max-turns 5"
```

**Action parameters (v1):**

| Parameter           | Description                                              | Required  |
| :------------------ | :------------------------------------------------------- | :-------- |
| `prompt`            | Instructions for Claude (or a skill name)                | No        |
| `claude_args`       | CLI arguments passed to Claude Code                      | No        |
| `anthropic_api_key` | Claude API key                                           | Yes (direct API) |
| `github_token`      | GitHub token for API access                              | No        |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)               | No        |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API                    | No        |
| `use_vertex`        | Use Google Vertex AI instead of Claude API               | No        |

**Common `claude_args` options:**

| Flag                    | Purpose                                |
| :---------------------- | :------------------------------------- |
| `--max-turns N`         | Limit conversation turns (default: 10) |
| `--model MODEL`         | Override model (e.g. `claude-opus-4-7`) |
| `--allowedTools LIST`   | Comma-separated tool allowlist         |
| `--disallowedTools LIST`| Comma-separated tool denylist          |
| `--append-system-prompt`| Append custom instructions             |
| `--mcp-config PATH`     | Path to MCP configuration              |

**Beta → v1 migration:**

| Old Beta Input        | New v1 Input                          |
| :-------------------- | :------------------------------------ |
| `mode`                | (Removed — auto-detected)             |
| `direct_prompt`       | `prompt`                              |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |

**Quick setup:** run `/install-github-app` in the Claude terminal (direct API only).

**Manual setup steps:**
1. Install [https://github.com/apps/claude](https://github.com/apps/claude) on your repo
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy `.github/workflows/claude.yml` from the [examples directory](https://github.com/anthropics/claude-code-action/tree/main/examples)

**Cloud provider auth secrets:**

| Provider      | Required secrets                                       |
| :------------ | :----------------------------------------------------- |
| AWS Bedrock   | `AWS_ROLE_TO_ASSUME` (OIDC-based)                      |
| Vertex AI     | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`|
| Custom GitHub App | `APP_ID`, `APP_PRIVATE_KEY`                        |

---

### GitLab CI/CD (Beta)

Maintained by GitLab. Add a Claude job to `.gitlab-ci.yml` and set `ANTHROPIC_API_KEY` as a masked CI/CD variable.

**Minimal job:**

```yaml
claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Summarize recent changes and suggest improvements'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Key CI/CD variables:**

| Variable                        | Provider      | Purpose                              |
| :------------------------------ | :------------ | :----------------------------------- |
| `ANTHROPIC_API_KEY`             | Claude API    | API authentication (masked)          |
| `AWS_ROLE_TO_ASSUME`            | Bedrock       | IAM role ARN for OIDC                |
| `AWS_REGION`                    | Bedrock       | Bedrock region (e.g. `us-west-2`)    |
| `GCP_WORKLOAD_IDENTITY_PROVIDER`| Vertex AI     | Full WIF provider resource name      |
| `GCP_SERVICE_ACCOUNT`           | Vertex AI     | Service account email                |
| `CLOUD_ML_REGION`               | Vertex AI     | Vertex region (e.g. `us-east5`)      |
| `AI_FLOW_INPUT`                 | All           | Prompt passed from trigger/webhook   |
| `AI_FLOW_CONTEXT`               | All           | Thread/issue context from trigger    |

**Common Claude CLI flags for GitLab:**

| Flag                            | Purpose                                              |
| :------------------------------ | :--------------------------------------------------- |
| `--permission-mode acceptEdits` | Auto-accept file edits                               |
| `--allowedTools "..."`          | Tool allowlist (include `mcp__gitlab` for GitLab ops)|
| `-p "PROMPT"`                   | Non-interactive prompt                               |

---

### GitHub Enterprise Server (GHES)

Available for Team and Enterprise plans. Admin connects the GHES instance once at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code); developers need no per-repo setup.

**Feature support:**

| Feature             | GHES Support   | Notes                                              |
| :------------------ | :------------- | :------------------------------------------------- |
| Claude Code on web  | Supported      | Use `claude --remote` or claude.ai/code            |
| Code Review         | Supported      | Same as github.com                                 |
| Teleport sessions   | Supported      | `claude --teleport` from matching checkout         |
| Plugin marketplaces | Supported      | Use full git URLs instead of `owner/repo` shorthand|
| GitHub Actions      | Supported      | Manual workflow setup; `/install-github-app` is github.com only |
| GitHub MCP server   | Not supported  | Use `gh` CLI configured for your GHES host instead |

**Admin setup:** Guided flow creates a GitHub App via manifest redirect. Manual option available if redirect is blocked.

**GitHub App permissions required:**

| Permission       | Access         | Used for                                    |
| :--------------- | :------------- | :------------------------------------------ |
| Contents         | Read and write | Clone repos and push branches               |
| Pull requests    | Read and write | Create PRs and post review comments         |
| Issues           | Read and write | Respond to issue mentions                   |
| Checks           | Read and write | Post Code Review check runs                 |
| Actions          | Read           | Read CI status for auto-fix                 |
| Repository hooks | Read and write | Webhooks for contribution metrics           |

**GHES marketplace references** — use full git URLs:

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

---

### Claude Code in Slack

`@Claude` mentions in Slack channels automatically route coding requests to Claude Code on the web sessions.

**Prerequisites:**

| Requirement          | Detail                                                               |
| :------------------- | :------------------------------------------------------------------- |
| Claude plan          | Pro, Max, Team, or Enterprise with Claude Code access                |
| Claude Code on web   | Must be enabled                                                      |
| GitHub account       | Connected to Claude Code on the web with at least one repo           |
| Slack authentication | Slack account linked to Claude account via the Claude app            |

**Routing modes** (configured in Claude App Home):

| Mode          | Behavior                                                              |
| :------------ | :-------------------------------------------------------------------- |
| Code only     | All @mentions route to Claude Code sessions                           |
| Code + Chat   | Claude intelligently routes between Code and Chat per message         |

**Setup steps:**
1. Workspace admin installs Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Each user connects their Claude account in the App Home tab
3. Configure Claude Code on the web at claude.ai/code with GitHub connected
4. Invite Claude to channels: `/invite @Claude`

**Message actions:** View Session, Create PR, Retry as Code, Change Repo

**Limitations:** GitHub only; works in channels only (not DMs); one PR per session; sessions use individual plan rate limits.

---

### Code Review (Managed Service)

Automated GitHub PR reviews via multi-agent analysis. Available for Team and Enterprise plans.

**Setup:** Admin enables at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code). Install the Claude GitHub App, select repositories, then configure review behavior per repo.

**Review trigger options:**

| Trigger                | Behavior                                                                |
| :--------------------- | :---------------------------------------------------------------------- |
| Once after PR creation | Runs once when PR opens or is marked ready                              |
| After every push       | Runs on every push; auto-resolves threads when issues are fixed         |
| Manual                 | Only runs when `@claude review` or `@claude review once` is commented   |

**Manual trigger commands** (top-level PR comment only):

| Command               | Behavior                                                            |
| :-------------------- | :------------------------------------------------------------------ |
| `@claude review`      | Starts a review and subscribes PR to push-triggered reviews         |
| `@claude review once` | One-shot review without subscribing to future pushes                |

**Severity levels:**

| Marker | Severity    | Meaning                                               |
| :----- | :---------- | :---------------------------------------------------- |
| Red    | Important   | Bug that should be fixed before merging               |
| Yellow | Nit         | Minor issue, not blocking                             |
| Purple | Pre-existing| Bug not introduced by this PR                         |

**Customization files:**

| File        | Priority      | Scope                                                       |
| :---------- | :------------ | :---------------------------------------------------------- |
| `CLAUDE.md` | Lower         | General project context; violations flagged as nits         |
| `REVIEW.md` | Highest       | Review-specific instructions injected into every agent      |

**`REVIEW.md` tuneable behaviors:** severity redefinition, nit volume cap, skip rules for paths/branches/categories, repo-specific checks, verification bar, re-review convergence rules, summary shape.

**Parse severity from check run output:**

```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# Returns e.g. {"normal": 2, "nit": 1, "pre_existing": 0}
```

**Pricing:** ~$15-25 per review on average, billed as extra usage separate from plan limits. Set a monthly spend cap at [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage).

**To retrigger a failed review:** comment `@claude review once` (the Re-run button in GitHub Checks does not work for Code Review).

**Usage dashboard:** [claude.ai/analytics/code-review](https://claude.ai/analytics/code-review)

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, v1 action parameters, upgrade from beta, cloud provider auth (Bedrock/Vertex), example workflows, troubleshooting, and advanced configuration
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — quick setup, GitLab job examples, AWS Bedrock and Vertex AI OIDC configuration, best practices, and troubleshooting
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, GitHub App permissions, developer workflow, GHES plugin marketplaces, managed settings, and limitations
- [Claude Code in Slack](references/claude-code-slack.md) — prerequisites, setup steps, routing modes, session flow, access controls, best practices, and current limitations
- [Code Review](references/claude-code-code-review.md) — how reviews work, severity levels, setup, manual triggers, CLAUDE.md and REVIEW.md customization, pricing, and troubleshooting

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Code Review: https://code.claude.com/docs/en/code-review.md
