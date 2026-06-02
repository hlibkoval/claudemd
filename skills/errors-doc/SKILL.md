---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors — what each message means, how to recover, and when to report.

## Quick Reference

### Error Message Index

| Message | Category |
|:--------|:---------|
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors |
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
| `403` with `x-deny-reason: host_not_allowed` | Network |
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

Claude Code retries transient failures up to 10 times with exponential backoff before showing an error. The spinner shows `Retrying in Ns · attempt x/y` while retrying.

| Env var | Default | Effect |
|:--------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

---

### Server Errors

Originate from the inference provider infrastructure, not your account.

| Error | Cause | Fix |
|:------|:------|:----|
| `500 Internal server error` | Unexpected API failure | Check status.claude.com; type `try again`; run `/feedback` if persists |
| `529 Overloaded errors` | API at capacity, not your quota | Check status page; try again; run `/model` to switch to a less-loaded model |
| `Request timed out` | No response before 10-minute deadline | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` for slow networks |

**Auto mode classifier failures** (only affect actions outside your working directory):

| Message | Cause | Fix |
|:--------|:------|:----|
| `<model> is temporarily unavailable...` | Classifier model overloaded | Retry; continue with read-only tasks |
| `Auto mode could not evaluate this action...` | Classifier returned unparseable result | Retry; run `claude --debug` to diagnose |
| `Auto mode classifier transcript exceeded context window` | Conversation too large for classifier | Approve manually in the prompt; run `/compact` |

---

### Usage Limits

Quota tied to your account or plan — distinct from server errors.

| Error | Cause | Fix |
|:------|:------|:----|
| `You've hit your session/weekly/Opus limit` | Rolling usage allowance exhausted | Wait for reset; run `/usage`; buy credits with `/usage-credits`; upgrade plan |
| `Server is temporarily limiting requests` | Short-lived throttle, not plan quota | Wait briefly and retry |
| `Request rejected (429)` | API key, Bedrock, or Vertex rate limit hit | Run `/status` to verify active credential; check provider console; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

Monitor remaining usage: add `rate_limits` fields to a custom status line, or use the Desktop app usage ring.

---

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Cause | Fix |
|:------|:------|:----|
| `Not logged in` | No valid credential | Run `/login`; check `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Invalid API key` | Key rejected by API | Check for typos/revocation in Console; run `env \| grep ANTHROPIC`; unset key and use `/login` |
| `This organization has been disabled` | Stale key from disabled org overriding subscription | Unset `ANTHROPIC_API_KEY` and remove from shell profile; relaunch `claude` |
| `Your organization has disabled Claude subscription access` | Org setting blocks subscription auth | Ask admin to enable access; use Console API key instead |
| `Routines are disabled...` | Team/Enterprise admin turned off routines | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked/expired` | Saved login no longer valid | Run `/login`; run `/logout` then `/login` if error returns |
| `does not meet scope requirement user:profile` | Token predates a newer permission scope | Run `/login` to mint a new token |

---

### Network Errors

Usually caused by local network, proxy, firewall, or cloud environment policy.

| Error | Cause | Fix |
|:------|:------|:----|
| `Unable to connect to API` + `ECONNREFUSED`/`ECONNRESET`/`ETIMEDOUT` | No internet, VPN blocking API, or missing proxy | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall allowlist |
| `SSL certificate verification failed` | Proxy intercepting TLS with its own certificate | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; do NOT use `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403` with `x-deny-reason: host_not_allowed` | Cloud session network policy blocking domain | Edit cloud environment → change Network Access to **Custom** → add allowed domain → save |

**Linux/WSL network tips:** Check `/etc/resolv.conf` for unreachable nameserver. On macOS, look for stale `utun` interfaces from disconnected VPNs. Docker Desktop can intercept outbound traffic — quit it and retry.

---

### Request Errors

API received the request but rejected its content.

| Error | Fix |
|:------|:----|
| `Prompt is too long` | Run `/compact` or `/clear`; use `/context` to see window usage; disable unused MCP servers with `/mcp disable <name>`; trim CLAUDE.md |
| `Error during compaction: Conversation too long` | Press Esc twice to step back several turns, then run `/compact` again; or run `/clear` (session preserved for `/resume`) |
| `Request too large` (max 30 MB) | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Press Esc twice; resize to ≤8000px longest edge (2000px when many images in context) |
| `Unable to resize image` | Convert to PNG/JPEG/GIF/WebP; or resize below the reported limit |
| `PDF too large` / `PDF is password protected` | Read a page range with the Read tool; extract text with `pdftotext`; remove password or re-export |
| `Extra inputs are not permitted` | Configure gateway to forward `anthropic-beta` header; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Run `/model`; use an alias like `sonnet`/`opus`; check model config priority order for stale IDs |
| `Claude Opus is not available with the Claude Pro plan` | Run `/model` to select an included model; re-login after a plan upgrade (`/logout` then `/login`) |
| `thinking.type.enabled is not supported for this model` | Run `claude update` (Opus 4.7 needs ≥v2.1.111; Opus 4.8 needs ≥v2.1.154); or select Opus 4.6/Sonnet |
| `max_tokens must be greater than thinking.budget_tokens` | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` above the thinking budget |
| `400 due to tool use concurrency issues` | Update Claude Code first; run `/rewind` to step back to a checkpoint before the corrupted turn |
| Usage Policy refusal | Press Esc twice or run `/rewind` to step back; rephrase prompt; or run `/clear` and start fresh |

---

### Response Quality (No Error Shown)

If answers seem lower quality than expected, check in order:

1. **Model** — run `/model` to confirm expected model. A stale `ANTHROPIC_MODEL` env var or settings entry may select a smaller model.
2. **Effort level** — run `/effort` to check reasoning level; raise it for complex work. Use `ultrathink` shortcut for maximum effort.
3. **Context pressure** — run `/context` to see window fullness. Run `/compact` near capacity or `/clear` to start fresh.
4. **Stale instructions** — large/outdated CLAUDE.md and MCP tool definitions consume context. Run `/doctor` to flag oversized files.

When a response goes wrong, rewinding (Esc twice or `/rewind`) works better than replying with corrections — corrections keep the bad turn in context.

---

### Reporting Errors

| If the error is from… | Go to… |
|:----------------------|:-------|
| MCP server connection/auth | `/mcp` docs |
| Hook script failure | Hooks docs → Debug hooks |
| Installation / login | Troubleshoot installation docs |
| Anything else | Run `/feedback` inside Claude Code to send transcript + description |

Other channels: run `/doctor` for local config problems; check [status.claude.com](https://status.claude.com); search [GitHub issues](https://github.com/anthropics/claude-code/issues).

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — Full runtime error catalog: server errors, usage limits, authentication, network, request errors, response quality, and reporting

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
