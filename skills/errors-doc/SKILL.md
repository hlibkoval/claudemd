---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error messages, categories (server, usage limits, authentication, network, request), automatic retries, recovery commands, and response quality troubleshooting.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors and how to recover from them.

## Quick Reference

### Error Index

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | [Server errors](#server-errors) |
| `API Error: Repeated 529 Overloaded errors` | [Server errors](#server-errors) |
| `Request timed out` | [Server errors](#server-errors) |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | [Server errors](#server-errors) |
| `Auto mode could not evaluate this action and is blocking it for safety` | [Server errors](#server-errors) |
| `Auto mode classifier transcript exceeded context window` | [Server errors](#server-errors) |
| `You've hit your session limit` / `You've hit your weekly limit` | [Usage limits](#usage-limits) |
| `Server is temporarily limiting requests` | [Usage limits](#usage-limits) |
| `Request rejected (429)` | [Usage limits](#usage-limits) |
| `Credit balance is too low` | [Usage limits](#usage-limits) |
| `Not logged in · Please run /login` | [Authentication](#authentication-errors) |
| `Invalid API key` | [Authentication](#authentication-errors) |
| `This organization has been disabled` | [Authentication](#authentication-errors) |
| `Routines are disabled by your organization's policy` | [Authentication](#authentication-errors) |
| `OAuth token revoked` / `OAuth token has expired` | [Authentication](#authentication-errors) |
| `does not meet scope requirement user:profile` | [Authentication](#authentication-errors) |
| `Unable to connect to API` | [Network](#network-and-connection-errors) |
| `SSL certificate verification failed` | [Network](#network-and-connection-errors) |
| `403` with `x-deny-reason: host_not_allowed` in a cloud or routine session | [Network](#network-and-connection-errors) |
| `Prompt is too long` | [Request errors](#request-errors) |
| `Error during compaction: Conversation too long` | [Request errors](#request-errors) |
| `Request too large` | [Request errors](#request-errors) |
| `Image was too large` | [Request errors](#request-errors) |
| `PDF too large` / `PDF is password protected` | [Request errors](#request-errors) |
| `Extra inputs are not permitted` | [Request errors](#request-errors) |
| `There's an issue with the selected model` | [Request errors](#request-errors) |
| `Claude Opus is not available with the Claude Pro plan` | [Request errors](#request-errors) |
| `thinking.type.enabled is not supported for this model` | [Request errors](#request-errors) |
| `max_tokens must be greater than thinking.budget_tokens` | [Request errors](#request-errors) |
| `API Error: 400 due to tool use concurrency issues` | [Request errors](#request-errors) |
| Responses seem lower quality than usual | [Response quality](#response-quality) |

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying. Retried: server errors, 529 overloaded, request timeouts, temporary 429s, dropped connections.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

Errors from Anthropic infrastructure — not caused by your account or request.

| Error | Recovery |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Check status.claude.com; wait and retry; run `/feedback` if persistent |
| `API Error: Repeated 529 Overloaded errors` | Check status.claude.com; wait a few minutes; switch models with `/model` |
| `Request timed out` | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode classifier unavailable | Retry after a few seconds; continue with read-only tasks |
| Auto mode could not evaluate action | Retry; run `claude --debug` to see classifier response |
| Auto mode classifier transcript too long | Approve/deny in the prompt that appears; run `/compact` to reduce conversation size |

Note: Read, search, and edits inside your working directory skip the auto mode classifier and always work.

### Usage Limits

Errors tied to your account or plan quota — distinct from server errors.

| Error | Recovery |
| :--- | :--- |
| `You've hit your session limit` / `You've hit your weekly limit` | Wait for reset time shown; run `/usage` for details; run `/extra-usage` to buy more |
| `Server is temporarily limiting requests` | Wait briefly and retry; check status.claude.com |
| `Request rejected (429)` | Run `/status` to check active credential; check provider rate limits; reduce concurrency via `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; switch to subscription auth with `/login` |

### Authentication Errors

Run `/status` at any time to see which credential is currently active.

| Error | Recovery |
| :--- | :--- |
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env | grep ANTHROPIC`; unset `ANTHROPIC_API_KEY` and use `/login`; run `/status` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell profile; relaunch `claude`; confirm active credential with `/status` |
| `Routines are disabled by organization policy` | Ask admin to enable Routines toggle at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | Run `/login`; if recurring, run `/logout` then `/login`; see troubleshoot-install for clock/Keychain checks |
| `OAuth token does not meet scope requirement` | Run `/login` to mint new token with current scopes |

Environment variables take precedence over `/login`. A stale `ANTHROPIC_API_KEY` in your shell profile will override your subscription even after logging in.

### Network and Connection Errors

| Error | Recovery |
| :--- | :--- |
| `Unable to connect to API` | Run `curl -I https://api.anthropic.com`; set `HTTPS_PROXY` if behind corporate proxy; set `ANTHROPIC_BASE_URL` for LLM gateways |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; see Network configuration docs |
| `403` with `x-deny-reason: host_not_allowed` (cloud/routine) | Change environment Network access from **Trusted** to **Custom**; add blocked domain to **Allowed domains** |

For `Unable to connect` when `curl` succeeds: check `/etc/resolv.conf` on Linux/WSL; check for stale VPN tunnel interfaces on macOS; quit Docker Desktop or similar tools.

Do NOT set `NODE_TLS_REJECT_UNAUTHORIZED=0` (disables certificate validation entirely).

### Request Errors

Errors where the API received but rejected the request content.

| Error | Recovery |
| :--- | :--- |
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` to see breakdown; disable unused MCP servers; trim CLAUDE.md; re-enable auto-compact if `DISABLE_AUTO_COMPACT` is set |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns then run `/compact`; if still failing, run `/clear` (use `/resume` to reopen) |
| `Request too large (max 30 MB)` | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize image before pasting (max 8000px single image, 2000px with many images); take tighter screenshot |
| `PDF too large` / `PDF is password protected` | Use Read tool with page range instead of attaching; extract text with `pdftotext`; remove password or re-export |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model` to pick available model; use alias (`sonnet`, `opus`) instead of full versioned ID; check `ANTHROPIC_MODEL`, settings files for stale model ID |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model` to select plan-eligible model; run `/logout` then `/login` if recently upgraded |
| `thinking.type.enabled is not supported for this model` | Run `claude update` to upgrade to v2.1.111+; or switch to Opus 4.6 or Sonnet with `/model` |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |

### Response Quality

When responses seem lower quality than expected (no error shown):

| Check | Action |
| :--- | :--- |
| Model selection | Run `/model` to confirm expected model; check `ANTHROPIC_MODEL` env var and settings files for stale IDs |
| Effort level | Run `/effort` to check reasoning level; raise it for complex work; see `/model-config` for per-model defaults |
| Context pressure | Run `/context` to check window fill; run `/compact` near capacity; re-enable auto-compact if disabled |
| Stale instructions | Run `/doctor` to flag oversized CLAUDE.md and subagent definitions; run `/context` to see MCP tool token usage |

When a response goes wrong, **rewinding works better than correcting in-thread** — press Esc twice or run `/rewind` to step back before the bad turn, then rephrase.

### Reporting Errors

| Situation | Action |
| :--- | :--- |
| Error not listed or fix doesn't work | Run `/feedback` inside Claude Code to send transcript to Anthropic |
| MCP server failed | See [MCP docs](/en/mcp) |
| Hook script failed | See [Debug hooks](/en/hooks#debug-hooks) |
| Permission/filesystem errors during install | See [Troubleshoot installation](/en/troubleshoot-install) |
| Bedrock/Vertex/Foundry deployments | `/feedback` unavailable — open GitHub issue directly |

Additional resources: run `/doctor` to check local config; check status.claude.com for incidents; search [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues).

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — Complete runtime error messages, categories, recovery steps, automatic retries, and response quality troubleshooting

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
