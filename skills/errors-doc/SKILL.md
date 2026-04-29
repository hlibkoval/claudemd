---
name: errors-doc
description: Complete official documentation for Claude Code runtime error messages — what each error means, how to recover, automatic retry behavior, and how to report issues.
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors and how to recover from them.

## Quick Reference

### Error Index

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `Prompt is too long` | Request errors |
| `Error during compaction: Conversation too long` | Request errors |
| `Request too large` | Request errors |
| `Image was too large` | Request errors |
| `PDF too large` / `PDF is password protected` | Request errors |
| `Extra inputs are not permitted` | Request errors |
| `There's an issue with the selected model` | Request errors |
| `Claude Opus is not available with the Claude Pro plan` | Request errors |
| `thinking.type.enabled is not supported for this model` | Request errors |
| `max_tokens must be greater than thinking.budget_tokens` | Request errors |
| `API Error: 400 due to tool use concurrency issues` | Request errors |
| Responses seem lower quality than usual | Response quality |

---

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. The spinner shows `Retrying in Ns · attempt x/y`. When an error is displayed, retries are already exhausted.

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

---

### Server Errors

These come from Anthropic infrastructure, not your account or request.

| Error | Recovery |
| :--- | :--- |
| `API Error: 500 Internal server error` | Check status.claude.com; retry with `try again`; run `/feedback` if persistent |
| `API Error: Repeated 529 Overloaded errors` | Check status.claude.com; retry in a few minutes; use `/model` to switch to a less-loaded model |
| `Request timed out` | Retry; break large tasks into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode cannot determine the safety of an action | Retry after a few seconds; continue with read-only tasks; setting change not needed |

---

### Usage Limits

Tied to your account or plan quota, distinct from server errors.

| Error | Recovery |
| :--- | :--- |
| `You've hit your session limit` | Wait for reset time shown; run `/usage` for limits; run `/extra-usage` to buy more; upgrade at claude.com/pricing |
| `Server is temporarily limiting requests` | Wait briefly and retry; check status.claude.com |
| `Request rejected (429)` | Run `/status` to confirm active credential; check provider console limits; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; enable auto-reload; switch to subscription auth with `/login` |

---

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Recovery |
| :--- | :--- |
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env | grep ANTHROPIC`; unset key and use `/login`; test `apiKeyHelper` script directly |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell and profile; relaunch `claude`; run `/status` to confirm |
| `OAuth token revoked or expired` | Run `/login`; if recurring, run `/logout` then `/login`; check system clock and macOS Keychain |
| OAuth scope requirement (`user:profile`) | Run `/login` to mint a new token — no need to log out first |

---

### Network and Connection Errors

Almost always originate in local network, proxy, or firewall.

| Error | Recovery |
| :--- | :--- |
| `Unable to connect to API` | Run `curl -I https://api.anthropic.com` from the same shell; set `HTTPS_PROXY` for corporate proxies; set `ANTHROPIC_BASE_URL` for LLM gateways |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |

**Additional connectivity checks:**

- Linux/WSL: check `/etc/resolv.conf` for an unreachable nameserver
- macOS: check `ifconfig` for stale `utun` interfaces from disconnected VPNs
- Docker Desktop: quit and retry to rule out traffic interception

---

### Request Errors

The API received the request but rejected its content.

| Error | Recovery |
| :--- | :--- |
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` to inspect usage; disable unused MCP servers with `/mcp disable <name>`; trim large CLAUDE.md files |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns, then run `/compact` again; or run `/clear` and `/resume` |
| `Request too large` | Press Esc twice and step back; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice and step back; resize to under 8000px (or 2000px when many images in context) |
| `PDF too large` / `PDF is password protected` | Read a page range with the Read tool; extract text with `pdftotext`; remove password protection |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header (see LLM gateway docs); or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model` to pick an available model; use aliases (`sonnet`, `opus`) instead of versioned IDs; check for stale model in env vars or settings files |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model` to select an included model; if recently upgraded, run `/logout` then `/login` |
| `thinking.type.enabled is not supported for this model` | Run `claude update` to v2.1.111+; or switch to Opus 4.6 or Sonnet with `/model` |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |

---

### Response Quality Seems Lower Than Usual

No error shown but responses seem less capable. Claude Code does not silently change models.

| Check | Command |
| :--- | :--- |
| Confirm active model | `/model` |
| Check reasoning level | `/effort` — raise for hard tasks; try `ultrathink` shortcut |
| Inspect context window | `/context` — run `/compact` or `/clear` if near capacity |
| Check for stale CLAUDE.md or large MCP definitions | `/doctor` |

When a response goes wrong, **rewind instead of correcting in-thread**: press Esc twice or run `/rewind` to step back to before the bad turn and rephrase.

---

### Reporting Errors

| Situation | Action |
| :--- | :--- |
| Error not listed or fix did not help | Run `/feedback` to send transcript + description to Anthropic |
| Bedrock / Vertex AI / Foundry deployment (`/feedback` unavailable) | Search [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues) or open a new issue |
| Local config problems | Run `/doctor` |
| Active incidents | Check [status.claude.com](https://status.claude.com) |
| MCP server failures | See [MCP docs](/en/mcp) |
| Hook script failures | See [Debug hooks](/en/hooks#debug-hooks) |
| Install / filesystem errors | See [Troubleshoot installation and login](/en/troubleshoot-install) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — full list of runtime error messages with causes, recovery steps, automatic retry behavior, and reporting guidance

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
