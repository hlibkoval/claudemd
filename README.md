# claudemd

[Official Claude Code documentation](https://code.claude.com/docs) packaged as a plugin. Gives Claude instant access to up-to-date reference docs for skills, hooks, plugins, MCP, sub-agents, settings, CLI, IDE integrations, and more — without web searches or hallucinated APIs.

## What's included

18 skill topics covering the full Claude Code documentation surface:

| Skill | Covers |
|-------|--------|
| `getting-started` | Installation, authentication, agentic loop, built-in tools |
| `cli` | CLI flags, commands, keyboard shortcuts, terminal config |
| `settings` | Configuration scopes, permissions, sandbox, environment variables |
| `memory` | CLAUDE.md files, auto memory, project rules, imports |
| `skills` | Creating skills, SKILL.md format, Agent Skills standard |
| `hooks` | Event-driven shell commands, lifecycle hooks, matchers |
| `plugins` | Creating, distributing, discovering, and installing plugins |
| `mcp` | MCP server integration, stdio/SSE/HTTP, tool search |
| `sub-agents` | Custom subagent markdown files, tool restrictions, models |
| `agent-teams` | Multi-agent teams, shared task lists, inter-agent messaging |
| `ide` | VS Code, JetBrains, Desktop app, Chrome extension |
| `headless` | Programmatic CLI, streaming, CI/CD, cloud environments |
| `ci-cd` | GitHub Actions, GitLab CI/CD, Slack workflows |
| `features` | Model config, fast mode, output styles, checkpointing |
| `best-practices` | Context management, prompting, parallel execution |
| `operations` | Cost management, OpenTelemetry, analytics, troubleshooting |
| `security` | Sandboxing, devcontainers, network config, data policies |
| `cloud-providers` | Bedrock, Vertex AI, Foundry, LLM gateways |

Each skill includes a concise `SKILL.md` summary and `references/` with 57 word-for-word copies of the official docs, sourced from [code.claude.com/docs](https://code.claude.com/docs).

## Installation

### From the marketplace (recommended)

1. Add the marketplace:

```
/plugin marketplace add hlibkoval/claudemd
```

2. Install the plugin:

```
/plugin install claudemd@claudemd
```

### Local development

Clone the repo and run Claude Code with the plugin loaded from disk:

```bash
git clone https://github.com/hlibkoval/claudemd.git
cd claudemd
claude --plugin-dir .
```

## How it works

Skills use `user-invocable: false` — they don't show up as slash commands. Instead, Claude automatically consults the relevant skill when you ask about hooks, plugins, MCP configuration, etc.

For example, asking "how do I create a hook that runs after every file edit?" will cause Claude to pull in the hooks skill and give you an accurate answer based on the actual docs.

## Updating

Update the marketplace to pull the latest docs:

```
/plugin marketplace update claudemd
```

Or enable auto-updates in the plugin manager (`/plugin` > Marketplaces > claudemd > Enable auto-update).

## License

MIT