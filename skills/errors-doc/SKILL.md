---
name: errors-doc
user-invocable: false
---

# Error Reference Documentation

This skill provides the complete official documentation for Claude Code runtime errors: what each error message means, how to recover from it, and how to tune retry behavior.

## Quick Reference

### Error Categories

| Category | Examples |
|:---------|:---------|
| Server errors | `500 Internal server error`, `529 Overloaded`, `Request timed out`, Auto mode classifier failures |
| Usage limits | Session/weekly limit hit, `Server is temporarily limiting requests`, `429`, `Credit balance is too low` |
| Authentication | `Not logged in`, `Invalid API key`, org disabled, OAuth revoked/expired/scope mismatch |
| Network | `Unable to connect to API`, SSL certificate errors, host blocked in cloud session |
| Request errors | Prompt too long, request too large, image/PDF errors, model not found, thinking budget issues, tool-use mismatch, usage policy refusal |

### Retry Behavior

Claude Code retries transient failures (server errors, 529, timeouts, temporary 429s, dropped connections) up to 10 times with exponential backoff. The spinner shows `Retrying in Ns · attempt x/y`. When you see an error, retries are already exhausted.

| Variable | Default | Effect |
|:---------|:--------|:-------|
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in milliseconds |

### Server Errors

| Message | Cause | Fix |
|:--------|:------|:----|
| `API Error: 500 Internal server error` | Unexpected failure in API infrastructure | Check status.claude.com; retry; run `/feedback` if persistent |
| `API Error: Repeated 529 Overloaded errors` | API at capacity across all users | Wait and retry; run `/model` to switch to a less-loaded model |
| `Request timed out` | API did not respond before connection deadline | Retry; break work into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier failure | Classifier overloaded, unparseable response, or transcript too large | Retry; run `/compact`; approve manually if context-window issue |

### Usage Limit Errors

| Message | Cause | Fix |
|:--------|:------|:----|
| `You've hit your session limit` / `You've hit your weekly limit` | Plan quota exhausted | Wait for reset (shown in message); `/usage`; `/usage-credits` to buy more; upgrade at claude.com/pricing |
| `Server is temporarily limiting requests` | Short-lived server-side throttle (not your quota) | Wait briefly and retry |
| `Request rejected (429)` | API key / Bedrock / Vertex AI rate limit hit | Check `/status`; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console org prepaid credits exhausted | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors

| Message | Cause | Fix |
|:--------|:------|:----|
| `Not logged in · Please run /login` | No valid credential available | Run `/login`; confirm `ANTHROPIC_API_KEY` is exported |
| `Invalid API key` | Key in env var or `apiKeyHelper` was rejected | Check for typos/revocation; run `env \| grep ANTHROPIC`; unset and use `/login` |
| `Your ANTHROPIC_API_KEY belongs to a disabled organization` | Stale key overrides subscription | Unset `ANTHROPIC_API_KEY`; relaunch; run `/status` |
| `Your organization has disabled Claude subscription access` | Org policy blocks subscription login | Ask admin to enable, or use Console API key |
| `Routines are disabled by your organization's policy` | Admin turned off routines | Ask admin to enable at claude.ai/admin-settings/claude-code |
| `OAuth token revoked` / `OAuth token has expired` | Login no longer valid | Run `/login` (or `/logout` then `/login` if error recurs) |
| `does not meet scope requirement user:profile` | Token predates a required OAuth scope | Run `/login` to mint a fresh token |

### Network Errors

| Message | Cause | Fix |
|:--------|:------|:----|
| `Unable to connect to API` (ECONNREFUSED / ECONNRESET / ETIMEDOUT) | No internet, VPN, or proxy issue | `curl -I https://api.anthropic.com`; set `HTTPS_PROXY`; check firewall |
| `SSL certificate verification failed` / `Self-signed certificate detected` | Corporate proxy doing TLS inspection | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem` |
| `403` + `x-deny-reason: host_not_allowed` | Blocked by cloud session network policy | Edit cloud environment settings; switch Network Access from Trusted to Custom and add domain |

### Request Errors

| Message | Cause | Fix |
|:--------|:------|:----|
| `Prompt is too long` | Conversation + files exceeds context window | `/compact`; `/clear`; `/context` to see usage; disable unused MCP servers |
| `Error during compaction: Conversation too long` | `/compact` itself has no room for its summary | Press Esc twice to step back, then retry `/compact`; or `/clear` |
| `Request too large (max 30 MB)` | Raw HTTP body over byte limit | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` / `image dimensions exceed max allowed size` | Image over size/dimension API limits (8000px single, 2000px many) | Press Esc twice; resize image before attaching |
| `Unable to resize image` | Native image processor failed | Convert to PNG/JPEG/GIF/WebP; resize below stated limit |
| `PDF too large` / `PDF is password protected` | PDF over 100 pages / 32 MB, or protected | Read page ranges with Read tool; extract text with `pdftotext`; remove password |
| `Extra inputs are not permitted ... context_management` | Gateway stripped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; or set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model name not recognized or no access | `/model` to pick valid model; use aliases like `sonnet` or `opus` |
| `Claude Opus is not available with the Claude Pro plan` | Plan does not include selected model | `/model` to pick an included model; `/logout` + `/login` if recently upgraded |
| `"thinking.type.enabled" is not supported for this model` | Claude Code version too old for Opus 4.7+ | Run `claude update`; Opus 4.7 needs v2.1.111+, Opus 4.8 needs v2.1.154+ |
| `max_tokens must be greater than thinking.budget_tokens` | Thinking budget exceeds output limit (Bedrock/Vertex) | Lower `MAX_THINKING_TOKENS`; raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `API Error: 400 due to tool use concurrency issues` | Conversation history in inconsistent state | Update to v2.1.156+ for Opus 4.7/4.8; run `/rewind` |
| Usage Policy refusal | Request content triggered usage policy check | Press Esc twice or `/rewind` to step back; rephrase; `/clear` to start fresh |

### Quality Seems Lower Than Usual (No Error)

| Check | Command | What to look for |
|:------|:--------|:-----------------|
| Model selection | `/model` | Confirm you are on the expected model |
| Effort level | `/effort` | Raise for hard debugging/design; check per-model defaults |
| Context pressure | `/context` | Near capacity → run `/compact` or `/clear` |
| Stale instructions | `/doctor` | Oversized CLAUDE.md or subagent definitions |

When a response goes wrong, `/rewind` (or Esc twice) to before the bad turn and rephrase — correcting in-thread keeps the wrong answer in context.

### Reporting Errors

- Run `/feedback` inside Claude Code to send transcript + description to Anthropic
- Run `/doctor` to check local configuration problems
- Check [status.claude.com](https://status.claude.com) for active incidents
- Search [GitHub issues](https://github.com/anthropics/claude-code/issues)

For errors from other components: MCP failures → `/mcp` docs; hook failures → hooks docs; install errors → troubleshoot-install docs.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error Reference](references/claude-code-errors.md) — Full error listing with messages, causes, recovery steps, retry configuration, and quality troubleshooting

## Sources

- Error Reference: https://code.claude.com/docs/en/errors.md
