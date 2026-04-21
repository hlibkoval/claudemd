---
name: ci-cd-doc
description: Complete official documentation for Claude Code CI/CD integrations — GitHub Actions, GitLab CI/CD, GitHub Code Review, Claude Code in Slack, and GitHub Enterprise Server support.
user-invocable: false
---

# CI/CD Documentation

This skill provides the complete official documentation for Claude Code CI/CD integrations.

## Quick Reference

### GitHub Actions

Trigger Claude via `@claude` mentions in PR/issue comments, or run automated workflows with a `prompt` parameter.

**Setup options:**
- Quick: run `/install-github-app` in the Claude terminal (direct API users only)
- Manual: install [github.com/apps/claude](https://github.com/apps/claude), add `ANTHROPIC_API_KEY` secret, copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)

**Action v1 parameters:**

| Parameter           | Description                                          | Required  |
| :------------------ | :--------------------------------------------------- | :-------- |
| `prompt`            | Instructions for Claude (optional — omit for `@claude` trigger mode) | No |
| `claude_args`       | CLI arguments passed through to Claude Code          | No        |
| `anthropic_api_key` | Claude API key                                       | Yes (direct API) |
| `github_token`      | GitHub token for API access                          | No        |
| `trigger_phrase`    | Custom trigger phrase (default: `@claude`)           | No        |
| `use_bedrock`       | Use AWS Bedrock instead of Claude API                | No        |
| `use_vertex`        | Use Google Vertex AI instead of Claude API           | No        |

**Common `claude_args`:** `--max-turns N`, `--model <id>`, `--allowedTools`, `--disallowedTools`, `--append-system-prompt`, `--mcp-config`

**Beta → v1 migration:**

| Old Beta Input        | New v1 Input                          |
| :-------------------- | :------------------------------------ |
| `mode`                | *(removed — auto-detected)*           |
| `direct_prompt`       | `prompt`                              |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns`           | `claude_args: --max-turns`            |
| `model`               | `claude_args: --model`                |
| `allowed_tools`       | `claude_args: --allowedTools`         |
| `claude_env`          | `settings` JSON format                |

**Minimal workflow:**
```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    # prompt: "optional instructions"
    # claude_args: "--max-turns 5"
```

**Cloud provider secrets:**

| Provider         | Required secrets                                          |
| :--------------- | :-------------------------------------------------------- |
| Direct API       | `ANTHROPIC_API_KEY`                                       |
| AWS Bedrock      | `AWS_ROLE_TO_ASSUME` (OIDC); Bedrock model IDs use region prefix e.g. `us.anthropic.claude-sonnet-4-6` |
| Google Vertex AI | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`   |
| Custom GitHub App| `APP_ID`, `APP_PRIVATE_KEY`                               |

---

### GitLab CI/CD (Beta)

Claude Code runs in GitLab CI jobs and commits results back via MRs. Maintained by GitLab.

**Quick setup — add to `.gitlab-ci.yml`:**
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
      claude -p "${AI_FLOW_INPUT:-'Review this MR'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**Key CI/CD variables:**

| Variable                         | Purpose                                      |
| :------------------------------- | :------------------------------------------- |
| `ANTHROPIC_API_KEY`              | Direct Claude API (masked)                   |
| `AWS_ROLE_TO_ASSUME`, `AWS_REGION` | AWS Bedrock (OIDC, no static keys)         |
| `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` | Google Vertex AI (WIF) |
| `AI_FLOW_INPUT`                  | Prompt from mention trigger                  |
| `AI_FLOW_CONTEXT`                | Context from thread/issue                    |
| `AI_FLOW_EVENT`                  | Trigger event type                           |

**Mention triggers:** configure a webhook that fires the pipeline trigger API with `AI_FLOW_*` variables when a comment contains `@claude`.

---

### Code Review (Team/Enterprise)

Automated PR reviews posted as inline comments on specific diff lines. Uses a fleet of specialized agents.

**Setup:** admin enables at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code), installs Claude GitHub App (Contents/Issues/Pull requests: read+write), selects repositories, sets per-repo trigger.

**Review triggers:**

| Trigger                   | Behavior                                              |
| :------------------------ | :---------------------------------------------------- |
| Once after PR creation    | Runs once on open/ready-for-review                    |
| After every push          | Runs on each push; auto-resolves fixed threads        |
| Manual                    | Runs only when `@claude review` is commented          |

**Manual trigger commands (top-level PR comment only):**

| Command               | Effect                                                        |
| :-------------------- | :------------------------------------------------------------ |
| `@claude review`      | Start review + subscribe PR to push-triggered reviews         |
| `@claude review once` | Start one review without subscribing to future pushes         |

