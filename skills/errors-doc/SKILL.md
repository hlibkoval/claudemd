---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors — what each message means and how to recover from it.

## Quick Reference

### Error Lookup Table

| Message | Category |
|:--------|:---------|
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors (or Network if internet mentioned) |
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
| `403` with `x-deny-reason: host_not_allowed` | Network (cloud session) |
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

---

### Automatic Retries

Claude Code retries transient failures (server errors, 529 overloaded, timeouts, temporary 429s, dropped connections) up to 10 times with exponential backoff. The spinner shows `Retrying in Ns · attempt x/y` while retrying. When you see an error, retries are already exhausted.

| Env Var | Default | Effect |
|:--------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms |

---

### Server Errors

| Error | Cause | Fix |
|:------|:------|:----|
| `500 Internal server error` | Unexpected API failure | Check status.claude.com; wait and retry; run `/feedback` |
| `Repeated 529 Overloaded errors` | API at capacity | Check status.claude.com; wait; run `/model` to switch models |
| `Request timed out` | API did not respond before deadline | Retry; break into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier unavailable | Classifier model overloaded | Retry after a few seconds |
| Auto mode could not evaluate action | Classifier returned unparseable response | Retry; run `claude --debug` to inspect |
| Auto mode classifier transcript exceeded context window | Conversation too large for classifier | Approve/deny manually; run `/compact` to reduce context |

---

### Usage Limits

| Error | Cause | Fix |
|:------|:------|:----|
| `You've hit your session/weekly/Opus limit` | Plan quota exhausted | Wait for reset time shown; run `/usage`; buy credits with `/usage-credits` |
| `Server is temporarily limiting requests` | Short-lived throttle, not your quota | Wait briefly; check status.claude.com |
| `Request rejected (429)` | API key or provider rate limit hit | Run `/status`; check provider console; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

---

### Authentication Errors

Run `/status` to see which credential is active.

| Error | Cause | Fix |
|:------|:------|:----|
| `Not logged in` | No valid credential | Run `/login`; check `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Key rejected by API | Check for typos; run `env \| grep ANTHROPIC`; run `/status` |
| `This organization has been disabled` | Stale key from disabled org overrides login | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` |
| `Your organization has disabled Claude subscription access` | Org policy blocks subscription login | Ask admin to enable; use Console API key instead |
| `Routines are disabled by your organization's policy` | Admin turned off routines | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | Saved login invalid | Run `/login`; if persists, run `/logout` then `/login` |
| OAuth scope requirement (`user:profile`) | Token predates a newer scope | Run `/login` to mint a new token (no logout needed) |

---

### Network Errors

| Error | Cause | Fix |
|:------|:------|:----|
| `Unable to connect to API` (ECONNREFUSED/ECONNRESET/ETIMEDOUT) | TCP connection failed | Test with `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for gateways |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; see Network configuration docs |
| `403` with `x-deny-reason: host_not_allowed` | Cloud session blocked by network policy | In environment settings, add blocked domain to Allowed domains under Custom network access |

Linux/WSL tips for connection failures: check `/etc/resolv.conf` for unreachable nameservers. macOS: check `ifconfig` for stale VPN tunnel interfaces. Docker Desktop can intercept traffic — quit it and retry.

---

### Request Errors

| Error | Cause | Fix |
|:------|:------|:----|
| `Prompt is too long` | Conversation exceeds model context window | Run `/compact` or `/clear`; use `/context` to see what's consuming the window; disable unused MCP servers |
| `Error during compaction: Conversation too long` | `/compact` itself ran out of context | Press Esc twice to step back several turns, then retry `/compact`; or run `/clear` |
| `Request too large` (max 30 MB) | Raw HTTP body exceeds byte limit | Press Esc twice and remove oversized attachment; reference large files by path |
| `Image was too large` | Image exceeds size/dimension limits | Press Esc twice past the turn with the image; resize to ≤8000px on longest edge (≤2000px if many images) |
| `Unable to resize image` | Image processor failed | Convert to PNG/JPEG/GIF/WebP; resize below reported limit |
| `PDF too large` / `PDF is password protected` / invalid PDF | PDF cannot be processed | Split or extract text; remove password; re-export from source |
| `Extra inputs are not permitted` (context_management, etc.) | Gateway stripped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model not recognized or no access | Run `/model` to pick available model; use alias like `sonnet` instead of versioned ID |
| `Claude Opus is not available with the Claude Pro plan` | Plan doesn't include selected model | Run `/model`; if recently upgraded, run `/logout` then `/login` |
| `thinking.type.enabled is not supported` | Claude Code version too old for Opus 4.7+ | Run `claude update`; or select Opus 4.6/Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Thinking budget exceeds output limit | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Conversation history has inconsistent tool/thinking blocks | Run `/rewind` or press Esc twice to step back to a checkpoint |
| Usage Policy refusal | Content triggered Usage Policy check | Press Esc twice or run `/rewind` to step back and rephrase; run `/clear` for a fresh session |

---

### Response Quality Checklist

If responses seem lower quality with no error shown:

1. **Model**: run `/model` — check you're on the expected model; look for stale `ANTHROPIC_MODEL` env var
2. **Effort**: run `/effort` — raise it for hard debugging; check per-model defaults
3. **Context**: run `/context` — if near full, run `/compact` or `/clear`
4. **Instructions**: large/outdated `CLAUDE.md` files or MCP tools consume context; run `/doctor` to flag oversized files
5. **Bad turn**: press Esc twice or run `/rewind` to step back and rephrase — correcting in-thread keeps the wrong attempt in context

---

### Reporting Errors

- Run `/feedback` inside Claude Code to send transcript + description to Anthropic (also offers to open a prefilled GitHub issue)
- Run `/doctor` for local configuration problems
- Check [status.claude.com](https://status.claude.com) for active incidents
- Search [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)

For component-specific errors: MCP connection issues → see MCP docs; hook failures → see Hooks docs; install errors → see Troubleshoot installation docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Full listing of every Claude Code runtime error message with causes and recovery steps

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
