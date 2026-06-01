---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors, what they mean, and how to recover from each one.

## Quick Reference

### Error Lookup Table

| Message | Category |
|:--------|:---------|
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors / Network |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `Auto mode could not evaluate this action and is blocking it for safety` | Server errors |
| `Auto mode classifier transcript exceeded context window` | Server errors |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `Your organization has disabled Claude subscription access` | Authentication |
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `SSL certificate verification failed` | Network |
| `403` with `x-deny-reason: host_not_allowed` in a cloud session | Network |
| `Prompt is too long` | Request errors |
| `Error during compaction: Conversation too long` | Request errors |
| `Request too large` | Request errors |
| `Image was too large` | Request errors |
| `Unable to resize image` | Request errors |
| `PDF too large` / `PDF is password protected` | Request errors |
| `Extra inputs are not permitted` | Request errors |
| `There's an issue with the selected model` | Request errors |
| `Claude Opus is not available with the Claude Pro plan` | Request errors |
| `thinking.type.enabled is not supported for this model` | Request errors |
| `max_tokens must be greater than thinking.budget_tokens` | Request errors |
| `API Error: 400 due to tool use concurrency issues` | Request errors |
| `Claude Code is unable to respond to this request, which appears to violate our Usage Policy` | Request errors |
| Responses seem lower quality than usual | Response quality |

### Automatic Retries

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. While retrying, the spinner shows `Retrying in Ns · attempt x/y`.

| Variable | Default | Effect |
|:---------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

These come from infrastructure (Anthropic API, Bedrock, Vertex AI, etc.), not your account.

| Error | Recovery |
|:------|:---------|
| `500 Internal server error` | Check [status.claude.com](https://status.claude.com); retry; run `/feedback` if it persists |
| `529 Overloaded` | Check status page; try again in a few minutes; switch model with `/model` |
| `Request timed out` | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` if on a slow network |
| Auto mode classifier failure | Retry (usually transient); run `/compact` if it's a context window overflow |

### Usage Limits

These are tied to your account or plan quota, not server-wide issues.

| Error | Recovery |
|:------|:---------|
| `You've hit your session/weekly limit` | Wait for reset shown in message; run `/usage`; buy credits with `/usage-credits`; upgrade plan |
| `Server is temporarily limiting requests` | Wait briefly and retry |
| `Request rejected (429)` | Check active credential with `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Add credits at [platform.claude.com/settings/billing](https://platform.claude.com/settings/billing) |

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Recovery |
|:------|:---------|
| `Not logged in` | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Check for typos; run `env \| grep ANTHROPIC`; unset key and run `/login` |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY`; relaunch `claude`; confirm active credential with `/status` |
| `Organization has disabled Claude subscription access` | Ask admin to enable access, or use a Console API key |
| `Routines are disabled by your organization's policy` | Ask admin to enable Routines at [claude.ai/admin-settings/claude-code](https://claude.ai/admin-settings/claude-code) |
| `OAuth token revoked or expired` | Run `/logout` then `/login` |
| `OAuth scope requirement` | Run `/login` to mint a new token with current scopes |

### Network and Connection Errors

Usually originate in local network, proxy, firewall, or cloud environment network policy.

| Error | Recovery |
|:------|:---------|
| `Unable to connect to API` | Test with `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall allowlist |
| `SSL certificate verification failed` | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` with `x-deny-reason: host_not_allowed` | Open cloud environment settings; add the blocked domain to **Allowed domains** under **Custom** network access |

### Request Errors

The API received the request but rejected its content or configuration.

| Error | Recovery |
|:------|:---------|
| `Prompt is too long` | Run `/compact` or `/clear`; run `/context` to see usage; disable unused MCP servers |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns; then run `/compact`; or run `/clear` |
| `Request too large` | Press Esc twice to step back; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice to step back; resize image (max 8000px longest edge; 2000px when many images in context) |
| `Unable to resize image` | Convert to PNG/JPEG/GIF/WebP; resize below stated dimension/size limit |
| `PDF too large` | Read a page range with the Read tool; extract text with `pdftotext` |
| `PDF is password protected` | Remove password and re-export from source application |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model` to pick an available model; use aliases like `sonnet` or `opus` instead of versioned IDs |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model` and select an included model; re-authenticate if you recently upgraded |
| `thinking.type.enabled is not supported` | Run `claude update`; Opus 4.7 needs v2.1.111+; Opus 4.8 needs v2.1.154+ |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `400 due to tool use concurrency issues` | Update Claude Code first (v2.1.156+ fixes Opus 4.7/4.8 trigger); then run `/rewind` to step back to a clean checkpoint |
| Usage Policy refusal | Press Esc twice or run `/rewind` to step back before the triggering turn; run `/clear` if you cannot identify the cause |

### Responses Seem Lower Quality

No error shown — check these first:

| Check | Command |
|:------|:--------|
| Confirm active model | `/model` |
| Raise reasoning level | `/effort` |
| Check context fullness | `/context` |
| Check for stale instructions / oversized memory files | `/doctor` |
| Compact or clear if context is near capacity | `/compact` or `/clear` |

When a response goes wrong, rewinding (Esc twice or `/rewind`) works better than in-thread corrections.

### Reporting Errors

| Approach | When to use |
|:---------|:------------|
| `/feedback` | Submit transcript + description to Anthropic; prefills a GitHub issue |
| `/doctor` | Check local configuration problems |
| [status.claude.com](https://status.claude.com) | Check for active incidents |
| [GitHub Issues](https://github.com/anthropics/claude-code/issues) | Search existing reports |

For errors not covered here, see related guides: MCP connection issues → `/mcp`; hook failures → hooks docs; installation errors → troubleshoot-install docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Full runtime error reference: server errors, usage limits, authentication, network, request errors, response quality, and reporting

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
