---
name: errors-doc
user-invocable: false
---

# Errors Documentation

This skill provides the complete official documentation for Claude Code runtime errors — what each error message means and how to recover from it.

## Quick Reference

### Error Message Index

| Message | Category |
| :--- | :--- |
| `API Error: 500 Internal server error` | Server errors |
| `API Error: Repeated 529 Overloaded errors` | Server errors |
| `Request timed out` | Server errors |
| `<model> is temporarily unavailable, so auto mode cannot determine the safety of...` | Server errors |
| `Auto mode could not evaluate this action and is blocking it for safety` | Server errors |
| `Auto mode classifier transcript exceeded context window` | Server errors |
| `You've hit your session limit` / `You've hit your weekly limit` | Usage limits |
| `Usage credits required for 1M context` | Usage limits |
| `Server is temporarily limiting requests` | Usage limits |
| `Request rejected (429)` | Usage limits |
| `Credit balance is too low` | Usage limits |
| `Not logged in · Please run /login` | Authentication |
| `Could not resolve authentication method` | Authentication |
| `Invalid API key` | Authentication |
| `This organization has been disabled` | Authentication |
| `Your organization has disabled API key authentication` | Authentication |
| `Your organization has disabled Claude subscription access` | Authentication |
| `Routines are disabled by your organization's policy` | Authentication |
| `OAuth token revoked` / `OAuth token has expired` | Authentication |
| `does not meet scope requirement user:profile` | Authentication |
| `Unable to connect to API` | Network |
| `Waiting for API response · will retry in` | Network / Automatic retries |
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

### Automatic Retries

Claude Code retries transient failures up to 10 times (capped at 15 as of v2.1.186) with exponential backoff before showing an error. Retried automatically: server errors, 529 overloaded, request timeouts, temporary 429 throttles, dropped connections.

Retry tuning env vars:

| Variable | Default | Effect |
| :--- | :--- | :--- |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Number of retry attempts (max 15 as of v2.1.186) |
| `CLAUDE_CODE_RETRY_WATCHDOG` | unset | Set to `1` in CI to retry 429/529 indefinitely |
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms |

When no data arrives for 20 seconds (v2.1.185+; 10 seconds on older versions), the spinner shows `Waiting for API response · will retry in … · check your network`. The request has not failed yet.

### Server Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `500 Internal server error` | Unexpected failure inside the API | Check status.claude.com, wait, retry; run `/feedback` if it persists |
| `Repeated 529 Overloaded errors` | API temporarily at capacity | Check status.claude.com, wait, try `/model` to switch models |
| `Request timed out` | API did not respond before connection deadline | Retry; break large tasks into smaller prompts; raise `API_TIMEOUT_MS` |
| Auto mode classifier failures | Classifier overloaded, returned unparseable response, or transcript exceeded context window | Retry; run `/compact` for context window case; interactive sessions fall back to manual approval |

### Usage Limits

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `You've hit your session/weekly limit` | Subscription rolling allowance exhausted | Wait for reset time shown; `/usage` to check limits; `/usage-credits` to buy more |
| `Usage credits required for 1M context` | 1M context window requires metered billing | `/model` to switch to non-1M variant; `/usage-credits` to enable; set `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` to hide 1M variants |
| `Server is temporarily limiting requests` | Short-lived server-side throttle, unrelated to plan quota | Wait briefly, retry |
| `Request rejected (429)` | Rate limit for your API key / Bedrock / Vertex project | Check `/status` for active credential; reduce concurrency; lower `CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` |
| `Credit balance is too low` | Console organization out of prepaid credits | Add credits at platform.claude.com/settings/billing; enable auto-reload |

### Authentication Errors

Run `/status` to see which credential is currently active.

| Error | Fix |
| :--- | :--- |
| `Not logged in` | `/login`; confirm `ANTHROPIC_API_KEY` is exported; configure `apiKeyHelper` for CI |
| `Could not resolve authentication method` | Upgrade to v2.1.174+; confirm credentials are in the worker's environment, not just your interactive shell |
| `Invalid API key` | Check for typos; run `env | grep ANTHROPIC` for stale keys; confirm `apiKeyHelper` script output |
| `This organization has been disabled` | Unset `ANTHROPIC_API_KEY` from shell and profile; relaunch |
| `Your organization has disabled API key authentication` | Unset `ANTHROPIC_API_KEY` and/or remove `apiKeyHelper` setting; `/login` with claude.ai account |
| `Your organization has disabled Claude subscription access` | Ask admin to enable access; or use Console API key instead |
| `Routines are disabled by your organization's policy` | Ask admin to enable Routines at claude.ai/admin-settings/claude-code |
| `OAuth token revoked or expired` | `/logout` then `/login` |
| `OAuth scope requirement: user:profile` | `/login` to mint a new token (no need to log out first) |

