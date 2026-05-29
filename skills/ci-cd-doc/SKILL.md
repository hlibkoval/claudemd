---
name: ci-cd-doc
user-invocable: false
---

# CI/CD & Integrations Documentation

This skill provides the complete official documentation for integrating Claude Code with CI/CD systems and external services — GitHub Actions, GitLab CI/CD, GitHub Enterprise Server, automated Code Review, and Claude in Slack.

## Quick Reference

### Integration Overview

| Integration | Trigger | Runs on | Best for |
|:-----------|:--------|:--------|:---------|
| GitHub Actions | `@claude` mention in PR/issue, or scheduled/automated prompt | GitHub-hosted runners | Custom CI automation, PR workflows |
| GitLab CI/CD (beta) | `@claude` in issue/MR, `AI_FLOW_INPUT` variable, or manual job | Your GitLab runners | MR creation, issue implementation, custom pipelines |
| Code Review (managed) | PR open/push/`@claude review` comment | Anthropic infrastructure | Automated multi-agent PR review |
| GitHub Enterprise Server | Same as above | Anthropic infra + GHES | GHES-hosted repos, self-managed GitHub |
| Claude in Slack | `@Claude` mention in channel | Anthropic infrastructure | Task delegation from Slack conversations |

### GitHub Actions Setup

**Quick setup:** Run `/install-github-app` in Claude Code terminal (direct API users only).

