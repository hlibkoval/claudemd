---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error messages, causes, and recovery steps for server errors, usage limits, authentication errors, network errors, request errors, and response quality issues.
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
| `Request timed out` | Server errors (or Network if it mentions internet connection) |
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

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. Retried automatically: server errors, 529 overloaded, request timeouts, temporary 429 throttles, dropped connections. Spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Env Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `API Error: 500` | Unexpected API failure | Check status.claude.com; retry; run `/feedback` |
| `API Error: Repeated 529 Overloaded errors` | API at capacity for all users | Check status.claude.com; retry in a few minutes; run `/model` to switch models |
| `Request timed out` | API did not respond before deadline (10 min default) | Retry; break large tasks into smaller prompts; raise `API_TIMEOUT_MS` for slow proxies |
| `<model> is temporarily unavailable, so auto mode cannot determine safety...` | Auto mode classifier overloaded | Retry after a few seconds (Claude usually retries automatically); continue with read-only tasks |

### Usage Limit Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `You've hit your session/weekly/Opus limit` | Subscription quota exhausted | Wait for reset time shown; run `/usage`; run `/extra-usage` to buy more; upgrade plan |
| `Server is temporarily limiting requests` | Short-lived server throttle (not your quota) | Wait briefly and retry |
| `Request rejected (429)` | Rate limit on API key or cloud provider project | Run `/status` to verify credential; check provider console; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload; switch to subscription auth |

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Not logged in · Please run /login` | No valid credential | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Key rejected by API | Check for typos; run `env \| grep ANTHROPIC`; unset key and run `/login` |
| `This organization has been disabled` | Stale `ANTHROPIC_API_KEY` from disabled org overrides subscription | Unset `ANTHROPIC_API_KEY`; remove from shell profile; relaunch |
| `OAuth token revoked` / `OAuth token has expired` | Saved login is no longer valid | Run `/login`; if error recurs, run `/logout` first then `/login` |
| `OAuth token does not meet scope requirement: user:profile` | Token predates a newer permission scope | Run `/login` to mint a new token (no logout needed) |

### Network Errors

These almost always originate in local network, proxy, or firewall rather than Anthropic infrastructure.

| Error | Common cause | Fix |
| :--- | :--- | :--- |
| `Unable to connect to API (ECONNREFUSED/ECONNRESET/ETIMEDOUT)` | No internet, VPN blocking api.anthropic.com, unconfigured proxy | Test with `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways |
| `SSL certificate verification failed` / `Self-signed certificate detected` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |

Additional diagnostics for `curl` succeeding but Claude Code failing:
- Linux/WSL: check `/etc/resolv.conf` for unreachable nameserver
- macOS: stale VPN tunnel interfaces or routing rules (check `ifconfig` for stale `utun` interfaces)
- Docker Desktop: can intercept outbound traffic (quit and retry to rule out)

### Request Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Prompt is too long` | Conversation + files exceed model context window | Run `/compact`; run `/context` to see usage; disable unused MCP servers with `/mcp disable <name>`; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Not enough free context to hold compaction summary | Press Esc twice to step back several turns then run `/compact`; or run `/clear` (session preserved, use `/resume`) |
| `Request too large (max 30 MB)` | Raw request body too large (separate from context window) | Press Esc twice to step back; reference large files by path instead of pasting |
| `Image was too large` | Image exceeds API size/dimension limits | Press Esc twice to remove image; resize to under 8000px longest edge (2000px with many images) |
| `PDF too large` / `PDF is password protected` | PDF exceeds 100 pages/32 MB, or has password | Use Read tool for page ranges; extract text with `pdftotext`; remove password and re-export |
| `Extra inputs are not permitted ... context_management` | Proxy/gateway stripped `anthropic-beta` header | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name not recognized or no account access | Run `/model`; use aliases like `sonnet` or `opus`; check `ANTHROPIC_MODEL`, settings files for stale IDs |
| `Claude Opus is not available with the Claude Pro plan` | Plan doesn't include selected model | Run `/model` and select a supported model; run `/logout` then `/login` if recently upgraded |
| `"thinking.type.enabled" is not supported for this model` | Claude Code version too old for Opus 4.7 | Run `claude update` to v2.1.111+; or switch to Opus 4.6 or Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Thinking budget exceeds provider output limit | Lower `MAX_THINKING_TOKENS`; or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the budget |
| `API Error: 400 due to tool use concurrency issues` | Conversation history in inconsistent state (interrupted tool call) | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |

### Response Quality Checklist

When responses seem lower quality but no error is shown:

| Check | Command | What to look for |
| :--- | :--- | :--- |
| Model selection | `/model` | Confirm you're on the expected model; check `ANTHROPIC_MODEL` env var |
| Effort level | `/effort` | Raise for hard debugging or design work; use `ultrathink` shortcut |
| Context pressure | `/context` | If near capacity, run `/compact` or `/clear` |
| Stale instructions | `/doctor` | Flags oversized CLAUDE.md files and subagent definitions |

When a response goes wrong: use `/rewind` or Esc twice to step back before the bad turn and rephrase rather than correcting in-thread (corrections keep the wrong attempt in context, anchoring later answers).

### Reporting Errors

| Resource | Use when |
| :--- | :--- |
| `/feedback` | Run inside Claude Code to send transcript + description to Anthropic (unavailable on Bedrock/Vertex/Foundry) |
| `/doctor` | Check for local configuration problems |
| [status.claude.com](https://status.claude.com) | Check for active incidents |
| [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues) | Search existing issues |

For errors from specific components: MCP issues → see MCP docs; hook failures → see hooks debug docs; install/permission errors → see troubleshoot-install docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — full list of runtime error messages with causes and recovery steps, automatic retry behavior, and guidance for server errors, usage limits, authentication, network, and request errors

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