**Severity levels:**

| Marker | Level        | Meaning                                              |
| :----- | :----------- | :--------------------------------------------------- |
| 🔴     | Important    | Bug that should be fixed before merging              |
| 🟡     | Nit          | Minor issue, not blocking                            |
| 🟣     | Pre-existing | Bug not introduced by this PR                        |

**Customization files:**

| File         | Priority           | Use for                                                      |
| :----------- | :----------------- | :----------------------------------------------------------- |
| `CLAUDE.md`  | Project context    | Standards/conventions; violations flagged as nits            |
| `REVIEW.md`  | Highest (injected) | Severity redefinition, nit caps, skip rules, repo-specific checks |

**Pricing:** ~$15–25 per review, billed as extra usage separate from plan limits. Set cap at [claude.ai/admin-settings/usage](https://claude.ai/admin-settings/usage). Monitor at [claude.ai/analytics/code-review](https://claude.ai/analytics/code-review).

**Parse severity from check run:**
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# Returns e.g. {"normal": 2, "nit": 1, "pre_existing": 0}
```

---

### Claude Code in Slack

`@Claude` mentions in Slack channels auto-route coding requests to Claude Code on the web.

**Requirements:** Pro/Max/Team/Enterprise with Claude Code access; Claude Code on the web enabled; GitHub account connected; Slack account linked to Claude account.

**Setup steps:**
1. Workspace admin installs Claude app from Slack Marketplace
2. Each user connects their Claude account in App Home
3. Configure GitHub in Claude Code on the web ([claude.ai/code](https://claude.ai/code))
4. Choose routing mode; invite Claude to channels with `/invite @Claude`

**Routing modes:**

| Mode          | Behavior                                                         |
| :------------ | :--------------------------------------------------------------- |
| Code only     | All @mentions go to Claude Code sessions                         |
| Code + Chat   | Claude intelligently routes between Code and Chat per message    |

**Session flow:** mention → detect intent → create session at claude.ai/code → post Slack status updates → @mention with summary + "View Session" / "Create PR" buttons.

**Limitations:** GitHub only; channels only (not DMs); one PR per session; requires individual plan with Claude Code access.

---

### GitHub Enterprise Server (Team/Enterprise)

Connect Claude Code to a self-managed GHES instance. Admin setup is one-time; developers use it transparently.

**Feature support:**

| Feature                | GHES support    | Notes                                                          |
| :--------------------- | :-------------- | :------------------------------------------------------------- |
| Claude Code on the web | Supported       | `claude --remote` detects GHES host from git remote            |
| Code Review            | Supported       | Same as github.com                                             |
| Teleport sessions      | Supported       | `claude --teleport`                                            |
| Plugin marketplaces    | Supported       | Use full git URLs, not `owner/repo` shorthand                  |
| Contribution metrics   | Supported       | Via webhooks to analytics dashboard                            |
| GitHub Actions         | Supported       | Manual workflow setup required; `/install-github-app` is github.com only |
| GitHub MCP server      | Not supported   | Use `gh` CLI configured with `gh auth login --hostname <host>` |

**Admin setup:** [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) → Connect → enter GHES hostname (+ optional CA cert) → Create GitHub App on GHES instance → install app on repositories → enable Code Review/metrics.

**Developer workflow:** no extra config needed after admin setup. Claude detects the GHES host from the git remote automatically.

**GHES plugin marketplace:**
```bash
# Full URL required (owner/repo resolves to github.com)
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

**Allowlist GHES in managed settings:**
```json
{
  "strictKnownMarketplaces": [
    { "source": "hostPattern", "hostPattern": "^github\\.example\\.com$" }
  ]
}
```

**Network requirement:** GHES must be reachable from Anthropic infrastructure. Allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses) if behind a firewall.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code GitHub Actions](references/claude-code-github-actions.md) — setup, workflow examples, cloud provider auth (Bedrock/Vertex), action parameters, best practices, troubleshooting
- [Claude Code GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — beta integration, job configuration, OIDC/WIF auth, use cases, security, troubleshooting
- [Code Review](references/claude-code-code-review.md) — automated PR reviews, severity levels, REVIEW.md customization, pricing, usage analytics
- [Claude Code in Slack](references/claude-code-slack.md) — setup, routing modes, session flow, access controls, limitations
- [Claude Code with GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — admin setup, GitHub App permissions, developer workflow, GHES marketplaces, limitations

## Sources

- Claude Code GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- Claude Code GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- Claude Code in Slack: https://code.claude.com/docs/en/slack.md
- Claude Code with GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