**Manual setup:**
1. Install [Claude GitHub App](https://github.com/apps/claude) — requires Contents/Issues/Pull requests: Read & Write
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow from [examples/claude.yml](https://github.com/anthropics/claude-code-action/blob/main/examples/claude.yml)

**Action reference (v1):**

| Parameter | Required | Description |
|:----------|:---------|:------------|
| `anthropic_api_key` | Yes (not for Bedrock/Vertex) | Claude API key secret |
| `prompt` | No | Instructions or skill invocation; required for automation mode |
| `claude_args` | No | Any Claude Code CLI flags (`--max-turns`, `--model`, etc.) |
| `plugin_marketplaces` | No | Newline-separated plugin marketplace Git URLs |
| `plugins` | No | Newline-separated plugin names to install |
| `github_token` | No | GitHub token (default: GITHUB_TOKEN) |
| `trigger_phrase` | No | Custom trigger phrase (default: `@claude`) |
| `use_bedrock` | No | Use Amazon Bedrock instead of Claude API |
| `use_vertex` | No | Use Google Vertex AI instead of Claude API |

**Minimal workflow:**
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

**v1 breaking changes from beta:**

| Old beta input | New v1.0 input |
|:---------------|:---------------|
| `mode` | Removed — auto-detected |
| `direct_prompt` | `prompt` |
| `override_prompt` | `prompt` with GitHub variables |
| `custom_instructions` | `claude_args: --append-system-prompt` |
| `max_turns` | `claude_args: --max-turns` |
| `model` | `claude_args: --model` |
| `allowed_tools` | `claude_args: --allowedTools` |
| `disallowed_tools` | `claude_args: --disallowedTools` |
| `claude_env` | `settings` JSON format |

### GitLab CI/CD Setup

**Quick setup:**
1. Add `ANTHROPIC_API_KEY` as a masked CI/CD variable (Settings → CI/CD → Variables)
2. Add a Claude job to `.gitlab-ci.yml`:

```yaml
claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk add --no-cache git curl bash
    - curl -fsSL https://claude.ai/install.sh | bash
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'Review this MR and implement the requested changes'}"
      --permission-mode acceptEdits
      --allowedTools "Bash Read Edit Write mcp__gitlab"
```

**GitLab CI/CD variables:**

| Variable | Description |
|:---------|:------------|
| `ANTHROPIC_API_KEY` | API key (masked) |
| `AI_FLOW_INPUT` | Prompt/instruction from event listener |
| `AI_FLOW_CONTEXT` | MR/issue context |
| `AI_FLOW_EVENT` | Event type that triggered the job |
| `AWS_ROLE_TO_ASSUME` | IAM role ARN for Bedrock |
| `AWS_REGION` | AWS region for Bedrock |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | WIF provider for Vertex AI |
| `GCP_SERVICE_ACCOUNT` | Service account email for Vertex AI |
| `CLOUD_ML_REGION` | Vertex AI region (e.g., `us-east5`) |

### Cloud Provider Authentication

Both GitHub Actions and GitLab CI/CD support Bedrock and Vertex AI as alternatives to the direct Claude API:

**Amazon Bedrock (GitHub Actions):**
- Set up GitHub OIDC Identity Provider in AWS; create IAM role with Bedrock permissions
- Use `use_bedrock: "true"` in action inputs; model IDs use region prefix (e.g., `us.anthropic.claude-sonnet-4-6`)
- Required secret: `AWS_ROLE_TO_ASSUME`

**Google Vertex AI (GitHub Actions):**
- Configure Workload Identity Federation in GCP; create service account with `Vertex AI User` role
- Use `use_vertex: "true"` in action inputs; set `ANTHROPIC_VERTEX_PROJECT_ID` and `CLOUD_ML_REGION` env vars
- Required secrets: `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT`

### Code Review (Managed Service)

Available for Team and Enterprise plans. Not available with Zero Data Retention.

**Review triggers per repo:**

| Mode | When reviews run |
|:-----|:----------------|
| Once after PR creation | On PR open or ready-for-review |
| After every push | On each push to the PR branch |
| Manual | Only when `@claude review` or `@claude review once` is commented |

**Manual trigger commands:**

| Command | Effect |
|:--------|:-------|
| `@claude review` | Starts review + subscribes PR to push-triggered reviews |
| `@claude review once` | Starts a single review without subscribing to future pushes |

Both commands require: top-level PR comment, owner/member/collaborator access, and an open PR.

**Severity levels:**

| Marker | Severity | Meaning |
|:-------|:---------|:--------|
| 🔴 | Important | Bug that should be fixed before merging |
| 🟡 | Nit | Minor issue, not blocking |
| 🟣 | Pre-existing | Bug exists but not introduced by this PR |

**Customizing reviews:**

| File | Effect |
|:-----|:-------|
| `CLAUDE.md` | Project context; new violations flagged as nits |
| `REVIEW.md` | Highest-priority instructions injected into every review agent; controls severity, nit volume, skip rules, and repo-specific checks |

**Pricing:** ~$15–25 per review, billed via usage credits, separate from plan usage. Set a monthly cap at claude.ai/admin-settings/usage.

**Setup:** Admin goes to claude.ai/admin-settings/claude-code → Code Review → Setup, installs the Claude GitHub App, selects repositories, and configures review behavior per repo.

**Retrigger a failed review:** Comment `@claude review once` on the PR. The Re-run button in GitHub Checks does NOT retrigger Code Review.

**Parse severity from check run output:**
```bash
gh api repos/OWNER/REPO/check-runs/CHECK_RUN_ID \
  --jq '.output.text | split("bughunter-severity: ")[1] | split(" -->")[0] | fromjson'
# Returns: {"normal": 2, "nit": 1, "pre_existing": 0}
```

**Local review:** Use the `/code-review` command in any Claude Code session. Pass `--comment` to post findings as inline PR comments, or `--fix` to apply fixes to the working tree.

### GitHub Enterprise Server (GHES)

Available for Team and Enterprise plans.

**GHES feature support:**

| Feature | Supported | Notes |
|:--------|:----------|:------|
| Claude Code on the web | Yes | Uses `claude --remote` |
| Code Review | Yes | Same as github.com |
| Claude Security | Yes | Public beta for Enterprise |
| Teleport sessions | Yes | `claude --teleport` |
| Plugin marketplaces | Yes | Use full git URLs, not `owner/repo` |
| Contribution metrics | Yes | Via webhooks |
| GitHub Actions | Yes | Manual workflow setup only; `/install-github-app` is github.com only |
| GitHub MCP server | No | Use `gh` CLI configured for GHES instead |

**Admin setup:** claude.ai/admin-settings/claude-code → GitHub Enterprise Server → Connect. Enter display name and GHES hostname. Follow guided flow to create the GitHub App on the GHES instance.

**GitHub App permissions required:**

| Permission | Access | Used for |
|:-----------|:-------|:---------|
| Contents | Read & write | Cloning repos, pushing branches |
| Pull requests | Read & write | Creating PRs, posting review comments |
| Issues | Read & write | Responding to issue mentions |
| Checks | Read & write | Posting Code Review check runs |
| Actions | Read | Reading CI status |
| Repository hooks | Read & write | Contribution metrics webhooks |
| Metadata | Read | Required by GitHub |

**GHES plugin marketplaces:** Use full git URLs instead of `owner/repo` shorthand:
```bash
/plugin marketplace add git@github.example.com:platform/claude-plugins.git
```

**Network requirement:** GHES instance must be reachable from Anthropic infrastructure. Allowlist [Anthropic API IP addresses](https://platform.claude.com/docs/en/api/ip-addresses).

### Claude in Slack

**Requirements:** Pro/Max/Team/Enterprise plan with Claude Code access; Claude Code on the web enabled; GitHub account connected; Slack account linked.

**Setup:**
1. Workspace admin installs Claude app from [Slack App Marketplace](https://slack.com/marketplace/A08SF47R6P4)
2. Each user connects their Claude account in the Claude App Home
3. Configure routing mode; invite Claude to channels with `/invite @Claude`

**Routing modes:**

| Mode | Behavior |
|:-----|:---------|
| Code only | All @mentions route to Claude Code sessions |
| Code + Chat | Claude auto-routes between Claude Code (coding tasks) and Chat (general questions) |

**Session flow:** @mention → detection → session created at claude.ai/code → progress updates in thread → completion with "View Session" and "Create PR" buttons.

**Limitations:** GitHub only; one PR per session; works in channels only (not DMs); requires Claude Code on the web access.

## Full Documentation

For the complete official documentation, see the reference files:

- [GitHub Actions](references/claude-code-github-actions.md) — Setup, workflow examples, action parameters, cloud provider integration, best practices, and troubleshooting
- [GitLab CI/CD](references/claude-code-gitlab-ci-cd.md) — Setup, job examples for Claude API/Bedrock/Vertex, security guidance, and troubleshooting
- [Code Review](references/claude-code-code-review.md) — Managed PR review service: how it works, setup, triggers, REVIEW.md customization, pricing, and troubleshooting
- [GitHub Enterprise Server](references/claude-code-github-enterprise-server.md) — Connect GHES to Claude Code: admin setup, feature support, plugin marketplaces, and limitations
- [Claude in Slack](references/claude-code-slack.md) — Delegate coding tasks from Slack: setup, routing modes, session flow, access controls, and troubleshooting

## Sources

- GitHub Actions: https://code.claude.com/docs/en/github-actions.md
- GitLab CI/CD: https://code.claude.com/docs/en/gitlab-ci-cd.md
- Code Review: https://code.claude.com/docs/en/code-review.md
- GitHub Enterprise Server: https://code.claude.com/docs/en/github-enterprise-server.md
- Claude in Slack: https://code.claude.com/docs/en/slack.md
