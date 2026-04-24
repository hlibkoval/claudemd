---
name: errors-doc
description: Complete official documentation for Claude Code runtime errors — error message lookup, automatic retry behavior, server errors, usage limits, authentication errors, network errors, request errors, and response quality troubleshooting.
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors.

## Quick Reference

When Claude Code shows an error, automatic retries (up to 10 attempts with exponential backoff) have already been exhausted. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

### Error index

| Message | Category |
| :--- | :--- |
| `API Error: 500 ... Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors (or Network if internet is mentioned) |
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

### Retry tuning

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts before surfacing the error |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server errors

| Error | Recovery |
| :--- | :--- |
| `API Error: 500 Internal server error` | Check status.claude.com; type `try again`; run `/feedback` if it persists |
| `API Error: Repeated 529 Overloaded errors` | Check status.claude.com; wait a few minutes; run `/model` to switch models (capacity is per-model) |
| `Request timed out` | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |
| Auto mode safety classifier unavailable | Retry after a few seconds; continue with read-only tasks; reads/edits in working directory still work |

### Usage limits

| Error | Recovery |
| :--- | :--- |
| `You've hit your session/weekly/Opus limit` | Wait for the reset time shown; run `/usage`; run `/extra-usage` to buy more or request from admin |
| `Server is temporarily limiting requests` | Wait briefly and retry; check status.claude.com if it persists |
| `Request rejected (429)` | Run `/status` to verify the active credential; check provider console for limits; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at platform.claude.com/settings/billing; enable auto-reload; or switch to subscription via `/login` |

### Authentication errors

Run `/status` at any time to see which credential is currently active.

| Error | Recovery |
| :--- | :--- |
| `Not logged in` | Run `/login`; verify `ANTHROPIC_API_KEY` is exported; use `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos/revocation in Console; run `env \| grep ANTHROPIC` to find stale keys from direnv/.env files |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell and profile; relaunch `claude`; run `/status` to confirm |
| `OAuth token revoked or expired` | Run `/logout` then `/login`; check system clock for repeated prompts |
| `OAuth token does not meet scope requirement: user:profile` | Run `/login` to mint a new token with current scopes (no logout needed) |

### Network and connection errors

| Error | Recovery |
| :--- | :--- |
| `Unable to connect to API` | Test with `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for LLM gateways; verify firewall allows api.anthropic.com |
| `SSL certificate verification failed` / self-signed cert | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |

Common non-obvious `Unable to connect` causes (curl succeeds but Claude Code fails):
- **Linux/WSL**: broken `/etc/resolv.conf` nameserver; WSL can inherit unreachable resolver from host
- **macOS**: stale VPN `utun` interfaces left behind after VPN uninstall; check `ifconfig` and remove VPN network extension in System Settings
- **Docker Desktop**: may intercept outbound traffic; quit it and retry

### Request errors

| Error | Recovery |
| :--- | :--- |
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` to see what fills the window; disable unused MCP servers with `/mcp disable <name>`; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns, then `/compact`; or `/clear` and `/resume` |
| `Request too large` (max 30 MB) | Press Esc twice; reference large files by path instead of pasting their contents |
| `Image was too large` | Press Esc twice; resize to ≤8000px longest edge (≤2000px when many images in context); take a tighter screenshot |
| `PDF too large` (max 100 pages, 32 MB) | Ask Claude to read a page range with the Read tool; extract text with `pdftotext` |
| `PDF is password protected` / invalid PDF | Remove password or re-export from source application |
| `Extra inputs are not permitted` | Configure LLM gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model`; use an alias like `sonnet` or `opus` instead of a versioned ID |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model`; if recently upgraded, run `/logout` then `/login` to refresh the token |
| `thinking.type.enabled is not supported for this model` | Run `claude update` to v2.1.111+; or switch to Opus 4.6 or Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `API Error: 400 due to tool use concurrency issues` | Run `/rewind` or press Esc twice to step back to a checkpoint before the corrupted turn |

### Response quality (no error shown)

Claude Code does not silently change model versions. Check these in order:

1. **Model** — run `/model`; a stale `ANTHROPIC_MODEL` env var or previous `/model` choice may have you on a smaller model
2. **Effort** — run `/effort`; defaults vary by model; raise for hard tasks; use `ultrathink` shortcut
3. **Context** — run `/context`; near-capacity windows degrade quality; run `/compact` at a natural breakpoint or `/clear`
4. **Instructions** — run `/doctor` to flag oversized CLAUDE.md files and subagent definitions; run `/context` to see MCP tool token usage

When a response goes wrong, rewinding (Esc twice or `/rewind`) works better than correcting in-thread — corrections keep the bad answer in context and can anchor later responses to it.

### Reporting errors

- Run `/feedback` to send transcript + description to Anthropic (unavailable on Bedrock, Vertex AI, Foundry)
- Run `/doctor` to check local configuration
- Check [status.claude.com](https://status.claude.com) for active incidents
- Search [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)

Other error categories with dedicated guides:
- MCP server connection/auth failures: MCP docs
- Hook script failures: Hooks docs (debug hooks section)
- Install/filesystem errors: Troubleshooting docs

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — full error index, automatic retry behavior, server errors, usage limits, authentication errors, network and SSL errors, request errors, response quality troubleshooting, and how to report errors

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