### Network Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Unable to connect to API` | No internet, VPN blocking api.anthropic.com, proxy not configured | `curl -I https://api.anthropic.com` to test; set `HTTPS_PROXY`; set `ANTHROPIC_BASE_URL` for LLM gateways |
| `SSL certificate verification failed` | Corporate proxy intercepting TLS with its own cert | Set `NODE_EXTRA_CA_CERTS=/path/to/ca-bundle.pem`; never set `NODE_TLS_REJECT_UNAUTHORIZED=0` |
| `403 x-deny-reason: host_not_allowed` | Cloud session / routine blocked by network policy | Edit cloud environment settings: change Network access to Custom and add the blocked domain to Allowed domains |

### Request Errors

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Prompt is too long` | Conversation + files exceeds model context window | `/compact` or `/clear`; `/context` to inspect usage; disable unused MCP servers; trim `CLAUDE.md` |
| `Error during compaction: Conversation too long` | Not enough free context for compaction summary | Press Esc twice to step back several turns, then `/compact`; or `/clear` |
| `Request too large (max 30 MB)` | Raw request body exceeded byte limit | Press Esc twice; reference large files by path instead of pasting |
| `Image was too large` | Pasted image exceeds size/dimension limits | Resize before pasting (max 8000px longest edge; 2000px with many images in context); as of v2.1.142 Claude Code auto-replaces with placeholder |
| `Unable to resize image` | Native image processor failed | Convert to PNG/JPEG/GIF/WebP; resize below stated limit |
| `PDF too large` / `PDF is password protected` | PDF exceeds 100 pages / 32 MB, or is protected | Read by page range; extract text with `pdftotext`; remove password or re-export |
| `Extra inputs are not permitted` | Proxy/gateway dropped `anthropic-beta` header | Configure gateway to forward `anthropic-beta`; fallback: set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` |
| `There's an issue with the selected model` | Model not recognized or no account access | Interactive: `/model`; non-interactive: `--model` flag or `ANTHROPIC_MODEL`; use aliases (`sonnet`, `opus`) instead of versioned IDs |
| `Claude Opus is not available with the Claude Pro plan` | Plan does not include selected model | `/model` to pick an included model; `/logout` + `/login` after upgrading plan |
| `thinking.type.enabled is not supported for this model` | Claude Code version too old for Opus 4.7 / 4.8 | `claude update`; Opus 4.7 needs v2.1.111+, Opus 4.8 needs v2.1.154+ |
| `max_tokens must be greater than thinking.budget_tokens` | Extended thinking budget exceeds provider's output limit | Lower `MAX_THINKING_TOKENS` or raise `CLAUDE_CODE_MAX_OUTPUT_TOKENS` |
| `400 due to tool use concurrency issues` | Conversation history has inconsistent tool/thinking blocks | Update to v2.1.156+ for Opus 4.7/4.8; `/rewind` or Esc twice to step back to a checkpoint |
| Usage Policy refusal | Content triggered Usage Policy check | Press Esc twice or `/rewind` to step back and rephrase; `/clear` for a fresh session |

### Response Quality Checklist

When responses seem lower quality but no error is shown:

| Check | Command |
| :--- | :--- |
| Confirm active model | `/model` |
| Check reasoning effort level | `/effort` |
| Inspect context window usage | `/context` |
| Check for oversized memory/MCP definitions | `/doctor` |
| Compact or clear context if near capacity | `/compact` or `/clear` |
| Step back past a bad turn and rephrase | Esc twice or `/rewind` |
| Report a regression | `/feedback` |

Claude Code does not silently change models except in three cases: a configured `--fallback-model` takes over after an availability error; a Bedrock/Vertex startup check finds the default model unavailable; or Fable 5 automatic model fallback moves to the default Opus model.

### Reporting Errors

- Run `/feedback` inside Claude Code to send the transcript and description to Anthropic (also offers to open a prefilled GitHub issue)
- Run `/doctor` to check for local configuration problems
- Check [status.claude.com](https://status.claude.com) for active incidents
- Search [existing issues](https://github.com/anthropics/claude-code/issues) on GitHub

For errors from other components: MCP issues → see `mcp-doc`; hook failures → see `hooks-doc`; installation errors → see the troubleshoot-install doc.

## Full Documentation

For the complete official documentation, see the reference files:

- [Error reference](references/claude-code-errors.md) — Complete list of runtime error messages with causes and recovery steps

## Sources

- Error reference: https://code.claude.com/docs/en/errors.md
