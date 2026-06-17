# Changelog

All notable upstream documentation changes detected by `/update` are documented here.

## 26.6.17

**29 references updated across 12 skills:** agent-sdk-doc, agent-teams-doc, best-practices-doc, cli-doc, cloud-providers-doc, features-doc, hooks-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **`SystemMessage` subtypes `"informational"` and `"worker_shutting_down"` (Agent SDK)** — two new subtypes documented for session lifecycle events; TypeScript SDK maps each non-`"init"` subtype to its own union type in `SDKMessage` (agent-sdk-doc)
- **`TaskUpdate` key normalization caveat** — Claude Code repairs close-but-incorrect key names (`id`/`task_id` → `taskId`, `active_form` → `activeForm`) before execution but this repair is not reflected in the stream; SDK docs now show defensive reading patterns for both TypeScript and Python (agent-sdk-doc)
- **`footerLinksRegexes` setting** — new `settings.json` key that renders clickable footer badge chips when a configured regex matches text in a turn; supports named capture groups for URL/label substitution (settings-doc, features-doc)
- **`Expiration` field on Bedrock credential-process output** — optional ISO 8601 field; as of v2.1.176 Claude Code caches credentials until 5 minutes before expiry instead of a fixed 1-hour cache (cloud-providers-doc)
- **`availableModels` alias resolution and fast-mode enforcement (v2.1.176)** — `ANTHROPIC_DEFAULT_*_MODEL` env vars cannot redirect an allowed alias to a model outside the list; `/fast` refuses when it would switch to a blocked Opus model (features-doc, settings-doc)
- **Advisor pairing validation moved client-side** — Claude Code now validates advisor/main-model pairing before sending; mismatched pairs suppress the advisor rather than error; subagents apply the same check against their own model (features-doc)
- **Remote Control `/rc failed` indicator** — when a Remote Control connection fails the footer indicator turns red and reads `/rc failed`; selecting it shows the failure reason and a dismiss option; also promoted connection-status notes to a dedicated section (features-doc)
- **Remote Control auto-generated title localization (v2.1.176)** — auto-generated session titles now match the conversation language or the configured `language` setting (features-doc)
- **New Remote Control eligibility error messages (v2.1.178)** — "Couldn't verify Remote Control eligibility" and "Couldn't verify your organization's Remote Control policy" documented; replaces old environment-variable-specific troubleshooting (features-doc)
- **MCP server-level patterns in `disallowedTools`** — `mcp__<server>`, `mcp__<server>__*`, and `mcp__*` patterns now accepted in subagent and SDK `AgentDefinition` `disallowedTools` fields (sub-agents-doc, agent-sdk-doc)
- **`--add-dir` scans `.claude/agents/`** — directories added with `--add-dir` are now also scanned for subagents (sub-agents-doc)
- **Nested subagent name resolution (v2.1.178)** — when multiple nested `.claude/agents/` directories define the same `name`, Claude Code uses the definition closest to the working directory (sub-agents-doc)
- **Nested skills with directory-qualified names** — skills load from nested `.claude/skills/` directories; name clashes surface as `dir:name`; Claude picks the variant matching the files being worked on (skills-doc)
- **Plugin `skills` path behavior for marketplace-root entries** — when a plugin entry's `source` resolves to the marketplace root, listing specific subdirectories under `skills` makes that list the complete set rather than additive (plugins-doc)
- **`Tool(param:value)` deny/ask rule syntax** — permission rules can match any scalar top-level tool input parameter with exact value or `*` wildcard (e.g. `Agent(model:opus)`, `Bash(run_in_background:true)`); documented constraints on which fields are matchable (settings-doc)
- **Workflow save location logic (v2.1.178)** — saving a workflow to the project location now writes to the closest existing `.claude/workflows/` between cwd and repo root; project workflows load from every `.claude/workflows/` along that path; nearest-to-cwd wins on name clash (best-practices-doc)
- **Output style nearest-to-cwd precedence (v2.1.178)** — when multiple nested `.claude/output-styles/` directories define the same style name, Claude Code uses the one closest to the working directory (features-doc)
- **v2.1.179 release notes** — covers mid-stream connection drop fix, WSL2 mouse-wheel regression fix, sandbox glob performance fix, and 6+ other bug fixes (operations-doc)

### Changed

- **Agent teams: no separate team-creation step (v2.1.178+)** — `TeamCreate` and `TeamDelete` tools removed; team forms automatically when the first teammate spawns; `team_name` input on Agent tool accepted but ignored; cleanup happens automatically at session end (agent-teams-doc, cli-doc)
- **Agent teams: team name is now session-derived** — team name is `session-` + first 8 chars of session ID; team config directory removed at session end; task list directory persists across resumed sessions under `cleanupPeriodDays` (agent-teams-doc)
- **`team_name` field deprecated in hook payloads** — `TaskCreated`, `TaskCompleted`, and `TeammateIdle` hook payloads still carry `team_name` but it now holds the session-derived name and is marked deprecated for future removal (hooks-doc)
- **`resolvedModel` clarification in hooks** — clarified that `resolvedModel` can differ from the `model` input when `availableModels` or another override applies (hooks-doc)
- **Permission rule evaluation clarification** — documented that a broad deny rule overrides a narrower allow rule; `WebFetch` domain wildcard behavior clarified (settings-doc)
- **`Fable` advisor picker note removed** — note that Fable 5 does not appear in the `/advisor` picker was removed; also removed redundant note from the table (features-doc)
- **Haiku plan-mode upgrade restriction** — clarified that a Haiku session whose Sonnet upgrade is blocked by `availableModels` stays on Haiku rather than upgrading (features-doc)
- **Fork mode spawn behavior updated** — fork mode no longer replaces general-purpose subagent spawns by default; Claude can spawn a fork by requesting the `fork` subagent type explicitly (sub-agents-doc)
- **Costs doc: teammate lifecycle wording** — "clean up teams" replaced with "shut down teammates when their work is done" to reflect automatic cleanup (operations-doc)
- **Settings `/status` description improved** — clarified that a layer only appears in Setting sources when loaded with at least one key; Config tab described as editor for a fixed set of toggles, not a view of `settings.json` (settings-doc)
- **Subagents discovered from `--add-dir` clarified** — previous wording said `--add-dir` grants file access only; corrected to say `.claude/agents/` inside an added directory is scanned (sub-agents-doc)

### Removed

- **"Clean up the team" section removed** — dedicated section on asking the lead to clean up the team removed; replaced with note that shared directories are cleaned automatically at session end (agent-teams-doc)
- **Remote Control inline status notes removed** — per-tab inline notes about the `/rc active` indicator removed from "start from CLI" and "start from existing session" tabs; replaced by the new "Check connection status" section (features-doc)

## 26.6.16

**17 references updated across 8 skills:** agent-sdk-doc, features-doc, getting-started-doc, headless-doc, ide-doc, operations-doc, security-doc, settings-doc

### New

- **`Tool(param:value)` permission rule syntax (v2.1.178)** — permission rules can now match a tool's input parameters with optional `*` wildcard, e.g. `Agent(model:opus)` to block Opus subagents (operations-doc)
- **v2.1.178 release notes** — covers nested skills with directory-qualified names, improved auto mode subagent classification, daemon version mismatch warning, `/bug` requiring a description, and 15+ bug fixes (operations-doc)
- **Week 23 and Week 24 "What's New" digests** — Week 23 covers auto mode on Bedrock/Vertex/Foundry for Opus 4.7/4.8; Week 24 covers `/cd` mid-session, subagent-spawning-subagents up to depth 5, `--safe-mode`, and `fallbackModel` chains (operations-doc)
- **Homebrew cask unavailable error** — new troubleshooting entry for `No Cask with this name exists`; fix is `brew update && brew install --cask claude-code`; also documents the `claude-code@latest` cask for the newest release (operations-doc)
- **`agentPushNotifEnabled` setting** — enables proactive push notifications to phone via Remote Control when a long task finishes; appears in `/config` as **Push when Claude decides** (settings-doc)
- **`inputNeededNotifEnabled` setting** — sends a push notification when a permission prompt or question waits for input; appears in `/config` as **Push when actions required** (settings-doc)
- **`autoCompactEnabled` setting** — toggles automatic conversation compaction when context approaches the limit; default `true` (settings-doc)
- **`fileCheckpointingEnabled` setting** — toggles file snapshots before each edit for `/rewind`; appears in `/config` as **Rewind code (checkpoints)** (settings-doc)
- **`theme` setting** — sets the color theme (`"auto"`, `"dark"`, `"light"`, daltonized, ANSI, or custom); previously stored only in `~/.claude.json` before v2.1.119 (settings-doc)
- **`verbose` setting** — shows full tool output instead of truncated summaries; the `--verbose` flag overrides for one session (settings-doc)

### Changed

- **`claude daemon status` version mismatch warning** — command now warns when the running supervisor is on a different version than the invoked `claude`, and instructs `claude daemon stop --any` (or `claude daemon stop` for OS-service installs) to pick up the update (features-doc)
- **Remote Control push notifications: second toggle added** — setup step now enables both **Push when Claude decides** (proactive) and **Push when actions required** (permission prompts); wording updated from "the on/off toggle" to "the two on/off toggles" (features-doc)
- **Tool canonical name vs. display label clarified** — documented that the label shown in transcript/dialog (e.g. `Stop Task`) differs from the canonical name used in permission rules and hooks (e.g. `TaskStop`); startup warning catches the mismatch for deny/ask rules (settings-doc)
- **IDE desktop troubleshooting support links updated** — "Still stuck?" now directs users to Help → Get Support in the desktop app first; GitHub Issues reserved for bugs that also reproduce in the standalone CLI (ide-doc)
- **`~/.claude.json` migration note updated** — clarifies that pre-v2.1.119 versions stored `theme`, `verbose`, `editorMode`, `autoCompactEnabled`, and `preferredNotifChannel` there, replacing the previous partial list (settings-doc)

### Removed

- **Agent SDK credit note removed from four pages** — the June 15, 2026 note about Agent SDK credits on subscription plans drawing from a separate monthly allowance has been removed from the SDK overview, headless, authentication, and legal-and-compliance docs (agent-sdk-doc, headless-doc, getting-started-doc, security-doc)

## 26.6.15

**29 references updated across 15 skills:** agent-sdk-doc, agent-teams-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, plugins-doc, settings-doc, sub-agents-doc

### New

- **Nested subagents (v2.1.172)** — subagents can now spawn their own subagents; foreground subagents can spawn at any depth, background subagents are limited to depth 5; `Agent` tool is no longer excluded from subagent tool lists (sub-agents-doc, agent-sdk-doc)
- **`enforceAvailableModels` setting (v2.1.175)** — when enabled alongside `availableModels` in managed or policy settings, constrains the Default model picker option to the allowlist; managed/policy values now replace lower-precedence entries rather than merging (features-doc, settings-doc)
- **`wheelScrollAccelerationEnabled` setting (v2.1.174)** — new `settings.json` key to disable mouse-wheel scroll acceleration in fullscreen mode; also documented in env vars reference (features-doc, settings-doc)
- **`resolvedModel` field on Agent tool output (v2.1.174)** — `completed` and `async_launched` subagent results now include the model the subagent actually ran on, available in hooks `PostToolUse` and the Agent SDK (agent-sdk-doc, hooks-doc)
- **`Could not resolve authentication method` error (v2.1.174)** — new error entry covering background, cloud, and SDK sessions that reach the API without credentials; includes fix note for idle pre-warmed worker bug fixed in v2.1.174 (errors-doc, operations-doc)
- **`skipMcpDiscovery` field on `SdkPluginConfig` (TypeScript SDK)** — when `true`, the SDK loads skills, hooks, agents, and commands from a plugin but skips its `.mcp.json`/`mcpServers` configuration (agent-sdk-doc)
- **`auto-continuation` origin kind** — new `SDKMessageOrigin` variant for synthetic turns injected when a session continues without fresh user input (agent-sdk-doc)
- **v2.1.174 and v2.1.175 and v2.1.176 release notes** — three new changelog entries covering scroll acceleration, model picker fixes, `enforceAvailableModels`, authentication fixes, background session fixes, Remote Control fixes, and more (operations-doc)
- **VS Code Account & usage dialog** — `/usage` in VS Code now shows usage attribution by skill, subagent, plugin, and MCP server with Day/Week toggle; requires v2.1.174 (ide-doc, operations-doc)
- **`CLAUDE_CODE_CHILD_SESSION` env var (v2.1.172)** — set in subprocesses Claude Code spawns; recommended for gating plugin hints instead of `CLAUDECODE` to avoid false positives in IDE terminals and tmux (plugins-doc, settings-doc)
- **`host_owned_mcp` telemetry field (v2.1.172)** — new attribute on plugin-loaded events indicating whether the SDK host manages the plugin's MCP connections (operations-doc)
- **`model` attribute on `claude_code.lines_of_code.count` (v2.1.172)** — lines-of-code metric now carries model identifier so per-model code volume can be tracked directly without joining to token metrics (operations-doc)
- **1M context auto-compaction (v2.1.172)** — when context exceeds 200K mid-conversation on a standard-context session, Claude Code now auto-compacts rather than repeating the "Usage credits required for 1M context" error (errors-doc, operations-doc)
- **AWS GovCloud region prefix support** — `us-gov.` inference profile prefix documented for Bedrock GovCloud regions (cloud-providers-doc)
- **JetBrains installation clarified** — setup now documented as two explicit steps (CLI first, then plugin); explains "Cannot launch Claude Code" notification when CLI is missing from PATH (ide-doc, getting-started-doc)

### Changed

- **`availableModels` enforcement scope expanded** — allowlist now applies to subagent model fields, advisor model, and the Agent tool's `model` parameter, not just the main session; blocked `--model` or `ANTHROPIC_MODEL` at startup substitutes a default with a warning rather than failing (features-doc, settings-doc)
- **`availableModels` merge behavior changed (v2.1.175)** — managed or policy `availableModels` now replaces lower-precedence entries entirely; user and project settings can no longer widen a managed allowlist (features-doc, settings-doc)
- **`availableModels` matching broadened** — allowlist matching now accepts model alias, version prefix (e.g. `claude-opus-4-8`), or full model ID; `[1m]` suffix stripped before matching; provider-specific prefixes not stripped (features-doc)
- **`opusplan` extended context behavior** — plan-mode Opus phase now uses the same context window as the `opus` alias, including auto-upgrade to 1M on eligible tiers; `opusplan[1m]` documented for manual 1M on other tiers; excluded Opus falls back to Sonnet in plan mode (features-doc)
- **`xhigh` effort level updated** — recommended model updated from "Opus 4.8" to "Fable 5 and Opus 4.7+" in the effort table (agent-sdk-doc)
- **`error_max_structured_output_retries` description expanded** — error subtype now covers model-fallback retraction mid-stream (no validation failure needed); `errors` text recommended for distinguishing the two causes (agent-sdk-doc)
- **Bedrock AWS region resolution (v2.1.172)** — `AWS_REGION` is no longer required; region resolves via `AWS_REGION` → `AWS_DEFAULT_REGION` → active AWS profile → `us-east-1` fallback; `/status` shows resolved region and source (cloud-providers-doc)
- **`peer` origin kind description corrected** — marked as reserved for inter-agent messages; Agent SDK does not emit this origin; treat as unknown (agent-sdk-doc)
- **SessionStart `model` field is now optional** — documented as omittable after `/clear` or conversation recovery; hooks should check for its presence before reading (hooks-doc)
- **WebFetch permission rule matching clarified** — `*` wildcard behavior described precisely: matches across `.` only as a leading `*.` or whole-pattern `*`; `WebFetch(domain:*)` is equivalent to bare `WebFetch`; exact rules take precedence over wildcards (settings-doc)
- **`Ctrl+X Ctrl+K` description updated** — wording changed from "Kill" to "Stop" background subagents (cli-doc)
- **`/status` managed settings location** — now references the **Status** tab specifically; wording updated in admin setup and settings docs (settings-doc)

### Removed

- Minor wording/formatting updates across agent-teams-doc, headless-doc, mcp-doc (commented-out Playwright example removed from mcp-doc; minor rewordings elsewhere)

## 26.6.12

**19 references updated across 9 skills:** ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, ide-doc, mcp-doc, memory-doc, operations-doc

### New

- **Claude Code v2.1.173 release notes** — Fable 5 model names with a `[1m]` suffix are now stripped automatically since 1M context is included by default; fixed spurious "sandbox dependencies missing" warning on Windows (operations-doc)
- **Plugin MCP tool naming convention** — tools from plugin-bundled MCP servers are now callable as `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`; documented for use in permission rules, skill `allowed-tools`, and subagent `tools` fields (mcp-doc)
- **`/code-review` default diff scope clarified** — now covers branch commits ahead of upstream plus uncommitted working-tree changes by default; target argument expanded to accept file path, PR number, branch name, or ref range like `main...my-feature` (ci-cd-doc)
- **Ultrareview scope documented** — `/code-review ultra` uses current branch vs. repository default branch plus uncommitted and staged changes, independent of how the branch's upstream is configured (ci-cd-doc)

### Changed

- **`--resume` session ID scope narrowed** — passing a session ID now searches only the current project directory and its git worktrees; the picker and name search still include sessions added via `/add-dir` (cli-doc)
- **Session ID resume scoping rule added to headless and sessions docs** — `--resume <session-id>` must be run from the directory the session was started in; error message `No conversation found with session ID` explained (headless-doc)
- **VS Code extension does not add `claude` to PATH** — extension bundles a private CLI copy for its chat panel only; standalone CLI install required to run `claude` in any terminal; `claude mcp add` and `--resume` commands require the standalone install (ide-doc)
- **VS Code prerequisites clarified** — any paid Claude subscription (Pro, Max, Team, Enterprise) or Claude Console account works; no API key required (ide-doc)
- **JetBrains prerequisites clarified** — same subscription note added: paid Claude subscription or Console account, no API key required (ide-doc)
- **Quickstart essential commands reorganized** — shell commands and session commands split into separate tables; `exit` corrected to `/exit`; links updated to include both CLI reference and commands reference (getting-started-doc)
- **Grafana Cloud added to observability platform examples** — listed alongside Honeycomb and Datadog for metrics, events, and traces backends (operations-doc)

### Removed

- Minor wording/formatting updates across cloud-providers-doc, features-doc, memory-doc docs (interactive JSX components added to source)

## 26.6.11

**11 references updated across 4 skills:** cloud-providers-doc, features-doc, memory-doc, operations-doc, plugins-doc

### New

- **Claude Code v2.1.172 release notes** — sub-agents can now spawn their own sub-agents up to 5 levels deep; Bedrock reads AWS region from `~/.aws` config when `AWS_REGION` is unset; search bar added to `/plugin` marketplace browser; `model` attribute added to `claude_code.lines_of_code.count` OTEL metric; multiple bug fixes for model picker, `availableModels`, background agents, `WebFetch` wildcard rules, and workflow validation (operations-doc)

### Changed

- **`claude-plugins-official` marketplace registration** — the official Anthropic marketplace is now only auto-registered on first interactive launch; non-interactive scripts that run before that must add it explicitly with `claude plugin marketplace add anthropics/claude-plugins-official` (plugins-doc)
- **Plugin submission URL and access requirements** — the claude.ai submission form moved to `claude.ai/admin-settings/directory/submissions/plugins/new` and now requires a Team or Enterprise org with directory management access; individual authors without a Team/Enterprise org should use the Console form instead (plugins-doc)

### Removed

- Minor wording/formatting updates across cloud-providers-doc, features-doc, memory-doc docs (interactive JSX components removed from rendered source)

## 26.6.10

**86 references updated across 20 skills:** agent-sdk-doc, agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **Claude Fable 5 model** — new Mythos-class model available via `/model fable` or `best` alias (where available); requires v2.1.170; not available under ZDR; cybersecurity/biology content triggers automatic fallback to Opus (features-doc, getting-started-doc, settings-doc, sub-agents-doc, agent-sdk-doc)
- **`fable` model alias and `ANTHROPIC_DEFAULT_FABLE_MODEL` env var** — new alias resolves to Fable 5; new env var pins Fable model ID for third-party providers and controls automatic fallback recognition (features-doc, settings-doc, cloud-providers-doc, agent-sdk-doc)
- **Fallback model chains** — configure up to three fallback models via `fallbackModel` setting or `--fallback-model` flag for availability-based switching; separate from content-based Fable 5 automatic fallback (features-doc)
- **Automatic model fallback for Fable 5** — when a safety classifier flags a request, Claude Code re-runs it on the default Opus model with a transcript notice; session continues on Opus until `/model fable` is re-selected (features-doc, operations-doc, errors-doc)
- **`ask` rules now override `bypassPermissions`** — explicit ask rules in `permissions` force a prompt even in `bypassPermissions` mode; documented across permissions, SDK, security, and sub-agents docs (agent-sdk-doc, settings-doc, security-doc, sub-agents-doc, features-doc)
- **`plan` mode behavior clarified: file edits prompt via `canUseTool`** — plan mode no longer described as "read-only"; file edits are never auto-approved and route through the callback even when an allow rule matches (agent-sdk-doc, settings-doc, features-doc, ide-doc)
- **`disallowed_tools=["*"]` glob deny rule** — documented: a `"*"` deny rule removes every tool definition from the request; tool-name globs are supported in deny rules (agent-sdk-doc)
- **Allow rules reject non-MCP globs** — allow rules only accept wildcards after a literal `mcp__<server>__` prefix; unanchored globs like `"*"` in allow rules are ignored with a startup warning (agent-sdk-doc)
- **`ttft_stream_ms` field on `ResultMessage`** — new field measuring time to first `message_start` stream event, lower than `ttft_ms`; the gap between them is streaming time (agent-sdk-doc)
- **`audio` and `resource_link` tool result content types** — tool result `content` array now accepts `audio` and `resource_link` blocks alongside `text`, `image`, and `resource` (agent-sdk-doc)
- **`CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS` documented for interactive sessions** — built-in subagents are always registered interactively; env var only applies in non-interactive/SDK mode (sub-agents-doc)
- **`post-session` lifecycle hook for self-hosted runners** — new hook runs after the session ends and before the workspace is deleted; SIGTERM→SIGKILL window is also configurable (operations-doc)
- **`defer` permission decision value** — hooks can now return `defer` as a `PreToolUse` permission decision; precedence order updated to `deny > defer > ask > allow` (hooks-doc)
- **Hook content rewriting summary** — new section documenting which events support `updatedInput`/`updatedToolOutput` rewriting vs. only `additionalContext` injection (hooks-doc)
- **`diagnostics` field on LSP server config** — set to `false` to suppress automatic diagnostic injection after edits while keeping code navigation (plugins-doc)
- **Single-skill plugin root `SKILL.md` layout** — plugins with exactly one skill can place `SKILL.md` at the plugin root instead of `skills/`; `name` frontmatter controls invocation name (plugins-doc)
- **Plugin `ref` + `sha` pinning survives deleted upstream branches** — when both are set, the pinned commit is fetched directly; install succeeds even if the branch/tag was deleted (plugins-doc)
- **Plugin detail view shows component inventory** — the plugin detail view lists contributed commands, skills, agents, hooks, MCP servers, and LSP servers; also available via `claude plugin details` (plugins-doc)
- **Sandbox session temp directory writable by default** — `$TMPDIR` inside the sandbox now points to the session temp dir (writable alongside the working dir); documented write behavior and `sandbox.filesystem.allowWrite` scope (security-doc)
- **`DISABLE_PROMPT_CACHING_FABLE` env var** — disables prompt caching for Fable models only (features-doc, settings-doc)
- **`Remote Control active` footer indicator (v2.1.162)** — a persistent link to the claude.ai session URL stays in the footer while Remote Control is connected; selectable with the down arrow key (features-doc)
- **`/mcp` command works from mobile and web (v2.1.166)** — returns a text summary of server status instead of opening the picker; accepts `reconnect`, `enable`, and `disable` subcommands (features-doc)
- **URL filter in agent view dispatch input** — any non-special URL in the dispatch filter finds the session whose first prompt contained that URL (features-doc)
- **`claude agents --json --all` flag** — includes completed background sessions in addition to live and in-progress ones; JSON schema also adds `state` field and changes `status` to only appear while the process is alive (features-doc)
- **`--safe-mode` flag now documented in troubleshooting** — use `claude --safe-mode` as the first isolation step before pointing `CLAUDE_CONFIG_DIR` at an empty directory (operations-doc)
- **`Usage credits required for 1M context` error** — new error entry: fires on entitlement check, not quota exhaustion; resolution steps include `/usage-credits` and switching to standard context (operations-doc, errors-doc)
- **`Your organization has disabled API key authentication` error** — new error entry with multiple recovery variants depending on whether the key came from `ANTHROPIC_API_KEY`, env, or `apiKeyHelper` (operations-doc, errors-doc)
- **`safe_mode` attribute on OTEL plugin/session events** — `"true"` when session started with `--safe-mode`; requires v2.1.169 (operations-doc)
- **`user.id` OTEL attribute clarified** — documented as a random anonymous identifier generated on first run, persisted in `~/.claude.json`, not derived from account; deleting the file creates a new unrelated value (operations-doc)
- **`--fallback-model` now appears in transcript notices, not `/model` change** — availability-based fallback is visible in the transcript; `/model` only changes for Bedrock/Vertex startup checks and Fable 5 automatic fallback (operations-doc, errors-doc)
- **`/model` picker shows worktree lock note** — while an agent runs, its worktree is locked with `git worktree lock`; released when the agent finishes; `--force` needed to remove a locked worktree manually (features-doc)
- **Skills in `-p` mode** — user-invoked skills like `/code-review` now work in `-p` mode; only interactive-dialog built-ins like `/config` remain unavailable (headless-doc)
- **Cloud session user skills and agents not available** — `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/commands/` do not transfer to cloud sessions; skills enabled on claude.ai load automatically (headless-doc)
- **apt/dnf/apk `stable` vs `latest` channel docs** — setup instructions now document both channels with explicit `latest` repository URLs for each package manager (getting-started-doc)
- **Model availability under ZDR section** — Fable 5 is unavailable for ZDR organizations; `best` alias resolves to Opus for ZDR accounts (security-doc)
- **`model` field on `AgentDefinition` now links to accepted values** — clarified to accept alias or full model name with link to model-config doc (agent-sdk-doc)
- **Tool search model support broadened** — now supported on every Claude model except Haiku, not just Sonnet 4+ and Opus 4+ (agent-sdk-doc, mcp-doc)
- **MCP tool search has no per-server tool cap** — Claude Code imposes no fixed per-server limit; practical limit is context window budget (mcp-doc)

### Changed

- **"Remote sessions" renamed to "cloud sessions"** — all references to "remote sessions" updated to "cloud sessions" across IDE, headless, best-practices, and CI/CD docs (ide-doc, headless-doc, best-practices-doc, ci-cd-doc)
- **`best` alias now resolves to Fable 5 where available** — previously resolved to latest Opus; on accounts without Fable 5 access (including ZDR), still resolves to Opus (features-doc)
- **`xhigh` effort now recommended for Opus 4.8 and Opus 4.7** — table updated; Fable 5 added with effort range `low`–`max` and default `high` (agent-sdk-doc, features-doc)
- **TypeScript SDK `effort` default changed to `Model default`** — both SDKs now leave effort unset when not specified, deferring to the model's default; TypeScript no longer defaults to `"high"` (agent-sdk-doc)
- **`plan` mode description corrected** — described as "explore without editing" rather than "read-only tools only" across all docs (agent-sdk-doc, settings-doc, features-doc, getting-started-doc, ide-doc)
- **`bypassPermissions` description updated** — now described as "bypass permission checks" with the ask-rule exception noted everywhere it appears (agent-sdk-doc, settings-doc, sub-agents-doc, ide-doc)
- **Managed settings: first non-empty config wins** — clarified that Claude Code applies the first source that returns a non-empty configuration, not just the first one found (settings-doc)
- **Auto mode: deny and ask rules evaluated before classifier** — explicit ask/deny rules now documented as pre-classifier steps that still block or prompt regardless of auto mode (settings-doc)
- **`MAX_THINKING_TOKENS=0` behavior on Fable 5 and third-party providers** — has no effect on Fable 5 (thinking cannot be turned off); on third-party providers, omits the `thinking` parameter instead of disabling thinking (features-doc, ide-doc)
- **`/feedback` data stored in Google Cloud Storage** — data retention note updated to mention GCS encryption at rest (security-doc)
- **`--dangerously-skip-permissions` described as bypassing "other than explicit ask rules"** — security and sub-agents docs updated to reflect ask-rule exception (security-doc, sub-agents-doc)
- **Sandbox: `ask` rules for bare `Bash` skipped for sandboxed commands** — content-scoped ask rules like `Bash(git push *)` still prompt for sandboxed commands; bare `Bash` ask rule does not (security-doc)
- **`settings.local.json` described as "gitignored when Claude Code creates it"** — note added that manually created files need manual gitignore entries (hooks-doc, memory-doc, settings-doc, best-practices-doc)
- **`initialPrompt` field: ignored when agent is a subagent** — clarified that `initialPrompt` is only submitted when the agent runs as the main thread agent (agent-sdk-doc)
- **`fable` alias added to `model` field on `AgentDefinition`** — accepted aliases now include `fable`, `opus`, `sonnet`, `haiku`, and `inherit` (agent-sdk-doc, sub-agents-doc)
- **Session storage respects `CLAUDE_CONFIG_DIR`** — resume troubleshooting note updated: sessions are under `$CLAUDE_CONFIG_DIR/projects/` when set (agent-sdk-doc)
- **`/resume` picker updated for `/cd` relocations (v2.1.169)** — sessions moved with `/cd` appear in the new directory's picker (headless-doc)
- **Desktop macOS managed settings preference domain corrected** — changed from `com.anthropic.Claude` to `com.anthropic.claudefordesktop` (ide-doc)
- **Plugin suggestion marketplace requires admin allowlist** — the "suggested for this directory" label now requires `pluginSuggestionMarketplaces` managed setting (plugins-doc)
- **`/reload-plugins` warning documented in plugins-doc** — v2.1.163 behavior (warn and hold instead of silently applying) now noted in the reload cost section (plugins-doc)
- **`CLAUDE_CODE_FORK_SUBAGENT` rollout note clarified** — split into explicit enable/disable instructions; staged rollout note simplified (sub-agents-doc)
- **`claude agents --json` output schema expanded** — `state` field added; `status`/`pid` only present while process is alive; `waitingFor` documented (features-doc)
- **Built-in Explore/Plan agents confirmed one-shot, no `agentId` returned** — explicitly noted that they cannot be resumed; use `general-purpose` or custom agent when resumption is needed (agent-sdk-doc, sub-agents-doc)
- **Cloud sessions: `Accept edits` replaces `Auto accept edits` label** — cloud sessions pre-approve file edits; selector shows "Accept edits" instead of "Ask permissions" (headless-doc, ide-doc)
- **Desktop Cowork on 3P research preview noted** — Desktop can run the Code tab on Bedrock, Vertex AI, Foundry, or a self-hosted gateway via the Cowork on 3P research preview (ide-doc, cloud-providers-doc, getting-started-doc)
- **Teleport requires claude.ai subscription** — noted in how-it-works doc (getting-started-doc)
- **`disableBundledSkills` setting documented** — bundled skills are available "unless disabled with `disableBundledSkills`" (skills-doc)
- **`\\$1` escape behavior corrected** — doubled backslash leaves both backslashes in place and `$1` still expands (skills-doc)
- **`model` metric attribute scope clarified** — only available on `claude_code.token.usage` and `claude_code.cost.usage`, not activity counters (operations-doc)
- **Pasted image error handling improved (v2.1.142)** — Claude Code now replaces unprocessable images with a text placeholder and retries; prior version workaround removed from docs (operations-doc, errors-doc)

### Trivial

- Minor wording/formatting updates across agent-sdk-doc, ci-cd-doc, features-doc, getting-started-doc, hooks-doc, ide-doc (link URL hash fixes, duplicated `theme` attributes in code fences, column-width alignment)

## 26.6.9

**30 references updated across 15 skills:** agent-sdk-doc, best-practices-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **`initialPrompt` field on `AgentDefinition`** — auto-submitted as the first user turn when the agent runs as the main thread agent (agent-sdk-doc)
- **`--safe-mode` flag and `CLAUDE_CODE_SAFE_MODE` env var** — starts Claude Code with all customizations (CLAUDE.md, plugins, skills, hooks, MCP servers) disabled for troubleshooting (operations-doc)
- **`/cd` command** — moves a session to a new working directory without breaking the prompt cache mid-session (operations-doc)
- **`disableBundledSkills` setting and `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` env var** — hides bundled skills, workflows, and built-in slash commands from the model (operations-doc)
- **`fallbackModel` setting** — configures up to three fallback models tried in order when the primary model is overloaded or unavailable; `--fallback-model` now also applies to interactive sessions (operations-doc)
- **Glob pattern support in deny rule tool-name position** — `"*"` in a deny rule denies all tools; allow rules reject non-MCP globs, unknown tool names in deny rules warn at startup (operations-doc)
- **`api_refusal` OTEL event** — logged when an API request returns `stop_reason: "refusal"`; includes `model` and `request_id` attributes (operations-doc)
- **`is_plugin`, `plugin_id_hash`, and `plugin.name` attributes on `mcp_server_connection` events** — identifies whether a server comes from a plugin, with redaction for third-party plugin names unless `OTEL_LOG_TOOL_DETAILS=1` (operations-doc)
- **`/btw` overlay `c` key to copy answer** — copies the overlay answer to clipboard as raw Markdown rather than hard-wrapped terminal text (cli-doc)
- **`/reload-plugins --force` flag** — when a reload would change which MCP tools are loaded and invalidate the prompt cache, the command warns and skips; pass `--force` to apply anyway (cli-doc, features-doc)
- **Background task termination behavior for `claude -p`** — background Bash tasks are terminated about five seconds after Claude returns its final result; before v2.1.163 a never-exiting task held the process open indefinitely (headless-doc)
- **`Bash(if)` matching table in hooks guide and reference** — detailed table documenting how `if` patterns match against subcommands, `$(...)` expansions, and backticks, including fail-open behavior for constrained patterns (hooks-doc)
- **`hookSpecificOutput.additionalContext` for SubagentStop hooks** — SubagentStop now supports `additionalContext` (same as Stop), for non-error feedback that keeps the subagent running (hooks-doc)
- **`additionalContext` as Stop/SubagentStop feedback channel** — documented in the `additionalContext` placement in the `where the reminder appears` table; Stop and SubagentStop now listed alongside other events (hooks-doc)
- **`/plugin list` subcommand inside interactive sessions** — `/plugin list` prints the inline listing; accepts `--enabled`/`--disabled` filters and `ls` as a shorthand (plugins-doc)
- **`requiredMinimumVersion` and `requiredMaximumVersion` settings** — managed-settings-only keys that block startup when the running version is outside the approved range (settings-doc, getting-started-doc)
- **`CLAUDE_CODE_SYNC_SKILLS_INSTALL_TIMEOUT_MS` env var** — bounds the download triggered when the host requests a skill reload during a session (settings-doc)
- **`disallowed-tools` skill frontmatter key** — removes tools from Claude's available pool while a skill is active; restriction clears after the next message (skills-doc)
- **`$` escape syntax in skill argument substitutions** — `\$` before a digit, `ARGUMENTS`, or a declared argument name inserts a literal `$` (skills-doc)
- **ZDR eligibility note** — explicit note that Zero Data Retention is not included in the standard Enterprise plan and requires separate confirmation by Anthropic (security-doc)
- **`requiredMinimumVersion`/`requiredMaximumVersion` row in admin control surface table** — documented alongside `minimumVersion` in the managed settings control table (settings-doc)
- **Git commit attribution format change** — the `🤖 Generated with Claude Code` line was removed from the default commit trailer; only `Co-Authored-By:` remains, with a note that the model name reflects the active session model (settings-doc)

### Changed

- **Dynamic workflows out of research preview** — "research preview" qualifier removed from the availability note (best-practices-doc)
- **Model alias resolution clarified for cloud providers** — Bedrock, Vertex AI, Foundry, and Claude Platform on AWS docs updated to say aliases resolve to Claude Code's "built-in default" for that provider (which can lag the newest release), not simply "the latest version" (cloud-providers-doc, features-doc, errors-doc)
- **`CLAUDE_CODE_FORK_SUBAGENT` accepts `0` to opt out of rollout** — setting to `0` now explicitly disables fork mode, overriding any server-side staged rollout (settings-doc, sub-agents-doc)
- **`CLAUDE_CODE_SESSION_ID` behavior on `--resume`** — clarified that `--resume <session-id>` delivers the resumed ID to MCP servers, matching hooks and Bash; `--continue` or `--resume` without an explicit ID may still deliver the startup ID (settings-doc)
- **`CLAUDE_CODE_TMPDIR` sandboxing scope clarified** — the short fallback `$TMPDIR` for long paths applies only to sandboxed Bash subprocesses; unsandboxed commands inherit the shell's `$TMPDIR` unchanged (settings-doc)
- **Hook `if` field description updated to reference new matching table** — reference now links to the Bash matching table and drops the prior "fails open on complex commands" inline prose (hooks-doc)
- **Hook `prompt` field documents `\$` literal escape** — `\$1.00` renders as `$1.00` in prompt and agent hook bodies (hooks-doc)
- **Subagent resumption example updated** — Python example uses a custom `endpoint-finder` agent definition and `ToolResultBlock`-based extraction instead of JSON stringification; TypeScript example removed (agent-sdk-doc)
- **Quickstart welcome screen description updated** — launch text now describes the prompt bar showing version, model, and working directory rather than a "welcome screen" (getting-started-doc)

### Removed

- **`/reload-plugins` silent cache-invalidating reload** — as of v2.1.163, a reload that would trigger a full prompt-cache re-read now warns and holds instead of applying silently (features-doc)

### Trivial

- Minor wording/formatting updates across agent-sdk-doc, cli-doc, features-doc, getting-started-doc, settings-doc docs (link updates, column-width alignment, duplicated `theme` attributes in code fences)

## 26.6.5

**11 references updated across 7 skills:** agent-sdk-doc, cli-doc, features-doc, ide-doc, mcp-doc, memory-doc, operations-doc, settings-doc

### New

- **`ResultMessage` subtype and error-field documentation** — new prose explains all `subtype` values (`success`, `error_during_execution`, `error_max_turns`, `error_max_budget_usd`, `error_max_structured_output_retries`) and clarifies `is_error`, `api_error_status`, `result`, and `errors` field semantics for each (agent-sdk-doc)
- **`requiredMinimumVersion` / `requiredMaximumVersion` managed settings** — new fields in managed settings that block startup if Claude Code's version is outside the allowed range (operations-doc)
- **`/plugin list` command** — lists installed plugins with `--enabled`/`--disabled` filters (operations-doc, cli-doc)
- **Stop/SubagentStop hook `additionalContext` output** — Stop and SubagentStop hooks can now return `hookSpecificOutput.additionalContext` to pass feedback to Claude without triggering a hook error (operations-doc)
- **`$` escape syntax in skill command bodies** — `\$` now inserts a literal `$` before a digit in skill command bodies (operations-doc)
- **`tool_use_id` and `gen_ai.tool.call.id` OTEL attributes** — new attributes added to `claude_code.tool` and `claude_code.tool.execution` spans for joining spans to tool-result and tool-decision events and hook payloads (operations-doc)
- **`skill.kind` OTEL attribute** — new `skill.kind: "workflow"` attribute on skill invocation events for workflow skills (operations-doc)
- **Anthropic-hosted connectors (Microsoft 365, Gmail, Google Calendar) local-OAuth limitation** — from v2.1.162, authenticating these providers in `/mcp` redirects the user to Settings → Connectors on claude.ai; once connected there, the connector appears in Claude Code automatically (mcp-doc)
- **Extension storage removal paths by platform** — VS Code extension uninstall instructions now provide separate `rm -rf` paths for macOS, Linux, and a PowerShell `Remove-Item` command for Windows (ide-doc)
- **`waitingFor` field in `claude agents --json`** — when `status` is `waiting`, the JSON entry now includes `waitingFor` describing the block (e.g., `permission prompt`, `input needed`) (features-doc)

### Changed

- **WebFetch preapproved documentation domains** — WebFetch no longer prompts for a built-in set of preapproved docs domains; explicit `deny`/`ask`/`allow` rules still override the preapproved set (cli-doc)
- **LSP tool "list symbols" split into two capabilities** — "List symbols in a file" and "Search for a symbol by name across the workspace" are now listed as separate capabilities (cli-doc)
- **`mcp add` option-ordering note updated** — note clarifies that `--env` must not be immediately followed by the server name (the CLI would read it as a `KEY=value` pair); examples updated accordingly (mcp-doc)
- **MCP per-server `timeout` behavior for values below 1000** — values below 1000 are now ignored and fall through to `MCP_TOOL_TIMEOUT` (or its ~28-hour default); prior to v2.1.162 they were floored to one second; `MCP_TOOL_TIMEOUT` env var retains the floor-to-one-second behavior (mcp-doc, settings-doc)
- **Deep-link session-open warning UI updated** — the banner above the input is replaced by a persistent `Prompt from an external link` warning line below the input box that stays visible until the prompt is sent or cleared; character count shown for prompts over 1,000 characters (features-doc)
- **Deep-link `repo` mode welcome header simplified** — the welcome header now shows which path was picked; the "last fetched" timestamp detail was removed (features-doc)
- **`/init` reads `.devin/rules/`** — `/init` now incorporates `.devin/rules/` alongside `.cursorrules` and `.windsurfrules` when generating `CLAUDE.md` (memory-doc)
- **PowerShell `curl` alias note in troubleshoot-install** — added note that PowerShell aliases `curl` to `Invoke-WebRequest`; users should run `curl.exe -sI` instead (operations-doc)
- **Ops changelog v2.1.163** — June 4 release notes added (operations-doc)

## 26.6.4

**27 references updated across 10 skills:** agent-sdk-doc, cli-doc, cloud-providers-doc, features-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, settings-doc, sub-agents-doc

### New

- **`/fork` command (v2.1.161+)** — spawns a forked subagent that inherits the full conversation and works on a directive while you continue; available by default from v2.1.161 without setting `CLAUDE_CODE_FORK_SUBAGENT`; `/branch` is now distinct and only switches you into a conversation copy (cli-doc, sub-agents-doc)
- **`SDKCommandsChangedMessage`** — new SDK message type emitted when the available command set changes mid-session (e.g., skills discovered on directory change); contains the full updated `commands` array and supersedes the `supportedCommands()` snapshot (agent-sdk-doc)
- **`pending_permission_requests` on `initialize` response** — when a client connects to an already-running session, the control-response wrapper carries in-flight permission requests that arrived before the client connected and will not be re-sent (agent-sdk-doc)
- **`overloaded` error type** — new `SDKAssistantMessageError` value `'overloaded'` (HTTP 529) distinguishing server-capacity errors from `'rate_limit'` (HTTP 429); added to headless `api_retry` event, `StopFailure` hook matcher, and hooks reference (agent-sdk-doc, headless-doc, hooks-doc)
- **`OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES` env var** — controls whether `OTEL_RESOURCE_ATTRIBUTES` keys are attached as labels on every metric datapoint (default: `true`); `OTEL_RESOURCE_ATTRIBUTES` keys now also appear as standard attributes in the monitoring table (settings-doc, operations-doc)
- **"When your context fills up" section** — new context-window guidance covering `/compact` with focus, `/clear` between tasks, delegating large reads to subagents, and the 1M token window available on Opus 4.6+/Sonnet 4.6 (features-doc)
- **Fast mode and prompt cache interaction documented** — new "Turning on fast mode" section in prompt-caching docs explains the one-time cache-bust cost, that the fast-mode header stays in subsequent toggles (v2.1.86+), and what resets it (features-doc)
- **Garbled text troubleshooting entry** — new entry for boxes/smears in VS Code, Cursor, or Devin Desktop integrated terminal, directing users to disable GPU acceleration via `/terminal-setup` (operations-doc)
- **Agent-view parallel work item count** — from v2.1.161, session rows show a `done/total` count when two or more parallel items are running; peek panel names the longest-running item (features-doc)
- **Ops changelog v2.1.162** — June 3 release notes added covering `claude agents --json waitingFor`, `/effort` confirmation, autocomplete fill-then-run, Remote Control footer pill, and numerous bug fixes (operations-doc)
- **MCP unused connectors collapsed** — from v2.1.161, connectors never signed in to are hidden behind a "Show unused connectors" row in the claude.ai panel; previously-signed-in connectors stay visible (mcp-doc)
- **WebSearch unavailable on Bedrock** — explicit note added to the Bedrock limitations list with link to the WebSearch tool behavior reference (cloud-providers-doc)

### Changed

- **`agent` setting applied mid-session** — `agent` moved from "no effect mid-session" to "applied on the next turn" list; switching agent also applies that agent's model override, hooks, and system prompt on the next turn (agent-sdk-doc)
- **`CLAUDE_CODE_FORK_SUBAGENT` behavior updated** — variable now makes forked subagents the model's *default* spawn behavior rather than also changing `/fork` (which is now always available); description updated accordingly (settings-doc)
- **Fast mode cost clarification** — cost applies once per conversation; toggling off and on again does not repeat the cache-bust; documented in both fast-mode and prompt-caching references (features-doc)
- **Fullscreen clipboard copy paths documented** — clipboard path now broken out by OS (`pbcopy`, `wl-copy`/`xclip`/`xsel` with PRIMARY selection, PowerShell `Set-Clipboard`); per-terminal bypass modifier list expanded (Terminal.app `Fn`, VS Code/Cursor/Devin Desktop `Shift` or `Option`) (features-doc)
- **Auto mode ignores project settings clarified** — now specifies v2.1.142 and later; `CLAUDE_CODE_ENABLE_AUTO_MODE` requirement on Bedrock/Vertex/Foundry specifies v2.1.158 and later (settings-doc)
- **`.claude` protected-directory scope narrowed** — protection now covers only `.claude/worktrees`; earlier entry listed `.claude/commands`, `.claude/agents`, `.claude/skills` as exceptions (settings-doc)
- **`CLAUDE_CODE_TMPDIR` gets short fallback `$TMPDIR`** — from v2.1.161, Bash subprocesses on macOS/Linux receive a short fallback `$TMPDIR` under the system default when the override path is long; Claude Code's own temp files still use the override (settings-doc)
- **Agent SDK quickstart run instructions** — TypeScript tab moved first; Python split into separate `uv run` and `python agent.py` (pip) tabs (agent-sdk-doc)

### Removed

- **`/fork` as alias for `/branch`** — before v2.1.161, `/fork` was an alias for `/branch`; it is now a distinct command; the alias behavior is documented as legacy only (cli-doc, sub-agents-doc)

## 26.6.3

**23 references updated across 9 skills:** agent-sdk-doc, best-practices-doc, cli-doc, errors-doc, features-doc, getting-started-doc, headless-doc, ide-doc, operations-doc, settings-doc, sub-agents-doc

### New

- **`CLAUDE_CODE_ENABLE_AUTO_MODE` env var** — enables auto mode on Amazon Bedrock, Google Cloud Vertex AI, and Microsoft Foundry; only Opus 4.7 and 4.8 are supported on these providers; without it auto mode does not appear in the `Shift+Tab` cycle (settings-doc)
- **Auto mode on Bedrock/Vertex AI/Foundry: new setup section** — new "Enable auto mode on Bedrock, Vertex AI, or Foundry" section documents how to set the env var per-user or org-wide in managed settings, and how `defaultMode: "auto"` requires it on these providers (settings-doc)
- **SDK hook matcher comparison rules documented** — matchers containing only letters, digits, `_`, and `|` are exact-match with `|` as OR; any other characters trigger regex evaluation; `*` or omitted matcher matches everything; examples show `Write|Edit` vs `^mcp__` (agent-sdk-doc)
- **Ops changelog v2.1.161** — June 2 release notes added covering OTEL label improvements, parallel tool call fix, Linux clipboard support, and numerous bug fixes (operations-doc)
- **Protected directories expanded** — `.config/git`, `.devcontainer`, `.yarn`, and `.mvn` added to the protected-path list across `default`, `acceptEdits`, `auto`, `dontAsk`, and `bypassPermissions` modes (settings-doc, sub-agents-doc)
- **Protected files expanded** — shell startup files (`.bash_login`, `.bash_aliases`, `.bash_logout`, `.zshenv`, `.zlogin`, `.zlogout`, `.envrc`), package manager configs (`.npmrc`, `.yarnrc`, `.yarnrc.yml`, etc.), build-tool lockfiles (`.bazelrc`, `.bazelversion`, etc.), hook configs (`.pre-commit-config.yaml`, lefthook variants), wrapper properties, `.devcontainer.json`, and `pyrightconfig.json` added to protected files (settings-doc)
- **Protected-path behavior table** — new table clearly maps each permission mode to its protected-path write behavior (settings-doc)
- **Agent-view attached sessions always use fullscreen rendering** — documented that background sessions from agent view or `claude attach` always render in fullscreen mode; `tui` setting and `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` do not apply (features-doc, settings-doc)
- **Auto-fix merge conflict limitation documented** — GitHub does not emit a webhook when the base branch advances and creates a merge conflict; documented that auto-fix cannot react automatically and the user must open the session to rebase (headless-doc)
- **Auto mode availability on Desktop with Vertex AI** — Enterprise Desktop routing through Vertex AI requires `CLAUDE_CODE_ENABLE_AUTO_MODE`; only Opus 4.7 and 4.8 supported there (ide-doc)

### Changed

- **`ultracode` replaces `workflow` as the workflow keyword trigger** — the literal trigger keyword changed from `workflow` to `ultracode`; natural-language requests ("use a workflow") also work; `/config` label renamed to "Ultracode keyword trigger"; `workflowKeywordTriggerEnabled` setting description updated (best-practices-doc, settings-doc)
- **SDK matcher section renamed "Filter with multi-tool matchers"** — section was "Filter with regex matchers"; prose updated to describe pipe-separated exact lists, regex patterns, and omitted matchers as three distinct behaviors (agent-sdk-doc)
- **Model error hint varies by surface** — "There's an issue with the selected model" error now gives surface-specific guidance: `/model` in interactive CLI, `--model` flag in `-p` mode, structured `model_not_found` in Agent SDK (errors-doc, operations-doc)
- **`grep`/`egrep`/`fgrep` count for read-before-edit** — these commands now satisfy the read-before-edit requirement alongside `cat`/`head`/`tail`/`sed`; `grep` also triggers Read deny rules, but `egrep`/`fgrep` do not (cli-doc)
- **`/terminal-setup` lists Devin Desktop instead of Windsurf** — all references to Windsurf replaced with Devin Desktop in terminal setup docs, commands reference, and VS Code extension install instructions (cli-doc, ide-doc)
- **Fast mode pricing clarification** — pricing line rephrased to "per MTok input/output" for clarity; Opus 4.6 fast mode override env var (`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE`) removed and marked as retired (features-doc)
- **`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` removed** — marked deprecated in env-vars reference; to use Opus 4.6 for fast mode, select the model with `/model` first then `/fast on` (settings-doc)
- **Auto mode availability wording simplified** — glossary and auto-mode-config notes updated to say "research preview" without provider restriction language, now that Bedrock/Vertex/Foundry support is opt-in via the enable var (getting-started-doc, settings-doc)
- **`CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` caveat added** — env-vars table note clarifies this flag does not apply to background sessions from agent view (settings-doc)
- **`tui` setting caveat added** — setting description notes that background sessions from agent view always use fullscreen regardless of this setting (settings-doc)
- **`bypassPermissions` warning updated** — warning now lists the expanded protected directories (`.config/git`, `.devcontainer`, `.yarn`, `.mvn`) (settings-doc, sub-agents-doc)

## 26.6.2

**36 references updated across 11 skills:** agent-sdk-doc, best-practices-doc, cli-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc

### New

- **`claude daemon stop --any`** — new CLI command stops the background supervisor and the sessions it hosts; `--keep-workers` leaves background sessions running so the next supervisor reconnects to them (cli-doc, features-doc)
- **`~/.claude/jobs/<id>/tmp/` per-session scratch directory** — writes here don't require permission prompts; `CLAUDE_JOB_DIR` env var set for each background session pointing to `~/.claude/jobs/<id>/` (features-doc)
- **`ANTHROPIC_DEFAULT_HAIKU_MODEL` for third-party providers** — on Bedrock, Vertex AI, Foundry, and custom gateways the agent-view session summary falls back to the session's main model; set this env var to choose the Haiku-class model for summaries (features-doc)
- **Voice dictation in agent view** — hold or tap push-to-talk key while the peek-panel reply or dispatch input is focused to dictate to a background session (features-doc)
- **Agent-view dispatch commands `/exit`, `/quit`, `/logout`** — these run in agent view itself instead of dispatching to a new background session (features-doc)
- **MCP quickstart link in overview and MCP doc** — overview accordion and MCP reference now link to the new `/en/mcp-quickstart` step-by-step walkthrough (getting-started-doc, mcp-doc)
- **Plugin reload token-cost note** — docs now explain that `/reload-plugins` appends announcements to the conversation and that plugins with MCP servers can invalidate the prompt cache (plugins-doc)
- **`claude.ai` MCP connectors in SDK** — `strictMcpConfig: true` now also suppresses claude.ai connectors; new table row documents the connector input and how to disable it via `strictMcpConfig` or `ENABLE_CLAUDEAI_MCP_SERVERS=false` (agent-sdk-doc)
- **`ListMcpResourcesTool` / `ReadMcpResourceTool` tool name rename** — MCP resource tool names changed from `ListMcpResources`/`ReadMcpResource` to `ListMcpResourcesTool`/`ReadMcpResourceTool` in SDK references (agent-sdk-doc)
- **`MessageDisplay` hook: code examples added** — new macOS/Linux and Windows PowerShell example scripts for stripping markdown formatting in the MessageDisplay hook (hooks-doc)
- **Extended thinking no longer incompatible with streaming** — removed the "extended thinking disables StreamEvent" limitation from the SDK streaming docs (agent-sdk-doc)
- **Hooks now fire inside subagents for programmatic callbacks** — programmatic hook callbacks now fire inside subagents, not just the main session; callbacks receive `agent_id` and `agent_type` to distinguish (agent-sdk-doc)
- **macOS background session folder-access troubleshooting** — new section for `Operation not permitted` errors on `~/Desktop`, `~/Documents`, `~/Downloads` in background sessions; explains Privacy & Security grant (features-doc)
- **"Background service did not respond" recovery steps** — new troubleshooting section with `claude daemon stop --any --keep-workers` workflow and Windows `taskkill` fallback (features-doc)
- **Empty unprompted agent-view rows auto-removed** — rows left from pressing `←` without entering a prompt are removed after ~5 minutes (features-doc)
- **Ops changelog v2.1.160** — June 2 release notes added (operations-doc)

### Changed

- **`[1m]` suffix scope clarified** — the 1M context suffix applies only to `opus` and `sonnet` aliases, not to the `opusplan` plan-mode Opus phase, which remains capped at 200K (features-doc)
- **Prompt caching: MCP tool search and plugin changes documented** — cache invalidation rules now distinguish deferred vs prefix-loaded tools; enabling/disabling a plugin that provides MCP servers follows the same rules as connecting/disconnecting a server (features-doc)
- **`Enabling or disabling a plugin` added to cache-invalidation list** — new section explains per-component-type cost when reloading plugins mid-session (features-doc)
- **Desktop app loads `claude_desktop_config.json` MCP servers into Code tab** — previously said these were separate; now they load alongside `~/.claude.json` servers; standalone CLI still requires `claude mcp add-from-claude-desktop` (ide-doc)
- **Workflows comparison table adds "Agent teams" column** — subagents/skills/workflows table now includes agent teams as a fourth option with its own row describing shared task list and peer-session model (best-practices-doc)
- **Workflow `ultracode` keyword trigger** — docs updated to reflect that the trigger keyword is now `ultracode` (renamed from `workflow`); pressing `Option+W`/`Alt+W` dismisses the highlight (best-practices-doc)
- **Saved workflows: `args` parameter and script-path access documented** — new section explains how saved workflows accept input via `args` global and where to find the generated script under `~/.claude/projects/` (best-practices-doc)
- **Workflow cost section expanded** — `/workflows` shows per-agent token usage; recommends running on a small slice to gauge spend before committing to large runs (best-practices-doc)
- **`MessageDisplay` timeout lowered to 10 seconds** — default timeout for MessageDisplay hooks is now 10 s, down from 600 s; documented in hook reference and guide (hooks-doc)
- **`MessageDisplay` description expanded** — use-cases (strip markdown, transform SDK output, redact secrets) and "hold each batch until hook returns" behavior now documented (hooks-doc)
- **Auto-mode classifier evaluates protected paths even with allow rules** — allow rules no longer bypass the classifier for writes to protected paths (settings-doc)
- **`/en/hooks-guide` page retitled "Automate actions with hooks"** — was "Automate workflows with hooks" across hooks-doc, features-doc, best-practices-doc, security-doc (hooks-doc, features-doc, best-practices-doc, security-doc)
- **`PreToolUse` hook block format updated** — `decision`/`reason` top-level fields are deprecated; use `hookSpecificOutput.permissionDecision: "deny"` and `permissionDecisionReason` instead; code examples updated in both Python and TypeScript (agent-sdk-doc)
- **`updatedMCPToolOutput` deprecated in SDK hooks** — use `updatedToolOutput` instead, which works for any tool in both SDKs (agent-sdk-doc)
- **Slash-command `$0`-indexed arguments** — example command corrected: first argument is `$0`, second is `$1` (was `$1`/`$2`) (agent-sdk-doc)
- **CLAUDE.md scope note updated** — all discovered CLAUDE.md files are concatenated from broadest to most specific scope rather than overriding each other (getting-started-doc)
- **MCP tool search description updated** — tool names and server instructions (not just names) load at session start (mcp-doc)
- **Plugin manifest now optional** — docs updated to state `plugin.json` is optional; Claude Code auto-discovers components from directory layout without it; plugin root is the parent of `skills/`, `agents/`, etc. (plugins-doc, agent-sdk-doc)
- **`SandboxNetworkConfig` clarified** — explicitly states these settings apply only to sandboxed Bash commands, not to the WebFetch tool (agent-sdk-doc)
- **Background session permission-mode/model/effort persistence documented** — model and effort mid-session changes persist through supervisor restart, not just permission mode (features-doc)

### Removed

- **LSP plugin `shutdownTimeout` and `restartOnCrash` fields removed** — these two optional fields are no longer documented in the plugin reference (plugins-doc)
- **Streaming limitation for extended thinking removed** — the incompatibility between `max_thinking_tokens` and `StreamEvent` messages is no longer listed (agent-sdk-doc)
- **Single message input "hook integration" limitation removed** — hooks are no longer listed as unavailable in single-message input mode (agent-sdk-doc)
- Minor wording/formatting updates across errors-doc, getting-started-doc, settings-doc docs

## 26.6.1

**35 references updated across 14 skills:** agent-sdk-doc, best-practices-doc, cli-doc, errors-doc, features-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **Skills-directory plugins auto-load** — any folder under `~/.claude/skills/` or `.claude/skills/` with a `.claude-plugin/plugin.json` manifest loads automatically as `<name>@skills-dir` with no marketplace or install step; project-scope plugins require workspace trust (plugins-doc, skills-doc)
- **`claude plugin init <name>`** — new command scaffolds a plugin in `~/.claude/skills/<name>/`; `--with` flag adds component folders (`skills`, `agents`, `hooks`, `mcp`, `lsp`, `output-style`, `channel`); alias `new`; can be blocked by `strictKnownMarketplaces` or `blockedMarketplaces` in managed settings (plugins-doc)
- **WebSocket MCP transport (`type: "ws"`)** — new `ws` transport for remote MCP servers needing persistent bidirectional connections; configure via `.mcp.json` or `claude mcp add-json`; accepts `url`, `headers`, `headersHelper`, `timeout`, `alwaysLoad`; not supported by `claude mcp add --transport` (mcp-doc)
- **`Workflow` tool in TypeScript SDK** — `WorkflowInput` and `WorkflowOutput` types added; `script`, `name`, `scriptPath`, `args`, `resumeFromRunId` fields; available in Agent SDK v0.3.149+; include `Workflow` in `allowedTools` to auto-approve (agent-sdk-doc)
- **Agent SDK hosting guide rewritten** — new sections on subprocess model, four session patterns (ephemeral, long-running, hybrid, multi-agent), production concerns (observability, auth, scaling, cost, multi-tenant isolation), and known limitations table; links to deployable hosting cookbook (agent-sdk-doc)
- **`workflowKeywordTriggerEnabled` setting** — set to `false` to stop the word "workflow" in a prompt from triggering a dynamic workflow; appears in `/config` as "Workflow keyword trigger"; unaffected: ultracode, `/workflows`, saved workflow commands (settings-doc)
- **`--agent` flag on `claude agents`** — sets the default subagent for dispatched sessions; falls back to `agent` setting, then built-in `claude` catch-all; naming a subagent in the dispatch input overrides it; requires v2.1.157 (cli-doc, features-doc, settings-doc)
- **`applyFlagSettings()` mid-session behavior documented** — keys applied on next turn: `model`, `effortLevel`, `ultracode`, `permissions`, `hooks`, `skillOverrides`, `fastMode`, `awaySummaryEnabled`; keys with no mid-session effect: `agent` and system prompt options (agent-sdk-doc)
- **`AskUserQuestionOutput.response` field** — freeform reply field set when user dismisses structured questions and types a general reply; Claude receives "The user responded: …" instead of per-question answers (agent-sdk-doc)
- **`tool_parameters` on `tool_decision` telemetry events** — when `OTEL_LOG_TOOL_DETAILS=1`, `tool_decision` events now include `tool_parameters` with Bash commands, MCP server/tool names, and skill names; useful for seeing which command was rejected (operations-doc)
- **`WorkspaceBash` tool parameters in telemetry** — `tool_decision` and `tool_result` events document `WorkspaceBash` parameters: `bash_command`, `full_command`, `timeout` (operations-doc)
- **Ops changelog v2.1.157–v2.1.159 and weekly digests** — weeks 21 and 22 ("What's New") reference pages added; changelog entries through v2.1.159 (operations-doc)
- **`/terminal-setup` sets GPU acceleration off** — now also sets `terminal.integrated.gpuAcceleration` to `"off"` in VS Code/Cursor/Windsurf to prevent garbled-text rendering; undo with `"auto"` (cli-doc)
- **Python SDK Windows pip setup instructions** — quickstart now includes Windows-specific venv activation (`py -m venv`, `.venv\Scripts\Activate.ps1`) and PowerShell execution-policy fix (agent-sdk-doc)
- **`.cargo` added to protected directories** — `.cargo` is now a protected directory in `acceptEdits` and `auto` modes; `bypassPermissions` also updated (settings-doc, sub-agents-doc)

### Changed

- **`effort.level` no longer reports `ultra`** — ultracode is no longer a distinct effort level; it reports as `xhigh` in `effort.level` (status line), `$CLAUDE_EFFORT` (env var), hooks `effort` field, and `${CLAUDE_EFFORT}` skill substitution (features-doc, hooks-doc, settings-doc, skills-doc)
- **`autoMemoryDirectory` scope widened** — now honored from project and local `settings.json` after accepting the workspace trust dialog, instead of being rejected from those scopes entirely (memory-doc, settings-doc)
- **`agent` setting also sets dispatched-session default** — the `agent` setting now sets the default subagent for sessions dispatched from `claude agents`, not just the main thread (settings-doc)
- **`EnterWorktree` can switch between Claude-managed worktrees** — from within a worktree or subagent with a pinned working directory, `EnterWorktree` accepts the `path` form to switch to another worktree under `.claude/worktrees/` (cli-doc, features-doc)
- **Worktree auto-cleanup scope broadened** — worktrees created for background sessions are now also swept by the `cleanupPeriodDays` cleanup, not just crash-orphaned subagent worktrees (features-doc)
- **`OTEL_LOG_TOOL_DETAILS` behavior clarified** — expanded into per-signal breakdown: `tool_result` gets `tool_parameters` + `tool_input`; `tool_decision` gets `tool_parameters`; `user_prompt` gets `command_name`; trace spans get `tool_input` with same truncation; `full_command` is emitted untruncated (operations-doc)
- **Task tool renamed to Agent tool in telemetry docs** — span hierarchy, `subagent_type` attribute, and security signal table updated to reference "Agent tool or legacy Task tool" (operations-doc)
- **MCP OAuth fallback behavior** — if `headers.Authorization` is configured and rejected by the server, Claude Code reports the connection as failed instead of falling back to OAuth (mcp-doc)
- **`CLAUDE_CODE_DISABLE_TERMINAL_TITLE` extended** — also skips the background Haiku request that generates session titles in Agent SDK and `claude -p` sessions (settings-doc)
- **Errors doc: corrupted-conversation fix for Opus 4.7/4.8** — new bullet advises running `claude update` before `/rewind` if using Opus 4.7 or 4.8 on versions before v2.1.156 (errors-doc)
- **Marketplace `name` field: one-per-name constraint documented** — adding a second marketplace with the same name replaces the first; list all plugins in one `marketplace.json` to share a name (plugins-doc)

### Removed

- Minor wording/formatting updates across best-practices-doc, ide-doc docs

## 26.5.29

**38 references updated across 16 skills:** best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **Dynamic workflows** — new feature and new reference page (`workflows.md`); ask Claude to create a workflow that orchestrates tens to hundreds of subagents in the background; run `/workflows` to track runs; added to agent parallelism comparison table alongside subagents, agent view, and agent teams (best-practices-doc, features-doc)
- **Opus 4.8 launch** — Claude Opus 4.8 is now available; defaults to high effort (`/effort xhigh` for maximum); fast mode on Opus 4.8 available at 2× standard rate for 2.5× speed; `claude-opus-4-8` is now the example full model ID in subagent docs; `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` deprecated, removal on 2026-06-01 (features-doc, sub-agents-doc, operations-doc)
- **`defaultEnabled: false` for plugins** — plugins can declare `defaultEnabled: false` in `plugin.json` or a marketplace entry; enable with `/plugin` or `claude plugin enable`; plugin dependencies of enabled plugins are still enabled automatically (plugins-doc)
- **`! <command>` in `claude agents`** — type `! <cmd>` in the agents dispatch input to run a shell command as a background session you can attach to and detach from; also available as `claude --bg --exec '<command>'` (cli-doc, features-doc)
- **MCP restrictions now cover subagent frontmatter servers** — `--strict-mcp-config`, `--bare`, enterprise managed MCP config, and `allowedMcpServers`/`deniedMcpServers` policies all apply to servers declared in subagent frontmatter as of v2.1.153; blocked servers surface a visible warning (sub-agents-doc, mcp-doc)
- **Tools unavailable to subagents documented** — explicit list added: `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, `WaitForMcpServers` are never available inside subagents even if listed in `tools` (sub-agents-doc)
- **Status line `COLUMNS`/`LINES` env vars** — status line commands now receive terminal dimensions as environment variables so scripts can size their output (features-doc, settings-doc)
- **`skipLfs` marketplace source option** — `github`/`git` plugin marketplace sources accept a new `skipLfs` flag to skip Git LFS downloads during clone and update (plugins-doc)
- **Plugin Discover tab contextual pinning** — the `/plugin` Discover tab now pins plugins whose relevance signals match the current directory with a "suggested for this directory" annotation (plugins-doc)
- **Chrome browser selection** — Claude in Chrome: pick which connected browser to use via `/chrome` → "Select browser…", or in-chat when a browser action runs with multiple browsers connected (ide-doc)
- **`claude doctor` last-update result** — `/doctor` now shows the result of your last update attempt (operations-doc)

### Changed

- **`/simplify` is now cleanup-only** — no longer runs the full bug-hunting review; now runs reuse, simplification, efficiency, and altitude cleanup only and applies the fixes (best-practices-doc, ci-cd-doc)
- **Lean system prompt now default** — lean system prompt is now default for all models except Haiku, Sonnet, and Opus 4.7 and earlier (features-doc, settings-doc)
- **`/model` saves selection as default** — selecting a model in the picker now saves it as the default for new sessions; press `s` to switch for the current session only; `modelPicker:setAsDefault` keybinding renamed to `modelPicker:thisSessionOnly` (cli-doc, features-doc)
- **Streaming tool execution always enabled** — no longer behind a feature flag; applies even when telemetry is disabled or on Bedrock/Vertex/Foundry (features-doc)
- **Subagent `isolation: worktree` base branch clarified** — isolated worktrees now branch from the default branch rather than the parent session's `HEAD` (sub-agents-doc)
- **Auto mode consent removed** — auto mode no longer requires opt-in consent (settings-doc)
- **`--strict-mcp-config` scope clarified** — does not filter servers passed inline via `--agents` or SDK `agents` option (sub-agents-doc)

### Removed

- Minor wording/formatting updates across cli-doc, cloud-providers-doc, errors-doc, getting-started-doc, hooks-doc, ide-doc, memory-doc, operations-doc, settings-doc, skills-doc docs

## 26.5.28

**37 references updated across 15 skills:** agent-sdk-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc

### New

- **`MessageDisplay` hook event** — new hook that fires while assistant message text streams to screen; return `displayContent` to replace the displayed text without affecting the transcript or what Claude sees; fires once per batch in interactive mode, once per full message in SDK/`-p` mode (hooks-doc, agent-sdk-doc, plugins-doc)
- **`disallowed-tools` skill frontmatter field** — skills can now declare tools to remove from Claude's available pool while the skill is active; restriction clears on the next user message (skills-doc)
- **`/reload-skills` command** — re-scans skill directories without restarting the session; `SessionStart` hooks can also trigger this via `reloadSkills: true` in hook output (cli-doc, hooks-doc)
- **`sessionTitle` in `SessionStart` hook output** — hooks can now set the session title on startup and resume via `hookSpecificOutput.sessionTitle`; the `session_title` input field lets hooks check the existing title before overwriting it (hooks-doc)
- **`reloadSkills` in `SessionStart` hook output** — when `true`, Claude Code re-scans skill directories after hooks complete so skills installed by the hook are available in the same session (hooks-doc)
- **`/code-review --fix` applies findings to working tree** — `/code-review --fix` now applies review findings after the review; `/simplify` now invokes `/code-review --fix`; `/code-review ultra --fix` runs ultrareview then applies findings (ci-cd-doc, cli-doc)
- **`/ultrareview` renamed to `/code-review ultra`** — `/ultrareview` remains as an alias; PR mode now supports GitHub Enterprise Server instances in addition to github.com (best-practices-doc, ci-cd-doc)
- **`security-guidance` plugin documented** — new official plugin that reviews each change Claude makes for common vulnerabilities and instructs Claude to fix them in the same session (plugins-doc, security-doc)
- **`CLAUDE_CODE_PROPAGATE_TRACEPARENT` env var** — opt-in flag to propagate W3C trace context through a custom `ANTHROPIC_BASE_URL` proxy; by default propagation is only enabled for direct Anthropic API connections (settings-doc, operations-doc)
- **`OTEL_METRICS_INCLUDE_ENTRYPOINT` env var and `app.entrypoint` metric attribute** — opt-in attribute recording how the session was launched (`cli`, `sdk-ts`, `sdk-py`, `claude-vscode`, etc.) (settings-doc, operations-doc)
- **`mcp_server.name` and `mcp_tool.name` OTel metric attributes** — new attribution attributes on cost counter, token counter, and related events tracking which MCP server and tool ran in the turn (operations-doc)
- **`failIfUnavailable` sandbox option** — new `SandboxSettings` field; TypeScript SDK defaults to `true` (fail at startup if sandbox unavailable), Python SDK defaults to `false` (run unsandboxed with warning); behavior on unavailability now documented for both SDKs (agent-sdk-doc)
- **`pluginSuggestionMarketplaces` managed setting** — allowlist of org marketplace names whose plugins can appear as contextual install suggestions (settings-doc)
- **`--scope` option on `claude plugin marketplace remove`** — restrict removal to a single settings scope; without the flag, the declaration is removed from all editable scopes (plugins-doc)
- **`traceparent` propagation to HTTP MCP requests** — outbound HTTP MCP requests now carry `traceparent` the same way model requests do (operations-doc)
- **Adversarial review step guidance** — new best-practices section recommending a subagent reviewer in a fresh context to check diffs against stated requirements before treating work as done (best-practices-doc)
- **"Review a diff locally" section in Code Review docs** — added standalone section documenting the `/code-review` command as a way to review without the GitHub App (ci-cd-doc)

### Changed

- **`--fallback-model` extended to retired models** — flag description updated to clarify it also activates when the primary model is not found (e.g., a retired model), not only when overloaded; and the session now switches to the fallback for the rest of the session (cli-doc, operations-doc)
- **`--include-hook-events` and `--include-partial-messages` now require `--verbose`** — examples in CLI reference updated to include `--verbose` alongside `--output-format stream-json` (cli-doc)
- **`--replay-user-messages` example updated with `--verbose`** — CLI reference example now includes `--verbose` flag (cli-doc)
- **`--output-format stream-json` examples updated with `--verbose`** — best-practices guide and headless docs updated to add `--verbose` to streaming examples (best-practices-doc, headless-doc)
- **`/logout` correction for cloud providers** — Bedrock, Vertex AI, and Foundry docs previously said `/login` and `/logout` were disabled; now correctly states only `/logout` is unavailable (cloud-providers-doc)
- **Agent view PR status indicator redesigned** — `●` dot replaced by `⧉ PR #N` label with `+N` suffix for multiple PRs; label persists when a follow-up is sent; color semantics preserved (features-doc)
- **CLAUDE.md import depth reduced** — maximum recursive import depth changed from five hops to four hops (memory-doc)
- **`SessionStart` input gains `session_title` and `agent_type` fields** — hook input now includes the current session title and agent name (hooks-doc)
- **Plugin init message now exposes `skills` list** — SDK init messages now include a `skills` field listing namespaced plugin skills alongside `slash_commands` (agent-sdk-doc)
- **Plugin description updated** — plugins now described as extending Claude Code with "skills, agents, hooks, and MCP servers" rather than "commands, agents, skills, and hooks" (agent-sdk-doc)
- **MCP scope precedence clarified** — when the same server appears in multiple scopes, the entire entry from the highest-precedence scope is used; fields are not merged across scopes (mcp-doc)
- **`/code-review` command description updated** — now mentions reuse/simplification/efficiency cleanups in addition to correctness bugs, and notes `--fix` and `ultra` options (cli-doc)

### Removed

- **Desktop changelog reference file deleted** — `skills/ide-doc/references/claude-code-desktop-changelog.md` removed from the ide-doc skill (ide-doc)

## 26.5.26

**22 references updated across 11 skills:** agent-sdk-doc, ci-cd-doc, cli-doc, features-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **Claude Security GHES support** — Claude Security added as a supported feature on GitHub Enterprise Server, available in public beta for Enterprise plans; enable it alongside Code Review from the admin settings page (ci-cd-doc)
- **`/usage` breakdown by skill, subagent, plugin, and MCP server** — Pro, Max, Team, and Enterprise subscribers now see a usage attribution breakdown in `/usage`; press `d` or `w` to switch between 24-hour and 7-day views (cli-doc, operations-doc)
- **Usage credits monthly spend limit via `/usage-credits`** — Pro and Max users can set a monthly cap on usage-credit spend; Claude Code prompts to raise or remove the limit if it's hit mid-session (operations-doc)
- **`allowAllClaudeAiMcps` managed setting** — new managed-only setting that loads claude.ai connectors alongside a deployed `managed-mcp.json` instead of suppressing them; requires Claude Code v2.1.149 or later (mcp-doc, settings-doc)
- **`CLAUDE_CODE_SYNC_SKILLS` and `CLAUDE_CODE_SYNC_SKILLS_WAIT_TIMEOUT_MS` env vars** — `CLAUDE_CODE_SYNC_SKILLS=1` downloads enabled claude.ai skills into `~/.claude/skills/` before the first query in non-interactive mode and resyncs every 10 minutes; set automatically in Claude Code on the web (settings-doc)
- **Diff viewer pager-style scroll keybindings** — the diff detail view now binds `Space`, `Shift+Space`, `B`, `PageUp`, `PageDown`, `G`, `Shift+G`, `Home`, `End` for scrolling; `diff:previousFile` and `diff:nextFile` also gained `K`/`J` aliases (cli-doc)
- **"How a skill gets its command name" section** — new reference table documents how the invocation name (what you type after `/`) is derived from file location vs. the `name` frontmatter field, with the plugin-root `SKILL.md` as the one exception (skills-doc)
- **Tools unavailable to subagents explicitly listed** — `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, and `WaitForMcpServers` are now documented as not available to subagents even when listed in `tools` (sub-agents-doc)
- **Effort level added to prompt cache key** — effort level is now part of the cache key alongside model; switching with `/effort` invalidates the cache and triggers a confirmation dialog; new "Changing effort level" section added (features-doc)
- **OTel headers helper error reporting** — errors from the headers helper script are now reported in `/doctor` output, the debug log, and stderr in non-interactive sessions (operations-doc)
- **`todos/`, `statsig/`, `logs/` legacy directories documented** — these are now listed in the auto-cleanup table as legacy directories no longer written by current versions; the cleanup sweep removes them once empty (memory-doc)

### Changed

- **`Ctrl+C` behavior in agent view clarified** — while attached to a session, `Ctrl+C` cancels a running response or shell command rather than detaching; pressing it twice on an empty prompt detaches (features-doc)
- **MCP reliability note replaced with reconnect tip** — removed "MCP connections can fail silently" warning; replaced with tip noting automatic reconnection for remote servers and a reference to the reconnection docs (features-doc)
- **`env` option replaces rather than merges with `process.env`** — `query()` `env` option now documented as replacing the subprocess environment entirely; users must spread `process.env` to preserve inherited variables like `PATH` (agent-sdk-doc)
- **`EnterWorktree`/`ExitWorktree` restriction scoped** — "not available to subagents" clarified to "not available to subagents that already run in their own working directory, such as with `isolation: worktree`" (cli-doc)
- **`additionalDirectories` settings key does not load configuration** — `permissions.additionalDirectories` in settings files grants file access only; the configuration exceptions (skills, subagents, etc.) apply only to `--add-dir` flag and `/add-dir` command (settings-doc, skills-doc)
- **Tool result OTel event semantics corrected** — `decision_type` on `claude_code.tool_result` is always `"accept"` since the event is not emitted for rejected calls; `"user_abort"` and `"user_reject"` sources cannot appear on this event (operations-doc)
- **`user_reject` decision source refined** — in interactive CLI, `user_reject` is emitted only for the user's "No" choice itself; calls matching a deny rule in personal settings emit `"config"` instead; Agent SDK and `-p` sessions emit `"user_reject"` for deny-rule matches (operations-doc)
- **Remote session title syncs from claude.ai rename** — renaming a session from claude.ai or the Claude app now also updates the local title shown in `claude --resume` (features-doc)
- **`/output-style` removal note added** — deprecated in v2.1.73 and removed in v2.1.91; docs now include a versioned note directing users to `/config` or the `outputStyle` setting (features-doc)
- **`name` frontmatter field description updated** — clarified that `name` sets the display label in skill listings, not the command name used to invoke the skill (skills-doc)

### Removed

- **MCP silent-failure reliability warning** — removed the caution that MCP connections can fail silently mid-session without warning, superseded by the automatic reconnection capability note (features-doc)
- **`todos/` as a standalone "kept until you delete them" entry** — moved from the persistent paths table into the auto-cleanup legacy directories row (memory-doc)

- Minor wording/formatting updates across features-doc (fast-mode dollar-sign escaping), plugins-doc (marketplace name correction)

## 26.5.25

**13 references updated across 8 skills:** agent-sdk-doc, ci-cd-doc, cli-doc, features-doc, getting-started-doc, operations-doc, security-doc, sub-agents-doc

### New

- **`/clear` command in Agent SDK** — `/clear` resets conversation context in streaming-input mode and is now documented as available in the SDK (requires v2.1.117+); one-shot `query()` callers should start a new query instead (agent-sdk-doc)
- **Shell aliases and functions in Bash tool** — Claude Code now sources `~/.zshrc`, `~/.bashrc`, or `~/.profile` at session start and applies captured aliases, functions, and shell options to every Bash command (cli-doc)
- **`/code-review` local command note in CI/CD docs** — added note that `/code-review` can review a diff locally in-terminal without installing the GitHub App; replaces the previous Plugins marketplace cross-reference (ci-cd-doc)

### Changed

- **`allowedTools` reframed as "auto-approve"** — documentation now consistently describes `allowedTools` as auto-approving tools to skip permission prompts, rather than simply "granting access"; applies to MCP tools, subagents, and SDK quickstart examples (agent-sdk-doc)
- **`slash_commands` list format changed** — SDK `init` message now returns bare command names (e.g., `["clear", "compact", "context"]`) instead of slash-prefixed strings (e.g., `["/compact", "/context"]`) (agent-sdk-doc)
- **Subagent `isolation: worktree` base branch clarified** — worktrees for subagents branch from the repository's default branch by default, not the parent session's `HEAD`; overridable with `worktree.baseRef: "head"` (features-doc, sub-agents-doc)
- **Sandbox git worktree write access documented** — sandbox now explicitly allows writes to the main repo's shared `.git` directory when the cwd is a linked worktree; `hooks/` and `config` inside remain denied (security-doc)

## 26.5.21

**15 references updated across 7 skills:** cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, operations-doc, plugins-doc, settings-doc

### New

- **`ScheduleWakeup` tool** — new built-in tool that reschedules the next iteration of a self-paced `/loop`; Claude calls it automatically at the end of each iteration; not available on Bedrock, Vertex, or Foundry (cli-doc)
- **`initialUserMessage` SessionStart hook field** — new JSON output field sets the first user message of a non-interactive session (`-p`); unlike `additionalContext`, this creates a new turn rather than attaching to an existing one (hooks-doc)
- **`watchPaths` SessionStart hook field** — new JSON output field accepts an array of absolute paths to watch for `FileChanged` events during the session (hooks-doc)
- **`suppressOriginalPrompt` UserPromptSubmit hook field** — when `true` alongside `decision: "block"`, omits the original prompt text from the block message shown to the user (hooks-doc)
- **`strictPluginOnlyCustomization` managed setting** — new managed-only setting that blocks skills, agents, hooks, and MCP servers from user and project sources; accepts `true` to lock all four surfaces or an array of surface names; requires v2.1.82+ (settings-doc)
- **`auto` permission mode** — added as a valid value for `setMode` in `PermissionRequest` hook `updatedPermissions` output (hooks-doc, settings-doc)
- **`SessionStart`, `Setup`, `SubagentStart` in decision control table** — these events now appear in the hook decision table with a `Context only` pattern; `SessionStart` also documents `initialUserMessage` and `watchPaths` as decision fields (hooks-doc)
- **`TeammateIdle` `continueOnBlock` support** — `ok: false` on `TeammateIdle` now supports `continueOnBlock: true` to feed the block reason back to the teammate instead of stopping it (hooks-doc)
- **`PermissionDenied` prompt/agent hook limitations documented** — clarified that prompt and agent hooks run on `PermissionDenied` but their output is discarded; only command hooks can return `retry` (hooks-doc)
- **`TeammateIdle` and `PermissionDenied` promoted to all-5-hook-types** — both events now support `command`, `http`, `mcp_tool`, `prompt`, and `agent` hook types (hooks-doc)

### Changed

- **`Esc`+`Esc` behavior updated** — double `Esc` now clears the prompt input draft when input contains text (saving it to history); opens the rewind menu only when input is empty (cli-doc, features-doc)
- **`Ctrl+C` behavior clarified** — first press clears prompt input when idle; second press exits Claude Code; still interrupts a running operation (cli-doc)
- **Exit 0 semantics in PreToolUse hooks** — exit 0 now explicitly documented as "no decision; normal permission flow applies" rather than "allow"; a hook staying silent does not approve the tool call (hooks-doc)
- **`suppressOutput` behavior corrected** — `true` hides the hook's stdout from the transcript; stdout still appears in the debug log (previously described as omitting from debug log) (hooks-doc)
- **`/desktop` requires Claude subscription** — command now documented as requiring macOS or Windows and an active Claude subscription; not available with API key auth or on Bedrock, Vertex, or Foundry (cli-doc, ide-doc)
- **Interrupt and steer behavior detailed** — `Esc` stops Claude immediately and cancels the running tool call; typing a correction and pressing `Enter` sends without stopping the current action; Claude reads it after the current step completes (getting-started-doc, ide-doc)
- **`/loop` built-in maintenance prompt availability** — docs now state the built-in prompt isn't available to everyone yet and not on Bedrock/Vertex/Foundry; `loop.md` follows the same availability (features-doc, cli-doc)
- **`claude plugin validate` scoping clarified** — pointed at a marketplace directory it validates `marketplace.json` only; pointed at a plugin directory it validates `plugin.json` plus skill/agent/command/hook files (plugins-doc)
- **`session_crons` source list updated** — Stop hook input `session_crons` now includes `ScheduleWakeup` as a source alongside `CronCreate` and `/loop` (hooks-doc)
- **`strictPluginOnlyCustomization` added to admin controls table** — new row for customization lockdown surface alongside existing permission and MCP controls (settings-doc)
- **`/simplify` renamed to `/code-review`** — command renamed with optional effort level argument (e.g. `/code-review high`) as of v2.1.146 (operations-doc)

## 26.5.20

**41 references updated across 11 skills:** agent-sdk-doc, cli-doc, cloud-providers-doc, features-doc, hooks-doc, mcp-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **Bun single-file executable support in TypeScript SDK** — `extractFromBunfs()` helper (v0.3.144+) extracts the bundled CLI binary at runtime inside `bun build --compile` outputs; `pathToClaudeCodeExecutable` option wires it in (agent-sdk-doc)
- **`model_not_found` error type** — new `SDKAssistantMessageError` variant when the selected model doesn't exist or isn't available to the account or deployment; also added to `StopFailure` hook matcher values (agent-sdk-doc, hooks-doc, cli-doc)
- **`SDKResultMessage` diagnostic fields** — `api_error_status`, `ttft_ms`, `terminal_reason`, and `fast_mode_state` added to the result message type; `terminal_reason` lists 11 named exit reasons (agent-sdk-doc)
- **`NonNullableUsage` gains cache breakdown and service fields** — `cache_creation` splits into `ephemeral_5m_input_tokens` / `ephemeral_1h_input_tokens`; new `server_tool_use`, `service_tier`, `speed`, `inference_geo`, and `iterations` fields added (agent-sdk-doc)
- **`background_tasks` and `session_crons` in Stop/SubagentStop hooks** — arrays added to Stop and SubagentStop hook inputs (v2.1.145+) so hooks can tell whether the session is done or waiting for background work (hooks-doc)
- **`/run`, `/verify`, `/run-skill-generator` bundled skills** — three new bundled skills (v2.1.145+) that launch and drive your app to confirm changes in the running process; `/run-skill-generator` records a per-project recipe at `.claude/skills/run-<name>/` (skills-doc, cli-doc)
- **Community marketplace** — `anthropics/claude-plugins-community` is a new public marketplace for third-party plugins; add with `/plugin marketplace add anthropics/claude-plugins-community` and install as `@claude-community` (plugins-doc)
- **`claude plugin validate --strict`** — flag added to treat unrecognized `plugin.json` fields as errors rather than warnings; useful in CI to catch misspelled or leftover fields before publishing (plugins-doc)
- **`plugin.json` unrecognized-field tolerance** — Claude Code now ignores unrecognized top-level fields and loads the plugin; one-off typos surface as warnings with a suggested fix; enables sharing a manifest with VS Code, npm, or DXT tooling (plugins-doc)
- **Settings live-reload documented** — settings files are now watched and most keys (permissions, hooks, `apiKeyHelper`) apply to the running session without restart; `model` and `outputStyle` still require restart or `/clear` (settings-doc)
- **Env vars page restructured with precedence section** — page now has Set/Precedence/Variables sections; precedence rules between env vars, settings fields, CLI flags, and in-session commands documented (settings-doc)
- **`hook_plugin_metrics` telemetry event** — new OTEL event emitted by official-marketplace plugin hooks with per-invocation metrics (finding rates, costs, durations); third-party and user hooks do not emit it (operations-doc)
- **W3C `traceparent` header on Anthropic API requests** — when tracing is active and connected directly to Anthropic API, each model request carries a `traceparent` header linking the client span to the server trace (operations-doc)
- **Week 20 digest entry** — agent view (`claude agents`), `/goal` command, Opus 4.7 fast mode default, and Rewind "Summarize up to here" highlighted (operations-doc)
- **`/schedule` "Unknown command" troubleshooting** — new FAQ section listing causes: API-key auth, telemetry-disabling env vars, web sessions, or CLI older than v2.1.81 (features-doc)
- **`WorktreeCreate` hook as git fallback** — worktree isolation now applies when no git repo is present if a `WorktreeCreate` hook is configured; non-git VCS users can hook into Claude's isolation (features-doc)
- **Session model persistence on resume** — resumed sessions keep the model they had when the transcript was saved; retired models fall through to precedence order (features-doc)
- **`/model` press `d` to save default** — picker now lets you press `d` to write the selected model to user settings as the new default for future sessions; `/model` itself is session-only as of v2.1.144 (features-doc, cli-doc)
- **`/resume` shows background sessions** — as of v2.1.144, background sessions appear in the `/resume` picker marked with `bg` (cli-doc)
- **`/feedback` gains `/share` alias** — `feedback` command description updated to include sharing conversation; `/share` listed as a new alias alongside `/bug` (cli-doc)
- **`SDKTaskProgressMessage` gains `subagent_type` and `summary`** — fields added; `summary` is populated when `agentProgressSummaries` is enabled (agent-sdk-doc)
- **Claude.ai connector auth requirement documented** — connectors load only when the active auth method is a Claude.ai subscription; troubleshooting steps added when `/mcp` doesn't list a connector (mcp-doc)
- **Agent view terminal tab title** — tab title now shows awaiting-input count while agent view is open (features-doc)
- **Agent view background session `--name` display** — session name from `--name` appears after the short ID in the backgrounded confirmation line (features-doc)
- **`/add-dir` directories carry through on background** — directories added mid-session with `/add-dir` persist when the session is backgrounded (features-doc)
- **Code intelligence listed in features overview** — LSP tool behavior (symbol navigation, live type errors) added to the extensions list (features-doc)

### Changed

- **`tools` / `disallowedTools` availability vs permission distinction clarified** — docs now distinguish availability (removes tool from context) vs permission (blocks call); bare-name deny rules change availability, scoped rules change permission only (agent-sdk-doc, settings-doc)
- **`outputStyle` option moved from top-level `Options` to inline `settings`** — TypeScript SDK docs corrected: `outputStyle` goes in the inline `settings` object passed to `query()`, not as a top-level `Options` field (agent-sdk-doc)
- **`Read` tool partial-file behavior updated** — whole-file reads that exceed the token limit now return the first page with a `PARTIAL view` notice instead of an error; explicit offset/limit reads that exceed the limit still return an error (cli-doc)
- **`cat`/`head`/`tail`/`sed` satisfy read-before-edit requirement** — `head` and `tail` added alongside `cat` and `sed -n` as Bash commands that count as a read; pipe and redirect exclusions still apply (cli-doc)
- **Bedrock prompt-caching note expanded** — note now advises checking Bedrock docs for supported models, regions, and limits when cache token counts stay at zero (cloud-providers-doc)
- **PR badge behavior updated** — badge disappears on merge/close instead of turning purple; status now refreshes immediately after `gh pr` or `git push` commands (cli-doc)
- **Delete session clarification** — deleting a session no longer removes the transcript; transcript remains available via `claude --resume` (features-doc)
- **`outputStyle` cache interaction documented** — output style changes now link to prompt-caching docs explaining what a style change does to the cached prefix (features-doc)
- **Deny rule behavior in permissions reference clarified** — bare tool name removes tool from context; scoped rule leaves tool available and blocks matching calls (settings-doc)
- **Channel allowlist and submission process updated** — default allowlist is `claude-plugins-official` (Anthropic-curated); in-app form submits to community marketplace, not official; official listing requires Anthropic partner contact (features-doc)
- **`outputStyle` Proactive description corrected** — described as "stronger autonomous-execution guidance" than auto mode rather than "applies the same guidance" (features-doc)
- **`outputStyle` description updated** — changes take effect after `/clear` or new session; references prompt caching docs for cache impact (features-doc)
- **Deny rule behavior clarified in `disallowedTools` docs** — allow rules affect only approval; bare-name deny rules change availability; scoped deny rules block calls but leave tool visible (agent-sdk-doc)

### Removed

- **Official marketplace submission process simplified** — submission form no longer described as adding plugins to the official marketplace; official marketplace is curated separately at Anthropic's discretion with no application process (plugins-doc)

## 26.5.19

**43 references updated across 14 skills:** agent-sdk-doc, best-practices-doc, ci-cd-doc, cli-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **`TodoWrite` disabled by default as of v2.1.142** — Task tools (`TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`) are now the default in all modes; set `CLAUDE_CODE_ENABLE_TASKS=0` to revert to `TodoWrite`; examples in todo-tracking docs updated with the override env var (agent-sdk-doc)
- **TypeScript Agent SDK V2 session API removed in 0.3.142** — `unstable_v2_createSession`, `unstable_v2_resumeSession`, `unstable_v2_prompt`, `SDKSession`, and `SDKSessionOptions` removed; page updated with migration guidance and a pin to `@0.2` for legacy code (agent-sdk-doc)
- **`EffortLevel` type added to Python SDK** — new exported literal type replaces inline `Literal["low", "medium", "high", "xhigh", "max"]` in `ClaudeAgentOptions` and `AgentDefinition`; `xhigh` documented as Opus 4.7-only with fallback (agent-sdk-doc)
- **`ThinkingConfig` gains `display` field** — optional `"summarized" | "omitted"` field on `ThinkingConfigAdaptive` and `ThinkingConfigEnabled`; needed to receive thinking content on Opus 4.7+, which omits it by default (agent-sdk-doc)
- **`TaskCreate` / `TaskUpdate` replace `TodoWrite` in orchestration tools table** — orchestration tool row updated from `TodoWrite` to `TaskCreate` and `TaskUpdate` (agent-sdk-doc)
- **`WaitForMcpServers` tool documented** — new built-in tool that waits for background-connecting MCP servers; only appears when tool search is disabled (cli-doc, mcp-doc)
- **MCP startup non-blocking by default as of v2.1.142** — `MCP_CONNECTION_NONBLOCKING` now defaults to non-blocking; set to `0` to restore the blocking 5-second wait; `alwaysLoad: true` servers still block regardless (mcp-doc, settings-doc)
- **`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` env var** — configures how many consecutive times a Stop/SubagentStop hook may block before the turn is forced to end (default: 8); set to `0` to disable the cap (settings-doc, hooks-doc)
- **`CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` env var** — stops Claude Code from passing `-ExecutionPolicy Bypass` when spawning PowerShell; respects machine execution policy instead (settings-doc)
- **`CLAUDE_ENABLE_BYTE_WATCHDOG_BEDROCK` env var** — enables a byte-level streaming idle watchdog on Bedrock `vnd.amazon.eventstream` responses, separate from the event-level watchdog (settings-doc)
- **`worktree.bgIsolation` settings key** — controls isolation mode for background sessions; `"worktree"` (default) blocks edits in main checkout until `EnterWorktree` is called; `"none"` allows direct edits; requires v2.1.143 (settings-doc)
- **`defaultMode: "auto"` blocked in project/local settings** — `auto` is now ignored when set in `.claude/settings.json` or `.claude/settings.local.json` to prevent repos from self-granting auto mode; must be set in `~/.claude/settings.json` (settings-doc)
- **`Read` deny rules block IDE selection context** — deny rules now also prevent selected text and open-file context from a connected VS Code or JetBrains IDE from reaching Claude (settings-doc, ide-doc)
- **`/usage-credits` command replaces `/extra-usage`** — renamed across CLI; old name still works as alias; `DISABLE_EXTRA_USAGE_COMMAND` env var description updated (cli-doc, settings-doc, errors-doc, features-doc, best-practices-doc, ci-cd-doc)
- **Fast mode now defaults to Opus 4.7 as of v2.1.142** — `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE` removed; use `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` to pin Opus 4.6; "Use fast mode on Opus 4.7" section removed from docs (features-doc, settings-doc)
- **`--fallback-model` CLI flag** — enables automatic fallback to a specified model when the default is overloaded; applies in `-p` mode and background sessions, ignored in interactive mode (cli-doc)
- **Plugin `displayName` field** — new optional `plugin.json` field for human-readable plugin names shown in UI; falls back to `name`; requires v2.1.143 (plugins-doc)
- **Single-file plugin layout** — a plugin with only a `SKILL.md` at its root is auto-loaded as a single-skill plugin in v2.1.142+; no `"skills": ["./"]` manifest entry needed (plugins-doc)
- **Plugin context cost shown in discover pane** — `/plugin` details pane now shows a **Context cost** token estimate before installation; requires v2.1.143 (plugins-doc)
- **Plugin dependency enable/disable enforcement** — enabling a plugin now also enables its dependencies transitively; disabling a plugin fails if another enabled plugin depends on it, with a suggested chained command; requires v2.1.143 (plugins-doc)
- **LSP servers listed in `claude plugin inspect`** — `inspect` output now includes an LSP servers group (plugins-doc)
- **`claude --agent <name>` unscoped lookup** — passing just an agent name now finds it across installed plugins; scoped form still required to disambiguate name conflicts (sub-agents-doc)
- **Subagent startup context documented** — new "What loads at startup" section details exactly what a non-fork subagent receives: system prompt, task message, CLAUDE.md/memory, git status, and preloaded skills; Explore and Plan omit CLAUDE.md and git status (sub-agents-doc)
- **`CLAUDE_CODE_SUBAGENT_MODEL` overrides per-invocation model** — env var now documented as overriding both the `model` parameter and the subagent definition's `model` frontmatter (features-doc)
- **Code Review "no issues" behavior updated** — when no issues are found, Code Review updates the GitHub check run status instead of always posting a comment (ci-cd-doc)
- **`Your organization has disabled Claude subscription access` error** — new error entry for orgs that block subscription login to Claude Code; includes `oauth_org_not_allowed` SDK error code (errors-doc)
- **`Usage policy refusal` error entry** — new error for requests that violate the usage policy with a distinct message (errors-doc)
- **`Request rejected (429)` message now names status page** — error message suffix updated to include `status.claude.com`; Bedrock/Vertex name their own status pages (errors-doc)
- **Claude Code v2.1.144 release notes** — new changelog entry covering `/resume` for background sessions, elapsed time in subagent notifications, `/model` per-session-only change, plugin last-updated display, and many bug fixes (operations-doc)
- **Desktop terminal-dialog commands unavailable note** — `/permissions`, `/config`, `/agents`, `/doctor` now documented as unavailable in the Desktop Code tab; workaround is to use settings files or the standalone CLI (ide-doc)
- **`claude agents` entry added to CLI reference table** — full description including `--cwd`, `--permission-mode`, `--model`, `--effort`, and passthrough flags (cli-doc)
- **`claude project purge` entry added to CLI reference** — documents all flags: `--dry-run`, `-y`, `-i`, `--all` (cli-doc)
- **`claude auth status --text` flag** — human-readable output mode added to `claude auth status` (cli-doc)
- **`claude auth login` flags documented** — `--email`, `--sso`, `--console` now listed in the CLI reference table (cli-doc)
- **Stop hook block cap documented** — "Stop hook runs forever" troubleshooting entry rewritten to explain the 8-consecutive-block cap and `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` override (hooks-doc)
- **Project trust re-prompt in home directory** — glossary and security docs updated: trust acceptance in the home directory is session-only and prompts again on each launch (getting-started-doc, plugins-doc)

### Changed

- **`CLAUDE_CODE_ENABLE_TASKS` behavior reversed** — env var now documented as `0` to revert to `TodoWrite` rather than `1` to opt in to Task tools (agent-sdk-doc, settings-doc, cli-doc)
- **`query()` Python SDK session description updated** — clarified that `query()` creates a new session "by default" and documents `continue_conversation`/`resume` options for reuse; "Continue Chat" row updated (agent-sdk-doc)
- **`ClaudeSDKClient` context manager wording softened** — "must be used as" changed to "typically used as" an async context manager (agent-sdk-doc)
- **`updatedMCPToolOutput` deprecated in favor of `updatedToolOutput`** — `PostToolUseHookSpecificOutput` field now marked deprecated with note that `updatedToolOutput` works for all tools (agent-sdk-doc)
- **`strictMcpConfig` description corrected** — now accurately says it ignores project `.mcp.json`, user settings, and plugin-provided MCP servers (agent-sdk-doc)
- **`allowManagedDomainsOnly` sandbox flag clarified** — documented as managed-settings-only; has no effect when set via SDK options (agent-sdk-doc)
- **`CLAUDE_CODE_SIMPLE` / `--bare` mode now skips OAuth** — bare mode also documented as skipping OAuth and keychain credential reads; API key or `apiKeyHelper` required (settings-doc)
- **`CLAUDE_ENABLE_STREAM_WATCHDOG` applies to Bedrock** — now documented as applying to all providers including Bedrock; independent byte-level watchdog `CLAUDE_ENABLE_BYTE_WATCHDOG_BEDROCK` can be used alongside it (settings-doc)
- **`showThinkingSummaries` clarified for non-interactive contexts** — setting now documented as having no effect in SDK or IDE extension contexts, not just `-p` mode (settings-doc)
- **`[1m]` model suffix behavior on Bedrock/Vertex** — clarified that the suffix is read per-variable and a model ID without it uses 200K context even if the same model has the suffix in another variable (features-doc)
- **`context: fork` skips CLAUDE.md for Explore/Plan agents** — documented that forked skills using the Explore or Plan agent type do not see CLAUDE.md (skills-doc, sub-agents-doc)
- **Status line Windows path handling documented** — Git Bash on Windows consumes unquoted backslashes; paths in `command` must use forward slashes (features-doc)
- **Voice dictation `space` binding note clarified** — `"space": null` is decorative; custom key replaces the default binding rather than adding a second trigger (features-doc)
- **`ENABLE_TOOL_SEARCH=true` Vertex AI note simplified** — removed the parenthetical listing of Vertex AI model names; wording tightened (settings-doc)

### Removed

- **`CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE` env var** — removed in v2.1.142; replaced by `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` for pinning Opus 4.6 (settings-doc, features-doc)

## 26.5.18

**18 references updated across 8 skills:** agent-sdk-doc, cloud-providers-doc, errors-doc, features-doc, mcp-doc, memory-doc, operations-doc, security-doc, settings-doc, skills-doc

### New

- **`feedback-bundles/` directory under `~/.claude/`** — `/feedback` on third-party providers now writes a redacted local archive here instead of sending data to Anthropic; documented in the `~/.claude/` runtime data table (memory-doc)
- **`/feedback` on third-party providers saves local archive** — on Bedrock, Vertex AI, Foundry, and other third-party providers, `/feedback` writes a redacted transcript bundle to `~/.claude/feedback-bundles/` for sharing with an Anthropic account representative (security-doc)
- **`/feedback` history scope selector** — before submitting feedback you now choose how much history to include: current session only (default), other sessions from same project over the last 24 hours, or 7 days (security-doc)
- **Foundry "Run Claude Code" step (step 5)** — new section documents starting Claude Code after setting Foundry environment variables, and clarifies there is no interactive setup wizard (cloud-providers-doc)
- **Bedrock and Vertex AI small/fast model now defaults to primary model** — background tasks (session title generation, etc.) use the primary model by default on Bedrock and Vertex AI; set `ANTHROPIC_DEFAULT_HAIKU_MODEL` to restore Haiku for background tasks (cloud-providers-doc)
- **Vertex AI tool search now supported for Sonnet 4.5+ and Opus 4.5+** — `ENABLE_TOOL_SEARCH=true` works on those models; earlier Vertex AI models still reject the beta header (cloud-providers-doc, mcp-doc, settings-doc, agent-sdk-doc)
- **Claude Code v2.1.143 release notes** — new entry added to the upstream changelog covering plugin dependency enforcement, `worktree.bgIsolation: "none"`, stop hook block cap, PowerShell defaulting on for cloud providers, and many background agent fixes (operations-doc)

### Changed

- **`effortLevel` settings value clarified** — documented accepted values (`low`, `medium`, `high`, `xhigh`) and that `max` is session-only and not valid in settings files (features-doc)
- **`ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` now conditional** — only takes effect on Bedrock when `ANTHROPIC_DEFAULT_HAIKU_MODEL` or the deprecated `ANTHROPIC_SMALL_FAST_MODEL` is also set (settings-doc)
- **`ENABLE_TOOL_SEARCH=true` behavior on Vertex AI updated** — requests fail only on Vertex AI models earlier than Sonnet 4.5 or Opus 4.5, not on all Vertex AI (settings-doc, mcp-doc, agent-sdk-doc)
- **`/feedback` unavailability wording** — references to "unavailable on your provider" changed to "unavailable in your environment" (errors-doc, operations-doc)
- **`/feedback` third-party behavior clarified** — now states the command saves a local archive rather than being simply unavailable on Bedrock, Vertex AI, and Foundry (errors-doc, operations-doc)
- **Agent SDK Python examples use `ClaudeAgentOptions` typed constructor** — plugin and options examples updated from raw dict to `ClaudeAgentOptions(...)` pattern; `SystemMessage` and `ToolUseBlock` now imported and used with `isinstance()` checks (agent-sdk-doc)
- **Agent SDK TypeScript `SDKUserMessage` type exported and used** — streaming examples import `SDKUserMessage`, use `parent_tool_use_id: null`, and drop `as const` casts; `session_id` field is now optional (agent-sdk-doc)
- **Result message checks now require `subtype === "success"`** — TypeScript SDK examples updated to guard `message.type === "result"` with `&& message.subtype === "success"` before reading `message.result` (agent-sdk-doc)
- **Dynamic context substitution single-pass clarified** — documented that substitution runs once and command output is not re-scanned for further placeholders (skills-doc)

## 26.5.15.1

### Fixed

- **`skills-doc` no longer fails to load** — the generated `SKILL.md` contained the literal dynamic-context-injection trigger tokens (the inline exclamation-mark-plus-backtick form and the multi-line three-backtick-plus-exclamation fence opener). The skill preprocessor scans raw text before markdown parsing, so code/fence wrapping did not shield them, and `/skills-doc` aborted with `Shell command failed for pattern`. Both trigger descriptions are now spelled out in words.

### Changed

- **`skill-md-conventions` rule 3 expanded** — now covers both injection trigger tokens and documents that inline-code/fenced backticks do not neutralize them, to prevent regeneration from reintroducing the leak.

## 26.5.15

**24 references updated across 14 skills:** agent-sdk-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, settings-doc, sub-agents-doc

### New

- **`includeHookEvents` query option (TypeScript SDK)** — new boolean flag surfaces hook lifecycle events in the message stream as `SDKHookStartedMessage`, `SDKHookProgressMessage`, and `SDKHookResponseMessage`; required to see `systemMessage` output from hooks (agent-sdk-doc)
- **Task tool types now exported from the TypeScript SDK** — `TaskCreateInput`, `TaskUpdateInput`, `TaskGetInput`, `TaskListInput` and their output counterparts are now in `ToolInputSchemas`/`ToolOutputSchemas` and no longer require local definitions (agent-sdk-doc)
- **`plugin_marketplaces` and `plugins` inputs for GitHub Actions** — `anthropics/claude-code-action@v1` now accepts plugin installation inputs; skill invocations via `/plugin-name:skill-name` are documented with a full code-review example (ci-cd-doc)
- **`claude agents --cwd <path>`** — scopes the agent view session list to one project directory; also documented in the CLI reference and agents command reference (cli-doc, features-doc)
- **`claude --bg --name <name>`** — sets the session's display name in agent view instead of the auto-generated title (features-doc)
- **`claude agents` flags for defaults: `--permission-mode`, `--model`, `--effort`** — requires v2.1.142; active defaults appear in the footer; `bypassPermissions`/`auto` still require prior interactive acceptance (features-doc)
- **`claude agents` configuration flags: `--settings`, `--add-dir`, `--plugin-dir`, `--mcp-config`, `--strict-mcp-config`** — all flags pass through to every dispatched session; new "Settings, plugins, and MCP servers" section documents the full table (features-doc)
- **Rewind "Summarize up to here"** — new rewind menu option compresses earlier context while keeping recent turns intact; documented separately from "Summarize from here" with a Restore vs. summarize comparison (features-doc)
- **Scheduled task `update_scheduled_task` MCP tool** — a running task can now modify its own schedule or prompt; delete confirmation now includes an "Also delete files on disk" checkbox (features-doc)
- **Remote Control toggle in Desktop Settings** — "Enable Remote Control for all sessions" can now also be toggled from Desktop app Settings → Claude Code (features-doc)
- **WSL PulseAudio fix for voice dictation** — new troubleshooting entry: WSL requires `sox libsox-fmt-pulse` because WSLg routes audio through PulseAudio, not an ALSA device (features-doc)
- **`/goal` version requirement note** — `/goal` requires Claude Code v2.1.139 or later; `/goal` now also documented as working in the desktop app (getting-started-doc)
- **`terminalSequence` hook output field** — hooks can emit allowlisted terminal escape sequences (desktop notifications, window titles, BEL) without a controlling terminal; restricted to OSC 0/1/2/9/99/777 and BEL; full example with `jq` and `printf`; requires v2.1.141 (hooks-doc)
- **Command hooks run without a controlling terminal as of v2.1.139** — documented explicitly; hooks cannot open `/dev/tty`; use `systemMessage` for user messages or `terminalSequence` for notifications (hooks-doc)
- **`Agent` tool `PostToolUse` response fields** — `tool_response` for a completed Agent call now carries usage telemetry: `status`, `agentId`, `content`, `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `usage` (hooks-doc)
- **`UserPromptSubmit` default timeout is 30 seconds** — shorter than the 600-second default for other events; set `timeout` in the hook entry to override (hooks-doc)
- **Desktop app OS notifications** — the Desktop app sends an OS notification when a Code session finishes and you aren't viewing that session (ide-doc)
- **Desktop terminal: open second tab** — click `+` in the terminal pane header or right-click a folder in chat to open a second terminal tab (ide-doc)
- **`managedMcpServers` managed settings key** — pushes MCP server configurations with optional `toolPolicy` maps to all users; available in third-party Desktop deployments only (ide-doc)
- **`DEBUG` env var** — set to `1` to enable debug mode; namespace patterns like `DEBUG=express:*` do not trigger it (settings-doc)
- **`CLAUDE_CODE_PLUGIN_PREFER_HTTPS` env var** — documented in env vars reference (settings-doc)
- **`ANTHROPIC_WORKSPACE_ID` env var** — documented in env vars reference (settings-doc)
- **Subagent subdirectory scanning** — `.claude/agents/` and `~/.claude/agents/` are now scanned recursively; plugin `agents/` subdirectories become part of the scoped identifier (e.g. `my-plugin:review:security`) (sub-agents-doc)
- **v2.1.142 upstream changelog entry** — covers new `claude agents` flags, Opus 4.7 fast mode default, plugin root-level SKILL.md support, and numerous bug fixes (operations-doc)

### Changed

- **`systemMessage` clarified: shown to user, not model** — updated across SDK hooks guide, Python SDK reference, TypeScript SDK reference, and hooks reference; use `additionalContext` to pass context to Claude (agent-sdk-doc, hooks-doc)
- **Checkpointing: checkpoint created per prompt, not per edit** — glossary and best-practices now say "each prompt you send" creates a checkpoint; clarified that Claude Code snapshots files before each edit so the checkpoint can restore them (best-practices-doc, getting-started-doc)
- **"Summarize from here" / "Summarize up to here" best-practices updated** — both options now documented with their respective behaviors (best-practices-doc)
- **Hook timeout defaults now vary by event and hook type** — guide and reference updated to show `UserPromptSubmit` lowers `command`/`http`/`mcp_tool` default to 30 s; `prompt` is 30 s; `agent` is 60 s (hooks-doc)
- **Async hook `systemMessage` behavior corrected** — `systemMessage` from async hooks is shown to the user, not delivered to Claude as context; code example updated to use `additionalContext` via `hookSpecificOutput` (hooks-doc)
- **`awsCredentialExport` trigger condition clarified** — runs at session start and on every credential reload, not only on expiry; separate from `awsAuthRefresh` which only runs on detected expiry (cloud-providers-doc)
- **MCP OAuth now triggers on `401` or `403`** — previously only `401 Unauthorized` flagged a server for OAuth; `403 Forbidden` now also triggers the `/mcp` authentication flow (mcp-doc)
- **`CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT` applies to all models** — previously documented as Opus 4.7 only; now applies to any model and accepts `0`/`false`/`no`/`off` to opt out (settings-doc)
- **`/status` setting sources output clarified** — explains the `Setting sources` line shows which layers are loaded, not which layer supplied each key; distinguishes the Config tab from `settings.json` contents (settings-doc)
- **`claude agents` piped-output behavior removed from sub-agents doc** — note about `claude agents | cat` listing subagents removed; feature no longer documented (sub-agents-doc)

### Removed

- **`claude agents` piped listing of subagents** — note that piping `claude agents` output lists configured subagents has been removed from sub-agents docs (sub-agents-doc)

## 26.5.14

**17 references updated across 9 skills:** agent-sdk-doc, best-practices-doc, cli-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc

### New

- **Agent SDK monthly credit starting June 15, 2026** — Agent SDK and `claude -p` usage on subscription plans will draw from a new monthly Agent SDK credit pool, separate from interactive usage limits; note now appears in agent-sdk-doc, headless-doc, getting-started-doc, and security-doc (agent-sdk-doc, headless-doc, getting-started-doc, security-doc)
- **`keep-coding-instructions` frontmatter key for output styles** — custom output styles can now set `keep-coding-instructions: true` to layer instructions on top of the built-in software engineering prompt instead of replacing it; code-reviewer example updated to use it (agent-sdk-doc, features-doc)
- **`ANTHROPIC_WORKSPACE_ID` env var** — scopes workload identity federation tokens to a specific workspace when the federation rule covers more than one (operations-doc)
- **`CLAUDE_CODE_PLUGIN_PREFER_HTTPS` env var** — clones GitHub plugin sources over HTTPS instead of SSH for environments without a GitHub SSH key (operations-doc)
- **`terminalSequence` field in hook JSON output** — hooks can emit desktop notifications, window titles, and bells without a controlling terminal (operations-doc, hooks-doc)
- **`claude agents --cwd <path>`** — scopes the session list to a specific directory (operations-doc)
- **`/feedback` can include recent sessions** — last 24 hours or 7 days of session data can be included for issues spanning multiple sessions (operations-doc)
- **Rewind "Summarize up to here"** — new rewind menu option compresses earlier context while keeping recent turns intact (operations-doc)
- **Note that some features require Claude.ai accounts** — admin setup doc now calls out that Claude Code on the web, Routines, Code Review, Remote Control, and the Chrome extension are unavailable through Console API keys or cloud-provider credentials alone (settings-doc)
- **v2.1.141 upstream changelog entry** — 60+ items including hook `terminalSequence`, `CLAUDE_CODE_PLUGIN_PREFER_HTTPS`, `ANTHROPIC_WORKSPACE_ID`, improved spinner feedback, and many bug fixes (operations-doc)

### Changed

- **Output styles doc overhauled** — creation workflow restructured as a step-by-step guide; "How output styles work" moved after the create section; comparison table replaces prose comparisons with CLAUDE.md, `--append-system-prompt`, agents, and skills; "Related resources" section added (features-doc)
- **Permission deny-rule precedence clarified** — settings and permissions docs now explain that deny rules from any scope block allow rules from any scope, not just that project overrides user (settings-doc)
- **Settings precedence examples updated** — scalar settings example now uses `spinnerTipsEnabled` and `permissions.defaultMode` instead of a permission rule to avoid confusion with array-merge behavior; summary updated to distinguish scalar override from array concatenation (settings-doc)
- **CLAUDE.md load order table reordered** — user instructions row now appears before project instructions row to reflect actual load order (managed → user → project → local) (memory-doc)
- **`disableAllHooks` scope clarification** — hooks configured in managed settings still run unless `disableAllHooks` is also set there; previously implied it was a global kill switch (hooks-doc)
- **`--plugin-dir` managed override expanded** — plugins that managed settings force-disable are now also documented as immune to `--plugin-dir` override (plugins-doc)
- **API provider choice note expanded** — provider comparison note now includes that the choice affects which Claude Code features developers can use (settings-doc)
- **Output styles customization level updated in comparison table** — "Replace default" changed to "Replace or extend default" in the system prompt customization comparison table (agent-sdk-doc)

### Removed

- **Opus 4.7 Agent SDK version note** — removed note requiring Agent SDK v0.2.111 or later for Opus 4.7 (agent-sdk-doc)
- **Migration Guide note from agent-sdk-doc overview** — note about SDK rename from "Claude Code SDK" to "Claude Agent SDK" and migration guide link removed (agent-sdk-doc)

## 26.5.13

**34 references updated across 10 skills:** agent-sdk-doc, agent-teams-doc, cli-doc, features-doc, getting-started-doc, headless-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc

### New

- **Fast mode on Opus 4.7** — fast mode now supports Opus 4.7 at the same 2.5x speed and $30/150 MTok pricing; opt in with `CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE=1`; Opus 4.7 becomes the default fast mode model on May 14, 2026; Opus 4.6 and 4.7 share the same rate limit pool; pin to 4.6 with `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` (features-doc, settings-doc)
- **`mcp-server-dev` plugin for scaffolding MCP servers** — new section replacing the dynamic server-listing component; directs to Anthropic Directory and describes using the official `mcp-server-dev` plugin to scaffold remote HTTP or stdio servers via `/mcp-server-dev:build-mcp-server` (mcp-doc)
- **`feedback_survey` OpenTelemetry event** — new OTEL event logged when a session quality survey appears or is answered; attributes include `event_type`, `appearance_id`, `survey_type`, `response`, and `enabled_via_override` (operations-doc)
- **`CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL` env var** — routes session quality survey ratings to an org's own OTEL collector instead of Anthropic when nonessential traffic is blocked; transcript sharing stays disabled (security-doc, settings-doc)
- **`CLAUDE_CODE_ENABLE_OPUS_4_7_FAST_MODE` env var** — opts fast mode into Opus 4.7 before the May 14 automatic default change (settings-doc)
- **`CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` env var** — pins fast mode to Opus 4.6 regardless of other fast mode model settings (settings-doc)
- **`CLAUDE_CODE_RESUME_PROMPT` env var** — overrides the continuation message injected when resuming a session that ended mid-turn; useful for spawn scripts in long-running agents (settings-doc)
- **`teammateDefaultModel` config setting** — default model for agent team teammates when the spawn prompt doesn't specify one; appears in `/config` as "Default teammate model"; set to `null` to inherit the lead's current model (agent-teams-doc, settings-doc)
- **AppArmor profile for bubblewrap on Ubuntu 24.04+** — new setup instructions to allow `bwrap` to create user namespaces blocked by Ubuntu 24.04's default AppArmor policy (security-doc)
- **Pull request status dot in agent view rows** — colored dot at the right edge of each row linked to the PR; dot color reflects PR state (yellow = waiting/failed, green = checks passed, purple = merged, grey = draft/closed) (features-doc)
- **`autoUpdate` field on `extraKnownMarketplaces` entries** — admins can set `"autoUpdate": true` on a marketplace entry in managed settings to enable auto-update for org marketplaces without per-user toggles (plugins-doc, settings-doc)
- **`--plugin-dir` accepts `.zip` archives** — the `--plugin-dir` flag now accepts a `.zip` archive of the plugin directory, requiring Claude Code v2.1.128 or later (plugins-doc)
- **Project skills load from parent directories** — skills now load from `.claude/skills/` in the starting directory and every parent up to the repo root; nested discovery for subdirectories below the starting dir remains unchanged (skills-doc)
- **`CLAUDE_CODE_ENABLE_TASKS` opt-in for non-interactive mode** — set to `1` to switch `-p` and Agent SDK sessions to the Task tools before `TodoWrite` is removed (cli-doc)
- **GitHub App access clarification for cloud sessions** — a cloud session can access any repo the connected GitHub account can see; App installation scopes PR webhooks for Auto-fix, not session-level access; auto-fix is now a per-PR toggle with a clear/stop flow (headless-doc)
- **`claude auth` exempt from `forceRemoteSettingsRefresh` exit** — `claude auth` subcommands bypass the fail-closed startup check so users can re-authenticate when expired credentials cause the settings fetch to fail (settings-doc)
- **Embedder managed settings via SDK `managedSettings` option** — embedding hosts can supply additional managed policy via the SDK `managedSettings` option when `parentSettingsBehavior` is set to `"merge"`; embedder values can tighten policy but not loosen it (settings-doc)
- **v2.1.140 upstream changelog entry** — case/separator-insensitive `subagent_type` matching, updated agent color palette, plugin folder-vs-manifest-key warning, plus eleven bug fixes (operations-doc)

### Changed

- **`TodoWrite` deprecation documented** — `TodoWrite` is now marked deprecated in favor of `TaskCreate`, `TaskGet`, `TaskList`, and `TaskUpdate`; interactive sessions already use Task tools; `TodoWrite` remains the default for `-p` and Agent SDK until `CLAUDE_CODE_ENABLE_TASKS=1` is set (cli-doc)
- **Agent view documentation expanded** — PR status table, `Ctrl+R` rename shortcut, session deletion behavior with worktree cleanup, `/exit` detach behavior in background sessions, and grouping logic (`Ready for review` vs `Completed`) all documented (features-doc, cli-doc)
- **`/goal` availability conditions expanded** — `/goal` is also blocked when `disableAllHooks` or `allowManagedHooksOnly` is set at any settings level, not only managed policy (getting-started-doc)
- **Agent SDK `settingSources` location table updated** — `"project"` source now documents that `settings.json` and hooks load only from `<cwd>/.claude/` with no parent-directory fallback; skills load up to repo root; `CLAUDE.local.md` loads from `<cwd>` and every parent (agent-sdk-doc)
- **Agent SDK system prompt page restructured** — page reorganized around a decision table for choosing between the `claude_code` preset, preset with `append`, and a custom string; Python examples updated to use `AssistantMessage` isinstance check (agent-sdk-doc)
- **`--exclude-dynamic-system-prompt-sections` description updated** — dynamic sections now listed as working directory, environment info, memory paths, and git-repo flag (replacing "git status") (cli-doc, agent-sdk-doc)
- **`--system-prompt` guidance expanded** — flag description now explains when to append vs. replace with guidance on output styles and CLAUDE.md for persistent use; links to Agent SDK system prompt decision guide (cli-doc)
- **MCP page removes dynamic server-listing component** — large JSX component replaced with static guidance pointing to the Anthropic Directory and `mcp-server-dev` plugin (mcp-doc)
- **Feedback survey disabled by `DO_NOT_TRACK`** — survey is now also suppressed when `DO_NOT_TRACK` is set, matching `DISABLE_TELEMETRY` behavior (security-doc, settings-doc)
- **`DISABLE_TELEMETRY` side-effect documented** — setting `DISABLE_TELEMETRY` also disables feature flags, which may affect features still rolling out (settings-doc)
- **Read-only Bash commands list expanded** — `echo`, `pwd`, `which` added to the built-in set of commands that run without a permission prompt (settings-doc)
- **`--add-dir` hooks and settings scope clarified** — hooks and other `settings.json` keys now documented as loading only from the current working directory's `.claude/` folder with no parent-directory fallback (settings-doc)
- **`worktree.sparsePaths` description updated** — clarifies that only listed directories plus root-level files are written to disk (settings-doc)
- **Sonnet 1M context requires extra usage** — clarified that Sonnet with 1M context is not included in the Max/Team/Enterprise automatic upgrade and requires extra usage on every plan (features-doc)
- **Routines MCP connector scope clarified** — connectors in routines are claude.ai integrations, not locally-added `claude mcp add` servers; guidance on adding local servers as connectors or via `.mcp.json` (features-doc)
- **Output styles vs CLAUDE.md guidance rewritten** — guidance now frames the choice around whether Claude should change identity vs. keep coding-assistant defaults (features-doc)
- **Worktree cleanup conditions updated** — "no changes" auto-removal now requires no uncommitted changes, no untracked files, and no new commits; named sessions prompt instead of auto-removing (features-doc)
- **Security page references Anthropic Directory** — MCP server trust guidance updated to note that Anthropic reviews Directory connectors against listing criteria but does not security-audit individual servers (security-doc)
- **Plugin manifest-vs-folder warning documented** — when a plugin has both a default folder and the matching manifest key, Claude Code v2.1.140 flags the ignored folder in `/doctor`, `claude plugin list`, and the `/plugin` detail view (plugins-doc)
- **`claude plugin uninstall/prune --yes` condition updated** — `-y, --yes` flag now documented as required when stdin or stdout is not a TTY, not just stdin (plugins-doc)

## 26.5.12

**43 references updated across 13 skills:** agent-sdk-doc, best-practices-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New

- **Agent view (`claude agents`)** — new TUI dashboard that lists every running, blocked, and finished background session; replaces the old subagent-listing behavior of `claude agents` (piping still lists subagents); `--bg` flag launches a session detached and returns immediately (cli-doc, sub-agents-doc, operations-doc)
- **`claude attach/logs/respawn/rm/stop` shell commands** — new shell-level commands for managing background sessions without opening agent view (cli-doc)
- **`/background` and `/goal` commands** — `/background` detaches the current session as a background agent; `/goal` sets a completion condition and Claude keeps working across turns until it is met (cli-doc, features-doc, hooks-doc)
- **`/scroll-speed` command** — interactive dialog to tune mouse wheel scroll speed with a live preview ruler; persists to `~/.claude/settings.json` (cli-doc, features-doc)
- **Hook exec form (`args` field)** — new `args: string[]` field on command hooks spawns the executable directly without a shell; path placeholders need no quoting; `${CLAUDE_PROJECT_DIR}` syntax replaces `"$CLAUDE_PROJECT_DIR"` in examples (hooks-doc)
- **Hook `continueOnBlock` for prompt hooks** — `PostToolUse` prompt hooks now accept `continueOnBlock: true` to feed rejection reason back to Claude and continue the turn instead of stopping (hooks-doc)
- **`ExitPlanMode` hook input fields** — `PreToolUse`/`PostToolUse` hooks on `ExitPlanMode` now receive `plan`, `planFilePath`, and `allowedPrompts` fields; `PostToolUse` `tool_response` carries the approved plan (hooks-doc)
- **`SubagentStop` `additionalContext` restriction documented** — `SubagentStop` hooks do not support `additionalContext`; returning `decision: "block"` with `reason` re-instructs the subagent; use `PostToolUse` on `Agent` to inject context into the parent (hooks-doc)
- **`/goal` as built-in Stop hook shortcut** — Stop hook reference now notes that `/goal` is a session-scoped prompt-based Stop hook that requires no hook configuration (hooks-doc)
- **Claude Platform on AWS provider** — new third-party provider documented across overview, quickstart, third-party integrations comparison table, LLM gateway, model config, and security data-usage pages; env vars `CLAUDE_CODE_USE_ANTHROPIC_AWS`, `ANTHROPIC_AWS_WORKSPACE_ID`, `ANTHROPIC_AWS_API_KEY`, `ANTHROPIC_AWS_BASE_URL`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` (agent-sdk-doc, cloud-providers-doc, settings-doc, security-doc)
- **LLM gateway agent ID headers** — `X-Claude-Code-Agent-Id` and `X-Claude-Code-Parent-Agent-Id` headers documented for attributing API cost to individual subagents/nested agents in a proxy (cloud-providers-doc)
- **Claude Platform on AWS through a gateway** — new LiteLLM gateway example for routing to Claude Platform on AWS via `ANTHROPIC_AWS_BASE_URL` and `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` (cloud-providers-doc)
- **`Proactive` output style** — new built-in output style that instructs Claude to execute immediately and minimize clarifying questions without changing permission mode; listed in glossary and output-styles reference (features-doc, getting-started-doc)
- **Notification hook event types `elicitation_response` and `elicitation_complete`** — two additional `Notification` event types added to the SDK hooks reference (agent-sdk-doc)
- **`CLAUDE_CODE_MAX_TURNS` env var** — caps agentic turns per session; equivalent to `--max-turns`; rejected at startup if not a positive integer (settings-doc)
- **`CLAUDE_CODE_DISABLE_AGENT_VIEW` env var and `disableAgentView` setting** — turn off agent view, `--bg`, `/background`, and the on-demand supervisor; can also be set via managed settings `disableAgentView` key (settings-doc)
- **`claudeMd` managed setting** — embed organization-wide CLAUDE.md instructions directly in `managed-settings.json` without deploying a separate file; honored in managed and policy settings only (settings-doc, memory-doc)
- **`remote-settings.json` in `~/.claude/`** — cached copy of server-managed settings; cleared by deleting the file and re-fetched on next launch (memory-doc)
- **`Turn` glossary entry** — defines a turn as one complete Claude response, notes that Stop hooks fire at turn end (getting-started-doc)
- **`CLAUDE_PROJECT_DIR` in MCP stdio server environment** — MCP stdio servers now receive `CLAUDE_PROJECT_DIR`; plugin configs can use `${CLAUDE_PROJECT_DIR}` in commands (mcp-doc, plugins-doc)
- **MCP server auth on custom servers** — any server that returns `401 Unauthorized` with `WWW-Authenticate` now gets the same `/mcp` auth flow as built-in remote servers (mcp-doc)
- **Tools reference expanded with per-tool behavior sections** — tools table now links to per-tool behavior sub-sections for Agent, Bash, Edit, Glob, Grep, LSP, Monitor, NotebookEdit, Read, WebFetch; full tool list including CronCreate/Delete/List, EnterPlanMode, ExitPlanMode, EnterWorktree, ExitWorktree, SendMessage, ShareOnboardingGuide, Skill, TaskCreate/Get/List/Stop/Update, TodoWrite, ToolSearch documented (cli-doc)
- **VS Code `Reopen Closed Session` shortcut** — `Cmd/Ctrl+Shift+T` reopens the last closed Claude session tab; falls through to VS Code's native reopen when the tab wasn't Claude; controlled by `enableReopenClosedSessionShortcut` setting (default `true`) (ide-doc)
- **v2.1.139 upstream changelog entry** — agent view, `/goal`, `/scroll-speed`, `claude plugin details`, exec-form hooks, `continueOnBlock`, `CLAUDE_PROJECT_DIR` in MCP stdio env, compaction preserves user instructions, `/mcp` Reconnect picks up `.mcp.json` edits (operations-doc)

### Changed

- **`ENABLE_TOOL_SEARCH=true` now fails on Vertex AI** — setting `true` forces the beta header even on unsupported backends; previously documented as an opt-in, now explicitly warned to cause Vertex AI request rejections (cloud-providers-doc, agent-sdk-doc, mcp-doc, settings-doc)
- **MCP tool search default behavior clarified** — unset defaults to deferred loading, with automatic fallback to upfront loading on Vertex AI or non-first-party `ANTHROPIC_BASE_URL`; `true` forces the header everywhere and will fail on unsupported backends (agent-sdk-doc, mcp-doc, settings-doc)
- **`permissionDecision: "defer"` available in both SDKs** — `"defer"` is no longer described as TypeScript-only; Python SDK docs updated; `updatedInput` note clarified: also requires `"ask"` or is ignored with `"defer"` (agent-sdk-doc)
- **Output style activation changed** — `/output-style` command removed; styles now activated via `/config` or by setting `outputStyle` in `.claude/settings.local.json`; creation is via Markdown file at `~/.claude/output-styles/` (agent-sdk-doc, features-doc)
- **`--model` flag and `ANTHROPIC_MODEL` not saved** — clarified that `--model` and `ANTHROPIC_MODEL` apply only to the launched session and are not persisted; use separate `--model` flags to run different models in parallel terminals (features-doc)
- **`BASH_MAX_OUTPUT_LENGTH` behavior updated** — large outputs now saved to a file and Claude receives the path plus a short preview, instead of being middle-truncated (settings-doc)
- **Read/Edit deny rules extended to recognized Bash file commands** — deny rules now also apply to `cat`, `head`, `tail`, and `sed` in Bash, not only to Claude's built-in file tools; does not cover arbitrary subprocesses (settings-doc)
- **Background subagent permission model clarified** — background subagents auto-deny any tool call that would prompt; pre-approval flow language removed; fork mode behavior re-aligned with this model (sub-agents-doc)
- **`claude agents` command repurposed** — now opens agent view TUI; `| cat` or piping prints subagent list (sub-agents-doc, cli-doc)
- **Custom subagent `name` field is `agent_type` in hooks** — clarified that `agent_type` in `SubagentStart`/`SubagentStop` hooks and `agent_type` in common hook fields use the frontmatter `name`, not the filename (hooks-doc, sub-agents-doc)
- **Hook deduplication includes `args`** — command hooks are now deduplicated by command string and `args`, not by command string alone (hooks-doc)
- **Hook shell form clarified** — shell form uses `sh -c` on macOS/Linux and Git Bash on Windows; JSON parse errors from profile echo explained as Git Bash/`BASH_ENV` sourcing rather than full shell sourcing (hooks-doc)
- **`$CLAUDE_PROJECT_DIR` syntax replaced with `${CLAUDE_PROJECT_DIR}`** — path placeholder syntax changed in all hook examples; exec form recommended for path placeholders to avoid quoting (hooks-doc)
- **`/background` and parallel session monitoring cross-references added** — best-practices-doc, sub-agents-doc, features-doc, and getting-started-doc now link to agent view where worktrees, parallel workflows, and background operation are discussed (best-practices-doc, getting-started-doc, sub-agents-doc, features-doc)
- **Channels non-interactive mode behavior** — tools requiring terminal input (multiple-choice, plan mode approval) disabled when channels run with `-p` (features-doc)
- **Channels notification delivery semantics documented** — notifications not acknowledged; queuing behavior and event-drop conditions explained; delivery confirmation pattern via reply tool described (features-doc)
- **`/loop` self-paced mode termination** — in self-paced mode Claude can end the loop by not scheduling the next wakeup once the task is provably complete (features-doc)
- **Scheduled tasks cross-reference to `/goal`** — note added that `/goal` keeps Claude working until a condition is met, contrasting with interval-based loop (features-doc)
- **Security data-usage table updated for Claude Platform on AWS** — telemetry and error reporting default off; session quality surveys default on; same opt-out env vars apply (security-doc)
- **Claude Platform on AWS listed in model alias resolution** — `opus` and `sonnet` aliases resolve to the same models as the Anthropic API (Opus 4.7 / Sonnet 4.6) on Claude Platform on AWS (features-doc)
- **`claude plugin details <name>` command** — new CLI subcommand to show a plugin's component inventory and projected per-session token cost (operations-doc)

## 26.5.11

**29 references updated across 13 skills:** agent-sdk-doc, agent-teams-doc, cli-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc

### New

- **`resolveSettings()` TypeScript SDK function** — inspects the effective merged settings for a directory without spawning the CLI; returns `effective`, `provenance`, and per-source `sources`; accepts `settingSources`, `managedSettings`, and `serverManagedSettings` options; alpha API (agent-sdk-doc)
- **`SDKPermissionDeniedMessage` stream event** — new `system`/`permission_denied` event emitted when the permission system auto-denies a tool call without a prompt; includes `tool_name`, `tool_use_id`, `agent_id`, `decision_reason_type`, and `decision_reason` fields; requires v2.1.136+ (agent-sdk-doc)
- **`autoMode.hard_deny` classifier rule tier** — new fourth tier that blocks unconditionally, ignoring user intent and `allow` exceptions; supported in `autoMode` settings and the `$defaults` splice; classifier precedence is now `hard_deny` → `soft_deny` → `allow` → user intent (settings-doc, operations-doc)
- **`policyHelper` setting** — admin-deployed executable that computes managed settings dynamically at startup; returns a JSON envelope with `managedSettings`, `claudeMd`, and `appendSystemPrompt`; only honored from MDM or system `managed-settings.json`; requires v2.1.136+ (settings-doc)
- **`sshHostAllowlist` managed setting for Desktop** — restricts SSH sessions to approved hostname patterns; `*` and `*.example.com` wildcards supported; empty array disables SSH; read from managed settings only (ide-doc, settings-doc)
- **`/radio` command** — opens Claude FM lo-fi radio in browser; prints stream URL when no browser available; not available on Bedrock, Vertex, or Foundry (cli-doc)
- **`/clear [name]` optional label argument** — pass a name to label the cleared session so it appears in the `/resume` picker (cli-doc)
- **`/context [all]` fullscreen expand flag** — in fullscreen mode the per-item breakdown is collapsed by default; pass `all` to expand it (cli-doc)
- **Routines organization-level admin toggle** — Team and Enterprise admins can disable routines for all members from the admin settings console (features-doc, errors-doc, operations-doc)
- **"Routines are disabled by your organization's policy" error** — new error entry and troubleshooting section; server-side setting, not overridable locally (errors-doc, operations-doc)
- **Auto mode classifier context-window and unparseable-response errors** — two new auto mode failure modes documented: classifier transcript exceeded context window (falls back to manual prompt in interactive mode, aborts in non-interactive) and classifier returned an unparseable response (retry usually succeeds) (errors-doc, operations-doc)
- **Combine results from multiple hooks section** — new doc section with JSON example explaining that all matching hooks run to completion before results are merged; deny does not short-circuit sibling hooks (hooks-doc)
- **`CLAUDE_CODE_NATIVE_CURSOR` env var** — shows the terminal's own cursor at the input caret instead of a drawn block (settings-doc)
- **`DO_NOT_TRACK` env var** — equivalent to `DISABLE_TELEMETRY`; honored as the standard cross-tool convention (settings-doc)
- **`maxSkillDescriptionChars` setting** — configures per-skill character cap on `description` + `when_to_use` text in the skill listing; default 1536; requires v2.1.105+ (settings-doc, skills-doc)
- **`skillListingBudgetFraction` setting** — fraction of context window reserved for skill listing; default 0.01; least-used skills are collapsed first when budget overflows; `/doctor` shows truncation count; requires v2.1.105+ (settings-doc, skills-doc)
- **v2.1.136 and v2.1.137/2.1.138 upstream changelog entries** — includes `hard_deny` auto mode rules, `CLAUDE_CODE_ENABLE_FEEDBACK_SURVEY_FOR_OTEL`, 50+ bug fixes, Windows VSCode activation fix, and internal fixes (operations-doc)
- **Week 18 and Week 19 what's-new entries** — Week 18: Windows without Git Bash, `claude ultrareview` in CI, `claude project purge`, PR URL in `/resume`; Week 19: plugins load from `.zip` archives and URLs, `worktree.baseRef`, auto mode hard deny, hooks see effort level (operations-doc)
- **npm upgrade guidance** — `npm install -g @anthropic-ai/claude-code@latest` is now documented as the correct upgrade command; `npm update -g` warned against due to semver range behavior (getting-started-doc)

### Changed

- **`autoMode` multi-source merge behavior updated** — developers can now extend `hard_deny` as well as `environment`, `allow`, and `soft_deny`; `allow` described as overriding only `soft_deny`, not `hard_deny` (settings-doc)
- **`--resume` now restores permission mode** — behavior changed from warning when modes differ to automatically restoring the mode from the prior session; `plan` and `bypassPermissions` are never carried over; explicit `--permission-mode` on resume overrides the restored value (hooks-doc)
- **Multi-select answers accept array format** — `answers` dict for `AskUserQuestion` now accepts `list[str]` in addition to comma-joined string; TypeScript type updated to `dict[str, str | list[str]]`; docs and examples updated to pass arrays (agent-sdk-doc)
- **HTTP transport alias `streamable-http` documented** — `.mcp.json`, `~/.claude.json`, and `claude mcp add-json` accept `streamable-http` as an alias for `http`; programmatic `mcpServers` option accepts only `"http"` (agent-sdk-doc, mcp-doc)
- **MCP note added to Agent SDK MCP page** — cross-reference to MCP installation scopes for adding servers to the CLI added as a Note at the top of the page (agent-sdk-doc)
- **Plugin `skills` field now additive** — specifying `skills` in `plugin.json` no longer replaces the default `skills/` directory; it now loads alongside it; docs for path behavior rules reorganized into a "replaces vs. adds" table (plugins-doc)
- **OTel permission `source` values clarified** — `config` source now documented to include session-scoped grants and personal allow rules; `user_permanent` and `user_temporary` now documented to emit differently in interactive CLI vs. Agent SDK/non-interactive sessions (operations-doc)
- **Prompt suggestions require Tab/arrow to accept** — changed from "press Tab/Right or Enter to accept" to "press Tab/Right to place in prompt input, then Enter to submit" (cli-doc)
- **`/schedule` description clarifies cloud infrastructure** — routines now described as executing on Anthropic-managed cloud infrastructure (cli-doc)
- **`claudeProcessWrapper` VS Code setting clarified** — now described as passing the bundled binary as an argument; use case for platform-missing builds documented (ide-doc)
- **`sshHostAllowlist` added to Desktop enterprise settings table** — new row in the managed settings reference table for the Desktop app (ide-doc)
- **Server-managed settings limitations updated** — new item: settings restricted to OS-level policy sources (`policyHelper`, `wslInheritsWindowsSettings`) are not honored via server-managed settings (settings-doc)
- **Trust verification exception for `--worktree`** — non-interactive `-p` mode disables trust verification, but `--worktree` still requires prior trust acceptance for the directory (security-doc)
- **tmux passthrough note generalized** — "iTerm2, Ghostty, or Kitty" replaced with "outer terminal" (cli-doc)
- **Deny rule anchor semantics table added** — new table illustrating how bare filenames, `**` patterns, and `//` absolute anchors determine the reach of deny rules (settings-doc)
- **Week 16 what's-new digest updated** — mobile push notifications promoted to a feature card, replacing `/ultrareview`; summary line updated to match (operations-doc)
- **Commands workflow orientation section added** — new "Commands across a typical workflow" section groups commands by session phase before the full table (cli-doc)

## 26.5.8

**35 references updated across 13 skills:** agent-sdk-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, sub-agents-doc

### New

- **`skills` option on `query()`** — new `skills` field (`"all"` | skill name list | `[]`) on TypeScript `QueryOptions` and Python `ClaudeAgentOptions`; SDK enables the Skill tool automatically when set; replaces the pattern of listing `"Skill"` in `allowedTools` (agent-sdk-doc)
- **`structuredContent` on custom tool results** — tool handlers can now return a `structuredContent` JSON object alongside `content`; TypeScript only; Python requires a standalone MCP server (agent-sdk-doc)
- **`ResultMessage` new fields** — `permission_denials`, `errors`, `api_error_status`, and `uuid` added to Python `ResultMessage`; `stop_reason` moved earlier in field order (agent-sdk-doc)
- **`effort` field in `BaseHookInput`** — hooks now receive `effort.level` in JSON input and `$CLAUDE_EFFORT` env var; reflects the active (possibly downgraded) effort level for the turn (hooks-doc, settings-doc, operations-doc)
- **`CLAUDE_EFFORT` env var** — set automatically in Bash tool subprocesses and hook commands to the active effort level; only present when the model supports the effort parameter (settings-doc)
- **`MCP_CONNECT_TIMEOUT_MS` env var** — controls how long the first query waits for MCP connections before snapshotting the tool list; default 5000 ms (settings-doc)
- **`gcpAuthRefresh` setting for Vertex AI** — runs a shell command to refresh GCP credentials when expired; browser-based flows supported; 3-minute timeout; project-settings require workspace trust (cloud-providers-doc)
- **`force-for-plugin` output style frontmatter** — plugin output styles can auto-apply when the plugin is enabled, overriding the user's `outputStyle` setting (features-doc)
- **Managed policy output style location** — output styles now supported at a third level: managed policy `.claude/output-styles` directory (features-doc)
- **`host_not_allowed` cloud session error** — new error entry and troubleshooting section for `403 x-deny-reason: host_not_allowed` in cloud or routine sessions (errors-doc, operations-doc)
- **Routines network access guide** — new step-by-step instructions for editing an environment's network access level from within a routine (features-doc)
- **`/debug [issue]` command** — new entry in the debug config command table; enables debug logging and prompts Claude to diagnose using log output and settings paths (operations-doc)
- **Test-against-clean-configuration section** — new doc section on isolating issues with `CLAUDE_CONFIG_DIR` pointing to an empty directory (operations-doc)
- **VS Code extension installs in Windsurf and Kiro** — documented that the extension works in VS Code forks via the Open VSX registry (ide-doc)
- **v2.1.133 upstream changelog entry** — includes `worktree.baseRef` setting, `sandbox.bwrapPath`/`socatPath`, `parentSettingsBehavior`, effort-in-hooks, and 10+ bug fixes (operations-doc)

### Changed

- **TypeScript SDK V2 session API deprecated** — `unstable_v2_createSession`, `unstable_v2_resumeSession`, and `unstable_v2_prompt` are deprecated and will be removed; use V1 `query()` instead; "preview" note removed from TypeScript SDK reference (agent-sdk-doc)
- **Subagent `skills` field semantics clarified** — `skills` now described as preloading content into context at startup; unlisted skills remain invocable through the Skill tool during execution (agent-sdk-doc, sub-agents-doc, features-doc)
- **`ANTHROPIC_VERTEX_PROJECT_ID` precedence documented** — overridden by `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or the project in `GOOGLE_APPLICATION_CREDENTIALS`; project ID resolution order fully described (cloud-providers-doc, settings-doc)
- **`--add-dir` now links to `permissions.additionalDirectories`** — description updated to note the setting can persist directories across sessions (cli-doc)
- **`--model` and `--verbose` flags link to settings** — descriptions now note that `--model` overrides the `model` setting and `ANTHROPIC_MODEL`, and `--verbose` overrides `viewMode` (cli-doc)
- **`--worktree` supports PR fetch** — pass `#<number>` or a GitHub PR URL to fetch that PR from `origin` and branch the worktree from it (cli-doc)
- **`--plugin-url` supports multiple URLs** — can now repeat the flag or pass space-separated URLs in a single quoted argument (cli-doc, plugins-doc)
- **`--no-session-persistence` documents `CLAUDE_CODE_SKIP_PROMPT_HISTORY`** — description now cross-references the env var that achieves the same effect in any mode (cli-doc)
- **`--teammate-mode` links to `teammateMode` setting** — description now notes the flag overrides the `teammateMode` setting (cli-doc)
- **`--effort` links to `effortLevel` setting** — description updated to note it overrides the `effortLevel` setting (cli-doc)
- **MCP URL hostname matching is case-insensitive** — clarified that hostname matching ignores case and trailing FQDN dots; paths remain case-sensitive (mcp-doc)
- **CLAUDE.md symlink documented** — `ln -s AGENTS.md CLAUDE.md` now documented as an alternative to `@AGENTS.md` import; Windows caveat noted; `/init` now reads `AGENTS.md` and other tool configs (memory-doc)
- **Hook advice added to CLAUDE.md troubleshooting** — guidance to use hooks instead of CLAUDE.md for instructions that must run at a specific lifecycle point (memory-doc)
- **`CLAUDE_CODE_ENABLE_FINE_GRAINED_TOOL_STREAMING` updated** — now on by default on Bedrock and Vertex per model; force-enable via `ANTHROPIC_BASE_URL`/`ANTHROPIC_VERTEX_BASE_URL`/`ANTHROPIC_BEDROCK_BASE_URL` for proxy routing (settings-doc)
- **`CLAUDE_CODE_DISABLE_AUTO_MEMORY` clarified** — `0` now described as forcing auto memory on even when `--bare` or `autoMemoryEnabled: false` would disable it (settings-doc)
- **`/doctor` improved** — pressing `f` after `/doctor` sends the diagnostic report to Claude for guided fixes (operations-doc)
- **MCP config troubleshooting row added** — new row for `mcpServers` in `settings.json` never appearing; correctly directs to `.mcp.json` (operations-doc)
- **`CLAUDE_CODE_REMOTE_SESSION_ID` URL prefix fix** — variable uses `cse_` prefix; transcript URL path uses `session_` prefix; sed substitution required when building the link (headless-doc)

- Minor wording/formatting updates across cloud-providers-doc (Experiment component removal), getting-started-doc (overview JSX removal), settings-doc (description cross-link additions)

## 26.5.7

**21 references updated across 9 skills:** agent-sdk-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, operations-doc, plugins-doc, settings-doc, skills-doc

### New

- **`strict_mcp_config` option** — new `ClaudeAgentOptions` field in Python SDK; ignores project `.mcp.json`, user settings, and plugin-provided MCP servers; maps to `--strict-mcp-config` (agent-sdk-doc)
- **`include_hook_events` option** — new `ClaudeAgentOptions` field in Python SDK; includes hook lifecycle events in the message stream as `HookEventMessage` objects (agent-sdk-doc)
- **`xhigh` effort level** — added `"xhigh"` to the `effort` literal type in Python and TypeScript SDKs and `AgentDefinition` (agent-sdk-doc)
- **`settings` option and `applyFlagSettings()` method** — TypeScript `query()` now accepts an inline settings object or file path; `applyFlagSettings()` merges settings into the flag layer at runtime mid-session (agent-sdk-doc)
- **API timeout and stall-detection env vars** — new "Handle slow or stalled API responses" section documenting `API_TIMEOUT_MS`, `CLAUDE_CODE_MAX_RETRIES`, `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS`, and `CLAUDE_ENABLE_STREAM_WATCHDOG` (agent-sdk-doc)
- **`ToolPermissionContext` expanded** — five new fields: `blocked_path`, `decision_reason`, `title`, `display_name`, `description`; `permissionDecision` now accepts `"defer"` (agent-sdk-doc)
- **`deferred_tool_use` on `ResultMessage`** — new optional field on `ResultMessage` (agent-sdk-doc)
- **`updatedToolOutput` in `PostToolUseHookSpecificOutput`** — new field to replace any tool output, not just MCP output (agent-sdk-doc)
- **`--plugin-url` flag** — fetch a plugin `.zip` from a URL for the current session; documented in CLI reference, headless bare mode, and plugins dev guide (cli-doc, headless-doc, plugins-doc)
- **JetBrains IDE scroll handling in fullscreen** — new section documenting custom scroll handling and automatic mitigation of 2025.2 scroll-wheel bugs (features-doc)
- **`CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` env var** — opt out of the fullscreen alternate-screen renderer; keeps conversation in native terminal scrollback (settings-doc)
- **`CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` env var** — stall watchdog for background subagents; default 10 minutes; aborts and surfaces partial result on timeout (settings-doc)
- **`CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` env var** — opt in to populating `/model` picker from gateway's `/v1/models` endpoint; was previously on by default (settings-doc)
- **`CLAUDE_CODE_FORCE_SYNC_OUTPUT` env var** — force-enable synchronized output for terminals that support it but fail auto-detection (e.g. Emacs `eat`) (settings-doc)
- **`CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` env var** — let Claude Code run the Homebrew or WinGet upgrade command in the background automatically (settings-doc)
- **`CLAUDE_CODE_SESSION_ID` env var** — set automatically in Bash/PowerShell tool subprocesses; matches the `session_id` passed to hooks (settings-doc)
- **`skillOverrides` setting** — per-skill visibility overrides (`"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`); writable from the `/skills` menu with `Space`; requires v2.1.129+ (settings-doc, skills-doc)
- **v2.1.131 and v2.1.132 upstream changelog entries** — 30+ fixes including `CLAUDE_CODE_SESSION_ID`, `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN`, JetBrains scroll fixes, Windows Terminal Shift+Enter, Alt+T fix on macOS (operations-doc)

### Changed

- **Gateway model discovery now opt-in** — `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` required to enable; was previously automatic when `ANTHROPIC_BASE_URL` pointed at an Anthropic-format gateway (cloud-providers-doc, settings-doc)
- **`context_window` token semantics changed** — `total_input_tokens` and `total_output_tokens` now reflect current context window usage (as of v2.1.132), not cumulative session totals; `current_usage` breaks them out by cache category (features-doc)
- **`themes` and `monitors` moved under `experimental` key** — plugin `plugin.json` manifest now uses `experimental.themes` and `experimental.monitors`; top-level keys still work but `claude plugin validate` will warn (plugins-doc)
- **`--settings` flag behavior clarified** — described as merging with file-based settings; keys set override lower layers, omitted keys keep their values; precedence section updated (cli-doc, settings-doc)
- **`CLAUDE_CODE_ENABLE_FINE_GRAINED_TOOL_STREAMING` behavior changed** — now on by default for direct Anthropic API connections; set to `0` to opt out or `1` to force-enable; no effect on Bedrock/Vertex/Foundry/gateway (settings-doc)
- **`/skills` menu gets Space-to-hide** — press `Space` to cycle skill visibility, `Enter` to save to `.claude/settings.local.json` (cli-doc)
- **Shift+Enter natively supported in Windows Terminal** — removed from the "not available" list; now documented as working without setup (cli-doc, features-doc)
- **`Option+T` (thinking toggle) works on macOS without Option as Meta** — fixed as of v2.1.132; terminal config note removed from model-config doc (cli-doc, features-doc)
- **Pull request counter expanded** — now counts PRs and MRs created via shell commands or MCP tools, not only via Claude Code directly (operations-doc)
- **`skillOverrides` referenced in skill budget and context docs** — tips for reducing context cost now mention setting skills to `"name-only"` via `skillOverrides` instead of editing SKILL.md (getting-started-doc, features-doc, skills-doc)
- **`CLAUDE_CODE_SCROLL_SPEED` ignored in JetBrains terminal** — note added that JetBrains IDE terminal uses its own scroll handling (settings-doc)

## 26.5.6

**50 references updated across 15 skills:** agent-sdk-doc, cli-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, skills-doc

### New

- **v2.1.129 upstream changelog entry** — 30+ fixes and features including `--plugin-url` flag, `CLAUDE_CODE_FORCE_SYNC_OUTPUT`, `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE`, `skillOverrides` fix, and many bug fixes (operations-doc)
- **`ShareOnboardingGuide` tool** — new built-in tool that uploads `ONBOARDING.md` and returns a shareable link; called from `/team-onboarding`; available on Pro, Max, Team, and Enterprise plans (cli-doc)
- **`session_store_flush` option** — new `ClaudeAgentOptions` field in Python SDK: `"batched"` (default, flush once per turn) or `"eager"` (background flush after every frame) (agent-sdk-doc)
- **`autoMemoryEnabled` setting** — new settings key to enable or disable auto memory; when `false`, Claude does not read from or write to the auto memory directory (settings-doc)
- **`disableRemoteControl` managed setting** — new setting (v2.1.128+) to disable Remote Control per device via MDM; blocks `claude remote-control`, the `--remote-control` flag, auto-start, and in-session toggle (settings-doc)
- **`pathPattern` marketplace allowlist source** — new `strictKnownMarketplaces` source type using regex against the filesystem path of `file` and `directory` sources; use `".*"` to allow all local paths (settings-doc, plugins-doc)
- **Piped stdin 10MB cap** — as of v2.1.128, piped stdin is capped at 10MB with a clear error; for larger inputs, write content to a file instead (headless-doc)
- **OTel SIEM audit guidance** — new "Audit security events" section covering user attribution, MCP activity auditing, security event-to-attribute mapping table, and sample managed-settings config for SIEM export (operations-doc)
- **SDK observability end-user attribution** — new section showing how to inject per-request end-user identity via `OTEL_RESOURCE_ATTRIBUTES` in `env` on `query()` calls (agent-sdk-doc)
- **`raw.githubusercontent.com` network requirement** — added to the network allowlist table; required for changelog feed and release notes shown after updating, plus plugin marketplace install counts (security-doc)
- **Web setup script 5-minute timing guidance** — new troubleshooting entry for sessions that hang during setup; recommends parallelizing installs with `&`/`wait` and moving heavy downloads to a SessionStart hook (headless-doc)
- **Split-pane Desktop sessions** — hold Cmd/Ctrl and click a session in the sidebar to open it alongside the current one; `Cmd+\` / `Ctrl+\` closes the focused pane (ide-doc)
- **Per-subagent `effort` override** — `effort` can now be set per subagent on `AgentDefinition` to override the session-level effort setting (agent-sdk-doc)
- **`/color` random color** — bare `/color` with no argument now picks a random session color; `/focus` now mentions `viewMode` setting for persisting the selection (cli-doc)
- **`Space` vim keybinding** — `Space` added as a move-right key in vim editing mode (cli-doc)
- **`/team-onboarding` share link** — for Pro, Max, Team, and Enterprise claude.ai subscribers, `/team-onboarding` now also returns a share link teammates can open directly in Claude Code (cli-doc)
- **`disableRemoteControl` fourth error cause** — added fourth cause for "Remote Control is disabled" error: `disableRemoteControl` managed setting applied per device (features-doc)
- **`alwaysLoad: true` blocks startup** — `alwaysLoad: true` MCP servers block startup even when `MCP_CONNECTION_NONBLOCKING=1` is set, since their tools must be present at first prompt (mcp-doc, settings-doc)
- **`workspace` MCP server name reserved** — the name `workspace` is reserved for internal use; Claude Code skips and warns if your config defines a server with that name (mcp-doc)

### Changed

- **Plan mode allows read-only tools** — `plan` permission mode now permits read-only tools (Read, Grep, etc.); Claude can explore the codebase but does not edit source files; updated across CLI, settings, and Agent SDK docs (cli-doc, settings-doc, agent-sdk-doc)
- **Channels enterprise controls expanded to Console API keys** — channels are now permitted by default for Console API key auth; `channelsEnabled` managed setting behavior documented per-plan; channels reference note updated to include Console API key auth (features-doc, settings-doc)
- **`PostToolUse` block behavior clarified** — `decision: "block"` in PostToolUse hooks adds the reason next to the tool result; Claude still sees the original output; use `updatedToolOutput` to replace it (hooks-doc)
- **mTLS OTLP configuration restructured** — `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY` and `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE` removed from main config table; replaced by a new mTLS section with protocol-specific variable tables for `http/protobuf` vs `grpc`; dynamic headers clarified as `http`-protocol-only (operations-doc)
- **Credential storage docs expanded** — Windows path now shown as `%USERPROFILE%\.claude\.credentials.json`; Linux and macOS storage documented separately with file mode details (getting-started-doc)
- **SDK hooks execute in parallel** — multiple `PreToolUse` hooks now run in parallel, not sequentially; most restrictive result wins; documentation and examples updated accordingly (agent-sdk-doc)
- **Telemetry service renamed from Statsig to Anthropic** — data-usage and env-vars docs updated to remove Statsig references; metrics now described as sent to Anthropic directly (security-doc, settings-doc)
- **`--plugin-dir` accepts `.zip` archives** — flag description updated to reflect zip archive support (cli-doc)
- **Status line script triggers** — script now also runs after `/compact` finishes; `context_window.current_usage` is null again after `/compact` until next API call (features-doc)
- **`acceptEdits` mode description clarified** — security docs now enumerate which Bash commands are auto-approved: `mkdir`, `touch`, `rm`, `mv`, `cp`, `sed` for paths in the working directory (security-doc)
- **Sandbox filesystem restrictions note** — clarified that filesystem restrictions combine `sandbox.filesystem` settings with Read/Edit deny rules (settings-doc)
- **Migration guide settings sources section revised** — warning converted to a note; SDK v0.1.0 behavior change described more neutrally; code examples simplified (agent-sdk-doc)
- **Mobile app navigation note** — Claude mobile app users now directed to tap "Code" in navigation to find Remote Control sessions (features-doc)
- **Scheduled task jitter expanded** — jitter cap raised to 30 minutes (or half the interval for sub-hourly tasks); previous 10%/15-minute cap removed (features-doc)
- **Fullscreen tmux caveat added** — new note that tmux does not support synchronized output, which can cause more flicker; suggests running outside tmux over SSH (features-doc)
- **Plugin `CLAUDE_PLUGIN_ROOT` update behavior** — documented that previous version's directory persists ~7 days post-update; hooks, MCP, and LSP servers keep old path until `/reload-plugins`; monitors require session restart (plugins-doc)
- **Plugin `CLAUDE.md` not loaded** — clarified that a `CLAUDE.md` at the plugin root is not loaded as project context; use skills instead (plugins-doc)
- **Plugin marketplace skill invocation updated** — walkthrough example now shows namespaced invocation `/quality-review-plugin:quality-review` and removes slash prefix from skill name in descriptions (plugins-doc)
- **`PermissionUpdate.suggestions` behavior documented** — Bash prompts include a `localSettings` suggestion; returning it in `updatedPermissions` writes the rule to `.claude/settings.local.json` (agent-sdk-doc)
- **Plugin settings precedence note** — new note clarifying project settings override user settings for plugins; use `.claude/settings.local.json` to opt out on your machine (settings-doc)
- **Skill body conciseness guidance** — new note that skill content stays in context across turns and should be kept concise (skills-doc)
- **`extraKnownMarketplaces` example corrected** — JSON example now wraps the source object correctly (settings-doc)
- **`strictKnownMarketplaces` `pathPattern` added** — `pathPattern` added alongside `hostPattern` as a regex-matching exception in the allowlist description (settings-doc)
- **Windows path note added to settings** — `~/.claude` paths resolve to `%USERPROFILE%\.claude` on Windows (settings-doc)

### Removed

- **`OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY` / `_CERTIFICATE` from main config table** — moved into new mTLS section as gRPC-specific variables (operations-doc)
- **Node.js CA store note removed** — note that system CA store requires native binary and not the Node.js runtime removed from network config (security-doc)

## 26.5.5

**10 references updated across 5 skills:** cli-doc, features-doc, hooks-doc, ide-doc, operations-doc, sub-agents-doc

### New

- **`suggestion` color token** — new theme override token controlling autocomplete suggestions and selection highlight in pickers (cli-doc)
- **Fullscreen message background tokens** — four new tokens: `userMessageBackgroundHover` (hovered/expanded message), `messageActionsBackground` (action bar open), `bashMessageBackgroundColor` (`!` shell entries), `memoryBackgroundColor` (`#` memory entries) (cli-doc)
- **Usage meter and speaker label tokens** — new section with `rate_limit_fill`, `rate_limit_empty` (usage meter bar), `briefLabelYou`, and `briefLabelClaude` (message speaker labels) (cli-doc)
- **`rainbow_<color>` gradient tokens** — seven-color rainbow gradient tokens (`rainbow_red` … `rainbow_violet` and their `_shimmer` variants) for `ultrathink`/`ultraplan` keyword rendering in the prompt input (cli-doc)
- **`Cmd+Esc` / macOS Tahoe Game Overlay fix documented** — new troubleshooting section: macOS Tahoe binds `Cmd+Esc` to the system Game Overlay by default, intercepting the VS Code shortcut; steps to clear it in System Settings or rebind in VS Code (ide-doc)
- **v2.1.128 upstream changelog entry** — 40+ fixes and features including `--plugin-dir` zip support, `--channels` console auth, `EnterWorktree` branch fix, and many more (operations-doc)
- **`--agents` Windows PowerShell syntax** — `--agents` flag docs now include a Windows PowerShell tab with here-string (`@' ... '@`) syntax alongside the existing macOS/Linux example (sub-agents-doc)
- **Windows hook script guidance for subagents** — notes added to the subagent hooks section and readonly-query example directing Windows users to write hooks in PowerShell with `shell: powershell` (sub-agents-doc)

### Changed

- **`ok: false` hook behavior now per-event** — `PreToolUse`: tool call is denied and reason returned to Claude as tool error; `PostToolUseFailure`, `TaskCreated`, `TaskCompleted`: reason returned as tool error; `PermissionRequest`: `ok: false` has no effect (use command hook `behavior: "deny"` instead); `PostToolUse`, `PostToolBatch`, `UserPromptSubmit`, `UserPromptExpansion`: turn ends with warning line (hooks-doc)
- **Shimmer variant list made explicit** — inline list of all shimmer-paired tokens (`claude`, `warning`, `permission`, `promptBorder`, `inactive`, `fastMode`) replaces the previous prose-only description (cli-doc)
- **`decision_source` / `source` field values fully documented** — the tool-decision event `source` field now has per-value explanations (`config`, `hook`, `user_permanent`, `user_temporary`, `user_abort`, `user_reject`) inline in the monitoring reference (operations-doc)
- **Context window impact row added to Skills vs Subagents table** — new row clarifies skills add to the main context window while subagents use a separate window with their own input/output tokens (features-doc)
- **`claude-code-guide` built-in subagent renamed** — display name changed from "Claude Code Guide" to `claude-code-guide` in the built-in subagents table (sub-agents-doc)
- **Subagent file reload behavior clarified** — files edited directly on disk require a session restart; subagents created via `/agents` take effect immediately (sub-agents-doc)
- **AVX troubleshooting section expanded** — VPS/VM users now get a diagnostic command (`grep -m1 -ow avx /proc/cpuinfo`) and an explicit note that hypervisor AVX pass-through must be enabled (operations-doc)

### Removed

- **`sessionTitle` `/rename` cross-reference** — brief parenthetical equating `sessionTitle` to `/rename` removed from hooks reference (hooks-doc)

## 26.5.4

**51 references updated across 16 skills:** agent-sdk-doc, agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **`SDKMessageOrigin` type** — new type tracking the provenance of user-role messages; values: `human`, `channel`, `peer`, `task-notification`, `coordinator`; appears as `origin` field on `SDKUserMessage`, `SDKUserMessageReplay`, and `SDKResultMessage`; use it to distinguish results triggered by your prompt from results emitted for background-task follow-ups (agent-sdk-doc)
- **`oauth_org_not_allowed` error category** — new error value added to `SDKAssistantMessageError`, the `error` field in `system/api_retry` events, `StopFailure` hook matcher, and the hooks reference; surfaces when OAuth login is blocked for the user's organization (agent-sdk-doc, headless-doc, hooks-doc)
- **LLM gateway model auto-discovery** — when `ANTHROPIC_BASE_URL` points at an Anthropic-compatible gateway, Claude Code v2.1.126+ queries the gateway's `/v1/models` endpoint at startup and adds discovered models to the `/model` picker, labeled "From gateway"; results are cached to `~/.claude/cache/gateway-models.json` (cloud-providers-doc, features-doc)
- **`claude project purge [path]` CLI command** — deletes all Claude Code state for a project: transcripts, tasks, file history, config entry; supports `--dry-run`, `-y/--yes`, `-i/--interactive`, and `--all`; added to CLI reference and `.claude/` directory docs (cli-doc, memory-doc)
- **Extended thinking dedicated section** — new `#extended-thinking` anchor on the model config page covers toggle controls, `showThinkingSummaries`, redacted thinking behavior, and token charging; replaces scattered `common-workflows` links across all docs (features-doc)
- **`ultrathink` keyword clarification** — `ultrathink` is the only recognized keyword for one-off deep reasoning; `think`, `think hard`, and similar phrases are passed through as plain text and are not recognized keywords (features-doc, skills-doc)
- **`historySearch:cycleScope` keybinding action** — new `Ctrl+S` binding cycles history search scope between session, project, and everywhere (cli-doc)
- **Notification hook matcher values documented** — table of matcher values for `Notification` hooks added to the hooks guide: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` (hooks-doc)
- **LLM hook `ok: false` behavior clarified** — for `Stop`/`SubagentStop`, an `ok: false` reason is fed back to Claude as its next instruction; for all other events, the turn ends and the reason appears as a warning line that Claude does not see (hooks-doc)
- **PowerShell permission rules** — new section documents PowerShell permission rule syntax: wildcard matching, alias canonicalization, case-insensitivity, and AST-level compound-command splitting (settings-doc)
- **`acceptEdits` PowerShell auto-approval** — when the PowerShell tool is enabled, `acceptEdits` mode auto-approves `Set-Content`, `Add-Content`, `Clear-Content`, and `Remove-Item` on in-scope paths (settings-doc)
- **Plan mode "Review and approve a plan" and "Set plan mode as default" sections** — `Ctrl+G` to edit plan in text editor documented; `showClearContextOnPlanAccept` setting described; plan-accepting auto-names the session; JSON snippet for `defaultMode: "plan"` added (settings-doc)
- **`CLAUDE_CODE_PROVIDER_MANAGED_BY_HOST` env var** — documented with full semantics: disables provider-selection and endpoint override from settings files, skips automatic telemetry opt-out for Bedrock/Vertex/Foundry (settings-doc)
- **`DISABLE_GROWTHBOOK` env var** — set to `1` to disable GrowthBook feature-flag fetching and use code defaults (settings-doc)
- **`invocation_trigger` attribute on `claude_code.skill_activated` OTel event** — values: `"user-slash"`, `"claude-proactive"`, or `"nested-skill"`; the event now also fires for user-typed `/` commands (operations-doc)
- **Headless pipe and build-script examples** — new "Pipe data through Claude" and "Add Claude to a build script" sections in headless docs with concrete stdin/stdout and `package.json` script patterns (headless-doc)
- **VS Code URI handler Linux and Windows examples** — `xdg-open` and `Start-Process`/`start ""` examples added alongside the existing macOS `open` snippet (ide-doc)
- **`autoMemoryDirectory` scope restrictions tightened** — now requires an absolute path or `~/`-prefixed path; accepted from policy settings, user settings, and `--settings` flag only; not accepted from project or local settings (memory-doc, settings-doc)
- **CLAUDE.md load order clarified** — content is ordered from filesystem root down to working directory; `foo/CLAUDE.md` appears before `foo/bar/CLAUDE.md` so instructions closer to the launch directory are read last (memory-doc)
- **Auto mode plan note** — note added clarifying auto mode is not available on Pro or on Bedrock/Vertex/Foundry (settings-doc)
- **v2.1.126 upstream changelog entry** — new release entry covering 30+ fixes and features (operations-doc)

### Changed

- **`bypassPermissions` mode now skips all protected-path prompts** — as of v2.1.126 writes to `.git`, `.claude`, `.vscode`, etc. no longer prompt; only catastrophic removals like `rm -rf /` still show a circuit-breaker prompt (settings-doc)
- **`Ctrl+L` behavior corrected** — no longer clears prompt input; it only forces a screen redraw while preserving input and conversation history; documentation updated across interactive mode, keybindings, and fullscreen docs (cli-doc, features-doc)
- **`preferredNotifChannel` setting surfaced** — terminal bell now documented as an option for non-Ghostty/Kitty/iTerm2 terminals via `preferredNotifChannel: "terminal_bell"`; VS Code integrated terminal explicitly mentioned as needing a hook or bell (cli-doc)
- **Windows PowerShell tool is now the primary shell** — when the PowerShell tool is enabled, Claude treats PowerShell as the primary shell; Bash tool remains available for POSIX scripts when Git Bash is installed (cli-doc)
- **"AWS Bedrock" renamed to "Amazon Bedrock"** — consistent renaming across ci-cd-doc, monitoring-usage, legal-and-compliance, zero-data-retention, and plugins reference (ci-cd-doc, operations-doc, security-doc)
- **Worktrees moved to dedicated `/en/worktrees` URL** — all references to `/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees` and related anchors updated to `/en/worktrees` across 10+ skills (agent-teams-doc, best-practices-doc, cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, memory-doc, settings-doc, sub-agents-doc)
- **Extended thinking links updated** — cross-skill links from `/en/common-workflows#use-extended-thinking-thinking-mode` updated to `/en/model-config#extended-thinking` (errors-doc, features-doc, ide-doc, operations-doc, settings-doc)
- **Plan mode links updated** — references from `/en/common-workflows#use-plan-mode-for-safe-code-analysis` updated to `/en/permission-modes#analyze-before-you-edit-with-plan-mode` (best-practices-doc, operations-doc, sub-agents-doc)
- **`subagent permissionMode` field note added** — now documented as ignored for plugin subagents; same for `mcpServers` and `hooks` fields (sub-agents-doc)
- **`CLAUDE_CODE_SHELL_PREFIX` scope expanded** — now documented as wrapping hook commands and stdio MCP server startup commands in addition to Bash tool calls (settings-doc)
- **`CLAUDE_STREAM_IDLE_TIMEOUT_MS` default unified** — both byte-level and event-level watchdogs now share the same 300,000 ms default and minimum (settings-doc)
- **`npm install -g` recommended over `npm update -g`** — plugins docs now recommend `npm install -g @anthropic-ai/claude-code@latest` for updating via npm (plugins-doc)
- **OAuth login failure guidance expanded** — troubleshooting section title broadened to "WSL2, SSH, or containers"; explains that the browser redirect can't reach the local callback server and instructs users to paste the login code (getting-started-doc, operations-doc)
- **Skill `allowed-tools` workspace trust note** — clarifies that `allowed-tools` in project skills takes effect only after accepting the workspace trust dialog (skills-doc)
- **Bundled skill example updated** — "Create your first skill" walkthrough replaced with a `summarize-changes` example using `git diff HEAD` dynamic context injection; `codebase-visualizer` example updated to use `python3` and `${CLAUDE_SKILL_DIR}` (skills-doc)
- **Common workflows page restructured** — page reorganized with new section headings and links; Plan Mode section removed and moved to `/en/permission-modes`; subagent workflow section removed (best-practices-doc)
- **`plugins/agents` manifest field now accepts an array** — example updated from a directory string to `["./custom/agents/reviewer.md"]` (plugins-doc)

## 26.4.30

**7 references updated across 5 skills:** agent-sdk-doc, best-practices-doc, operations-doc, security-doc, skills-doc

### New

- **`allowedDomains` and `deniedDomains` fields in `SandboxNetworkConfig`** — allow/deny domain lists for sandbox network filtering; `deniedDomains` takes precedence over `allowedDomains` (agent-sdk-doc)
- **`allowManagedDomainsOnly` field in `SandboxNetworkConfig`** — managed-settings-only flag that ignores `allowedDomains` from non-managed sources (agent-sdk-doc)
- **`allowMachLookup` field in `SandboxNetworkConfig`** — macOS-only list of XPC/Mach service names to allow, supports trailing wildcard (agent-sdk-doc)
- **Windows file-lock error troubleshooting section** — covers `The process cannot access the file ... because it is being used by another process`; fix is to delete `%USERPROFILE%\.claude\downloads` and rerun the installer (operations-doc)
- **Code Review integration note in ultrareview docs** — points to the Code Review product for automatic inline PR comments on GitHub without a CLI step (best-practices-doc)

### Changed

- **`SandboxNetworkConfig` TLS inspection warning** — new note clarifies the built-in proxy enforces `allowedDomains` by hostname only and does not inspect TLS, so domain fronting can bypass it; links to sandboxing security limitations and secure deployment docs (agent-sdk-doc)
- **Security limitations warning expanded** — domain fronting risk now explicitly documented with link to Wikipedia; guidance added to configure a TLS-terminating custom proxy as a mitigation; stronger TLS-aware isolation noted as an active development area (security-doc)
- **`name` field removed from SKILL.md frontmatter** — the directory name is now the slash-command; the `name` frontmatter key is no longer used or shown in the quickstart example (skills-doc)
- **fish and Nushell PATH note added** — troubleshooting guide now mentions that fish/Nushell users should add `~/.local/bin` to PATH using their shell's own syntax (operations-doc)
- **Windows install error routing table updated** — new row for the file-lock error added to the symptom quick-reference table (operations-doc)
- **"No TLS inspection" secure deployment limitation expanded** — now explicitly mentions domain fronting as a bypass vector and links to the TLS-terminating proxy configuration section (agent-sdk-doc)
- **`SandboxSettings` filesystem/network note removed from Python SDK** — note directing users to permission rules for filesystem/network access was removed from the `SandboxSettings` section (agent-sdk-doc)

## 26.4.29

**34 references updated across 13 skills:** agent-sdk-doc, best-practices-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc

### New

- **`Setup` hook event** — fires when you launch with `--init-only` or with `--init`/`--maintenance` in `-p` mode; matches on `init` or `maintenance`; supports `additionalContext` and `CLAUDE_ENV_FILE`; cannot block (hooks-doc, plugins-doc, agent-sdk-doc)
- **`additionalContext` field documented with full delivery semantics** — new dedicated section explains how context is wrapped and injected per event, stale-on-resume behavior, and formatting guidance for avoiding prompt-injection defenses (hooks-doc)
- **`updatedToolOutput` for PostToolUse hooks in Agent SDK** — `hookSpecificOutput` now accepts `updatedToolOutput` to replace tool output entirely before Claude sees it (agent-sdk-doc)
- **Agent SDK vs Managed Agents comparison tab** — new tab in the SDK overview compares infrastructure ownership, interface, session state, and use cases; suggests prototyping with SDK then moving to Managed Agents for production (agent-sdk-doc)
- **`ANTHROPIC_BEDROCK_SERVICE_TIER` env var** — selects Bedrock service tier (`default`, `flex`, `priority`); sent as `X-Amzn-Bedrock-Service-Tier` header; full section added to Bedrock docs (cloud-providers-doc, settings-doc)
- **`CLAUDE_CODE_ATTRIBUTION_HEADER` env var** — set to `0` to omit the system-prompt attribution block prepended by Claude Code; improves prompt-cache hit rates when routing through an LLM gateway (settings-doc)
- **`CLAUDE_CODE_DISABLE_POLICY_SKILLS` env var** — set to `1` to skip loading skills from the system-wide managed skills directory; useful in CI/container sessions (settings-doc)
- **`CLAUDE_CODE_EXTRA_BODY` env var** — merges a JSON object into every API request body; useful for provider-specific parameters (settings-doc)
- **`CLAUDE_CODE_MCP_ALLOWLIST_ENV` env var** — spawns stdio MCP servers with only a safe baseline environment plus their configured `env`, rather than inheriting the full shell environment (settings-doc)
- **`CLAUDE_CODE_USE_NATIVE_FILE_SEARCH` env var** — uses Node.js file APIs instead of ripgrep for discovering custom commands, subagents, and output styles (settings-doc)
- **`claude_code.at_mention` OTel event** — logged when Claude Code resolves an `@`-mention; includes `mention_type` and `success` attributes (operations-doc)
- **LLM gateway attribution block note** — documents that Claude Code prepends a version/fingerprint block to the system prompt; Anthropic API strips it before processing; gateway operators can disable it with `CLAUDE_CODE_ATTRIBUTION_HEADER=0` (cloud-providers-doc)
- **`elicitation_complete` and `elicitation_response` notification matchers** — two new Notification hook matcher values added for MCP elicitation lifecycle events (hooks-doc, best-practices-doc)
- **WSL1 sandboxing limitation and WSL2 Windows-binary restriction** — documented that WSL1 lacks namespace primitives for sandboxing, and sandboxed WSL2 commands cannot invoke Windows binaries under `/mnt/c/` (security-doc)
- **JetBrains WSL2 firewall fix steps** — full step-by-step instructions for Windows Firewall rule and mirrored-networking alternatives moved from troubleshooting into the JetBrains IDE page (ide-doc)
- **`chat:clearScreen` keybinding action** — new `Cmd+K` binding in fullscreen rendering that double-presses to run `/clear` (cli-doc)
- **Caps Lock added to non-rebindable keys** — Caps Lock is not delivered to terminal applications and is now listed in the hardcoded shortcuts table (cli-doc, memory-doc)
- **Fullscreen "clear the conversation" section** — `Ctrl+L` double-press (and `Cmd+K` on macOS) runs `/clear`; documented in new fullscreen section (features-doc)
- **Private plugin repository note** — plugins.md now mentions hosting a marketplace in a private repository to keep a plugin internal to a team (plugins-doc)
- **MCP duplicate-server visibility** — `/mcp` now shows claude.ai connectors hidden by a same-URL manually-added server, with a hint to remove the duplicate (mcp-doc)
- **v2.1.122 and v2.1.123 upstream changelog entries** — two new release entries added (operations-doc)
- **Troubleshooting page refactored into symptom-routing table** — installation/auth content moved to a new `/en/troubleshoot-install` page; remaining page covers performance, stability, and search only (operations-doc)

### Changed

- **`--init` and `--maintenance` flags clarified as print-mode-only** — docs now specify both flags only fire Setup hooks when combined with `-p`; interactive-mode behavior unchanged (cli-doc)
- **PowerShell tool auto-enables on Windows without Git Bash** — tool is now enabled automatically when Git Bash is absent; rolling-out behavior limited to Windows installs that have Git Bash (cli-doc, settings-doc, getting-started-doc, features-doc)
- **`SubagentStart` agent type renamed** — built-in agent name changed from `"Bash"` to `"general-purpose"` in matcher examples and input docs (hooks-doc)
- **Exit code 2 clarified: non-blockable events** — docs now explain that `SessionStart`, `Setup`, `Notification`, and similar events show stderr but continue regardless of exit 2; link to per-event table added (hooks-doc)
- **Notification hooks no longer accept `additionalContext`** — Notification hooks are now described as side-effect-only; `additionalContext` field removed from their output table (hooks-doc)
- **`/heapdump` writes to home directory on Linux without Desktop** — behavior on Linux systems without `~/Desktop` now documented (cli-doc, operations-doc)
- **OTel `status_code` changed from string to number** — `api_error` and `api_retries_exhausted` events now emit `status_code` as a number, absent for non-HTTP errors (operations-doc)
- **`CLAUDE_ENV_FILE` updated to include `Setup` hooks** — env var description now lists Setup alongside SessionStart, CwdChanged, and FileChanged as hooks that populate this variable (settings-doc)
- **Ultrareview billing: early-exit run still counts** — clarified that a run counts once the remote session starts; a paid review only bills for the portion that ran (best-practices-doc)
- **`/resume` picker search accepts PR URLs** — pasting a GitHub, GitHub Enterprise, GitLab, or Bitbucket PR URL into the search box finds the session that created it (best-practices-doc, cli-doc)
- **iTerm2 clipboard note updated** — running `/terminal-setup` in iTerm2 now enables the clipboard access permission automatically (features-doc)
- **`CLAUDE_CODE_USE_POWERSHELL_TOOL` description updated** — entry now reflects that on Windows without Git Bash the tool auto-enables, and the opt-in/opt-out behavior only applies when Git Bash is present (settings-doc)
- **Troubleshoot links updated from `/en/troubleshooting` to `/en/troubleshoot-install`** — auth, login, and installation links across errors-doc, getting-started-doc, settings-doc, and ide-doc updated to point to the new dedicated page (errors-doc, getting-started-doc, settings-doc, ide-doc)
- **Windows status line docs updated** — clarified that on Windows without Git Bash, commands run through PowerShell; "Git Bash only" caveat added to Bash script example (features-doc)
- **SDK plugin loading requires `type: "local"`** — docs now state `"local"` is the only accepted value for `type`; guidance added for marketplace plugins (agent-sdk-doc)

## 26.4.28

**35 references updated across 15 skills:** agent-sdk-doc, best-practices-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New

- **`claude ultrareview [target]` subcommand** — runs `/ultrareview` non-interactively from CI or scripts; blocks until done, prints findings to stdout, exits 0 on success or 1 on failure; `--json` and `--timeout` flags available (best-practices-doc, cli-doc)
- **`claude plugin prune` command** — removes auto-installed plugin dependencies that no installed plugin requires; supports `--dry-run`, `-y`, `--scope`; `--prune` flag also added to `claude plugin uninstall` (plugins-doc)
- **`updatedToolOutput` field in PostToolUse hooks** — replaces tool output for all built-in and MCP tools before Claude sees it; `updatedMCPToolOutput` is now deprecated in favor of this field (hooks-doc, agent-sdk-doc)
- **`alwaysLoad` MCP server config option** — set to `true` to skip tool-search deferral for a server; individual tools can also opt in via `"anthropic/alwaysLoad": true` in their `_meta` object; requires v2.1.121 (mcp-doc)
- **`hideVimModeIndicator` statusline field** — suppresses the built-in `-- INSERT --` text when a custom script renders `vim.mode` itself (features-doc)
- **`${CLAUDE_EFFORT}` skill placeholder** — expands to the current effort level (`low`, `medium`, `high`, `xhigh`, or `max`) so skills can adapt instructions to the active setting (skills-doc)
- **`bedrock:GetInferenceProfile` IAM permission** — lets Claude Code resolve application inference profile ARNs to backing models; without it Claude Code retries with the alternate shape, adding a round-trip (cloud-providers-doc)
- **X.509 certificate-based Workload Identity Federation for Vertex AI** — supported via Application Default Credentials in v2.1.121 or later; set `GOOGLE_APPLICATION_CREDENTIALS` to the credential config file (cloud-providers-doc)
- **MCP initial connection auto-retry** — HTTP/SSE servers that hit transient errors at startup are retried up to 3 times before being marked failed; auth and not-found errors are not retried (mcp-doc)
- **`stop_reason` and `gen_ai.response.finish_reasons` OTel attributes** — added to `claude_code.llm_request` spans on the LLM request span table (operations-doc)
- **`user_system_prompt` OTel attribute** — emitted once per session on the LLM request span, gated behind `OTEL_LOG_USER_PROMPTS=1`; carries the system prompt from `--system-prompt`/`--append-system-prompt`, truncated at 60 KB (operations-doc)
- **Organization IP allowlist constraint for cloud sessions** — documented that cloud sessions, Code Review, and Routines call the API from Anthropic infrastructure, causing auth failures when org IP allowlisting is enabled (headless-doc)
- **Dev container page fully rewritten** — now covers the Claude Code Dev Container Feature, persistent auth volumes, organization policy enforcement, network egress restrictions, and running without permission prompts; replaces the old reference-only overview (security-doc)
- **Session transcript upload follow-up** — after the session quality rating prompt, users may see an optional "Can Anthropic look at your session transcript?" step; upload details, retention period, and org opt-out conditions documented (security-doc)
- **v2.1.120 and v2.1.121 upstream changelog entries** — two new release entries added to the operations changelog reference (operations-doc)
- **Week 16 and Week 17 "What's New" digest entries** — two new weekly digest summaries added to the whats-new index (operations-doc)

### Changed

- **`!` prefix renamed from "Bash mode" to "Shell mode"** — all references in the interactive mode docs updated to reflect the more accurate name (cli-doc)
- **Git for Windows downgraded from required to recommended on Windows** — docs now say PowerShell is used as a fallback shell when Git Bash is absent; `--dangerously-skip-permissions` note in tools reference and setup comparison table updated accordingly (cli-doc, getting-started-doc)
- **`CLAUDE_CODE_FORK_SUBAGENT` now works in SDK and `claude -p`** — previously documented as interactive-only; forked subagents are no longer limited to interactive sessions (settings-doc, sub-agents-doc)
- **`CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT` scoped to Opus 4.7** — description updated: the shorter system prompt and abbreviated tool descriptions now apply only when using Opus 4.7; no effect on other models (settings-doc)
- **Server-managed settings bypass now enumerates all third-party provider vars** — lists `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_MANTLE`, `CLAUDE_CODE_USE_VERTEX`, `CLAUDE_CODE_USE_FOUNDRY`, and `ANTHROPIC_BASE_URL` explicitly instead of just the base URL (settings-doc)
- **`/terminal-setup` enables iTerm2 clipboard access** — now configures "Applications in terminal may access clipboard" in iTerm2 settings, enabling `/copy` to write to the system clipboard even from inside tmux (cli-doc, features-doc)
- **Mouse capture bypass modifier documented** — holding `Option` in iTerm2 or `Shift` on Linux/Windows lets you make native terminal selections without disabling mouse capture (features-doc)
- **Voice dictation in VS Code uses `accessibility.voice.speechLanguage` as fallback** — when the Claude Code `language` setting is empty, the VS Code extension now checks VS Code's speech language setting before defaulting to English (features-doc)
- **Windows shell error message updated in troubleshooting** — error string changed from `Claude Code on Windows requires git-bash` to `Claude Code on Windows requires either Git for Windows (for bash) or PowerShell`; troubleshooting section updated to match (operations-doc)
- **Marketplace manifest top-level fields restructured** — `description` and `version` promoted to top level (with `metadata.*` kept for backward compatibility); `$schema` field added to both `plugin.json` and `marketplace.json` manifests (plugins-doc)
- **Network config adds telemetry note** — brief callout added pointing to the data-usage page for optional telemetry domains and how to disable them before finalizing an allowlist (security-doc)
- **HackerOne vulnerability report URL updated** — both security.md and legal-and-compliance.md now point to the new embedded submission URL (security-doc)

### Removed

- **Windows "Git Bash required" limitation removed from PowerShell tool docs** — the bullet stating Git Bash is still required to start Claude Code on Windows was removed from the known limitations list (cli-doc)
- **Homebrew workaround suggestions removed from troubleshooting** — "try Homebrew" was removed as an alternative for both the `Illegal instruction` and `dyld: cannot load` errors; docs now clarify Homebrew downloads the same binary and won't resolve architecture or macOS version issues (operations-doc)

## 26.4.27

**22 references updated across 11 skills:** agent-sdk-doc, agent-teams-doc, cli-doc, cloud-providers-doc, features-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc

### New

- **`aliases` field on `SlashCommand` type** — optional string array for slash command aliases in the TypeScript SDK (agent-sdk-doc)
- **Color token reference for custom themes** — full list of named override tokens grouped by category (text/accent, status, input/mode, diff, fullscreen, shimmer/subagent colors) added to terminal configuration docs (cli-doc)
- **`effort.level` and `thinking.enabled` statusline fields** — statusline JSON now includes current reasoning effort level and whether extended thinking is enabled; `effort` only present when the model supports the effort parameter (features-doc)
- **`autoScrollEnabled`, `editorMode`, `showTurnDuration`, `terminalProgressBarEnabled` moved to `settings.json`** — these four keys are now documented as `settings.json` settings rather than `~/.claude.json` global config; old location still works on versions before v2.1.119 (settings-doc)
- **`teammateMode` and `prUrlTemplate` added to `settings.json` available settings** — both keys previously undocumented or changelog-only are now in the main settings table (settings-doc)
- **`CLAUDE_CODE_HIDE_CWD` env var** — set to `1` to hide the working directory in the startup logo; useful for screenshares (settings-doc)
- **`tool_use_id` and `tool_input_size_bytes` OTel fields** — tool execution and permission decision events now include `tool_use_id` (for correlating with hook data) and `tool_input_size_bytes` (operations-doc)
- **Routines Permissions tab** — "Allow unrestricted branch pushes" moved from the repository selection step to a new Permissions tab; Connectors tab behavior clarified (features-doc)
- **Desktop Cowork tab** — Desktop app now described as having three tabs: Chat, Cowork (for Dispatch and longer agentic work), and Code (ide-doc)

### Changed

- **`--from-pr` accepts GitLab and Bitbucket URLs** — flag now accepts GitHub PR URLs, GitHub Enterprise PR URLs, GitLab MR URLs, and Bitbucket PR URLs in addition to PR numbers (cli-doc)
- **`/claude-api` skill gains `migrate` and `managed-agents-onboard` subcommands** — `migrate` scans files and updates model IDs/parameters to a target version; `managed-agents-onboard` walks through creating a new Managed Agent (cli-doc)
- **MCP tool search disabled by default on Vertex AI** — `ENABLE_TOOL_SEARCH` table and `ENABLE_TOOL_SEARCH` env var description updated to reflect Vertex AI as a second disabled-by-default case alongside non-first-party `ANTHROPIC_BASE_URL` (cloud-providers-doc, mcp-doc, settings-doc)
- **Auto mode drops `PowerShell(*)` blanket allow rules** — entering auto mode now strips `PowerShell(*)` wildcards alongside the existing `Bash(*)` rules (settings-doc)
- **Desktop scheduled tasks UI renamed to Routines** — "Schedule" page → "Routines"; "New local task" → "Local"; field "Prompt" → "Instructions"; "Frequency" → "Schedule"; skipped run hover now shows reason (features-doc)
- **SSH sessions auto-install Claude Code on remote machine** — Desktop installs Claude Code on the remote machine automatically the first time you connect; no manual pre-installation required (ide-doc)
- **Plugin auto-update fetches highest satisfying tag** — constrained dependencies now receive updates within their allowed range (highest matching git tag) rather than being skipped entirely when the marketplace moves to a newer version (plugins-doc)
- **`PostToolUse` and `PostToolUseFailure` `duration_ms` field documented with table** — field description table added alongside the existing JSON example in the hooks reference (hooks-doc)
- **`duration_ms` added to SDK hook input types** — `PostToolUseHookInput` and `PostToolUseFailureHookInput` gain optional `duration_ms?: number` (agent-sdk-doc)
- **`~/.claude.json` description updated** — "preferences" removed from description; affected keys are now documented in `settings.json` (settings-doc)
- **Desktop preview pane supports video files** — video paths open in the preview pane alongside HTML, PDF, and image files (ide-doc)
- **`--allowedTools`/`--disallowedTools` Desktop CLI comparison updated** — noted that permission rules in settings files still apply even without a per-session equivalent (ide-doc)
- **Desktop managed settings deployment clarified** — managed settings on disk apply to Desktop; remote console settings reach CLI and IDE only (ide-doc)

### Removed

- **Windows `cmd /c` MCP workaround removed** — the `cmd /c npx` wrapper requirement for Windows native MCP servers is no longer documented (mcp-doc)

## 26.4.24

**42 references updated across 13 skills:** agent-sdk-doc, agent-teams-doc, best-practices-doc, cli-doc, cloud-providers-doc, errors-doc, features-doc, getting-started-doc, hooks-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New

- **`PostToolBatch` hook event** — fires once after a full batch of parallel tool calls resolves, before the next model call; supports all five hook types; can block the agentic loop via `decision: "block"`; TypeScript-only in the SDK (hooks-doc, agent-sdk-doc, plugins-doc)
- **`mcp_tool` hook type** — call a tool on an already-connected MCP server as a hook handler; `server`, `tool`, and `input` fields with `${path}` substitution; available on all events except those that only support `command` (hooks-doc, agent-sdk-doc, plugins-doc)
- **Forked subagents (`CLAUDE_CODE_FORK_SUBAGENT`)** — a fork inherits the full conversation context from the main session; `/fork` spawns a fork when enabled; panel UI with `↑/↓/Enter/x/Esc` controls for observing and steering running forks; fork mode runs all subagents in the background; experimental, v2.1.117+ (sub-agents-doc, settings-doc)
- **`ENABLE_PROMPT_CACHING_1H` env var** — request a 1-hour prompt cache TTL instead of the default 5-minute TTL on API key, Bedrock, Vertex AI, and Foundry; billed at a higher rate; documented with examples in SDK cost-tracking guide (agent-sdk-doc, cloud-providers-doc, settings-doc)
- **`DISABLE_UPDATES` env var** — blocks all update paths including manual `claude update` and `claude install`; stricter than `DISABLE_AUTOUPDATER` (settings-doc, getting-started-doc)
- **`CLAUDE_CODE_FORK_SUBAGENT` env var** — enables forked subagents and changes `/fork` behavior; interactive mode only (settings-doc)
- **`CLAUDE_CODE_HIDE_CWD` env var** — hides the working directory in the startup logo (operations-doc changelog)
- **`wslInheritsWindowsSettings` managed setting** — WSL reads managed settings from the Windows policy chain when set in HKLM registry or `C:\Program Files\ClaudeCode\managed-settings.json`; Windows admin required (settings-doc)
- **Custom themes (`~/.claude/themes/`)** — JSON files with `name`, `base`, and `overrides` fields; hot-reloaded on change; listed in `/theme` alongside built-in presets; selectable interactively via **New custom theme…**; plugins can ship themes in a `themes/` directory (cli-doc, memory-doc, plugins-doc)
- **`claude install [version]` CLI command** — install or reinstall the native binary; accepts a version string, `stable`, or `latest` (cli-doc)
- **`claude plugin tag` CLI command** — create a release git tag for the plugin in the current directory; `--push`, `--dry-run`, `--force` options; validates manifest and requires clean working tree (plugins-doc)
- **One-off schedule triggers for routines** — schedule a routine to fire once at a specific future time; auto-disables after firing; exempt from the daily run cap; create via `/schedule` with natural-language time descriptions (features-doc)
- **`$defaults` placeholder in `autoMode` arrays** — include `"$defaults"` in `environment`, `allow`, or `soft_deny` to splice in the built-in rules at that position instead of replacing them (settings-doc)
- **`prUrlTemplate` setting** — point the footer PR badge at a custom code-review URL (operations-doc changelog)
- **Vim visual mode** — `v` (character-wise) and `V` (line-wise) selection in the prompt input; operators `d`/`y`/`c`/`p`/`r`/`~`/`>`/`<`/`J`/`o` act on the selection; statusline reports `VISUAL` and `VISUAL LINE` modes (cli-doc, features-doc)
- **`Hook vs Skill` comparison tab** — new section in features overview explaining when to use hooks vs skills and how to put guardrails in hooks (features-doc)

### Changed

- **`/usage` consolidates `/cost` and `/stats`** — both remain as typing aliases; command reference updated throughout; `SDKLocalCommandOutputMessage` example updated (cli-doc, agent-sdk-doc, operations-doc)
- **Plugin version management rewritten** — explicit `version` pins the plugin; omitting `version` uses the git commit SHA so every commit is a new version; `plugin.json` wins over `marketplace.json` when both are set; semver still recommended when using explicit versions (plugins-doc)
- **`--continue` and `--resume` include `/add-dir` sessions** — sessions that added the current directory with `/add-dir` are now included in the session picker and `--continue` (cli-doc, best-practices-doc)
- **`DISABLE_AUTOUPDATER` clarified** — only stops background checks; `claude update` and `claude install` still work; use `DISABLE_UPDATES` to block everything (settings-doc, getting-started-doc)
- **Filesystem hook type table adds `mcp_tool`** — "four other types" updated to "five"; `SessionStart` and `Setup` now support `mcp_tool` in addition to `command` (hooks-doc, agent-sdk-doc)
- **`/branch` / `/fork` disambiguation** — when `CLAUDE_CODE_FORK_SUBAGENT` is set, `/fork` is no longer an alias for `/branch` (cli-doc)
- **`/color` syncs to Remote Control** — color change now syncs to claude.ai/code when Remote Control is connected (cli-doc)
- **`/theme` lists custom and plugin themes** — updated description includes local and plugin themes and the **New custom theme…** option (cli-doc)
- **`availableModels` Config tool reference removed** — `/model`, `--model`, and `ANTHROPIC_MODEL` remain; Config tool no longer listed as a way to switch models (settings-doc, features-doc)
- **Auto mode `$defaults` replaces `claude auto-mode defaults` copy-paste workflow** — documentation restructured around the `"$defaults"` placeholder; danger block moved to warn about omitting it (settings-doc)
- **`PostToolUse` / `PostToolUseFailure` gain `duration_ms`** — tool execution time (excluding permission prompts and PreToolUse hooks) now included in hook inputs (operations-doc changelog)
- **`if` field on hooks now applies to `PermissionDenied`** — previously only `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` (hooks-doc)
- **Model config companion env vars apply to LLM gateways** — `_NAME` and `_DESCRIPTION` variables now take effect when `ANTHROPIC_BASE_URL` points to an LLM gateway (features-doc)
- **`autoMode` setting description updated** — now mentions `"$defaults"` in example value (settings-doc)
- **Agent teams broadcast removed** — `broadcast` to all teammates replaced by sending one message per recipient (agent-teams-doc)
- **Data usage encryption-at-rest table** — per-provider AES-256 details added; TLS version clarified to 1.2+ (security-doc)
- **Context window advice updated** — CLAUDE.md trimming guidance now recommends path-scoped rules instead of imports (errors-doc)
- **Effort level advice simplified** — "defaults vary by model and plan" changed to "defaults vary by model" (errors-doc)
- **Plugin dependency `claude plugin tag` shortcut** — `git tag` manually still works but `claude plugin tag --push` is now the recommended workflow (plugins-doc)
- **Plugin dependency skip message now surfaces in `/doctor`** — auto-update constraint skip now listed in `/doctor` and the `/plugin` Errors tab (plugins-doc)
- **Version resolution priority documented in plugins** — precedence: `plugin.json` → `marketplace.json` → git SHA → `unknown` (plugins-doc)
- **`/usage` progress bar fix noted in upstream changelog** — overlapping "Resets …" labels fixed in v2.1.119 (operations-doc)

### Removed

- **`Config` tool removed from TypeScript SDK** — `ConfigInput`, `ConfigOutput`, and `Config` tool documentation removed from SDK reference; `ToolInputSchemas` and `ToolOutputSchemas` types updated (agent-sdk-doc)

## 26.4.23

**5 new reference docs added; 77 reference files updated across all 18 skills; all SKILL.md files regenerated.**

### New reference docs

- **Auto mode configuration** (`settings-doc`) — `autoMode` settings block for telling the auto mode classifier which repos, buckets, and domains your organization trusts; `autoMode.environment`, override block/allow rules, `claude auto-mode` CLI subcommands, and how scopes compose (user, project-local, managed)
- **Debug your configuration** (`operations-doc`) — guide for diagnosing why CLAUDE.md, settings, hooks, MCP servers, or skills aren't taking effect; covers `/context`, `/memory`, `/skills`, `/hooks`, `/mcp`, `/permissions`, `/doctor`, and `/status` commands
- **Error reference** (`operations-doc`) — runtime error lookup table mapping terminal messages to causes and recovery steps; covers server errors, usage limits, auth errors, network errors, and request errors
- **Plugin dependency version constraints** (`plugins-doc`) — declare `version` constraints in `plugin.json` `dependencies` array using semver ranges (`~`, `^`, exact); cross-marketplace dependency syntax and constraint intersection behavior
- **Ultrareview** (`best-practices-doc`) — `/ultrareview` launches a fleet of remote reviewer agents that independently reproduce and verify findings before reporting; pricing, free-run limits, PR mode, and comparison to local `/review`

### Changed

- Widespread reference doc updates across all skills (77 files, ~2500 insertions) reflecting ongoing upstream doc evolution throughout the `26.4.16` → `26.4.23` window

## 26.4.22

**30 references updated across 10 skills:** agent-sdk-doc, best-practices-doc, cli-doc, getting-started-doc, hooks-doc, memory-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`UserPromptExpansion` hook event** — fires when a slash command expands into a prompt before reaching Claude; can block the expansion; matches on `command_name`; stdout is added to Claude's context; supported by all four hook types (hooks-doc, plugins-doc)
- **`CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT` env var** — use the minimal system prompt from simple mode without disabling tool discovery, hooks, MCP servers, or CLAUDE.md (settings-doc)
- **`skipWebFetchPreflight` setting** — skip the WebFetch domain safety hostname check sent to `api.anthropic.com`; useful for Bedrock/Vertex/Foundry deployments with restrictive egress (settings-doc, security-doc)
- **WebFetch domain safety check** — before fetching a URL the WebFetch tool sends the hostname to `api.anthropic.com` against a safety blocklist; runs regardless of provider; results cached per hostname for five minutes; opt out with `skipWebFetchPreflight: true` (security-doc)
- **`sessionStore` SDK option** — mirror session transcripts to an external backend so any host can resume them; available in both TypeScript and Python SDKs (agent-sdk-doc)
- **`AgentDefinition` expanded fields** — `disallowedTools`, `initialPrompt`, `maxTurns`, `background`, `effort`, and `permissionMode` are now documented in both TypeScript and Python SDKs (agent-sdk-doc)
- **W3C trace context auto-propagation** — Agent SDK injects `TRACEPARENT`/`TRACESTATE` from an active span into the CLI subprocess so Claude Code spans appear as children of your application's trace; also forwarded to Bash/PowerShell subprocesses (agent-sdk-doc, operations-doc)
- **OTel span hierarchy documentation** — full schema for `claude_code.interaction`, `llm_request`, `tool`, `tool.blocked_on_user`, `tool.execution`, and `hook` spans with per-attribute gating details (operations-doc)
- **New OTel log events** — `permission_mode_changed`, `auth`, `mcp_server_connection`, `internal_error`, `api_retries_exhausted`, `hook_execution_start`, `hook_execution_complete`, `compaction` (operations-doc)
- **`allowCrossMarketplaceDependenciesOn` marketplace field** — allowlist other marketplaces from which plugins in this marketplace may pull dependencies; cross-marketplace dependencies are otherwise blocked at install (plugins-doc)
- **`userConfig` schema expanded** — `type`, `title`, `required`, `default`, `multiple`, `min`/`max` fields now documented for plugin user-config options; `type` and `title` are required (plugins-doc)
- **`start_type` metric attribute** — `session_start` metric now includes `start_type` (`fresh`, `resume`, or `continue`) (operations-doc)
- **`query_source` and `speed` metric attributes** — `api_request` counter and token counter now include `query_source` (`main`, `subagent`, or `auxiliary`) and `speed` (`fast`) (operations-doc)
- **Named skill arguments (`arguments` frontmatter)** — declare named positional arguments in skill frontmatter; use `$name` placeholders in skill content instead of `$ARGUMENTS[N]` (skills-doc)
- **Debug your configuration page** — new dedicated doc linked from settings, memory, skills, and hooks docs (settings-doc, memory-doc, skills-doc, hooks-doc)
- **`claude_code.hook` span requires beta tracing** — hook spans now require `ENABLE_BETA_TRACING_DETAILED=1` and `BETA_TRACING_ENDPOINT` in addition to standard trace variables (agent-sdk-doc, operations-doc)

### Changed
- **`OTEL_LOG_RAW_API_BODIES` file mode** — now accepts `file:<dir>` to write untruncated request/response bodies to disk with a `body_ref` path in the event instead of the inline truncated `body`; affects env vars doc, monitoring doc, and agent SDK observability doc (settings-doc, operations-doc, agent-sdk-doc)
- **`OTEL_LOG_TOOL_DETAILS` adds raw error strings** — tool failure error messages are now included when this flag is set (settings-doc)
- **`tool_result` event `error` field split** — `error` is now split into `error_type` (always present on failure) and `error` gated on `OTEL_LOG_TOOL_DETAILS=1` (operations-doc)
- **`plugin_installed` and `skill_activated` event redaction** — `plugin.name`, `plugin.version`, `marketplace.name`, and `skill.name` for third-party sources are now redacted unless `OTEL_LOG_TOOL_DETAILS=1` (operations-doc)
- **Subagent frontmatter hooks fire in main-session `--agent` mode** — previously documented as not firing for `--agent`; now fires alongside `settings.json` hooks in that case (sub-agents-doc)
- **Task list display reduced from 10 to 5 tasks** — `Ctrl+T` task list now shows up to 5 tasks at a time instead of 10 (cli-doc)
- **`/terminal-setup` sets mouse wheel scroll sensitivity** — in VS Code, Cursor, and Windsurf it now also writes `terminal.integrated.mouseWheelScrollSensitivity` for smoother fullscreen scrolling; conflict messaging updated (cli-doc)
- **Session recap `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` env var removed from docs** — override via env var no longer documented; toggle via `/config` only (cli-doc)
- **Auto mode classifier guidance updated** — CLAUDE.md now recommended for project-level classifier steering; `autoMode` settings block positioned for cross-project infrastructure rules (settings-doc)
- **`/status` now shows `HKCU` settings origin** — Windows user-level registry source `Enterprise managed settings (HKCU)` added to `/status` output (settings-doc)
- **macOS MDM settings plist format documented** — top-level keys mirror `managed-settings.json`; nested settings are dictionaries; arrays are plist arrays (settings-doc)
- **Sandboxing `failIfUnavailable` wording** — "platform restrictions" removed from failure triggers; only missing dependencies or unsupported platform apply (settings-doc, security-doc)
- **Sandbox auto-allow protects critical paths** — `rm`/`rmdir` targeting `/`, home directory, or critical system paths still trigger a permission prompt even in auto-allow sandbox mode (settings-doc, security-doc)
- **Download host updated to `downloads.claude.ai`** — network config, troubleshooting, and setup docs updated; `storage.googleapis.com` is now the legacy host used only by older clients (getting-started-doc, security-doc, operations-doc)
- **MCP connectors URL changed** — `claude.ai/settings/connectors` updated to `claude.ai/customize/connectors` (mcp-doc)
- **Troubleshooting content moved to debug-your-config page** — symptom table and `/context` inspection commands removed from claude-directory doc and replaced with a link (memory-doc)
- **`model` field in `AgentDefinition` accepts full model IDs** — previously only aliases (`sonnet`, `opus`, `haiku`, `inherit`); now accepts any full model ID string (agent-sdk-doc)
- **`effort` type in Python `ClaudeAgentOptions` dropped `xhigh`** — `effort` literal type is now `"low" | "medium" | "high" | "max"` (agent-sdk-doc)
- **Extended thinking spinner text updated** — "progress hints appear below the indicator" replaced with specific inline spinner text "still thinking" / "almost done thinking" (best-practices-doc)
- **`CwdChanged` and `FileChanged` hooks support all hook types** — "Only `type: command` hooks" restriction removed from docs (hooks-doc)

### Removed
- **`Experiment` A/B testing component removed from quickstart and overview** — client-side experiment bucketing code deleted from reference docs (getting-started-doc)

## 26.4.21

**67 references updated across 19 skills:** agent-sdk-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **Claude Opus 4.7** — new model available; `opus` alias on Anthropic API now resolves to Opus 4.7; Max/Team Premium default changed to Opus 4.7; requires Claude Code v2.1.111+; Agent SDK v0.2.111+ required for API compatibility (features-doc, cloud-providers-doc, cli-doc, settings-doc, agent-sdk-doc)
- **`xhigh` effort level** — new effort level for Opus 4.7 between `high` and `max`; recommended default on Opus 4.7; available in `--effort`, `/effort`, `effortLevel` setting, and skill/subagent frontmatter; falls back to `high` on models that don't support it (features-doc, settings-doc, cli-doc, skills-doc, sub-agents-doc)
- **`xhigh_effort` model capability flag** — declare `xhigh_effort` in `ANTHROPIC_DEFAULT_OPUS_MODEL_SUPPORTED_CAPABILITIES` to expose the `xhigh` level for custom model deployments (features-doc)
- **`VERTEX_REGION_CLAUDE_4_7_OPUS` env var** — override region for Opus 4.7 on Vertex AI (settings-doc)
- **MCP automatic reconnection** — HTTP/SSE servers now reconnect automatically with exponential backoff (5 attempts, doubling from 1s) when disconnected mid-session; server shows as pending in `/mcp` during retry (mcp-doc)
- **MCP OAuth scope restriction** — new `oauth.scopes` config field pins the scopes Claude Code requests during the OAuth flow to a space-separated subset (mcp-doc)
- **`deniedDomains` sandbox setting** — blocks specific domains even when a broader `allowedDomains` wildcard would otherwise permit them (security-doc, settings-doc)
- **Plugin monitors** — plugins can now declare background monitors in `monitors/monitors.json`; each stdout line from the command is delivered to Claude as a notification; supports `always` and `on-skill-invoke:<name>` trigger modes (plugins-doc)
- **Plugin dependency declarations** — `dependencies` array in `plugin.json` declares other required plugins with optional semver version constraints; dependencies are auto-installed (plugins-doc)
- **`claude plugin list` CLI command** — lists installed plugins with version, source, and enable status; supports `--json` and `--available` flags (plugins-doc)
- **Desktop SSH pre-configuration** — admins can distribute SSH connections to team members via `sshConfigs` in managed settings; connections appear as read-only in the environment dropdown (ide-doc, settings-doc)
- **Remote Control mobile push notifications** — Claude can send push notifications to the Claude mobile app when Remote Control is active; configure via `/config` "Push when Claude decides"; requires v2.1.110+ (features-doc)
- **Auto mode now available on Max plans** — expanded from Team/Enterprise/API to also include Max; Opus 4.7 required on Max; `--enable-auto-mode` flag removed and replaced by automatic availability detection (settings-doc)
- **Auto mode conversation boundaries** — user-stated constraints in the conversation ("don't push", "wait until I review") now function as classifier block signals that persist until explicitly lifted (settings-doc)
- **Read-only commands** — documented built-in set of Bash commands (e.g. `ls`, `cat`, `grep`, `git` read-only forms) that run without a permission prompt in every mode; not configurable (settings-doc)
- **Symlink permission rule behavior** — allow rules require both the symlink and its target to match; deny rules block when either the symlink or its target matches (settings-doc)
- **Exec-wrapper prompt behavior** — `watch`, `setsid`, `ionice`, `flock`, and `find -exec`/`find -delete` always prompt and cannot be auto-approved by prefix rules (settings-doc)
- **`CLAUDE_CODE_ENABLE_AWAY_SUMMARY` env var** — override session recap availability independently of the `/config` toggle (settings-doc)
- **`CLAUDE_CODE_ENABLE_BACKGROUND_PLUGIN_REFRESH` env var** — refresh plugin state at turn boundaries in non-interactive mode after a background install completes (settings-doc)
- **`OTEL_LOG_RAW_API_BODIES` env var** — emit full Anthropic Messages API request/response JSON as OpenTelemetry log events (settings-doc)
- **`awaySummaryEnabled` setting** — toggle session recap display from `settings.json`; equivalent to `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` (settings-doc)
- **`autoScrollEnabled` global config** — disable auto-follow-to-bottom in fullscreen rendering; permission prompts still scroll into view (settings-doc)
- **`externalEditorContext` global config** — prepend Claude's previous response as commented context when opening the external editor with `Ctrl+G` (settings-doc)
- **`sshConfigs` setting** — configure SSH connections for the Desktop environment dropdown; managed connections are read-only for users (settings-doc)
- **`tui` setting** — persist terminal UI renderer (`"default"` or `"fullscreen"`) across sessions; set via `/tui` command (settings-doc)
- **`/tui` command** — switch rendering modes in the current conversation; replaces `CLAUDE_CODE_NO_FLICKER` env var as the primary way to enable fullscreen rendering (cli-doc, features-doc)
- **`/focus` command** — toggle focus view (last prompt + one-line tool summary + response) independently of `Ctrl+O`; persists across sessions (cli-doc, features-doc)
- **`/heapdump` command** — write a heap snapshot and memory breakdown to `~/Desktop` for diagnosing high memory usage (cli-doc)
- **`/recap` command** — generate a one-line session summary on demand (cli-doc)
- **`/review [PR]` command** — review a pull request locally; replaces deprecated `/review` (cli-doc)
- **`/ultrareview [PR]` command** — deep multi-agent code review in a cloud sandbox; 3 free runs on Pro/Max through May 5, 2026 (cli-doc)
- **`/fewer-permission-prompts` skill** — scan transcripts for common read-only tool calls and add an allowlist to project settings (cli-doc)
- **Session picker enhancements** — picker now defaults to current worktree with `Ctrl+W` to widen to all worktrees, `Ctrl+A` for all projects; shortcuts updated to `Ctrl+R` rename, `Space` preview, `Ctrl+B` branch filter; resume-by-name resolves across worktrees (best-practices-doc)
- **Work in notes and non-code folders** — new workflow section documenting that Claude Code works in any directory including notes vaults and markdown collections (best-practices-doc)
- **`/clear` now preserves previous conversation** — clarified that `/clear` starts a new conversation while the previous one remains available in `/resume` (cli-doc)
- **`SessionStart` + `CwdChanged` direnv pattern** — recommended pattern now pairs both hooks so env vars load at launch and on every directory change (hooks-doc)
- **Hook `if` field semantics for compound commands** — `if` now matches against each subcommand of a compound Bash input; hook runs if any subcommand matches, or always when the command is too complex to parse (hooks-doc)
- **`bypassPermissions` restriction in `setMode`** — `setMode` with `bypassPermissions` only takes effect when the session was launched with bypass mode already available (hooks-doc)
- **Agent hooks marked experimental** — `type: "agent"` hooks are now labeled experimental with a warning to prefer command hooks in production (hooks-doc)
- **Opus 4.7 1M context window** — Opus 4.7 supports the 1M token context window on Bedrock and Vertex; Bedrock/Vertex setup wizard offers 1M option when pinning models (cloud-providers-doc)
- **`/loop` task persistence** — `/loop` tasks now survive `--resume` and `--continue` if unexpired (within 7 days for recurring, or scheduled time hasn't passed for one-shot) (best-practices-doc, features-doc)
- **`~/.claude` on Windows** — documented that `~/.claude` resolves to `%USERPROFILE%\.claude` on Windows (memory-doc)
- **VS Code diff view edit awareness** — if you edit proposed content in the diff view before accepting, Claude is told you modified it (ide-doc)
- **VS Code thinking block expand shortcut** — `Ctrl+O` expands or collapses every thinking block in the session (ide-doc)
- **Desktop troubleshooting link to error reference** — desktop troubleshooting section now references the error reference for API error codes (ide-doc)
- **`ultraplan` link to `ultrareview`** — ultraplan doc cross-references the new ultrareview feature (best-practices-doc)
- **ZDR contact-sales link** — ZDR request page now links to the contact-sales form in addition to account team (security-doc)

### Changed
- **`settingSources` default behavior reversed** — omitting `settingSources` in `query()` now loads all filesystem settings (user, project, local) matching CLI defaults, instead of loading nothing; pass `settingSources: []` to disable; Python SDK 0.1.59 and earlier treated empty list as omitted, so upgrade before relying on the isolated behavior (agent-sdk-doc)
- **`ResultMessage` clarification** — `ResultMessage` "marks the end of the agent loop" rather than being the last message; trailing system events like `prompt_suggestion` can arrive after it; iterate stream to completion rather than breaking on result (agent-sdk-doc)
- **`effort` field now includes `xhigh`** — `ClaudeAgentOptions.effort` type updated to include `"xhigh"` option (agent-sdk-doc)
- **`max_budget_usd` description updated** — clarified as a client-side cost estimate comparison, not authoritative billing data (agent-sdk-doc)
- **SDK hosting no longer requires Node.js** — both Python and TypeScript SDK packages now bundle a native Claude Code binary; no separate Claude Code or Node.js install needed (agent-sdk-doc)
- **Adaptive reasoning expanded to "models that support effort"** — docs no longer specify "Opus 4.6 and Sonnet 4.6" exclusively; Opus 4.7 always uses adaptive reasoning and has no fixed-budget mode (best-practices-doc, features-doc, settings-doc)
- **`/effort` command updated** — now opens an interactive slider when run with no argument; updated to show `xhigh` and all available levels; `max` no longer listed as Opus 4.6 only (cli-doc, features-doc)
- **`--effort` flag updated** — now includes `xhigh` option; removed "(Opus 4.6 only)" from `max` description (cli-doc)
- **`--enable-auto-mode` flag removed** — removed in v2.1.111; auto mode is now in the `Shift+Tab` cycle by default; use `--permission-mode auto` instead (cli-doc)
- **`Ctrl+L` clears prompt and redraws screen** — clarified that `Ctrl+L` also forces a full terminal redraw to recover garbled displays (cli-doc)
- **`Ctrl+G` external editor context** — `Ctrl+G` can prepend Claude's previous response as commented context when the new config toggle is enabled (cli-doc)
- **`Up/Down` history navigation** — `Ctrl+P`/`Ctrl+N` added as aliases; in multiline input, cursor moves within the prompt before navigating history (cli-doc)
- **Text editing shortcuts expanded** — added `Ctrl+A` (start of line), `Ctrl+E` (end of line), and `Ctrl+W` (delete previous word) to the keyboard reference (cli-doc)
- **Fullscreen rendering enabled via `/tui fullscreen`** — `/tui` is now the primary way to enable fullscreen; `CLAUDE_CODE_NO_FLICKER` still works as an equivalent (features-doc, settings-doc)
- **Fullscreen `Ctrl+O` no longer cycles focus view** — `Ctrl+O` now only toggles transcript mode; use `/focus` for the focus view (features-doc, cli-doc)
- **Fullscreen auto-scroll can be disabled** — new `autoScrollEnabled` setting and `/config` toggle; permission prompts still scroll into view regardless (features-doc)
- **Fullscreen keyboard selection extended** — `Shift+arrow` extends selection; `Shift+↑`/`Shift+↓` scroll the viewport when selection reaches the edge (features-doc)
- **Fast mode limited to Opus 4.6** — clarified that fast mode is not available on Opus 4.7 or other models (features-doc)
- **`opusplan` plan phase uses standard 200K context** — the automatic 1M upgrade does not apply to `opusplan`'s plan-mode Opus phase (features-doc)
- **Default model by plan updated** — Max and Team Premium now default to Opus 4.7; Enterprise/Pro/Team Standard/API still default to Sonnet 4.6; Bedrock/Vertex/Foundry default to Sonnet 4.5; Enterprise pay-as-you-go and Anthropic API default changes to Opus 4.7 on April 23, 2026 (features-doc)
- **`ENABLE_PROMPT_CACHING_1H_BEDROCK` deprecated** — replaced by `ENABLE_PROMPT_CACHING_1H` which works across all providers (settings-doc)
- **`FORCE_PROMPT_CACHING_5M` env var** — new variable to force 5-minute TTL even when 1-hour would otherwise apply (settings-doc)
- **`CLAUDE_CODE_USE_POWERSHELL_TOOL` extended** — now available on Linux and macOS (requires `pwsh` in PATH); on Windows it is rolling out progressively with opt-in/opt-out via `1`/`0` (settings-doc)
- **`CLAUDE_ENV_FILE` clarified** — described as running the file contents in the same shell process so exports are visible to the subsequent command (settings-doc)
- **`CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` limited to Opus 4.6/Sonnet 4.6** — has no effect on Opus 4.7 which always uses adaptive reasoning (settings-doc)
- **`/skills` sort by token count** — can now press `t` to sort skills by token count (cli-doc)
- **`/compact` description updated** — links to new doc on what survives compaction (cli-doc)
- **`/rewind` aliases expanded** — now also has `/undo` alias (cli-doc)
- **`/schedule` alias added** — `/routines` is now an alias (cli-doc)
- **`/terminal-setup` expanded** — now lists Cursor and Windsurf in addition to VS Code/Alacritty/Zed (cli-doc)
- **`/theme` auto option** — new `auto` option matches terminal's light/dark background (cli-doc)
- **`/model` picker confirmation** — picker now asks for confirmation when the conversation has prior output, since the next response re-reads full history without cached context (cli-doc, features-doc)
- **Plugin `/plugin` Installed tab improved** — sorted by problems first, then favorites, with disabled plugins collapsed; `f` to favorite; auto-installs dependencies when declared (plugins-doc)
- **Plugin private repo SSH access documented** — SSH works if host is in `known_hosts` and key is in `ssh-agent`; interactive prompts are suppressed (plugins-doc)
- **Hook `once` field only honored in skill frontmatter** — ignored in settings files and agent frontmatter (hooks-doc)
- **Hook `if` field removed from `PermissionDenied`** — `if` only works on `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, and `PermissionRequest` (hooks-doc)
- **`PermissionRequest` hook `behavior: allow` does not override deny rules** — clarified that deny and ask rules are still evaluated after a hook returns `"allow"` (hooks-doc)
- **`acceptEdits` added to subagent permission inheritance** — parent `acceptEdits` now also prevents subagent from overriding the permission mode (sub-agents-doc)
- **Routines `from fork` filter removed** — the "from fork" PR filter option has been removed (features-doc)
- **Routines setup script caching** — setup scripts are now cached so they don't re-run on every session (features-doc)
- **`dontAsk` mode description updated** — now also allows read-only Bash commands in addition to explicit allow rules (settings-doc)
- **`effortLevel` setting updated** — now accepts `"xhigh"` in addition to `"low"`, `"medium"`, `"high"` (settings-doc)
- **`minimumVersion` setting description expanded** — now documented as also blocking `claude update` and useful in managed settings (settings-doc)
- **`observability` `session.id` attribute** — omitted when `OTEL_METRICS_INCLUDE_SESSION_ID` is falsy; telemetry note updated that token counts may be omitted for failed/aborted requests (agent-sdk-doc)
- **Subagent and skill `effort` frontmatter updated** — now includes `xhigh` option; `max` no longer described as Opus 4.6 only (sub-agents-doc, skills-doc)
- **Typo-corrected subcommand suggestion** — CLI now suggests closest match when a subcommand is mistyped (cli-doc)
- Minor link/anchor updates across best-practices-doc, cli-doc, sub-agents-doc (e.g. `/btw` anchor path corrected)

## 26.4.16

**24 references updated across 11 skills:** agent-sdk-doc, best-practices-doc, ci-cd-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, ide-doc, operations-doc, settings-doc

### New
- **`excludeDynamicSections` option on `claude_code` preset** — moves per-session context (working directory, git status, OS, auto-memory paths) out of the system prompt and into the first user message so identical SDK configurations can share a prompt-cache entry across users and machines. Requires `@anthropic-ai/claude-agent-sdk` v0.2.98+ or `claude-agent-sdk` Python v0.1.58+ (agent-sdk-doc)
- **v2.1.110 release (Apr 15)** — `/tui` command and `tui` setting switch rendering modes in the current conversation; push notification tool lets Claude send mobile pushes when Remote Control is enabled; new `/focus` command and `autoScrollEnabled` config; `Ctrl+O` now toggles verbose transcript only; `/plugin` Installed tab reorganized; `/doctor` warns on MCP servers defined in multiple scopes with different endpoints; SDK/headless sessions honor `TRACEPARENT`/`TRACESTATE` for distributed tracing; recap now enabled for telemetry-disabled setups (Bedrock/Vertex/Foundry); plus many bug fixes (operations-doc)
- **v2.1.109 release (Apr 15)** — extended-thinking indicator now shows a rotating progress hint (operations-doc, best-practices-doc)
- **`CLAUDE_CODE_REMOTE` env var** — set automatically to `true` in cloud sessions; read from hooks/setup scripts to detect cloud environments (settings-doc)
- **`CLAUDE_CODE_REMOTE_SESSION_ID` env var** — set automatically in cloud sessions to the current session ID; use to construct links back to the session transcript (settings-doc, headless-doc)
- **`CLAUDE_CODE_TMUX_TRUECOLOR` env var** — set to `1` to allow 24-bit truecolor output inside tmux (bypasses the default 256-color clamp when `$TMUX` is set) (settings-doc)
- **Pre-fill sessions via query parameters** — `claude.ai/code` URL now accepts `prompt` (aka `q`), `prompt_url`, `repositories` (aka `repo`), and `environment` parameters to prefill a new web session (headless-doc)
- **Link cloud artifacts to sessions** — documented pattern for constructing `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID}` links in PR bodies, commits, and generated reports (headless-doc)
- **Spend-cap troubleshooting for Code Review** — new section documenting that reviews are skipped and a comment is posted when the org's monthly spend cap is reached; resumes at next billing period or when admin raises the cap (ci-cd-doc)

### Changed
- **Cost tracking reframed as client-side estimate** — added a prominent warning that `total_cost_usd` and `costUSD` are local estimates computed from a bundled price table, not authoritative billing data. Direct users to the Usage and Cost API or Claude Console for invoice-accurate spend. Language updated throughout SDK, `/cost`, statusline, and Code Review analytics docs (agent-sdk-doc, features-doc, operations-doc, ci-cd-doc)
- **`REVIEW.md` significantly expanded** — rewritten to emphasize that `REVIEW.md` is injected as highest-priority instructions into every review agent (vs. `CLAUDE.md` which is treated as project context and flagged as nits). New sections document tunable areas: severity calibration, nit-volume caps, skip rules, repo-specific checks, verification bar, re-review convergence, and summary shape. `@` import syntax is not expanded (ci-cd-doc)
- **Code Review findings now include summary in review body** — previously documented as inline-only (ci-cd-doc)
- **Routines GitHub triggers narrowed** — supported event categories reduced from ~17 (push, issues, checks, workflows, etc.) to just Pull request and Release. Added documentation of filter operators (equals, contains, starts with, is one of, is not one of, matches regex) and clarified that `matches regex` tests the entire field, not a substring (features-doc)
- **JetBrains diff tool config** — `/config` diff tool setting now documented as `auto` for IDE or `terminal` to keep diffs in the terminal (ide-doc)
- **`network.allowUnixSockets` is macOS-only** — clarified that on Linux/WSL2 the seccomp filter cannot inspect socket paths, so `allowAllUnixSockets` is the only way to permit Unix sockets there (settings-doc)
- **Install configurator added to overview page** — the interactive install configurator component (previously only on quickstart) is now also on the overview page; default-surface A/B test added; handoff card redesigned with product taglines (getting-started-doc)
- Minor wording/formatting updates across agent-sdk-doc, best-practices-doc, cloud-providers-doc, operations-doc what's-new digests (link paths updated from `/en/` to `/docs/en/`)

## 26.4.15

**New reference `claude-code-routines.md`** added to `features-doc` — first-class doc for cloud-hosted Claude Code automation, replacing the old `web-scheduled-tasks.md`.

**New reference `claude-code-whats-new-2026-w15.md`** added to `operations-doc` — Week 15 (Apr 6–10) digest covering Ultraplan, the Monitor tool, terminal `/autofix-pr`, and `/team-onboarding`.

**108 references updated across 19 skills:** agent-sdk-doc, agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **Routines** — new cloud-hosted automation page documents saved Claude Code configurations (prompt, repos, connectors) that run on Anthropic-managed cloud infrastructure. Each routine can combine Scheduled, API, and GitHub triggers; managed at `claude.ai/code/routines` or via `/schedule` in the CLI. Research preview on Pro/Max/Team/Enterprise plans with Claude Code on the web enabled. Replaces the removed `web-scheduled-tasks.md` page (features-doc)
- **`minimumVersion` setting** — prevents the auto-updater from downgrading below a specific version; automatically set when switching to the stable channel and choosing to stay on the current version. Used with `autoUpdatesChannel` (settings-doc)
- **`viewMode` setting** — default transcript view mode on startup: `"default"`, `"verbose"`, or `"focus"`. Overrides the sticky `Ctrl+O` selection when set (settings-doc)
- **v2.1.108 release (Apr 14)** — `ENABLE_PROMPT_CACHING_1H` env var opts into 1-hour prompt cache TTL on API key, Bedrock, Vertex, and Foundry (deprecates `ENABLE_PROMPT_CACHING_1H_BEDROCK`); `FORCE_PROMPT_CACHING_5M` forces 5-minute TTL; new `/recap` command provides context when returning to a session (configurable in `/config`, `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` to force with telemetry disabled); model can now discover built-in slash commands like `/init`, `/review`, `/security-review` via the Skill tool; `/undo` is now an alias for `/rewind`; `/model` warns before switching mid-conversation; `/resume` picker defaults to current-directory sessions with `Ctrl+A` to show all; server rate limits now distinguished from plan usage limits; startup warning when prompt caching is disabled via `DISABLE_PROMPT_CACHING*` (operations-doc)
- **v2.1.105 release (Apr 13)** — `path` parameter added to the `EnterWorktree` tool to switch into an existing worktree; `PreCompact` hook can now block compaction by exiting with code 2 or returning `{"decision":"block"}`; plugins can declare a top-level `monitors` manifest key that auto-arms background monitors at session start or on skill invoke; `/proactive` is now an alias for `/loop`; stalled API streams now abort after 5 minutes of no data and retry non-streaming; skill description listing cap raised from 250 to 1,536 characters with a startup warning for truncation; `WebFetch` strips `<style>`/`<script>` contents; stale agent worktree cleanup now removes worktrees whose PR was squash-merged; MCP large-output truncation prompt gives format-specific recipes (e.g. `jq` for JSON) (operations-doc)
- **Command hooks `shell` field** — accepts `"bash"` (default) or `"powershell"`; setting `"powershell"` runs the command via PowerShell on Windows without requiring `CLAUDE_CODE_USE_POWERSHELL_TOOL` (hooks-doc)
- **`PreCompact` hooks can block compaction** — exit 2 or `{"decision":"block"}` now halts compaction; blocking proactive compaction skips it, but blocking a recovery-from-limit compaction surfaces the original context-limit error (hooks-doc)
- **`SessionEnd` hooks 1.5s default timeout** — automatically raised to the highest per-hook `timeout` configured in settings files, up to 60 seconds; plugin-provided hook timeouts don't raise the budget; override with `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (hooks-doc, settings-doc)
- **Live skill change detection** — adding, editing, or removing a skill under `~/.claude/skills/`, the project `.claude/skills/`, or a `.claude/skills/` inside an `--add-dir` directory now takes effect within the current session without restarting. Creating a top-level skills directory that didn't exist at session start still requires a restart (skills-doc)
- **`CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` env var** — set to `1` to load `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from `--add-dir` directories; off by default (settings-doc)
- **`CLAUDE_CODE_DISABLE_VIRTUAL_SCROLL` env var** — disables virtual scrolling in fullscreen rendering so every transcript message is rendered. Use when scrolling shows blank regions (settings-doc)
- **`CLAUDE_CODE_MAX_CONTEXT_TOKENS` env var** — override the context window size for the active model. Only takes effect when `DISABLE_COMPACT` is also set. For routing through `ANTHROPIC_BASE_URL` to a model whose context window doesn't match its built-in size (settings-doc)
- **`CLAUDE_CODE_SKIP_PROMPT_HISTORY` env var** — set to `1` to skip writing prompt history and session transcripts to disk; sessions don't appear in `--resume`, `--continue`, or up-arrow history. Now the recommended way to disable transcript writes in interactive mode (settings-doc)
- **Streaming idle watchdogs** — `CLAUDE_ENABLE_BYTE_WATCHDOG` force-enables/disables the byte-level idle watchdog (on by default for Anthropic API, minimum 5 minutes); `CLAUDE_ENABLE_STREAM_WATCHDOG` enables the event-level watchdog (off by default, required for Bedrock/Vertex/Foundry); `CLAUDE_STREAM_IDLE_TIMEOUT_MS` configures the timeout (settings-doc)
- **`OTEL_LOG_TOOL_DETAILS` env var** — set to `1` to include tool input arguments, MCP server names, and tool details in OpenTelemetry traces and logs; disabled by default to protect PII (settings-doc)
- **`VERTEX_REGION_CLAUDE_4_5_OPUS` and `VERTEX_REGION_CLAUDE_4_6_OPUS` env vars** — override Vertex AI region for Claude Opus 4.5 and 4.6 (settings-doc, cloud-providers-doc)
- **`ANTHROPIC_CUSTOM_MODEL_OPTION_SUPPORTED_CAPABILITIES` env var** — declare capabilities for custom model options (see Model configuration) (settings-doc)
- **`/resume` picker cross-worktree support** — now shows interactive sessions from the same git repository including all worktrees; selecting a session from another worktree resumes it directly without switching directories first. `claude --resume` also accepts custom names set with `--name` or `/rename` in addition to session IDs (best-practices-doc)
- **MCP `http` transport rename** — `--transport streamable-http` is now `--transport http` in `claude mcp add` examples (mcp-doc)

### Changed
- **`cleanupPeriodDays` setting description** — updated to recommend the new `CLAUDE_CODE_SKIP_PROMPT_HISTORY` env var for disabling transcript writes in interactive mode; previously only `--no-session-persistence` / `persistSession: false` were suggested and only worked in non-interactive mode (settings-doc)
- **Scheduling comparison tables** — every "Cloud scheduled tasks" link/reference across docs now points to `/en/routines` instead of the removed `/en/web-scheduled-tasks` page; scheduling-option comparison tables rewritten to use "Routines" as the cloud option (features-doc, best-practices-doc)
- **Agent SDK examples** — minor wording tweaks in overview/permissions/modifying-system-prompts code samples (agent-sdk-doc)
- Minor formatting/whitespace updates and removal of the `<AgentInstructions>` feedback block across most reference files (all skills)

### Removed
- **`web-scheduled-tasks.md` reference** — removed from `features-doc`; superseded by the new `routines.md` page (features-doc)

## 26.4.11

**New skill `agent-sdk-doc`** — 29 references covering the Claude Agent SDK (overview, quickstart, agent loop, Claude Code features, cost tracking, custom tools, file checkpointing, hooks, hosting, MCP, migration guide, modifying system prompts, observability, permissions, plugins, python, secure deployment, sessions, skills, slash commands, streaming output, streaming vs single mode, structured outputs, subagents, todo tracking, tool search, typescript, typescript v2 preview, user input).

**80 references updated across 18 existing skills:** agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

**New reference `claude-code-web-quickstart.md`** added to `headless-doc`.

### New
- **Monitor tool** — streams stdout/stderr from background scripts back to Claude line-by-line; requires v2.1.98+ and is unavailable on Bedrock, Vertex AI, and Foundry (cli-doc, features-doc)
- **Interactive "Sign in with Bedrock" and "Sign in with Vertex AI" wizards** — new login-screen flows configure AWS/GCP auth, region, credential verification, and model pinning; `/setup-bedrock` and `/setup-vertex` reopen them later (cloud-providers-doc, cli-doc)
- **Startup model checks on Bedrock and Vertex** — pinned and default models are verified at startup with prompts to update or fall back when unavailable; Foundry has no equivalent check and surfaces errors instead (cloud-providers-doc, features-doc)
- **`ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` for Bedrock Mantle** — pin the small/fast model to a specific AWS region (cloud-providers-doc)
- **Fullscreen focus view** — Ctrl+O in fullscreen now cycles normal → transcript → focus view, which shows the last user prompt plus one-line tool summaries with diffstats and the final response (features-doc, cli-doc)
- **`Scroll` keybinding context** — new context exposes rebindable `scroll:lineUp/lineDown/pageUp/pageDown/top/bottom/halfPage*/fullPage*` and `selection:copy/clear` actions for fullscreen mode (cli-doc)
- **Status line `refreshInterval` setting** — re-runs the status line command every N seconds on a timer instead of only on events (features-doc)
- **Status line `workspace.git_worktree` JSON field** — populated when the cwd lives inside a linked git worktree (features-doc)
- **`--exclude-dynamic-system-prompt-sections` flag** — moves per-machine sections out of the system prompt into the first user message so the prompt cache can be shared across users and machines (cli-doc)
- **`claude setup-token` long-lived tokens** — prints a `CLAUDE_CODE_OAUTH_TOKEN` for CI and scripts without saving it; requires a Claude subscription (cli-doc, getting-started-doc)
- **`/loop` dynamic and maintenance modes** — omit the interval to let Claude pick a cadence between 1m and 1h, omit the prompt to run a built-in maintenance loop, and customize behavior with `.claude/loop.md` or `~/.claude/loop.md` (25,000 byte cap) (features-doc)
- **Remote Control `--spawn=session` single-session mode** — rejects additional connections once the first client attaches (features-doc)
- **VS Code Remote Control tab** — `/remote-control` (or `/rc`) in the VS Code extension; requires v2.1.79+ (features-doc)
- **Bundled skills `/batch`, `/claude-api`, `/debug`, `/loop`, `/simplify`** are now listed in the commands reference (cli-doc)
- **New built-in commands `/autofix-pr`, `/setup-vertex`, `/teleport`, `/web-setup`** (cli-doc)
- **`CCR_FORCE_BUNDLE` env var** — force local repo bundling to cloud sessions even when GitHub is connected, with size and branch fallbacks (settings-doc, headless-doc)
- **`CLAUDE_CODE_CERT_STORE` env var** — `=bundled` opts out of the OS CA store in favor of the bundled Node root certs (settings-doc)
- **`CLAUDE_CODE_PERFORCE_MODE` env var** — fails on read-only files with a `p4 edit` hint instead of overwriting them (settings-doc, operations-doc)
- **`CLAUDE_CODE_SCRIPT_CAPS` env var** — caps the number of subprocess script invocations per session (settings-doc)
- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` subprocess sandboxing** — scrubs secrets from child process environments (operations-doc, settings-doc)
- **`CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` env var** — disables the new main-session `cd` carry-over behavior inside project and additional directories (cli-doc, settings-doc)
- **`/team-onboarding` command** — new onboarding flow surfaced in the changelog (operations-doc)
- **Plugin manifest `skills` field** — declares `<name>/SKILL.md` skill directories alongside the legacy flat `commands/` field (plugins-doc)
- **Auto-fix pull requests from the terminal** — `/autofix-pr` now works from a local Claude Code session, not just the web (headless-doc)
- **Local repo bundling to cloud sessions** — non-GitHub repos can be uploaded directly from the terminal via `CCR_FORCE_BUNDLE`, with fallbacks for size and branch state (headless-doc)
- **"What survives compaction" table** — documents system prompt, CLAUDE.md, rules with `paths:`, nested CLAUDE.md, invoked skills, and hook behavior through compaction, with a 5,000-token-per-skill and 25,000-token total skill budget (features-doc)
- **"Skill content lifecycle" and "When to create a skill" guidance** — invoked skills are re-attached after compaction, filled from most recent, within the same 5K/25K budgets (skills-doc)
- **"Build your setup over time" trigger→feature table** — maps common needs to CLAUDE.md, skills, MCP, subagents, hooks, and plugins (features-doc)
- **"When to add to CLAUDE.md" section** (memory-doc)
- **`~/.claude/stats-cache.json` and `~/.claude/backups/` documented** alongside a `CLAUDE_CONFIG_DIR` reference (memory-doc)
- **Bash working-directory carry-over** — main-session `cd` now persists across turns within project and additional directories (cli-doc)
- **Homebrew `claude-code@latest` cask** — tracks the latest channel alongside the stable `claude-code` cask (getting-started-doc)
- **Mobile row in the platforms comparison table** (getting-started-doc)
- **ARM64 added to hardware requirements** (getting-started-doc)
- **Cedar syntax highlighting** in editors (operations-doc)
- **macOS microphone permission reset procedure** — `tccutil reset Microphone <bundle-id>` when the terminal is missing from System Settings (features-doc)

### Changed
- **`allowed-tools` in skills is now pre-approval, not restriction** — the field grants auto-approval for the listed tools instead of limiting which tools the skill can use; section renamed to "Pre-approve tools for a skill" (skills-doc)
- **Accept-edits mode auto-approves common filesystem commands** — `mkdir`, `touch`, `mv`, and `cp` no longer prompt (headless-doc, getting-started-doc)
- **Hook matcher pattern rules clarified** — `"*"`, `""`, or omitted matches all; strings containing only letters, digits, `_`, and `|` are exact or pipe-separated exact lists; anything else is a regex; `FileChanged` matcher is always a literal filename list (hooks-doc)
- **Hook error transcript notices** — now show `<hook name> hook error` plus the first line of stderr instead of full stderr (hooks-doc)
- **Plugin hooks from force-enabled managed plugins** are exempt from the `allowManagedHooksOnly` restriction (hooks-doc)
- **MCP scope precedence expanded** — new scope table (Local/Project/User) and precedence list now includes plugin-provided servers and claude.ai connectors (mcp-doc)
- **MCP `anthropic/maxResultSizeChars` for text** now applies independently of `MAX_MCP_OUTPUT_TOKENS`; images are still bounded by the global cap; section renamed to "Raise the limit for a specific tool" (mcp-doc)
- **Claude Code on the web docs substantially reorganized** — new sections for GitHub authentication options, the cloud environment and installed tools table, resource limits (4 vCPU / 16 GB / 30 GB), network access levels (None/Trusted/Full/Custom with expanded default allowed-domains list), GitHub and security proxies, setup scripts vs SessionStart hooks (with `CLAUDE_CODE_REMOTE` checks), moving tasks between web and terminal, and session management with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`, `CLAUDE_CODE_AUTO_COMPACT_WINDOW`, and `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (headless-doc)
- **Nested CLAUDE.md files are not re-injected after compaction** — they reload only on the next file read in that subdirectory (memory-doc, features-doc)
- **Plugins docs rename "commands" to "skills"** — terminology updated throughout marketplace and plugin manifest documentation; symlinks are now preserved in the plugin cache rather than dereferenced (plugins-doc)
- **`/release-notes` picks up 2.1.96–2.1.101** — Apr 8–10 release notes added to the upstream changelog (operations-doc)
- **`claude setup-token` description updated** to note it prints the token to the terminal without saving it and requires a Claude subscription (cli-doc)
- **Status line cache example** now keys on `session_id` instead of a stable filename (features-doc)
- **Fast mode copy** — "extra usage credits" softened to "extra usage" (features-doc)
- **Web scheduled tasks** now reference `/web-setup` for GitHub authentication and use the updated `the-cloud-environment` anchor (features-doc)
- **Agent SDK URLs updated** in the headless reference (headless-doc)
- Minor wording, anchor, and AgentInstructions boilerplate updates across most other skill docs

## 26.4.8

**20 references updated across 13 skills:** best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc

### New
- **Bedrock Mantle endpoint** — new `CLAUDE_CODE_USE_MANTLE` env var routes requests through the Mantle API shape; supports running alongside the Invoke API, gateway routing with `CLAUDE_CODE_SKIP_MANTLE_AUTH`, and custom URLs via `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` (cloud-providers-doc, settings-doc, features-doc)
- **`sessionTitle` hook output field** — `UserPromptSubmit` hooks can now set the session title via `hookSpecificOutput.sessionTitle`, equivalent to `/rename` (hooks-doc)
- **Rate and reply to code review findings** — each review comment ships with thumbs-up/down reactions for one-click rating; reaction data is used to tune the reviewer (ci-cd-doc)
- **Application data section in `~/.claude` docs** — documents every data file Claude Code writes: transcripts, snapshots, debug logs, caches, and prompt history, with retention behavior and how to clear them (memory-doc)
- **"Model not found" troubleshooting section** — guides users through diagnosing `ANTHROPIC_MODEL` and settings-level model misconfigurations (operations-doc)
- **macOS Keychain troubleshooting** — documents login failures when the Keychain is locked or its password is out of sync, with `claude doctor` diagnostics (operations-doc)
- **`chat:clearInput` keybinding action** — new Chat-context action bound to `Ctrl+L` by default (cli-doc)
- **Plugins can ship output styles** — plugins may include an `output-styles/` directory (features-doc)

### Changed
- **`Ctrl+L` repurposed from screen redraw to clear prompt input** — `app:redraw` is now unbound by default; the new `chat:clearInput` action takes `Ctrl+L` (cli-doc)
- **Default effort level now varies by plan** — Pro and Max subscribers default to medium; API-key, Team, Enterprise, and third-party provider users default to high (features-doc)
- **"ultrathink" keyword clarified** — has no effect when the session is already at high or max effort (features-doc)
- **Hook stdout routing changed** — plain stdout on non-zero exit codes now goes to the debug log instead of the verbose-mode transcript; transcript shows only a one-line error notice (hooks-doc)
- **Exit code 1 does not block hook actions** — added a warning that only exit code 2 blocks, even though 1 is the conventional Unix failure code; `WorktreeCreate` is the exception (hooks-doc)
- **Debug hooks section rewritten** — `claude --debug` no longer prints to the terminal; use `claude --debug-file <path>` or `/debug` mid-session to write to a known log path (hooks-doc)
- **`suppressOutput` field updated** — now described as omitting stdout from the debug log rather than from verbose mode (hooks-doc)
- **Session storage described as plaintext JSONL** — transcripts stored at `~/.claude/projects/` with a link to the new application data reference (getting-started-doc, security-doc)
- **Cross-worktree session resume** — `/resume` now resumes sessions from other worktrees directly without requiring a directory change (best-practices-doc)
- **Ultraplan requirements tightened** — requires v2.1.91+; explicitly not available on Bedrock, Vertex AI, or Foundry (best-practices-doc)
- **Timeout env var defaults documented** — `API_TIMEOUT_MS` (600000, max 2147483647), `BASH_DEFAULT_TIMEOUT_MS` (120000), `BASH_MAX_TIMEOUT_MS` (600000), `MCP_TIMEOUT` (30000), `MCP_TOOL_TIMEOUT` (100000000) now show their default values (settings-doc)
- **Plugin skill naming uses frontmatter `name`** — skills declared via `"skills": ["./"]` now use the SKILL.md frontmatter `name` field for the invocation name instead of the directory basename (plugins-doc)
- **Plugin cache orphan cleanup** — previous plugin versions are marked orphaned on update/uninstall and deleted after a 7-day grace period (plugins-doc)
- **Changelog v2.1.94 added** — upstream changelog now includes the April 7 release notes (operations-doc)
- Minor wording/formatting updates across features-doc, ide-doc, plugins-doc docs

## 26.4.6

**30 references updated across 14 skills:** agent-teams-doc, best-practices-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, ide-doc, mcp-doc, operations-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`forceRemoteSettingsRefresh` managed setting** — blocks CLI startup until remote managed settings are freshly fetched; exits if the fetch fails (fail-closed enforcement) (settings-doc)
- **Interactive Bedrock setup wizard** — select "3rd-party platform" at the login screen to launch a guided wizard for AWS authentication, region, credential verification, and model pinning; `/setup-bedrock` reopens it later (cloud-providers-doc, cli-doc)
- **`--remote-control-session-name-prefix` flag and `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` env var** — set a prefix for auto-generated Remote Control session names; defaults to your hostname (features-doc, cli-doc, settings-doc)
- **`/ultraplan` command** — draft a plan in a cloud session, review it in your browser, then execute remotely or send it back to your terminal (cli-doc, features-doc, settings-doc)
- **Ultraplan disconnects Remote Control** — documented that starting an ultraplan session disconnects any active Remote Control session (features-doc)
- **Fenced ```` ```! ```` shell blocks in skills** — multi-line shell commands can use a fenced code block opened with ```` ```! ```` in addition to the inline `` !`command` `` syntax (skills-doc)
- **`/cost` per-model and cache-hit breakdown** — subscription users now see a per-model and cache-hit breakdown in `/cost` output (operations-doc)
- **`/release-notes` interactive version picker** — replaced the flat changelog view with a version picker (cli-doc)
- **Bedrock `PutUseCaseForModelAccess` API for AWS Organizations** — submit the use-case form once from a management account and approval extends to child accounts (cloud-providers-doc)
- **`--permission-mode` in headless mode** — documented passing a permission mode like `acceptEdits` with `-p` for non-interactive runs (headless-doc)

### Changed
- **Permission modes docs restructured** — rewrote the permission modes page with a summary table up front, collapsed auto mode internals into accordions, added a dedicated "Protected paths" section listing all guarded directories and files, and documented `.claude/worktrees` as an allowed exception (settings-doc)
- **VS Code mode selector labels renamed** — "Ask permissions" is now "Ask before edits" and "Auto accept edits" is now "Edit automatically" (settings-doc, ide-doc)
- **VS Code `initialPermissionMode` no longer accepts `auto`** — use `defaultMode` in `settings.json` instead to start in auto mode by default (ide-doc)
- **Desktop scheduled tasks moved to dedicated page** — the "Schedule recurring tasks" section was removed from the Desktop reference page and links now point to `/en/desktop-scheduled-tasks` (ide-doc, features-doc, getting-started-doc, best-practices-doc)
- **Agent team subagent definitions clarified** — the definition's body is appended to the teammate's system prompt (not replacing it), `skills` and `mcpServers` frontmatter fields are ignored on teammates, and teammates can message each other by name (agent-teams-doc, sub-agents-doc)
- **MCP `anthropic/maxResultSizeChars` wording clarified** — raises the persist-to-disk threshold, not a hard limit; does not bypass the global `MAX_MCP_OUTPUT_TOKENS` cap (mcp-doc)
- **`CLAUDE_CODE_TMPDIR` path convention updated** — appends `/claude-{uid}/` on Unix instead of `/claude/`; default on Linux is `os.tmpdir()` (settings-doc)
- **OAuth authentication scope broadened** — now described as supporting Team and Enterprise plans alongside Free, Pro, and Max (security-doc)
- **WSL sandbox limitation documented** — sandboxed commands cannot launch Windows binaries; use `excludedCommands` to run them outside the sandbox (operations-doc)
- **`CLAUDE_CODE_SKIP_FAST_MODE_NETWORK_ERRORS` env var removed** (settings-doc)
- **`/vim` command removed** — use `/config` then Editor mode instead (cli-doc)
- **`/pr-comments` command removed** — ask Claude directly to view pull request comments (cli-doc)
- **`/tag` command removed** (operations-doc)
- Minor wording/formatting updates across getting-started-doc, best-practices-doc, security-doc, cli-doc docs

## 26.4.3

**37 references updated across 16 skills:** best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`CLAUDE.local.md` files** — personal project-specific memory files that load alongside `CLAUDE.md` but are gitignored; `/init` creates one automatically (memory-doc, best-practices-doc, settings-doc, ide-doc)
- **Plugin `bin/` directory** — plugins can ship executables under `bin/` that are added to the Bash tool's `PATH` while the plugin is enabled (plugins-doc)
- **CLI marketplace management subcommands** — `claude plugin marketplace add|list|remove|update` for non-interactive scripting and automation (plugins-doc)
- **`CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` env var** — keeps existing marketplace cache when `git pull` fails instead of wiping it, for offline/airgapped environments (plugins-doc, settings-doc)
- **`CLAUDE_CODE_PLUGIN_CACHE_DIR` for seed builds** — set during image build so plugins install directly into the seed path, skipping the copy step (plugins-doc)
- **MCP `_meta["anthropic/maxResultSizeChars"]` annotation** — MCP servers can override per-tool result size limits up to 500K characters (mcp-doc, operations-doc)
- **OpenTelemetry distributed tracing (beta)** — export spans linking prompts to API requests and tool executions via `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` and `OTEL_TRACES_EXPORTER` (operations-doc)
- **`OTEL_LOG_TOOL_CONTENT` env var** — log full tool input/output content in trace spans, truncated at 60 KB (operations-doc)
- **Statusline `workspace.added_dirs` field** — exposes directories added via `/add-dir` or `--add-dir` (features-doc)
- **Statusline `session_name` field** — exposes the custom session name set with `--name` or `/rename` (features-doc)
- **`disableSkillShellExecution` setting** — disables inline shell execution in skills, custom slash commands, and plugin commands (operations-doc)
- **`confirm:toggle` keybinding** — Space key toggles selection in confirmation dialogs (cli-doc)
- **`app:redraw` keybinding** — `Ctrl+L` is now a rebindable action in the Global context (cli-doc)
- **`settings:close` keybinding** — Enter saves and closes the config panel; Escape discards changes (cli-doc)
- **`/powerup` command** — added to the slash commands reference table (cli-doc)
- **Subagent worktree auto-cleanup** — orphaned subagent worktrees are removed at startup after `cleanupPeriodDays` if they have no modifications or unpushed commits (best-practices-doc, settings-doc)
- **Sandbox `autoAllowBashIfSandboxed` interaction with ask rules** — documented that sandboxed Bash commands bypass `ask: Bash(*)` rules when this default-on setting is active (settings-doc)

### Changed
- **Computer use now available on Windows via Desktop app** — previously macOS-only; CLI remains macOS-only (ide-doc, getting-started-doc)
- **Protected directories include `.husky`** — `bypassPermissions`, `acceptEdits`, and `auto` modes now also protect `.husky` from unintended writes (settings-doc, sub-agents-doc)
- **`acceptEdits` mode excludes protected directories** — file edits in `.git`, `.claude`, `.vscode`, `.idea`, and `.husky` still prompt (settings-doc)
- **Permission mode comparison table updated** — reflects protected-directory behavior across all modes (settings-doc)
- **`allowed-tools` frontmatter accepts space-separated strings** — comma-separated format replaced by spaces or YAML lists in skill examples (skills-doc)
- **`/resume` picker shows interactive sessions only** — headless `claude -p` sessions no longer appear; use `--resume <id>` to resume them directly (best-practices-doc)
- **Sandbox `excludedCommands` example uses glob pattern** — `"docker"` changed to `"docker *"` in docs and examples (settings-doc, security-doc)
- **Seed marketplace mutation blocked** — `/plugin marketplace remove` and `update` against seed-managed marketplaces now fail with guidance (plugins-doc)
- **Sandbox auto-allow mode clarification** — explicit deny rules always respected; ask rules apply only to non-sandboxed fallback commands (security-doc)
- **`Ctrl+L` redraws the screen** — previously described as "clear terminal screen" (cli-doc)
- **`chat:undo` gains `Ctrl+Shift+-` binding** — additional default binding alongside `Ctrl+_` (cli-doc)
- **Transcript `q` key is now rebindable** — `transcript:exit` binding includes `q` alongside `Ctrl+C` and `Escape` (cli-doc)
- **`Alt+T` extended thinking toggle** — no longer requires `/terminal-setup`; just configure Option as Meta on macOS (cli-doc)
- **VS Code Meta key docs updated** — now references `terminal.integrated.macOptionIsMeta` setting instead of Profiles > Keys (cli-doc)
- **Windows download URLs use `/setup/` path** — Desktop app download links changed from `/exe/` to `/setup/` across multiple pages (getting-started-doc, ide-doc)
- **`cleanupPeriodDays` also controls worktree cleanup** — setting now governs both session and orphaned subagent worktree removal (settings-doc)
- **Deep link `q` parameter supports multi-line prompts** — URL-encoded newlines (`%0A`) are no longer rejected (settings-doc)
- **Analytics dashboard heading renamed** — "Teams and Enterprise" changed to "Team and Enterprise" throughout (operations-doc)
- Minor wording/formatting updates across ci-cd-doc, cloud-providers-doc, headless-doc, operations-doc, getting-started-doc docs

### Removed
- **Fullscreen keybinding customization paragraph** — removed the paragraph about rebinding `scroll:*` actions and listing additional unbound scroll actions (features-doc)
- **`claude commit` from quickstart cheat sheet** — removed from the essential commands table (getting-started-doc)

## 26.4.2

**30 references updated across 13 skills:** best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **`PermissionDenied` hook event** — fires when the auto mode classifier denies a tool call; return `{retry: true}` to tell the model it may retry (hooks-doc, plugins-doc)
- **`"defer"` permission decision for `PreToolUse` hooks** — pauses a headless `-p` session at a tool call so an Agent SDK wrapper can collect input and resume with `--resume` (hooks-doc)
- **`best` model alias** — uses the most capable available model, currently equivalent to `opus` (features-doc)
- **`default` model alias clarification** — `default` now documented as a special value that clears any model override, not itself a model alias (features-doc)
- **`color` subagent frontmatter field** — set a display color (`red`, `blue`, `green`, etc.) for a subagent in the task list and transcript (sub-agents-doc)
- **`auto` permission mode for subagents** — subagent `permissionMode` field now accepts `auto` alongside `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, and `plan` (sub-agents-doc)
- **Managed subagents** — organization admins can deploy subagents via managed settings; managed definitions take highest priority (sub-agents-doc)
- **`MCP_CONNECTION_NONBLOCKING` env var** — skip the MCP connection wait in non-interactive mode when MCP tools are not needed (settings-doc)
- **`showThinkingSummaries` setting** — show extended thinking summaries in interactive sessions instead of collapsed stubs (settings-doc)
- **`forceLoginOrgUUID` array support** — now accepts an array of UUIDs to allow any listed organization, not just a single UUID (settings-doc)
- **1M token context window on Bedrock** — Opus 4.6 and Sonnet 4.6 support the extended context window on Amazon Bedrock; append `[1m]` to model ID (cloud-providers-doc)
- **GPG-signed release manifests** — binary integrity verification now uses a detached GPG signature on `manifest.json` with step-by-step verification instructions (getting-started-doc)
- **`/powerup` command** — interactive lessons teaching Claude Code features with animated demos (operations-doc)
- **Auto mode denied actions in `/permissions`** — denied actions now appear in `/permissions` under the Recently denied tab; press `r` to mark for retry (settings-doc)
- **Hook output character cap** — hook output injected into context is capped at 10,000 characters; larger output is saved to a file (hooks-doc)
- **PowerShell install troubleshooting** — added note about `&&` token separator error when running CMD installer in PowerShell (getting-started-doc)
- **iTerm2 mouse reporting note** — fullscreen mode mouse wheel scrolling requires Enable mouse reporting in iTerm2 profile settings (features-doc)
- **Plugin marketplace worktree behavior** — relative `directory`/`file` marketplace paths resolve against the main checkout, not the worktree (plugins-doc)

### Changed
- **Scheduled task expiry extended from 3 days to 7 days** — recurring tasks now expire after 7 days instead of 3 (features-doc)
- **`cleanupPeriodDays` setting** — setting to `0` is now rejected; minimum is 1; use `--no-session-persistence` to disable transcript writes (settings-doc)
- **Bedrock default primary model** — changed from `global.anthropic.claude-sonnet-4-6` to `us.anthropic.claude-sonnet-4-5-20250929-v1:0` (cloud-providers-doc)
- **Vertex AI default primary model** — changed from `claude-sonnet-4-6` to `claude-sonnet-4-5@20250929` (cloud-providers-doc)
- **`permissions.disableBypassPermissionsMode` key path** — corrected to use `permissions.` prefix; `disableAutoMode` similarly corrected to `permissions.disableAutoMode` (settings-doc)
- **Bash subagent removed from built-in agents table** — the Bash helper agent no longer listed as a separate built-in subagent (sub-agents-doc)
- **`--agent-teams` flag removal** — agent teams now enabled only via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, `--agent-teams` flag removed (sub-agents-doc)
- **Output styles token usage** — removed claim that all styles exclude conciseness instructions; added section on token usage by style (features-doc, best-practices-doc)
- **Network config URL roles clarified** — `storage.googleapis.com` is the primary download bucket; `downloads.claude.ai` hosts install scripts, manifests, signing keys, and plugin executables (security-doc)
- **PreToolUse decision precedence** — documented that when multiple hooks return different decisions, precedence is `deny` > `defer` > `ask` > `allow` (hooks-doc)
- Minor wording/formatting updates across cli-doc, ide-doc, ci-cd-doc, plugins-doc docs

## 26.4.1

**22 references updated across 13 skills:** cli-doc, cloud-providers-doc, features-doc, headless-doc, hooks-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`--agent-teams` flag** — enable agent teams from the CLI without setting the env var; makes `SendMessage`, `TeamCreate`, and `TeamDelete` tools available (cli-doc)
- **`SendMessage`, `TeamCreate`, `TeamDelete` tools** — new built-in tools for agent teams, gated behind `--agent-teams` or `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (cli-doc)
- **LSP tool behavior section** — dedicated reference section for the LSP tool covering auto-error-reporting after edits, jump-to-definition, find-references, and other navigation operations (cli-doc)
- **`--debug-file` flag** — write debug logs to a specific file path; implicitly enables debug mode (cli-doc)
- **`--replay-user-messages` flag** — re-emit user messages from stdin back on stdout for SDK acknowledgment (cli-doc)
- **`--include-partial-messages` now requires `--verbose`** — updated prerequisite flags documented (cli-doc)
- **`ANTHROPIC_BEDROCK_BASE_URL` env var** — override Bedrock endpoint URL for custom endpoints or gateways (settings-doc, cloud-providers-doc)
- **`ANTHROPIC_VERTEX_BASE_URL` env var** — override Vertex AI endpoint URL for custom endpoints or gateways (settings-doc, cloud-providers-doc)
- **`ANTHROPIC_BETAS` env var** — comma-separated beta header values that work with all auth methods, not just API keys (settings-doc)
- **`ANTHROPIC_VERTEX_PROJECT_ID` env var** — documented in env vars reference (settings-doc)
- **`API_TIMEOUT_MS` env var** — configurable API request timeout, default 10 minutes (settings-doc)
- **`CLAUDE_CODE_ACCESSIBILITY` env var** — keep native terminal cursor visible for screen magnifiers (settings-doc)
- **`CLAUDE_CODE_AUTO_CONNECT_IDE` env var** — override automatic IDE connection behavior (settings-doc)
- **`CLAUDE_CODE_DEBUG_LOGS_DIR` and `CLAUDE_CODE_DEBUG_LOG_LEVEL` env vars** — configure debug log file path and minimum log level (settings-doc)
- **`CLAUDE_CODE_DISABLE_ATTACHMENTS` env var** — disable `@` file expansion (settings-doc)
- **`CLAUDE_CODE_DISABLE_CLAUDE_MDS` env var** — prevent loading any CLAUDE.md memory files (settings-doc)
- **`CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING` env var** — disable file checkpointing and `/rewind` (settings-doc)
- **`CLAUDE_CODE_DISABLE_LEGACY_MODEL_REMAP` env var** — prevent automatic remapping of Opus 4.0/4.1 to current version (settings-doc)
- **`CLAUDE_CODE_DISABLE_THINKING` env var** — force-disable extended thinking (settings-doc)
- **`CLAUDE_CODE_ENABLE_FINE_GRAINED_TOOL_STREAMING` env var** — force-enable fine-grained tool input streaming on Anthropic API (settings-doc)
- **`CLAUDE_CODE_GIT_BASH_PATH` env var** — Windows path to Git Bash executable (settings-doc)
- **`CLAUDE_CODE_GLOB_HIDDEN`, `CLAUDE_CODE_GLOB_NO_IGNORE`, `CLAUDE_CODE_GLOB_TIMEOUT_SECONDS` env vars** — Glob tool configuration for dotfiles, gitignore, and timeout (settings-doc)
- **`CLAUDE_CODE_IDE_HOST_OVERRIDE` and `CLAUDE_CODE_IDE_SKIP_VALID_CHECK` env vars** — IDE connection overrides (settings-doc)
- **`CLAUDE_CODE_MAX_RETRIES` env var** — override API retry count (settings-doc)
- **`CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY` env var** — control parallel tool/subagent execution (settings-doc)
- **`CLAUDE_CODE_OAUTH_REFRESH_TOKEN`, `CLAUDE_CODE_OAUTH_SCOPES`, `CLAUDE_CODE_OAUTH_TOKEN` env vars** — OAuth authentication for automated environments (settings-doc)
- **`CLAUDE_CODE_OTEL_FLUSH_TIMEOUT_MS`, `CLAUDE_CODE_OTEL_SHUTDOWN_TIMEOUT_MS` env vars** — OpenTelemetry timing configuration (settings-doc)
- **`CLAUDE_CODE_PLUGIN_CACHE_DIR` env var** — override plugins root directory (settings-doc)
- **`CLAUDE_CODE_RESUME_INTERRUPTED_TURN` env var** — auto-resume interrupted turns in SDK mode (settings-doc)
- **`CLAUDE_CODE_SYNC_PLUGIN_INSTALL` and `CLAUDE_CODE_SYNC_PLUGIN_INSTALL_TIMEOUT_MS` env vars** — synchronous plugin installation for `-p` mode (settings-doc)
- **`CLAUDE_CODE_SYNTAX_HIGHLIGHT` env var** — disable syntax highlighting in diff output (settings-doc)
- **`CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS` and `CLAUDE_AGENT_SDK_MCP_NO_PREFIX` env vars** — SDK-specific controls for subagents and MCP tool naming (settings-doc)
- **`CLAUDE_AUTO_BACKGROUND_TASKS` env var** — force-enable automatic backgrounding of long-running subagents (settings-doc)
- **`CLAUDE_ENABLE_STREAM_WATCHDOG` env var** — abort stalled API streams after 90s idle (settings-doc)
- **`DISABLE_AUTO_COMPACT` and `DISABLE_COMPACT` env vars** — disable automatic or all compaction (settings-doc)
- **`DISABLE_DOCTOR_COMMAND`, `DISABLE_EXTRA_USAGE_COMMAND`, `DISABLE_INSTALL_GITHUB_APP_COMMAND`, `DISABLE_LOGIN_COMMAND`, `DISABLE_LOGOUT_COMMAND`, `DISABLE_UPGRADE_COMMAND` env vars** — hide individual commands (settings-doc)
- **`DISABLE_INTERLEAVED_THINKING` env var** — prevent interleaved thinking beta header for incompatible gateways (settings-doc)
- **`ENABLE_PROMPT_CACHING_1H_BEDROCK` env var** — request 1-hour prompt cache TTL on Bedrock (settings-doc)
- **`FALLBACK_FOR_ALL_PRIMARY_MODELS` env var** — extend fallback model behavior beyond Opus (settings-doc)
- **`MAX_STRUCTURED_OUTPUT_RETRIES` env var** — configure JSON schema validation retries (settings-doc)
- **`MCP_CONNECTION_NONBLOCKING` env var** — skip MCP connection wait in `-p` mode (operations-doc)
- **`MCP_REMOTE_SERVER_CONNECTION_BATCH_SIZE` and `MCP_SERVER_CONNECTION_BATCH_SIZE` env vars** — parallel MCP server connection limits (settings-doc)
- **`OTEL_LOG_TOOL_CONTENT`, `OTEL_LOG_TOOL_DETAILS`, `OTEL_LOG_USER_PROMPTS`, `OTEL_METRICS_INCLUDE_*` env vars** — granular OpenTelemetry data controls (settings-doc)
- **`TASK_MAX_OUTPUT_LENGTH` env var** — subagent output truncation limit (settings-doc)
- **Ctrl+J for newlines** — sends a line feed character, works in any terminal without configuration (cli-doc)
- **Right arrow accepts prompt suggestions** — in addition to Tab (cli-doc)
- **`"defer"` permission decision in PreToolUse hooks** — headless sessions can pause at a tool call and resume with `-p --resume` (operations-doc, hooks-doc)
- **Hooks and permission modes section** — PreToolUse hooks fire before permission-mode checks; `deny` blocks even in `bypassPermissions` mode (hooks-doc)
- **Authentication loop troubleshooting for Bedrock SSO** — guidance for corporate proxy/VPN SSO loops and removing `awsAuthRefresh` (cloud-providers-doc)
- **Auto-fix comment-triggered automation warning** — caution about Claude replies triggering Atlantis, Terraform, or GitHub Actions on `issue_comment` events (headless-doc)
- **Additional directories configuration discovery section** — table of what `.claude/` config is and isn't loaded from `--add-dir` directories (settings-doc, skills-doc, sub-agents-doc)
- **`disableBypassPermissionsMode` works from any scope** — noted it can be set in user settings, not just managed (settings-doc)
- **`pluginTrustMessage` and `channelsEnabled` managed-only settings** — added to managed-only settings reference table (settings-doc)
- **`sandbox.filesystem.allowManagedReadPathsOnly` clarified** — `denyRead` still merges from all sources (security-doc)
- **v2.1.89 changelog entry** — `defer` hook decision, `MCP_CONNECTION_NONBLOCKING`, autocompact thrash loop fix, numerous bug fixes (operations-doc)

### Changed
- **CLAUDE.md recommended size reduced from ~500 to 200 lines** — updated guidance across features overview and costs docs (features-doc, operations-doc)
- **`CLAUDE_CODE_NEW_INIT` value changed from `true` to `1`** — consistent with other boolean env vars (memory-doc, cli-doc)
- **`FORCE_AUTOUPDATE_PLUGINS` and `DISABLE_AUTOUPDATER` values normalized to `1`** — previously documented as `true` (plugins-doc, settings-doc)
- **`CLAUDE_CODE_PROXY_RESOLVES_HOSTS` value changed from `true` to `1`** (settings-doc)
- **`CLAUDE_CODE_ENABLE_TASKS` value changed from `true` to `1`** (settings-doc)
- **`IS_DEMO` value changed from `true` to `1`** (settings-doc)
- **`MCPSearch` renamed to `ToolSearch`** in permission deny rule examples (mcp-doc)
- **`--add-dir` description clarified** — grants file access only; most `.claude/` configuration not discovered from added directories (cli-doc, skills-doc, sub-agents-doc)
- **Vertex AI per-model region variables updated** — examples now show `VERTEX_REGION_CLAUDE_HAIKU_4_5` and `VERTEX_REGION_CLAUDE_4_6_SONNET` instead of older model names (cloud-providers-doc)
- **`CLAUDE_CONFIG_DIR` description expanded** — explains multiple account setup with alias example (settings-doc)
- **`CLAUDE_STREAM_IDLE_TIMEOUT_MS` now requires `CLAUDE_ENABLE_STREAM_WATCHDOG=1`** — watchdog is opt-in, not always active (settings-doc)
- **Hook multiple-match behavior documented** — most restrictive decision wins; `additionalContext` kept from all hooks (hooks-doc)
- **Hook `updatedInput` conflict warning** — when multiple PreToolUse hooks rewrite tool input, last to finish wins non-deterministically (hooks-doc)
- **Hook `additionalContext` clarified** — injected as a system reminder that Claude reads as plain text, cannot trigger commands (hooks-doc)
- **Hook output over 50K characters saved to disk** — file path + preview injected instead of full content (operations-doc)
- **Edit tool no longer requires separate Read call** — works on files viewed via Bash `sed -n` or `cat` (operations-doc)
- **`cleanupPeriodDays: 0` now rejected** — previously silently disabled transcript persistence (operations-doc)
- **Managed settings precedence clarified** — server-managed checked first, then endpoint-managed; sources do not merge (settings-doc)
- **Settings table sorted alphabetically** — all keys in available-settings table reordered A-Z (settings-doc)
- **Tools reference intro expanded** — added guidance on disabling tools, adding custom tools via MCP, and extending via skills (cli-doc)
- **`SendMessage` tool requires agent teams** — documented that agent teams must be enabled for subagent resume (sub-agents-doc)

### Removed
- **`CLAUDE_CODE_ACCOUNT_UUID`, `CLAUDE_CODE_ORGANIZATION_UUID`, `CLAUDE_CODE_USER_EMAIL` env vars** — removed from env vars reference (settings-doc)
- **`CLAUDE_CODE_PLAN_MODE_REQUIRED` env var** — removed from env vars reference (settings-doc)

## 26.3.31

**22 references updated across 13 skills:** agent-teams-doc, ci-cd-doc, cli-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **Subagent definitions for agent team teammates** — teammates can reference a subagent type by name and inherit its system prompt, tools, and model (agent-teams-doc, sub-agents-doc)
- **Code Review troubleshooting section** — how to retrigger failed/timed-out reviews with `@claude review once`, and where to find findings that aren't showing as inline comments (ci-cd-doc)
- **GitHub Enterprise Server support for Code Review and cloud sessions** — self-hosted GHES instances supported for Teams and Enterprise plans (ci-cd-doc, headless-doc)
- **`/web-setup` command** — connect GitHub to Claude Code on the web from the terminal using local `gh` CLI credentials (headless-doc)
- **`CLAUDE_CODE_NO_FLICKER` env var** — opt into fullscreen alt-screen rendering that reduces flicker and keeps memory flat in long sessions (settings-doc, cli-doc)
- **`CLAUDE_CODE_DISABLE_MOUSE` env var** — disable mouse tracking in fullscreen rendering to keep native copy-on-select (settings-doc)
- **`CLAUDE_CODE_SCROLL_SPEED` env var** — set mouse wheel scroll multiplier (1-20) in fullscreen rendering (settings-doc)
- **Computer use listed as CLI integration** — platforms comparison now shows computer use available in CLI on Pro and Max via `/mcp` (getting-started-doc, ide-doc)
- **GHES firewall allowlisting** — allowlist Anthropic API IP addresses so cloud infrastructure can reach self-hosted GHES instances (security-doc)
- **v2.1.87 and v2.1.88 changelog entries** — Cowork Dispatch fix, `CLAUDE_CODE_NO_FLICKER`, `PermissionDenied` hook, numerous bug fixes including prompt cache misses, CRLF doubling, and OOM on large files (operations-doc)

### Changed
- **Model pinning with `ANTHROPIC_DEFAULT_*_MODEL` env vars** — documented how to pin what the Default option and `sonnet`/`opus`/`haiku` aliases resolve to, since `model` setting is initial selection not enforcement (features-doc)
- **Scheduled tasks minimum interval** — cron expressions that fire more frequently than once per hour are now rejected (features-doc)
- **`bypassPermissions` now prompts for some writes** — writes to `.git`, `.vscode`, `.idea`, and `.claude` (except commands/agents/skills) still require confirmation (settings-doc)
- **Auto mode prompt injection defense documented** — server-side probe scans tool results before Claude reads them; classifier never sees tool results so injected instructions cannot influence approvals (settings-doc)
- **Auto mode available on Enterprise and API plans** — previously documented as Team-only with Enterprise "rolling out shortly" (settings-doc, cli-doc, ide-doc)
- **`--permission-mode` accepted values listed** — `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`; overrides `defaultMode` from settings (cli-doc, settings-doc)
- **`--allow-dangerously-skip-permissions` clarified** — adds `bypassPermissions` to the `Shift+Tab` cycle without starting in it (cli-doc)
- **Voice dictation privacy notice** — clarified that audio is streamed to Anthropic servers for transcription, not processed locally (features-doc)
- **Hook debug output simplified** — verbose hook matcher details moved behind `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`; default `--debug` shows fewer lines (hooks-doc)
- **TaskCreated exit code 2 wording** — changed from "prevents creation" to "rolls back the task creation" (hooks-doc)
- **Desktop computer use setup reformatted** — enable steps presented as numbered sequence; Settings path updated to "Settings > General" (ide-doc)
- **Dev Containers extension name updated** — "Remote - Containers" renamed to "Dev Containers" throughout devcontainer setup (security-doc)
- **Plugin marketplace GHES reference** — regex host allowlisting now recommended for GitHub Enterprise Server and self-hosted GitLab (plugins-doc)
- **Agent team config is runtime state** — clarified that team config is auto-generated and should not be hand-edited; use subagent definitions for reusable roles (agent-teams-doc)

## 26.3.29

**6 references updated across 6 skills:** cli-doc, cloud-providers-doc, hooks-doc, security-doc, settings-doc, skills-doc

### New
- **`X-Claude-Code-Session-Id` request header** — documented new header sent on every API request; proxies can use it to aggregate requests per session (cloud-providers-doc)
- **macOS notification troubleshooting for hooks** — accordion explaining how to grant Script Editor notification permission when `osascript` notifications fail silently (hooks-doc)

### Changed
- **`CLAUDE_CODE_SIMPLE` preserves `--mcp-config` tools** — MCP tools passed via `--mcp-config` are now available even in simple/bare mode (settings-doc)
- **Skill description 250-character truncation** — descriptions longer than 250 characters are truncated in the skill listing; front-load the key use case (skills-doc)
- **Skill metadata budget reduced to 1% / 8,000 chars** — `SLASH_COMMAND_TOOL_CHAR_BUDGET` default changed from 2% / 16,000 to 1% / 8,000; all skill names are always included but descriptions may be shortened (skills-doc, settings-doc)
- Minor wording/formatting updates across cli-doc, security-doc docs

## 26.3.28

**12 references updated across 8 skills:** agent-teams-doc, best-practices-doc, cli-doc, hooks-doc, mcp-doc, memory-doc, operations-doc, settings-doc

### New
- **`--tmux` CLI flag** — create a tmux session for a worktree; requires `--worktree`; auto-detects iTerm2 native panes, pass `--tmux=classic` for traditional tmux (cli-doc)
- **`if` field for hooks** — filter individual hook handlers with permission rule syntax (e.g., `Bash(git *)`, `Edit(*.ts)`) so hooks only spawn when the tool call matches; works on `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, and `PermissionRequest` events (hooks-doc)
- **`AskUserQuestion` tool in PreToolUse** — hook into multiple-choice questions Claude asks the user; supply `updatedInput` with an `answers` object to answer programmatically in headless mode (hooks-doc)
- **`ExitPlanMode` tool in PreToolUse** — now hookable alongside `AskUserQuestion`; return `permissionDecision: "allow"` with `updatedInput` for non-interactive flows (hooks-doc)
- **`CLAUDE_CODE_MCP_SERVER_NAME` / `CLAUDE_CODE_MCP_SERVER_URL` env vars for `headersHelper`** — write a single helper script that serves multiple MCP servers by reading which server triggered it (mcp-doc)
- **`disableDeepLinkRegistration` setting** — set to `"disable"` to prevent Claude Code from registering the `claude-cli://` protocol handler on startup (settings-doc)
- **`.worktreeinclude` in file explorer** — new entry in the interactive explorer and file reference table documenting the worktree include file (memory-doc)
- **v2.1.86 changelog entry** — `X-Claude-Code-Session-Id` header, `.jj`/`.sl` VCS exclusions, numerous bug fixes, reduced token overhead for `@` mentions and Read tool, improved prompt cache hit rate for Bedrock/Vertex/Foundry (operations-doc)

### Changed
- **Worktree base branch documented** — worktrees branch from `origin/HEAD`; instructions for re-syncing with `git remote set-head origin -a` or setting an explicit branch; WorktreeCreate hook noted as full override for custom base selection (best-practices-doc)
- **`.worktreeinclude` skipped with WorktreeCreate hooks** — custom VCS hooks replace default git behavior entirely, so `.worktreeinclude` is not processed; copy files inside the hook script instead (best-practices-doc, hooks-doc)
- **`updatedInput` replaces entire input object** — PreToolUse and PermissionRequest docs now clarify that `updatedInput` replaces all fields, so unchanged fields must be included (hooks-doc)
- **OAuth metadata discovery clarified** — default flow now described as RFC 9728 Protected Resource Metadata first, then RFC 8414 authorization server metadata fallback (mcp-doc)
- **`ENABLE_TOOL_SEARCH` values reworded** — unset now described as "all MCP tools deferred"; `auto` described as threshold mode loading upfront when tools fit within context percentage (mcp-doc, settings-doc)
- **`OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER` accept `none`** — explicitly disable an exporter while keeping telemetry enabled (operations-doc)
- **`tool_input` truncation details** — individual values over 512 characters are truncated, full payload bounded to ~4K characters (operations-doc)
- **`teammateMode` setting location** — now points to global config `~/.claude.json` instead of generic settings.json reference (agent-teams-doc)
- Minor wording/formatting updates across cli-doc, memory-doc, operations-doc, settings-doc docs

## 26.3.27

**24 references updated across 16 skills:** agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`.worktreeinclude` file** — copy gitignored files like `.env` and `.env.local` into new worktrees automatically; uses `.gitignore` syntax and applies to `--worktree`, subagent worktrees, and desktop app parallel sessions (best-practices-doc, ide-doc)
- **`@claude review once`** — run a single code review without subscribing the PR to push-triggered reviews; manual triggers now also work on draft PRs (ci-cd-doc)
- **Code Review check run output** — severity summary table in the Details link, per-line annotations in the Files changed tab, and a machine-readable JSON comment for CI parsing via `gh` and jq (ci-cd-doc)
- **Auto-fix pull requests** — Claude Code on the web can watch a PR and automatically respond to CI failures and review comments; available via the CI status bar, mobile app, or by pasting a PR URL (headless-doc)
- **`chat:newline` keybinding action** — insert a newline without submitting; unbound by default, assignable via keybindings config (cli-doc)
- **Chord unbinding** — unbind all chords sharing a prefix to free it for a single-key binding; partial unbinding still enters chord-wait mode (cli-doc)
- **`TaskCreated` hook fully documented** — input schema with `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name`; decision control via exit code 2 or `continue: false` JSON; example enforcing ticket-number naming conventions (hooks-doc, agent-teams-doc, plugins-doc)
- **Remote Control troubleshooting** — three new entries for subscription required, full-scope token required, and stale organization info errors (features-doc)
- **`paths` skill frontmatter field** — glob patterns that limit when a skill auto-activates; accepts comma-separated string or YAML list, same format as path-specific rules (skills-doc)

### Changed
- **MCP tool search is now on by default** — only tool names load at session start; full schemas are deferred until Claude needs a specific tool; `ENABLE_TOOL_SEARCH=auto` reverts to the old threshold-based mode (features-doc, getting-started-doc, mcp-doc, operations-doc)
- **Auto memory limit adds 25KB cap** — MEMORY.md loads the first 200 lines or 25KB, whichever comes first (getting-started-doc, memory-doc, sub-agents-doc)
- **`OTEL_LOG_TOOL_DETAILS` now gates `tool_parameters` too** — bash commands, MCP server/tool names, and skill names in tool_result events require `OTEL_LOG_TOOL_DETAILS=1`; security docs simplified accordingly (operations-doc)
- **Code Review severity label renamed** — "Normal" is now "Important" in the severity table (ci-cd-doc)
- **`Ctrl+U` description corrected** — now reads "Delete from cursor to line start" with note about repeating to clear across multiline input (cli-doc)
- **Context window visualization page linked** — new `/en/context-window` interactive walkthrough referenced from best-practices, features overview, how-it-works, memory, and sub-agents docs (best-practices-doc, features-doc, getting-started-doc, memory-doc, sub-agents-doc)
- **MCP local config takes precedence over claude.ai connectors** — when a server is configured both locally and through a connector, the local configuration wins (mcp-doc)
- **MCP tool description truncation** — tool descriptions and server instructions are truncated at 2KB each; authors advised to keep them concise (mcp-doc)
- **`CLAUDE_STREAM_IDLE_TIMEOUT_MS` env var added** — configure the streaming idle watchdog threshold; default 90s (settings-doc)
- **`allowedChannelPlugins` managed setting documented** — allowlist for channel plugins that may push messages; requires `channelsEnabled: true` (settings-doc)
- Minor wording/formatting updates across getting-started-doc, hooks-doc, operations-doc, settings-doc, skills-doc docs

## 26.3.26

**23 references updated across 11 skills:** cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **PowerShell tool (opt-in preview)** — run PowerShell commands natively on Windows via `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`; auto-detects `pwsh.exe` with fallback to `powershell.exe`; `defaultShell`, hook `shell`, and skill `shell` frontmatter control where PowerShell is used (cli-doc, getting-started-doc, settings-doc, hooks-doc, skills-doc)
- **Pinned model display and capability overrides** — `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_NAME`, `_DESCRIPTION`, and `_SUPPORTED_CAPABILITIES` env vars customize the `/model` picker label and declare `effort`, `max_effort`, `thinking`, `adaptive_thinking`, `interleaved_thinking` for third-party provider models (features-doc, settings-doc)
- **`allowedChannelPlugins` managed setting** — Team/Enterprise admins can define a channel plugin allowlist that replaces the default Anthropic allowlist; requires `channelsEnabled: true` (features-doc, settings-doc)
- **`TaskCreated` hook event** — fires when a task is created via `TaskCreate` (operations-doc)
- **`WorktreeCreate` HTTP hook support** — return worktree path via `hookSpecificOutput.worktreePath` in the response JSON (hooks-doc, plugins-doc)
- **VS Code URI handler** — `vscode://anthropic.claude-code/open` opens a Claude Code tab from external tools; supports `prompt` and `session` query parameters (ide-doc)
- **AGENTS.md import** — import `AGENTS.md` from `CLAUDE.md` so repositories using other coding agents share instructions without duplication (memory-doc)
- **HTML comment stripping in CLAUDE.md** — block-level HTML comments are stripped before injection into context, saving tokens while preserving notes for human maintainers (memory-doc)
- **`CLAUDE_STREAM_IDLE_TIMEOUT_MS` env var** — configure the streaming idle watchdog threshold (default 90s) (settings-doc)
- **Transcript viewer shortcuts** — `Ctrl+E` toggles show-all content; `q`/`Ctrl+C`/`Esc` exits transcript view (cli-doc)
- **`chat:killAgents` keybinding** — `Ctrl+X Ctrl+K` replaces `Ctrl+F` for killing all background agents (cli-doc)
- **`chat:fastMode` keybinding** — `Alt+O` toggles fast mode (cli-doc)
- **`footer:up` / `footer:down` keybinding actions** — navigate vertically in footer (cli-doc)
- **`useAutoModeDuringPlan` setting** — controls whether plan mode uses auto mode semantics when available (settings-doc)
- **`sandbox.failIfUnavailable` setting** — documented in sandboxing page with full explanation of behavior (security-doc)

### Changed
- **Effort level defaults clarified** — Opus 4.6 and Sonnet 4.6 both default to medium effort across all providers; `max` can now persist via `CLAUDE_CODE_EFFORT_LEVEL` env var; "ultrathink" keyword triggers high effort for a single turn (features-doc)
- **Enterprise channels controls rewritten** — channels page now documents `channelsEnabled` and `allowedChannelPlugins` as two separate managed settings with a detailed table; Pro/Max users without an org skip checks entirely (features-doc)
- **`CwdChanged` and `FileChanged` hooks fully documented** — hook guide adds direnv reload example; hook reference adds full input/output schemas, `watchPaths` output, `CLAUDE_ENV_FILE` support, and matcher semantics for `FileChanged` (hooks-doc)
- **Plugin hook events table updated** — adds `CwdChanged` and `FileChanged` to the lifecycle events table (plugins-doc)
- **Plugin manifest `commands`/`agents`/`skills`/`outputStyles` now replace defaults** — custom paths replace the default directory instead of supplementing it; include the default in your array to keep both (plugins-doc)
- **Plugin `userConfig` and `channels` manifest fields** — new sections document user-configurable values prompted at enable time and channel declarations (plugins-doc)
- **`/copy` command gains `w` key** — press `w` in the code block picker to write selection to a file instead of clipboard (cli-doc)
- **`/plan` accepts optional description** — `/plan fix the auth bug` enters plan mode and starts immediately (cli-doc)
- **`/status` works during responses** — no longer waits for current response to finish (cli-doc)
- **`/debug` enables debug logging mid-session** — debug logging is off by default; `/debug` starts capturing from that point forward (skills-doc)
- **`claude plugin` CLI command added** — new top-level command for managing plugins with alias `claude plugins` (cli-doc)
- **Background task output uses Read tool** — output is written to a file; `TaskOutput` tool is deprecated in favor of `Read` (cli-doc)
- **`OTEL_LOG_TOOL_DETAILS` expanded** — now also logs tool input arguments (truncated to 512 chars per value, ~4K total) in addition to MCP/skill names (operations-doc)
- **`CLAUDE_ENV_FILE` description updated** — now mentions `CwdChanged` and `FileChanged` hooks alongside `SessionStart` (settings-doc)
- **`managed-settings.d/` drop-in directory documented in settings page** — merge semantics (alphabetical, deep-merge, arrays concatenated) and precedence within managed tier clarified (settings-doc)
- **Hook events support `command` and `http` types** — many events previously documented as command-only now support HTTP hooks; `SessionStart` remains command-only (hooks-doc)
- **Subagent model resolution order documented** — `CLAUDE_CODE_SUBAGENT_MODEL` > per-invocation > frontmatter > main conversation model (sub-agents-doc)
- **Subagent `initialPrompt` frontmatter** — auto-submitted as first user turn when running as main session agent via `--agent` (sub-agents-doc)
- **Rules/skills `paths:` frontmatter accepts YAML list of globs** (operations-doc)
- Minor wording/formatting updates across getting-started-doc, memory-doc, features-doc docs

## 26.3.25

**20 references updated across 11 skills:** best-practices-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, operations-doc, settings-doc, sub-agents-doc

### New
- **Auto mode permission mode** — classifier-based permission mode that reviews tool calls with background safety checks, blocking scope escalation, unknown infrastructure, and hostile-content-driven actions; available on Team plans with Sonnet 4.6 or Opus 4.6; cycles via `Shift+Tab`, `--permission-mode auto`, or `--enable-auto-mode` flag (best-practices-doc, cli-doc, getting-started-doc, hooks-doc, ide-doc, settings-doc, sub-agents-doc)
- **`autoMode` settings block** — configure the auto mode classifier with `environment`, `allow`, and `soft_deny` prose rules to define trusted repos, buckets, and domains; read from user, local, and managed settings but not shared project settings (settings-doc)
- **`claude auto-mode defaults` / `config` / `critique` CLI subcommands** — inspect built-in classifier rules, view effective config with settings applied, and get AI feedback on custom rules (cli-doc, settings-doc)
- **`--enable-auto-mode` CLI flag** — unlock auto mode in the `Shift+Tab` cycle; requires Team plan and Sonnet 4.6 or Opus 4.6 (cli-doc)
- **`disableAutoMode` setting** — set to `"disable"` to prevent auto mode activation; works in user, project, and managed settings (settings-doc, ide-doc)
- **iMessage channel** — reads Messages database directly, sends replies via AppleScript; requires macOS, no bot token; self-chat bypasses access control, other senders added by handle with `/imessage:access allow` (features-doc)
- **MCP `headersHelper` for dynamic authentication headers** — run a shell command at connection time to generate custom HTTP headers (e.g., Kerberos, short-lived tokens); 10-second timeout, runs fresh on each connect (mcp-doc)
- **`managed-settings.d/` drop-in directory** — deploy independent policy fragments alongside `managed-settings.json` that merge alphabetically (operations-doc)
- **`CwdChanged` and `FileChanged` hook events** — reactive environment management hooks, e.g. for direnv (operations-doc)
- **`sandbox.failIfUnavailable` setting** — exit with error when sandbox cannot start instead of running unsandboxed (operations-doc)
- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`** — strip Anthropic and cloud provider credentials from subprocess environments (operations-doc)
- **Transcript search** — press `/` in transcript mode (`Ctrl+O`) to search, `n`/`N` to step through matches (operations-doc)
- **`Ctrl+X Ctrl+E` external editor alias** — readline-native binding alongside `Ctrl+G` (operations-doc, cli-doc)
- **Subagent `initialPrompt` frontmatter** — agents can auto-submit a first turn (operations-doc)
- **Plugin `userConfig` options** — plugins can prompt for configuration at enable time, with `sensitive: true` values stored in keychain (operations-doc)

### Changed
- **Permission modes documentation restructured** — permission modes now have their own dedicated page (`/en/permission-modes`); links updated across all docs (best-practices-doc, cli-doc, ide-doc, settings-doc, sub-agents-doc)
- **`Shift+Tab` cycles through all enabled modes** — description updated from "toggle" to "cycle through `default`, `acceptEdits`, `plan`, and any enabled modes such as `auto` or `bypassPermissions`" (cli-doc)
- **`--dangerously-skip-permissions` removed from best practices** — replaced with auto mode as the recommended approach for reducing interruptions; warning about `--dangerously-skip-permissions` removed (best-practices-doc)
- **`allowDangerouslySkipPermissions` VS Code setting repurposed** — now enables both Auto and Bypass permissions in the mode selector, not just bypass (ide-doc)
- **`initialPermissionMode` VS Code setting** — now accepts `auto` as a value (ide-doc)
- **`disableBypassPermissionsMode` managed setting key changed** — now namespaced as `permissions.disableBypassPermissionsMode` (ide-doc)
- **`permission_mode` hook field** — now includes `"auto"` as a possible value (hooks-doc)
- **LiteLLM security warning** — PyPI versions 1.82.7 and 1.82.8 flagged as compromised with credential-stealing malware; remediation steps linked (cloud-providers-doc)
- **Plugin MCP `.mcp.json` example fixed** — corrected to include the required `mcpServers` wrapper object (mcp-doc)
- **Desktop `@mention` unavailable in remote sessions** — clarified limitation for remote sessions (ide-doc)
- **"Stop all background agents" keybinding changed** — from `Ctrl+F` to `Ctrl+X Ctrl+K` to stop shadowing readline forward-char (operations-doc)
- **`Ctrl+M` documented as non-rebindable** — identical to Enter in terminals (both send CR) (cli-doc)
- **Subagent `permissionMode` inheritance with auto mode** — subagents inherit auto mode from parent and frontmatter override is ignored; classifier evaluates subagent tool calls with parent rules (sub-agents-doc)
- **Settings precedence applies uniformly across CLI, VS Code, and JetBrains** — clarified in settings docs (settings-doc)
- **Quickstart page rebuilt with interactive install configurator** — React-based UI with Terminal/Desktop/VS Code/JetBrains tabs, team/provider selection, and platform-specific install commands (getting-started-doc)
- **v2.1.83 changelog entry added** — covers managed-settings.d, CwdChanged/FileChanged hooks, sandbox.failIfUnavailable, transcript search, auto mode, and dozens of bug fixes (operations-doc)

### Removed
- **`disableBypassPermissionsMode` from managed-only settings table** — setting moved to `permissions.disableBypassPermissionsMode` and is no longer managed-only (settings-doc)

## 26.3.24

**9 references updated across 8 skills:** best-practices-doc, cli-doc, features-doc, getting-started-doc, headless-doc, ide-doc, plugins-doc, security-doc

### New
- **Computer use on Desktop** — research preview (macOS, Pro/Max plans) lets Claude open apps, control the screen, and interact with GUIs; includes per-app permission tiers (view-only, click-only, full control), denied-app list, and window-hiding behavior (ide-doc)
- **Dispatch sessions** — send a task from the Claude mobile app and get a Desktop Code session; Dispatch badge in sidebar, push notifications on completion, 30-minute app-approval window for computer use (ide-doc, getting-started-doc, features-doc)
- **Cloud scheduled tasks** — run on Anthropic-managed infrastructure without your machine on; create via `/schedule` CLI command, web UI, or Desktop app; minimum 1-hour interval; connectors configured per task (cli-doc, features-doc, ide-doc, headless-doc, best-practices-doc, getting-started-doc)
- **`/schedule` slash command** — create, update, list, or run cloud scheduled tasks conversationally from the CLI (cli-doc)
- **Scheduling options comparison table** — side-by-side matrix of Cloud vs Desktop vs `/loop` covering where tasks run, persistence, local file access, MCP servers, and minimum interval (features-doc, ide-doc, best-practices-doc)
- **"Choose the right approach" table for remote work** — compares Dispatch, Remote Control, Channels, Slack, and Scheduled tasks by trigger, runtime, and setup (features-doc)
- **"What sandboxing does not cover" section** — documents that built-in file tools (Read/Edit/Write) bypass the sandbox and computer use runs on the real desktop (security-doc)

### Changed
- **Desktop scheduled tasks split into local and remote** — task grid now shows both kinds; "New task" prompts for local vs remote; local task docs scoped to machine-only behavior (ide-doc)
- **Scheduled tasks page links to Cloud tasks for durable scheduling** — replaced single Desktop/GitHub Actions references with Cloud/Desktop/GitHub Actions alternatives throughout (features-doc)
- **Connectors note for remote sessions updated** — clarifies that cloud scheduled tasks configure connectors at task creation time instead of via the + button (ide-doc)
- **Plugin marketplace example command fixed** — corrected `/review` to `/quality-review` to match the actual plugin name in the walkthrough (plugins-doc)
- Minor wording/formatting updates across getting-started-doc, ide-doc docs

## 26.3.23

**26 references updated across 14 skills:** ci-cd-doc, cli-doc, features-doc, getting-started-doc, headless-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`--bare` CLI flag** — skip auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md for faster scripted `-p` calls; requires `ANTHROPIC_API_KEY` or `apiKeyHelper` via `--settings` (cli-doc, headless-doc)
- **Channel permission relay** — channels that declare `claude/channel/permission` can forward tool approval prompts remotely; full walkthrough with `permission_request` notification fields, verdict format, and assembled example (features-doc)
- **`showClearContextOnPlanAccept` setting** — controls whether the "clear context" option appears on the plan accept screen; defaults to `false` (settings-doc)
- **`autoConnectIde` global config key** — automatically connect to a running IDE from an external terminal (settings-doc)
- **`autoInstallIdeExtension` global config key** — control automatic IDE extension installation from VS Code terminals (settings-doc)
- **`editorMode` global config key** — set Vim or normal key binding mode directly in `~/.claude.json` (settings-doc)
- **`user.account_id` OTEL attribute** — tagged format matching Anthropic admin APIs, controlled by `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` (operations-doc)
- **`prompt.id` and `workspace.host_paths` event attributes** — correlate events per prompt and identify desktop app workspace directories (operations-doc)
- **`source: 'settings'` inline marketplace source** — declare plugin entries directly in `settings.json` without a hosted marketplace repository (settings-doc)
- **Hooks in managed settings** — server-managed settings now support hooks with the same format as `settings.json`, with security approval dialog (settings-doc)
- **`effort` frontmatter for skills** — override effort level per skill; options are `low`, `medium`, `high`, `max` (skills-doc)
- **Rate limit usage statusline section** — new dedicated section with Bash and Python examples for displaying 5h/7d rate limit windows (features-doc)
- **How channels compare table** — compares channels to web sessions, Slack, MCP, and Remote Control (features-doc)
- **tmux passthrough configuration** — `set -g allow-passthrough on` required for notifications and progress bar to reach outer terminal (cli-doc)

### Changed
- **`--allowedTools` is now the canonical flag name** — `--allowed-tools` still works as an alias (ci-cd-doc, cli-doc)
- **`--channels` flag description reworded** — clarified as research preview requiring Claude.ai authentication (cli-doc)
- **Remote Control/web sessions admin controls restructured** — no longer a managed settings key; controlled via Claude Code admin settings page (ide-doc, settings-doc)
- **Blocking hooks take precedence over allow rules** — clarified that exit code 2 stops tool calls before permission rules are evaluated (settings-doc)
- **`includeGitInstructions` setting expanded** — now also controls git status snapshot in system prompt (settings-doc)
- **Plugin agent frontmatter fields documented** — `model`, `effort`, `maxTurns`, `disallowedTools`, and other supported fields now listed; unsupported security fields noted (plugins-doc)
- **Subagent `tools` vs `disallowedTools` interaction clarified** — `disallowedTools` applied first, then `tools` resolved against remaining pool (sub-agents-doc)
- **MCP OAuth CIMD support** — Client ID Metadata Document (SEP-991) now auto-discovered for servers without Dynamic Client Registration (mcp-doc)
- **Sandbox `allowRead` path resolution clarified** — `.` resolves relative to the settings file location (security-doc)
- **Channel bot token storage path changed** — Telegram/Discord `.env` files now save to `~/.claude/channels/` instead of project-level `.claude/channels/` (features-doc)
- **Ctrl+O also expands collapsed MCP read/search calls** — shows full output instead of single "Queried" line (cli-doc)
- **`terminalProgressBarEnabled` supported terminals updated** — ConEmu, Ghostty 1.2.0+, and iTerm2 3.6.6+ replace generic "Windows Terminal and iTerm2" (settings-doc)
- **Context window description updated** — now mentions auto memory alongside CLAUDE.md (getting-started-doc)
- **`pip` removed as a marketplace plugin source type** (plugins-doc)
- **Plugin discover page** — added `claude.com/plugins` web catalog link and concrete install example (plugins-doc)
- Minor wording/formatting updates across memory-doc, features-doc, skills-doc docs

### Removed
- **`allow_remote_sessions` managed settings key** — replaced by admin settings toggle for Remote Control and web sessions (settings-doc)

## 26.3.20

**17 references updated across 10 skills:** cli-doc, features-doc, getting-started-doc, hooks-doc, mcp-doc, operations-doc, plugins-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **`--channels` CLI flag** — enable MCP channel servers to push messages (Telegram, Discord, webhooks) into a session (cli-doc)
- **`--dangerously-load-development-channels` CLI flag** — load unapproved channel servers for local development with a confirmation prompt (cli-doc)
- **Channels feature documented across docs** — MCP servers can declare the `claude/channel` capability to push messages into sessions; new "Channels" row in integration table and cross-references added (features-doc, getting-started-doc, mcp-doc)
- **`channelsEnabled` managed setting** — Team/Enterprise admins can allow or block channel message delivery regardless of `--channels` flag (settings-doc)
- **`effort` frontmatter for skills and subagents** — override model effort level per-skill or per-subagent; inherits from session by default; env var still takes precedence (features-doc, sub-agents-doc)
- **`rate_limits` field in statusline scripts** — exposes 5-hour and 7-day Claude.ai rate limit windows with `used_percentage` and `resets_at` (operations-doc)
- **`source: 'settings'` plugin marketplace source** — declare plugin entries inline in `settings.json` (operations-doc)
- **Workspace trust requirement for status line** — `statusLine` now requires workspace trust acceptance; shows `statusline skipped · restart to fix` notification if trust is not accepted (features-doc)
- **`resume` reason for `SessionEnd` hooks** — fires when switching sessions via interactive `/resume` (hooks-doc)
- **`knowledge-work-plugins` added to reserved marketplace names** (plugins-doc)

### Changed
- **`SessionEnd` hooks timeout scope expanded** — now applies to `/resume` session switching in addition to exit and `/clear` (hooks-doc, settings-doc)
- **Subagent memory wizard option renamed** — "Enable" changed to "User scope" in the `/agents` wizard memory step (sub-agents-doc)
- **`--agents` flag supported fields expanded** — now lists `effort`, `background`, and `isolation` alongside existing fields (sub-agents-doc)
- **Marketplace allowlist source count wording generalized** — "seven marketplace source types" changed to "multiple marketplace source types" (settings-doc)
- **`/reload-plugins` wording updated** — "reloaded commands" changed to "plugins" in reload output description (plugins-doc)
- **CLI tool usage detection added to plugin tips** — in addition to file pattern matching (operations-doc)
- Minor wording/formatting updates across getting-started-doc, skills-doc docs

## 26.3.19

**20 references updated across 11 skills:** best-practices-doc, cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **`ANTHROPIC_CUSTOM_MODEL_OPTION` env var for `/model` picker** — add a custom model entry without replacing built-in aliases; useful for LLM gateways; optional `_NAME` and `_DESCRIPTION` suffix vars control display; validation is skipped for the custom model ID (features-doc, settings-doc)
- **Built-in IDE MCP server documented** — the VS Code extension runs a local `ide` MCP server on `127.0.0.1` with two model-visible tools: `mcp__ide__getDiagnostics` (reads Problems panel) and `mcp__ide__executeCode` (runs Python cells in Jupyter with a Quick Pick confirmation); auth token is per-activation and stored in `~/.claude/ide/` (ide-doc)
- **`/remote-control` in VS Code** — bridge a VS Code session to claude.ai/code from the command menu (ide-doc, operations-doc)
- **AI-generated session titles in VS Code** — new sessions automatically receive titles based on the first message (ide-doc, operations-doc)
- **`--console` flag for `claude auth login`** — sign in with Anthropic Console for API usage billing instead of a Claude subscription (cli-doc, operations-doc)
- **`StopFailure` matcher support** — `StopFailure` hook event now supports matchers filtering on error type: `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` (hooks-doc)
- **`InstructionsLoaded` matcher support** — `InstructionsLoaded` now supports matchers filtering on `load_reason`: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` (hooks-doc)
- **`Elicitation` and `ElicitationResult` matcher support** — these events now support matchers filtering on MCP server name (hooks-doc)
- **Remote Control troubleshooting expanded** — new sections for "not yet enabled for your account" (env var conflicts), "disabled by your organization's policy" (API key vs OAuth, admin toggle, compliance), and restructured "credentials fetch failed" (features-doc)
- **Subagent persistent memory step in `/agents` wizard** — new "Configure memory" step to enable a persistent memory directory at `~/.claude/agent-memory/` during agent creation (sub-agents-doc)
- **"Show turn duration" toggle in `/config`** — `showTurnDuration` is now configurable from the `/config` menu instead of requiring direct `~/.claude.json` edits (settings-doc, operations-doc)

### Changed
- **`/bug` command renamed to `/feedback`** — all references updated to `/feedback`; env var `DISABLE_BUG_COMMAND` renamed to `DISABLE_FEEDBACK_COMMAND` (old name still accepted); `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` now references `DISABLE_FEEDBACK_COMMAND` (security-doc, settings-doc, operations-doc)
- **`bypassPermissions` mode clarified** — no longer described as "skips all permission checks"; now documented as skipping prompts except for writes to `.git`, `.claude`, `.vscode`, and `.idea` directories (with `.claude/commands`, `.claude/agents`, `.claude/skills` exempt) (settings-doc, cli-doc, ide-doc, best-practices-doc, sub-agents-doc)
- **Sandbox path prefix `//` deprecated in favor of `/`** — single-slash `/path` is now the standard absolute path prefix for sandbox filesystem rules; double-slash `//path` still works; `./path` is project-relative for project settings or `~/.claude`-relative for user settings (security-doc, settings-doc)
- **Remote Control admin toggle wording updated** — Team and Enterprise plans now state the toggle is "off by default" rather than requiring admins to "enable Claude Code" (features-doc)
- **Remote Control session title priority documented** — title is chosen from `--name`, `/rename`, last message, or first prompt (in that order) instead of the previous flat description (features-doc)
- **`CLAUDE_CODE_PLUGIN_SEED_DIR` now supports multiple directories** — paths separated by `:` on Unix or `;` on Windows; first seed containing a given cache wins (plugins-doc, settings-doc)
- **Plugin hook events table expanded** — replaced flat list with structured table matching user-defined hooks; added `StopFailure`, `InstructionsLoaded`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `Elicitation`, `ElicitationResult` events; added `http` hook type (plugins-doc)
- **`permission_mode` removed from several hook JSON examples** — `SessionStart`, `InstructionsLoaded`, `Notification`, `SubagentStart`, `ConfigChange`, `PreCompact`, `PostCompact`, and `SessionEnd` examples no longer show `permission_mode`; noted that not all events receive this field (hooks-doc)
- **Subagent `/agents` wizard UI updated** — "User-level" renamed to "Personal"; agent creation step descriptions reworded; new "save and edit" option with `e` key (sub-agents-doc)
- **Subagent persistent memory recommended scope changed** — `project` is now the recommended default scope instead of `user`, as it is shareable via version control (sub-agents-doc)
- **Upstream changelog updated** — new release v2.1.79 covering `--console` auth flag, turn duration toggle, `-p` mode fixes, voice mode fix, rate limit retry fix, `SessionEnd` hook fix, 18MB startup memory reduction, and VS Code `/remote-control` and AI-generated titles (operations-doc)
- Minor wording/formatting updates across getting-started-doc, operations-doc, plugins-doc docs

## 26.3.18

**27 references updated across 15 skills:** best-practices-doc, ci-cd-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **`/voice` command and push-to-talk voice dictation** — new `/voice` command toggles voice dictation; hold Space in chat to dictate; rebindable via `voice:pushToTalk` keybinding; requires a Claude.ai account (cli-doc, settings-doc)
- **`/branch` command** — `/fork` renamed to `/branch` (`/fork` kept as alias); forked sessions now grouped under `/branch` in docs (cli-doc, best-practices-doc)
- **`--agent` flag and `agent` setting** — run an entire session as a named subagent with its system prompt, tool restrictions, and model; set per-project via `agent` in settings or per-session via `--agent <name>` (sub-agents-doc, settings-doc)
- **@-mention subagents** — type `@` and pick a subagent from the typeahead to guarantee it runs for one task; plugin subagents appear as `<plugin>:<agent>` (sub-agents-doc)
- **`${CLAUDE_PLUGIN_DATA}` persistent data directory** — new variable for plugin state that survives updates; resolves to `~/.claude/plugins/data/{id}/`; auto-created on first reference; deleted on uninstall (with `--keep-data` opt-out) (plugins-doc, mcp-doc, hooks-doc)
- **`ANTHROPIC_BASE_URL` env var** — override the API endpoint for proxy/gateway routing; disables MCP tool search on non-first-party hosts by default (settings-doc)
- **`CLAUDE_CODE_NEW_INIT` env var** — set to `true` for an interactive `/init` flow that walks through CLAUDE.md, skills, and hooks setup (cli-doc, memory-doc, settings-doc)
- **`CLAUDE_CODE_PLUGIN_SEED_DIR` env var** — pre-populate a read-only plugins directory for container images and CI; seed marketplaces and caches are used at startup without re-cloning (plugins-doc, settings-doc)
- **`ANTHROPIC_CUSTOM_MODEL_OPTION` env var** — add a custom entry to the `/model` picker, with optional `_NAME` and `_DESCRIPTION` suffixed vars (operations-doc)
- **`sandbox.filesystem.allowRead` setting** — re-allow reading specific paths within `denyRead` regions; takes precedence over `denyRead`; arrays merge across scopes (security-doc, settings-doc)
- **`sandbox.filesystem.allowManagedReadPathsOnly` managed setting** — when `true`, only managed `allowRead` entries are respected; user/project/local entries ignored (security-doc, settings-doc)
- **`system/api_retry` streaming event** — new event emitted on retryable API errors with attempt number, delay, error status, and error category (headless-doc)
- **`StopFailure` hook event** — fires when a turn ends due to an API error such as rate limit or auth failure (operations-doc)
- **`PostCompact` matcher support** — `PostCompact` hook now supports `manual`/`auto` matchers alongside `PreCompact` (hooks-doc)
- **`InstructionsLoaded` `load_reason: "compact"` value** — fires when instruction files are re-loaded after a compaction event (hooks-doc)
- **Authentication precedence documentation** — new section documenting the full credential resolution order: cloud providers, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_API_KEY`, `apiKeyHelper`, then OAuth (getting-started-doc)
- **Managed CLAUDE.md vs managed settings guidance** — new comparison table clarifying when to use settings (enforcement) vs CLAUDE.md (behavioral guidance) (memory-doc)
- **Remote Control troubleshooting section** — documents `Remote credentials fetch failed` error, `--verbose` flag for debugging, and common causes (features-doc)
- **"Disabled organization" troubleshooting** — new section explaining how a stale `ANTHROPIC_API_KEY` overrides an active subscription and how to fix it (operations-doc)
- **Plugin `effort`, `maxTurns`, and `disallowedTools` agent frontmatter** — plugin-shipped agents now support these frontmatter fields (operations-doc)
- **Plugin validator expanded** — now checks skill/agent/command YAML frontmatter and `hooks/hooks.json` in addition to `plugin.json`; new warnings for non-kebab-case plugin names (plugins-doc)
- **Background task 5GB output limit** — background tasks are automatically terminated if output exceeds 5GB (cli-doc)
- **Network allowlist additions** — `downloads.claude.ai` and `storage.googleapis.com` added to required URLs for native installer and updates (security-doc)

### Changed
- **`ANTHROPIC_SMALL_FAST_MODEL` renamed to `ANTHROPIC_DEFAULT_HAIKU_MODEL`** — env var renamed across Bedrock and Vertex AI docs (cloud-providers-doc)
- **`/copy` now accepts an argument** — `/copy N` copies the Nth-latest response instead of only the last (cli-doc)
- **PreToolUse hook `"allow"` semantics clarified** — `"allow"` skips the interactive prompt but deny and ask rules (including managed deny lists) still apply; documented in both guide and reference (hooks-doc, settings-doc)
- **Compound command "don't ask again" saves per-subcommand rules** — approving `git status && npm test` saves a separate rule for each subcommand; up to 5 rules per compound command (settings-doc)
- **Read/Edit deny rules scoped to built-in tools only** — new warning that deny rules do not block Bash subprocesses; sandbox recommended for OS-level enforcement (settings-doc)
- **`MAX_THINKING_TOKENS` description updated** — ceiling is now model's max output minus one; on adaptive-reasoning models, budget is ignored unless adaptive reasoning is disabled (settings-doc, best-practices-doc, operations-doc)
- **`CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` expanded** — now also strips beta tool-schema fields (`defer_loading`, `eager_input_streaming`) in addition to `anthropic-beta` headers (settings-doc)
- **`CLAUDE_CODE_MAX_OUTPUT_TOKENS` description updated** — defaults and caps now vary by model rather than fixed at 32k/64k (settings-doc)
- **`showTurnDuration` and `terminalProgressBarEnabled` moved to global config** — these are now stored in `~/.claude.json` instead of `settings.json` (settings-doc)
- **Credential storage on Linux/Windows documented** — credentials stored in `~/.claude/.credentials.json` (or `$CLAUDE_CONFIG_DIR`) with mode `0600` on Linux; macOS remains Keychain (getting-started-doc)
- **Slow `apiKeyHelper` warning** — Claude Code now shows a notice if `apiKeyHelper` takes longer than 10 seconds (getting-started-doc)
- **Session auto-naming from plans** — accepting a plan automatically names the session from the plan content unless already named (best-practices-doc)
- **VS Code terminal option-as-meta instructions separated** — VS Code now has its own `terminal.integrated.macOptionIsMeta` setting note, separate from iTerm2 instructions (cli-doc)
- **tmux passthrough for terminal notifications** — notifications now reach the outer terminal inside tmux with `set -g allow-passthrough on` (operations-doc)
- **Subagent resumption via `SendMessage`** — stopped subagents auto-resume in background when they receive a `SendMessage`; no new `Agent` invocation needed (sub-agents-doc)
- **`${CLAUDE_PLUGIN_ROOT}` description clarified** — now explicitly noted as changing on each plugin update (plugins-doc, hooks-doc)
- **Windows path normalization for permissions** — paths normalized to POSIX form before matching; `C:\Users\alice` becomes `/c/Users/alice` (settings-doc)
- **Upstream changelog updated** — new release v2.1.78 covering `StopFailure` hook, `${CLAUDE_PLUGIN_DATA}`, agent frontmatter fields, tmux passthrough, line-by-line streaming, and 20+ bug fixes (operations-doc)
- Minor wording/formatting updates across ci-cd-doc, cloud-providers-doc, getting-started-doc, mcp-doc, operations-doc docs

## 26.3.17

**15 references updated across 9 skills:** cli-doc, features-doc, hooks-doc, mcp-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **Auto-approve permission prompts via hooks** — new `PermissionRequest` hook guide example showing how to auto-approve specific tool calls (e.g. `ExitPlanMode`) and optionally set a session permission mode with `updatedPermissions` (hooks-doc)
- **Permission update entries reference** — new table documenting `addRules`, `replaceRules`, `removeRules`, `setMode`, `addDirectories`, and `removeDirectories` entry types with `destination` field for `PermissionRequest` hook output and `permission_suggestions` input (hooks-doc)
- **`CLAUDECODE` env var** — set to `1` in shell environments Claude Code spawns (Bash tool, tmux sessions); use to detect when a script runs inside Claude Code (settings-doc)
- **`CLAUDE_CODE_SKIP_FAST_MODE_NETWORK_ERRORS` env var** — allow fast mode when the organization status check fails due to a network error, useful behind corporate proxies (settings-doc)
- **Plugin subagent security restriction** — `hooks`, `mcpServers`, and `permissionMode` frontmatter fields are now ignored for plugin subagents; copy the agent file to `.claude/agents/` if you need them (sub-agents-doc)

### Changed
- **Fast mode pricing simplified** — removed the >200K context tier; pricing is now flat at $30/$150 per MTok across the full 1M context window; 50% launch discount mention removed (features-doc)
- **`/reload-plugins` now reloads all component types** — reloads commands, skills, agents, hooks, plugin MCP servers, and plugin LSP servers; LSP no longer requires a full restart (plugins-doc, mcp-doc, cli-doc)
- **Hook settings file changes picked up automatically** — file watcher now detects hook edits without requiring a session restart or `/hooks` menu review (hooks-doc)
- **`permission_suggestions` format changed** — `toolAlwaysAllow` replaced with structured `addRules` entries specifying `toolName`, `ruleContent`, `behavior`, and `destination` (hooks-doc)
- **Session quality surveys enabled on all providers** — surveys now appear on Bedrock, Vertex, and Foundry by default (previously disabled); use `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY`, `DISABLE_TELEMETRY`, or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` to suppress; `feedbackSurveyRate` setting now controls frequency (security-doc, settings-doc)
- **Upstream changelog updated** — new release v2.1.77 covering 64k default output tokens for Opus 4.6, `allowRead` sandbox setting, `/copy N`, compound bash rule fix, auto-updater memory fix, and 30+ bug fixes (operations-doc)
- Minor wording/formatting updates across plugins-doc, settings-doc, features-doc docs (table alignment, shell script style changes in statusline examples, managed settings JSON nesting fix)

## 26.3.14

**33 references updated across 15 skills:** best-practices-doc, cli-doc, cloud-providers-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **MCP elicitation support** — MCP servers can now request structured input mid-task via interactive dialogs (form fields or browser URL); new `Elicitation` and `ElicitationResult` hooks to intercept and auto-respond programmatically (mcp-doc, hooks-doc)
- **`PostCompact` hook** — fires after context compaction completes; receives the generated summary in `compact_summary`; supports `manual` and `auto` matchers (hooks-doc)
- **`/effort` slash command** — set model effort level directly with `/effort low`, `/effort medium`, `/effort high`, `/effort max`, or `/effort auto` (features-doc, operations-doc)
- **`max` effort level** — new fourth effort level providing deepest reasoning with no token constraint; available on Opus 4.6 only and applies to the current session without persisting (features-doc)
- **`--effort` CLI flag** — pass `low`, `medium`, `high`, or `max` to set effort level for a single session at launch (features-doc)
- **`opus[1m]` model alias** — Opus 4.6 now supports the 1M token context window alongside Sonnet; use `/model opus[1m]` or append `[1m]` to pinned model IDs (features-doc, cloud-providers-doc)
- **`-n` / `--name` CLI flag** — set a display name for the session at startup (operations-doc, best-practices-doc)
- **`worktree.sparsePaths` setting** — configure git sparse-checkout paths for `--worktree` in large monorepos to check out only the directories you need (settings-doc, operations-doc)
- **Remote Control server mode with `--spawn` and `--capacity`** — `claude remote-control` now supports concurrent sessions; `--spawn same-dir|worktree` controls isolation and `--capacity N` sets the max (features-doc)
- **Remote Control `--remote-control` / `--rc` flag for interactive sessions** — start a normal interactive session that is also controllable remotely from claude.ai (features-doc)
- **`[1m]` suffix for pinned third-party models** — append `[1m]` to `ANTHROPIC_DEFAULT_OPUS_MODEL` or `ANTHROPIC_DEFAULT_SONNET_MODEL` to enable extended context for pinned deployments (features-doc)
- **GitHub Enterprise IP allow list guidance** — new section on configuring IP allow lists for Claude Code on the web and Code Review when using GitHub Enterprise Cloud (security-doc)
- **Hook source labels in permission prompts** — when a `PreToolUse` hook returns `"ask"`, the permission prompt now shows a label identifying the hook's origin (e.g. `[User]`, `[Project]`, `[Plugin]`) (hooks-doc)
- **Multiple CLI-defined subagents** — `--agents` JSON now accepts multiple subagent definitions in a single call (sub-agents-doc)

### Changed
- **Environment variables extracted to dedicated page** — the full env vars table moved from the settings page to a standalone `/en/env-vars` reference; all cross-references updated (settings-doc, and links across 12+ skills)
- **Tools reference moved** — `Tools available to Claude` moved from settings page to `/en/tools-reference`; links updated in how-it-works, sub-agents, and common-workflows docs (settings-doc, getting-started-doc, sub-agents-doc)
- **Built-in commands moved** — references to built-in commands changed from `/en/interactive-mode#built-in-commands` to `/en/commands` across docs (cli-doc, headless-doc, ide-doc, skills-doc, features-doc)
- **1M context window pricing simplified** — no longer billed at long-context premium; standard model pricing applies; Opus 1M included for Max/Team/Enterprise plans without extra usage (features-doc, cloud-providers-doc)
- **Opus 4.6 1M context on Vertex AI** — now GA (no longer beta); Opus 4.6 added alongside Sonnet models; beta header no longer required (cloud-providers-doc)
- **Adaptive reasoning expanded to Sonnet 4.6** — docs now state Opus 4.6 "and Sonnet 4.6" support adaptive reasoning (best-practices-doc)
- **`MAX_THINKING_TOKENS` behavior updated** — now ignored on both Opus 4.6 and Sonnet 4.6 (previously only Opus); setting to 0 still disables thinking on any model (best-practices-doc)
- **`/hooks` menu is now read-only** — hooks can no longer be added or deleted through the interactive menu; use settings JSON or ask Claude to make changes (hooks-doc)
- **Hook setup guide rewritten for JSON-first workflow** — the "Set up your first hook" walkthrough now starts by editing `settings.json` directly instead of using the `/hooks` menu (hooks-doc)
- **Desktop notification hook examples rewritten** — common-workflows notification setup now shows full JSON configuration blocks per platform instead of just the shell command (best-practices-doc)
- **CLI reference tables restructured** — commands, flags, and system prompt flags split into separate tables with clearer grouping; interactive-mode content trimmed (cli-doc)
- **CLAUDE.md compliance explanation clarified** — now states content is delivered as a user message after the system prompt, not as part of it; recommends `--append-system-prompt` for system-prompt-level instructions (memory-doc)
- **Bundled skills table reformatted** — changed from bullet list to a table with `<arg>` / `[arg]` notation for required vs optional arguments (skills-doc)
- **Async hook completion messages suppressed by default** — now only visible in verbose mode or transcript mode (hooks-doc)
- **Deprecated Windows managed settings path removed** — `C:\ProgramData\ClaudeCode\managed-settings.json` no longer supported; must use `C:\Program Files\ClaudeCode\` (settings-doc, operations-doc)
- **Upstream changelog updated** — two new releases (v2.1.75, v2.1.76) covering MCP elicitation, `/effort`, `/color`, session naming, `PostCompact` hook, `worktree.sparsePaths`, Remote Control server mode, and 30+ bug fixes (operations-doc)
- Minor wording/formatting updates across getting-started-doc, security-doc, ide-doc, cloud-providers-doc docs (UTM parameter additions to pricing/contact-sales links, table alignment fixes)

## 26.3.13

**21 references updated across 15 skills:** agent-teams-doc, best-practices-doc, ci-cd-doc, cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, sub-agents-doc

### New
- **Manual Code Review trigger (`@claude review`)** — comment `@claude review` on a PR to start a review and opt that PR into push-triggered reviews; new "Manual" trigger mode added alongside the renamed "Once after PR creation" and "After every push" modes (ci-cd-doc)
- **`autoMemoryDirectory` setting** — configure a custom directory for auto-memory storage; accepted from policy, local, and user settings but blocked from project settings to prevent redirecting writes to sensitive paths (memory-doc, settings-doc)
- **`CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` env var** — configure how long SessionEnd hooks may run (default 1.5 s); applies to both session exit and `/clear`; per-hook `timeout` is capped by this budget (hooks-doc, settings-doc)
- **Subagent `mcpServers` field** — scope MCP servers to individual subagents via inline definitions or named references; inline servers connect on start and disconnect on finish, keeping tools out of the parent context (sub-agents-doc)
- **`strictKnownMarketplaces` + `extraKnownMarketplaces` usage guide** — new "Using both together" section explains that `strictKnownMarketplaces` is a policy gate only and must be paired with `extraKnownMarketplaces` to auto-register marketplaces (settings-doc, plugins-doc)
- **Full model ID support for subagents** — the `model` field in subagent YAML frontmatter and `--agents` JSON now accepts full model IDs like `claude-opus-4-6` in addition to short aliases (sub-agents-doc, cli-doc)
- **Version requirements added** — docs now state minimum CLI versions: agent teams (v2.1.32), keybindings (v2.1.18), fast mode (v2.1.36), remote control (v2.1.51), scheduled tasks (v2.1.72), auto memory (v2.1.59) (agent-teams-doc, cli-doc, features-doc, memory-doc)

### Changed
- **Tool search default behavior changed** — tool search is now enabled by default instead of `auto`; disabled automatically when `ANTHROPIC_BASE_URL` points to a non-first-party host; `ENABLE_TOOL_SEARCH=true` forces it on for proxies (mcp-doc, settings-doc)
- **Code Review pricing clarification** — usage is billed separately through extra usage and does not count against plan's included usage (ci-cd-doc)
- **`/context` command description expanded** — now mentions optimization suggestions for context-heavy tools, memory bloat, and capacity warnings (cli-doc)
- **MessageSelector keybindings expanded** — `Ctrl+P` / `Ctrl+N` added as defaults for up/down navigation in message selector (cli-doc)
- **`--plugin-dir` override behavior documented** — local plugin with the same name as an installed marketplace plugin takes precedence for that session, except for force-enabled managed plugins (plugins-doc)
- **Relative path resolution for marketplace plugins clarified** — paths resolve relative to the marketplace root (the directory containing `.claude-plugin/`), not to `marketplace.json`; `../` is disallowed (plugins-doc)
- **Git URL field no longer requires `.git` suffix** — supports `https://` and `git@` URLs; Azure DevOps and AWS CodeCommit URLs without `.git` now work (plugins-doc)
- **Settings table expanded** — 30+ keys newly documented in the reference table including `cleanupPeriodDays`, `companyAnnouncements`, `availableModels`, `allowManagedHooksOnly`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`, `allowManagedPermissionRulesOnly`, `allowManagedMcpServersOnly`, `blockedMarketplaces`, `pluginTrustMessage`, `alwaysThinkingEnabled`, `plansDirectory`, `showTurnDuration`, `spinnerVerbs`, `language`, `autoUpdatesChannel`, `spinnerTipsEnabled`, `spinnerTipsOverride`, `terminalProgressBarEnabled`, `prefersReducedMotion`, `fastModePerSessionOptIn`, `teammateMode`, and others (settings-doc)
- **Upstream changelog replaced with proper markdown** — previously stored as raw GitHub HTML, now correct markdown content (operations-doc)

### Removed
- **`--dangerously-skip-permissions` section removed from best practices** — the "Safe autonomous mode" section recommending `--dangerously-skip-permissions` with sandboxing has been dropped (best-practices-doc)
- **`CLAUDE_CODE_ENABLE_TASKS=false` fallback removed** — the tip about reverting to the previous TODO list is no longer documented (cli-doc)

## 26.3.12

**6 references updated across 5 skills:** cli-doc, cloud-providers-doc, features-doc, operations-doc, settings-doc

### New
- **`modelOverrides` setting** — maps individual Anthropic model IDs to provider-specific strings (e.g. Bedrock inference profile ARNs) so each model picker entry routes to a distinct deployment; documented in model config, Bedrock setup, and settings table (features-doc, cloud-providers-doc, settings-doc)
- **`autoMemoryDirectory` setting** — configure a custom directory for auto-memory storage (operations-doc)

### Changed
- **`/output-style` deprecated in favor of `/config`** — output style selection moved into the `/config` menu; style is now fixed at session start so prompt caching can reduce latency and cost; frontmatter `description` field references the `/config` picker (features-doc)
- **`/config` command description expanded** — now mentions theme, model, output style, and other preferences instead of just "Config tab" (cli-doc)
- **Upstream changelog updated** — two new releases (v2.1.73, v2.1.74) with `modelOverrides` setting, `/context` actionable suggestions, `autoMemoryDirectory`, `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` timeout config, default Opus model on Bedrock/Vertex/Foundry changed to Opus 4.6, `/output-style` deprecated, and 30+ bug fixes including memory leaks, permission bypass, OAuth hangs, RTL rendering, CPU freezes, and Linux sandbox issues (operations-doc)
- Minor wording/formatting updates across cli-doc, operations-doc docs

## 26.3.11

**15 references updated across 12 skills:** agent-teams-doc, best-practices-doc, cli-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, operations-doc, plugins-doc, security-doc, skills-doc, sub-agents-doc

### New
- **`/btw` side question command** — ask a quick question without adding to conversation history; answer appears in a dismissible overlay, runs while Claude is working, reuses prompt cache, has no tool access (cli-doc)
- **`/btw` referenced in context management tips** — recommended for quick questions that don't need to stay in context (best-practices-doc)
- **`/btw` as alternative to subagents for context questions** — sees full conversation but has no tools; inverse of a subagent (sub-agents-doc)

### Changed
- **Plugin reload replaces restart** — auto-update notification, quickstart tutorial, skill loading instructions, and development workflow all now say `/reload-plugins` instead of "restart Claude Code"; LSP server config changes still require a full restart (plugins-doc)
- **Agent Skills specification reformatted** — directory structure example now shows optional directories inline, frontmatter field examples wrapped in Card components, directory names use backtick formatting, code block language hints added (skills-doc)
- Minor wording/formatting updates across agent-teams-doc, features-doc, getting-started-doc, hooks-doc, ide-doc, operations-doc, security-doc docs

## 26.3.10

**13 references updated across 11 skills:** best-practices-doc, ci-cd-doc, cli-doc, features-doc, getting-started-doc, ide-doc, memory-doc, operations-doc, plugins-doc, settings-doc, skills-doc

### New
- **GitHub Code Review integration** — new "Get automatic code review on every PR" row in the overview table linking to `/en/code-review` (getting-started-doc)
- **`CronCreate`, `CronDelete`, `CronList` tools** — session-scoped scheduled/one-shot prompts; documented in the tools table with links to `/en/scheduled-tasks` (settings-doc)
- **`EnterWorktree` / `ExitWorktree` tools** — create and leave isolated git worktrees from within a session (settings-doc)
- **`EnterPlanMode` tool** — switches to plan mode to design an approach before coding (settings-doc)
- **`ListMcpResourcesTool` / `ReadMcpResourceTool` tools** — list and read MCP server resources (settings-doc)
- **`TaskStop` tool** — kills a running background task by ID (settings-doc)
- **`TodoWrite` tool** — manages the session task checklist in non-interactive mode and the Agent SDK (settings-doc)
- **`ToolSearch` tool** — renamed from `MCPSearch`; searches for and loads deferred tools (settings-doc)
- **VS Code `vscode://anthropic.claude-code/open` URI handler** — opens a new Claude Code tab programmatically with optional `prompt` and `session` query parameters (operations-doc)

### Changed
- **`/review` command deprecated** — replaced with install instructions for the `code-review` plugin from the marketplace (cli-doc)
- **`CLAUDE.local.md` removed from docs** — local instructions scope dropped from the memory, settings, best-practices, and IDE reference pages; personal per-project preferences now use a home-directory import instead (memory-doc, settings-doc, best-practices-doc, ide-doc)
- **Tools table rewritten and expanded** — alphabetically sorted, added 10 new tools (`CronCreate/Delete/List`, `EnterPlanMode`, `EnterWorktree`, `ExitWorktree`, `ListMcpResourcesTool`, `ReadMcpResourceTool`, `TaskStop`, `TodoWrite`), renamed `MCPSearch` to `ToolSearch` and `KillShell` to `TaskStop`, updated descriptions for `Agent`, `Bash`, `ExitPlanMode`, `TaskOutput`, `WebSearch` (settings-doc)
- **GitHub Actions `/review` command replaced with plain prompt** — the auto-review workflow example now uses an explicit review instruction instead of `/review`; "Commands" feature renamed to "Skills" with link to `/en/skills`; `prompt` parameter description updated (ci-cd-doc)
- **Marketplace walkthrough example renamed** — `/review` skill renamed to `/quality-review` throughout the marketplace creation tutorial (plugins-doc)
- **Skill examples updated** — `/review` references changed to `/deploy` or `/audit` in features overview, plugins, and skills docs (features-doc, plugins-doc, skills-doc)
- **Effort levels simplified** — low/medium/high only (removed max); new symbols and `/effort auto` to reset (operations-doc)
- **CLAUDE.md HTML comments hidden from auto-injection** — `<!-- ... -->` comments no longer visible to Claude when CLAUDE.md is auto-injected; still visible via Read tool (operations-doc)
- **Upstream changelog updated** — new release with `ExitWorktree` tool, `/plan` description argument, `/copy` file-write shortcut, effort level simplification, CLAUDE.md HTML comment hiding, bash parser rewrite, ~510 KB bundle reduction, prompt cache fix reducing input costs up to 12x, and 30+ bug fixes including sandbox permission issues, voice mode stability, worktree isolation, and parallel tool call error handling (operations-doc)
- Minor wording/formatting updates across skills-doc docs

## 26.3.9

**7 references updated across 6 skills:** getting-started-doc, headless-doc, ide-doc, operations-doc, settings-doc, skills-doc

### New
- **Scheduled tasks in Desktop** — full documentation for recurring local sessions: create via sidebar or natural language, configure frequency (manual/hourly/daily/weekdays/weekly), missed-run catch-up behavior, per-task permission mode, and on-disk editing via `~/.claude/scheduled-tasks/<name>/SKILL.md` (ide-doc)
- **`/loop` bundled skill** — runs a prompt repeatedly on an interval within a session (e.g. `/loop 5m check the deploy`); schedules a recurring cron task and confirms cadence (skills-doc)
- **Setup scripts for cloud environments** — Bash scripts that run before Claude Code launches in new cloud sessions; configured in the environment settings dialog; replaces SessionStart hooks as the primary dependency installation method for cloud-only tooling (headless-doc)
- **`CLAUDE_CODE_DISABLE_CRON` env var** — set to `1` to disable scheduled tasks; the `/loop` skill and cron tools become unavailable and already-scheduled tasks stop firing (settings-doc)

### Changed
- **Cloud environment setup references updated to setup scripts** — "How it works" steps, environment dialog descriptions, dependency management section, and best practices all now reference setup scripts instead of or alongside SessionStart hooks (headless-doc)
- **Setup scripts vs. SessionStart hooks comparison table** — documents when to use each: setup scripts for cloud-only tooling (runs before launch, new sessions only), SessionStart hooks for cross-environment setup (runs after launch, every session) (headless-doc)
- **Upstream changelog updated** — new v2.1.71 release with `/loop` command, cron scheduling tools, `voice:pushToTalk` rebindable keybinding, expanded bash auto-approval allowlist, and 20+ bug fixes including stdin freeze in long sessions, startup freezes from CoreAudio/OAuth, forked conversation plan conflicts, and plugin installation loss across instances (operations-doc)
- Minor wording/formatting updates across getting-started-doc, ide-doc docs

## 26.3.6

**9 references updated across 7 skills:** best-practices-doc, features-doc, getting-started-doc, ide-doc, mcp-doc, operations-doc, security-doc

### New
- **VS Code Activity Bar sessions list** — spark icon in the Activity Bar always shows all Claude Code sessions; clicking opens a session as a full editor tab (ide-doc)
- **VS Code plan markdown document view** — Plan mode now opens the plan as a full markdown document where you can add inline comments to provide feedback before Claude begins (ide-doc)
- **VS Code `/mcp` management dialog** — native MCP server management in the chat panel to enable/disable servers, reconnect, and manage OAuth authentication without switching to the terminal (ide-doc)

### Changed
- **Remote Control available on all plans** — expanded from Max/Pro research preview to all plans including Team and Enterprise; admins must enable Claude Code in admin settings first (features-doc)
- **VS Code MCP server config upgraded to "Partial"** — feature comparison table updated: servers are added via CLI but can now be managed with `/mcp` in the chat panel (ide-doc)
- **Activity Bar icon vs Claude panel clarified** — the sessions list icon is always visible in the Activity Bar, while the Claude panel icon only appears there when docked to the left sidebar (ide-doc)
- **Upstream changelog updated** — new release with 18 bug fixes (API 400 errors with proxy endpoints, effort parameter on custom Bedrock profiles, clipboard corruption on Windows/WSL, voice mode on Windows, and more), performance improvements (~74% fewer prompt re-renders, ~426KB startup memory reduction, 300x reduction in Remote Control poll rate), and the three new VS Code features above (operations-doc)
- Minor wording/formatting updates across best-practices-doc, getting-started-doc, mcp-doc, security-doc docs

## 26.3.5

**18 references updated across 11 skills:** best-practices-doc, cli-doc, features-doc, hooks-doc, mcp-doc, memory-doc, operations-doc, plugins-doc, security-doc, settings-doc, skills-doc

### New
- **`InstructionsLoaded` hook event** — fires when `CLAUDE.md` or `.claude/rules/*.md` files are loaded (eagerly or lazily); async-only for observability, no blocking support (hooks-doc)
- **`/reload-plugins` command** — reloads all active plugins mid-session without restarting; reports what was loaded and which changes require a restart (cli-doc, plugins-doc)
- **`/claude-api` bundled skill** — loads Claude API and Agent SDK reference for the project's language; auto-activates on `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk` imports, replacing the unnamed developer platform skill (skills-doc)
- **`git-subdir` plugin source** — new marketplace plugin source type that sparse-clones a subdirectory from a git repo, reducing bandwidth for monorepos (plugins-doc)
- **`--callback-port` for MCP OAuth** — fixes the OAuth callback port so it matches a pre-registered redirect URI; works with or without `--client-id` (mcp-doc)
- **`authServerMetadataUrl` MCP OAuth override** — bypasses standard OAuth metadata discovery by pointing to a custom OIDC endpoint URL (mcp-doc)
- **`pathPattern` managed marketplace restriction** — allows filesystem-based marketplaces from specific directories via regex matching on the path (plugins-doc)
- **`${CLAUDE_SKILL_DIR}` substitution variable** — resolves to the directory containing a skill's `SKILL.md`; useful for referencing bundled scripts in bash injection commands (skills-doc)
- **`includeGitInstructions` setting and `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` env var** — removes built-in commit/PR workflow instructions from the system prompt when disabled (settings-doc)
- **`pluginTrustMessage` managed setting** — appends a custom organization message to the plugin trust warning shown before installation (settings-doc)
- **`enableWeakerNetworkIsolation` sandbox setting** — allows macOS TLS trust service access for Go-based tools (`gh`, `gcloud`, `terraform`) when using a MITM proxy with custom CA (settings-doc)
- **Worktree fields in status line JSON** — `worktree.name`, `worktree.path`, `worktree.branch`, `worktree.original_cwd`, and `worktree.original_branch` are now available during `--worktree` sessions (features-doc)
- **Windows status line configuration** — added PowerShell and Git Bash examples for configuring the status line on Windows (features-doc)
- **Remote Control `--name` flag** — set a custom session title visible in the claude.ai session list; also available as a positional argument to `/remote-control` (features-doc)

### Changed
- **`ultrathink` keyword documented as dedicated config row** — "ultrathink" now has its own entry in the thinking configuration table; it sets effort to high for that turn on Opus 4.6 and Sonnet 4.6 (best-practices-doc)
- **Opus 4.6 default effort is medium** — documented that Opus 4.6 defaults to medium effort for Max and Team subscribers (features-doc)
- **Effort level shown next to logo/spinner** — the current effort level is now displayed in the UI so you can confirm the active setting without opening `/model` (features-doc)
- **System prompt flags work in all modes** — `--system-prompt-file` and `--append-system-prompt-file` no longer limited to print mode; all four flags now work in both interactive and non-interactive modes (cli-doc)
- **`TeammateIdle` and `TaskCompleted` hooks support JSON `{"continue": false}` decision control** — allows stopping a teammate entirely instead of re-running, matching `Stop` hook behavior (hooks-doc)
- **Permission rule precedence clarified** — explicit numbered list showing managed > CLI args > local project > shared project > user; deny at any level cannot be overridden (settings-doc)
- **Managed settings cannot be overridden by CLI arguments** — precedence docs updated to state this explicitly (settings-doc)
- **`allowManagedDomainsOnly` blocks non-allowed domains automatically** — non-allowed domains are now blocked without prompting the user when this sandbox setting is enabled (security-doc, settings-doc)
- **Plugins security warning added** — new section warning that plugins execute arbitrary code with user privileges; recommends only installing from trusted sources (plugins-doc)
- **`InstructionsLoaded` hook mentioned in memory debugging tip** — memory docs now suggest using the hook to trace which instruction files are loaded and why (memory-doc)
- **Bash mode exit methods documented** — exit `!` bash mode with Escape, Backspace, or Ctrl+U on an empty prompt (cli-doc)
- **`/commit-push-pr` skill reference removed** — PR creation workflow simplified to just "ask Claude directly" or step-by-step guidance (best-practices-doc)
- **`--debug` flag for status line troubleshooting** — logs exit code and stderr from the first status line invocation in a session (features-doc)
- Minor wording/formatting updates across operations-doc docs

## 26.3.4.1

**1 reference updated across 1 skill:** operations-doc

### Changed
- **Opus 4.6 default effort lowered to medium** — Max and Team subscribers now start at medium effort instead of high; adjustable via `/model` (operations-doc)
- **"ultrathink" keyword re-introduced** — typing "ultrathink" enables high effort for the next turn (operations-doc)
- **Opus 4 and 4.1 removed from first-party API** — users with those models pinned are automatically migrated to Opus 4.6 (operations-doc)
- Minor wording/formatting updates across operations-doc docs

## 26.3.4

**4 references updated across 4 skills:** best-practices-doc, features-doc, operations-doc, settings-doc

### Changed
- **Effort levels now supported on Sonnet 4.6** — `CLAUDE_CODE_EFFORT_LEVEL` and the `/model` effort slider now apply to both Opus 4.6 and Sonnet 4.6; "high" is no longer labeled as the default (best-practices-doc, features-doc, settings-doc)
- Minor wording/formatting updates across operations-doc docs

## 26.3.3

**7 references updated across 6 skills:** cli-doc, features-doc, getting-started-doc, hooks-doc, operations-doc, skills-doc

### New
- **Built-in commands table expanded to ~50 commands** — interactive mode docs now list all available `/` commands including `/add-dir`, `/agents`, `/chrome`, `/diff`, `/extra-usage`, `/fast`, `/feedback`, `/fork`, `/hooks`, `/ide`, `/insights`, `/install-github-app`, `/install-slack-app`, `/keybindings`, `/login`, `/logout`, `/mobile`, `/output-style`, `/passes`, `/plugin`, `/pr-comments`, `/privacy-settings`, `/release-notes`, `/remote-control`, `/remote-env`, `/review`, `/sandbox`, `/security-review`, `/skills`, `/stickers`, `/terminal-setup`, `/upgrade`, `/vim`, and others with aliases and expanded descriptions (cli-doc)
- **Bundled `/debug` skill** — troubleshoots the current session by reading the debug log; optionally accepts a description to focus analysis (skills-doc)
- **Bundled developer platform skill** — auto-activates when code imports the Anthropic SDK; no manual invocation needed (skills-doc)

### Changed
- **`/debug` moved from built-in commands to bundled skills** — `/debug` is now a prompt-based bundled skill rather than a fixed built-in command (cli-doc, skills-doc)
- **Bundled skills section rewritten** — now explains that bundled skills are prompt-based playbooks (not fixed logic), can spawn parallel agents, and adapt to the codebase; expanded from two to four entries (skills-doc)
- **"Slash commands" renamed to "commands" throughout** — terminology changed from "slash command" to "command" in CLI reference, features overview, getting-started, hooks guide, and skills docs (cli-doc, features-doc, getting-started-doc, hooks-doc, skills-doc)
- **Built-in commands intro text rewritten** — now notes that command visibility depends on platform, plan, and environment; documents `<arg>` / `[arg]` notation for required/optional arguments (cli-doc)
- **Bundled skills referenced in features overview** — skills tab now mentions `/simplify`, `/batch`, and `/debug` as bundled skills that ship with Claude Code (features-doc)
- Minor wording/formatting updates across operations-doc docs

## 26.2.28

**19 references updated across 13 skills:** cli-doc, features-doc, getting-started-doc, headless-doc, hooks-doc, ide-doc, mcp-doc, memory-doc, operations-doc, security-doc, settings-doc, skills-doc, sub-agents-doc

### New
- **Bundled `/simplify` and `/batch` skills** — Claude Code now ships two built-in skills: `/simplify` reviews recent changes for code quality and `/batch` orchestrates large-scale parallel changes across a codebase using git worktrees (skills-doc)
- **Session management on the web** — new "Managing sessions" section covering archiving and deleting cloud sessions, with permanent data removal on delete (headless-doc, security-doc)
- **`sandbox.filesystem.allowWrite` / `denyWrite` / `denyRead` settings** — grant or block OS-level write/read access for sandboxed subprocess commands (e.g. `kubectl`, `terraform`) to paths outside the working directory; arrays merge across settings scopes (security-doc, settings-doc)
- **Sandbox path prefix table** — `//` for absolute, `~/` for home-relative, `/` for settings-file-relative, `./` for runtime-relative (security-doc, settings-doc)
- **`allowedHttpHookUrls` setting** — allowlist of URL patterns HTTP hooks may target; supports `*` wildcards; undefined means unrestricted, empty array blocks all (settings-doc)
- **`httpHookAllowedEnvVars` setting** — allowlist of env var names HTTP hooks may interpolate into headers; each hook's effective list is the intersection with this setting (settings-doc)
- **`allowedEnvVars` field on HTTP hooks** — only env vars listed in this array are resolved in header `$VAR` interpolation; unlisted references become empty strings (hooks-doc)
- **`ENABLE_CLAUDEAI_MCP_SERVERS` env var** — set to `false` to disable claude.ai MCP servers in Claude Code (mcp-doc, settings-doc)
- **CLAUDE.md vs Rules vs Skills comparison tab** — new tab explaining when to use each: CLAUDE.md for every-session instructions, rules for path-scoped guidelines, skills for on-demand reference (features-doc)
- **"Write effective instructions" guidance** — new section on CLAUDE.md size (target under 200 lines), structure, and specificity for reliable adherence (memory-doc)
- **"Troubleshoot memory issues" section** — debugging steps for when CLAUDE.md is not followed, auto memory contents are unknown, file is too large, or instructions disappear after `/compact` (memory-doc)
- **Organization-wide CLAUDE.md deployment guide** — step-by-step instructions for managed policy CLAUDE.md on macOS, Linux/WSL, and Windows (memory-doc)
- **`claudeMdExcludes` setting** — skip specific CLAUDE.md files by path or glob in large monorepos; arrays merge across settings layers; managed policy files cannot be excluded (memory-doc)
- **OAuth redirect failure troubleshooting** — new tip to paste the full callback URL from the browser when the redirect fails with a connection error (mcp-doc)

### Changed
- **`Task` tool renamed to `Agent`** — the subagent tool is now `Agent` everywhere: permissions use `Agent(name)`, hooks match on `Agent`, `--disallowedTools` uses `Agent(Explore)`; existing `Task(...)` references still work as aliases (cli-doc, hooks-doc, settings-doc, sub-agents-doc)
- **Memory docs fully rewritten** — page retitled "How Claude remembers your project"; restructured into CLAUDE.md files, `.claude/rules/`, auto memory, and troubleshooting sections with new comparison table and concise writing guidance (memory-doc)
- **CLAUDE.md recommended size lowered to 200 lines** — previously ~500; longer files should be split into rules files or skill references (features-doc, memory-doc)
- **Remote Control available on Pro plans** — changed from "rolling out to Pro plans soon" to available on both Max and Pro plans (features-doc)
- **`/copy` command gains persistent full-response setting** — select "Always copy full response" in the picker to skip it in future sessions; revert via `copyFullResponse: false` in `/config` (cli-doc)
- **VS Code session list shows rename and remove actions** — hover over a session to reveal rename and remove controls (ide-doc)
- **Sandbox and permissions interaction rewritten** — docs now explain that `sandbox.filesystem` settings and permission rules are merged together into the final sandbox config (security-doc, settings-doc)
- **Array settings merge behavior documented** — explicit note that array-valued settings like `allowWrite` and `permissions.allow` concatenate and deduplicate across scopes instead of replacing (settings-doc)
- **Hook configuration section expanded** — now covers `allowedHttpHookUrls` and `httpHookAllowedEnvVars` alongside `allowManagedHooksOnly`; includes configuration examples (settings-doc)
- **Auto memory mentioned in "What Claude can access"** — getting-started now lists auto memory as a resource alongside CLAUDE.md (getting-started-doc)
- Minor wording/formatting updates across operations-doc docs

## 26.2.27.2

**7 references updated across 5 skills:** features-doc, hooks-doc, operations-doc, security-doc, settings-doc

### New
- **HTTP hooks (`type: "http"`)** — new hook handler type that POSTs event JSON to a URL; supports custom headers with env var interpolation, 2xx/non-2xx error handling, and the same JSON output schema as command hooks (hooks-doc)
- **`fastModePerSessionOptIn` setting** — administrators can force fast mode to reset each session so users must re-enable it with `/fast`; available in managed and server-managed settings for Teams/Enterprise (features-doc, settings-doc)

### Changed
- **Zero Data Retention scope clarified** — ZDR is now described as available for Claude Code on Claude for Enterprise, enabled per-organization; each new org must have ZDR enabled separately by the account team (security-doc)
- **BAA healthcare compliance updated** — ZDR is per-organization; each org needs separate ZDR enablement to be covered under the BAA (security-doc)
- Minor wording/formatting updates across operations-doc docs — ZDR link targets updated to `/en/zero-data-retention`, asset hash updates in changelog page

## 26.2.27.1

Renamed all 18 plugin skills with `-doc` suffix (e.g. `memory` → `memory-doc`) to avoid shadowing Claude Code built-in commands like `/memory`, `/skills`, etc. No documentation content changes.

Workaround for: https://github.com/anthropics/claude-code/issues/29282

## 26.2.27

**29 references updated across 15 skills:** agent-teams, best-practices, ci-cd, cli, features, getting-started, headless, hooks, ide, operations, plugins, security, settings, skills, sub-agents

### New
- **`CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` env var** — set to `1` to disable adaptive reasoning on Opus 4.6 and Sonnet 4.6 and revert to the fixed `MAX_THINKING_TOKENS` budget (features, settings)
- **`CLAUDE_CODE_DISABLE_FAST_MODE` env var** — set to `1` to disable fast mode entirely (features, settings)
- **Official plugin marketplace submission forms** — submit plugins to the Anthropic marketplace via claude.ai/settings/plugins/submit or platform.claude.com/plugins/submit (plugins)
- **`/rename` auto-generates session name** — running `/rename` without an argument now generates a name from conversation history (cli)

### Changed
- **Remote Control availability narrowed to Max plans** — Pro plan support changed from "available" to "coming soon"; API keys still unsupported (features)
- **Adaptive reasoning disable option documented** — `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1` reverts Opus 4.6 and Sonnet 4.6 to the fixed thinking budget; noted in model config, common workflows, and env var table (features, best-practices, settings)
- **"Headless mode" renamed to "non-interactive mode"** — section title and descriptions updated from "headless" to "non-interactive" throughout best-practices (best-practices)
- Minor wording/formatting updates across all 15 skills — lowercase list items after colons, `text` language hints on code fences, CardGroup components replaced with plain markdown lists, asset hash updates in changelog page

## 26.2.26

**5 references updated across 5 skills:** cli, headless, memory, operations, plugins

### New
- **`autoMemoryEnabled` setting** — disable auto memory per-project or globally via `settings.json` instead of only environment variables (memory)
- **`/memory` auto-memory toggle** — on/off toggle added to the `/memory` selector for controlling auto memory interactively (memory)
- **`extraKnownMarketplaces` config example** — documented JSON snippet for adding team marketplace sources to `.claude/settings.json` (plugins)

### Changed
- **`--remote` replaces `&` prefix for web sessions** — terminal-to-web workflow now uses `claude --remote "..."` instead of the `& message` prefix; all examples and tips updated accordingly (headless)
- **`/copy` command gains code block picker** — when code blocks are present, `/copy` now shows an interactive picker to select individual blocks or the full response (cli)
- **Auto memory enabled by default** — no longer in gradual rollout; `CLAUDE_CODE_DISABLE_AUTO_MEMORY` env var now documented as an override that takes precedence over both the `/memory` toggle and `settings.json` (memory)
- Minor wording/formatting updates across operations docs

## 26.2.25

**19 references updated across 10 skills:** cli, getting-started, headless, ide, operations, plugins, security, settings, skills, sub-agents

### New
- **`claude auth login`, `claude auth logout`, `claude auth status` commands** — dedicated CLI commands for authentication with `--email`, `--sso`, and `--text` flags (cli)
- **`claude remote-control` command** — starts a Remote Control session to control Claude Code from Claude.ai or the Claude app while running locally (cli)
- **Remote Control execution environment** — new "Remote Control" row in environments table; runs on your machine but controlled from a browser (getting-started)
- **npm package plugin source** — plugins can now be distributed as npm packages with `package`, `version`, and `registry` fields (plugins)
- **`CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` env var** — configurable timeout for git operations during plugin installation, defaults to 120s (plugins)
- **`allowManagedMcpServersOnly` managed setting** — restricts MCP servers to managed-only allowlist (settings)
- **`blockedMarketplaces` managed setting** — blocklist of marketplace sources checked before download (settings)
- **`sandbox.network.allowManagedDomainsOnly` managed setting** — restricts allowed network domains to managed settings only (settings)
- **`allow_remote_sessions` managed setting** — controls whether users can start Remote Control and web sessions (settings)
- **MDM/OS-level policy delivery for managed settings** — macOS plist domain `com.anthropic.claudecode` and Windows registry `HKLM\SOFTWARE\Policies\ClaudeCode` as new managed settings sources (settings)
- **`/status` command for verifying active settings** — shows which settings sources are active and their origin (settings)
- **Terminal guide link** — quickstart and setup pages now reference a terminal guide for beginners (getting-started)
- **Windows Git for Windows requirement** — explicitly documented as required dependency for native Windows (getting-started)

### Changed
- **Authentication docs rewritten** — new "Log in to Claude Code" section with per-account-type instructions; "Microsoft Azure" renamed to "Microsoft Foundry" throughout (getting-started)
- **Setup page restructured** — renamed to "Advanced setup"; reorganized into install, verify, authenticate, update, and uninstall sections; Windows setup split into Git Bash and WSL options; npm install moved under "Advanced installation options" (getting-started)
- **Remote Control noted in data flow docs** — clarified that Remote Control sessions follow local data flow since execution stays on your machine (security)
- **Remote Control security model documented** — describes local execution, TLS-encrypted API traffic, and short-lived narrowly scoped credentials (security)
- **`/path` permission pattern meaning corrected** — changed from "relative to settings file" to "relative to project root" (settings)
- **Managed settings scope description expanded** — now lists server-managed, plist/registry, and file-based delivery mechanisms with precedence order (settings)
- **Background subagents MCP restriction removed** — dropped the note that MCP tools are not available in background subagents (sub-agents)
- **Managed settings link targets updated** — multiple docs now link to `/en/settings#settings-files` instead of `/en/permissions#managed-settings` (plugins, skills, security, settings, ide)
- **Android app link added** — Claude Code on the web docs now mention Android alongside iOS (headless)
- Minor wording/formatting updates across operations docs

## 26.2.24

**3 references updated across 3 skills:** agent-teams, cli, operations

### New
- **Team sizing guidance** — new section recommending 3-5 teammates per team and 5-6 tasks per teammate; covers token cost scaling, coordination overhead, and diminishing returns (agent-teams)

### Changed
- **Notification setup rewritten** — Kitty and Ghostty now noted as supporting desktop notifications natively; iTerm 2 setup steps updated to use "Notification Center Alerts"; macOS Terminal explicitly listed as unsupported; notification hooks clarified as additive, not replacement (cli)
- Minor wording/formatting updates across operations docs

## 26.2.23

**1 reference updated across 1 skill:** operations

Minor formatting updates only

## 26.2.22

**9 references updated across 8 skills:** best-practices, cli, features, getting-started, hooks, operations, settings, sub-agents

### New
- **`WorktreeCreate` hook event** — replaces default git worktree behavior for non-git VCS (SVN, Perforce, Mercurial); hook prints the created worktree path on stdout (hooks)
- **`WorktreeRemove` hook event** — cleanup counterpart to `WorktreeCreate`; fires at session exit or when a subagent finishes; receives `worktree_path` in input (hooks)
- **Subagent worktree isolation** — subagents can use `isolation: worktree` in frontmatter for parallel conflict-free work; worktrees auto-clean when subagent finishes without changes (best-practices)
- **`claude agents` CLI command** — lists all configured subagents grouped by source without starting an interactive session (cli, sub-agents)
- **`CLAUDE_CODE_DISABLE_1M_CONTEXT` env var** — set to `1` to hide 1M model variants from the model picker; useful for compliance environments (features, settings)

### Changed
- **Hook type support matrix reorganized** — explicit lists of which events support `command`/`prompt`/`agent` hook types replace the previous inline paragraph (hooks)
- **`ConfigChange` matcher values documented** — matches on `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` (hooks)
- **`SessionStart` source values updated** — `clear` added to the list alongside `startup`, `resume`, `compact` (hooks)
- **Default model tier table removed** — replaced with a link to the new `#default-model-setting` anchor (features)
- **Sonnet 4.5 references updated to Sonnet 4.6** in model configuration examples (features)
- Minor wording/formatting updates across getting-started, operations docs

## 26.2.21

**6 references updated across 4 skills:** best-practices, getting-started, ide, operations

### New
- **Live app preview** — Desktop can start dev servers in an embedded browser with auto-verify; configured via `.claude/launch.json` with support for multiple servers, custom ports, and `autoPort` conflict handling (ide)
- **GitHub PR monitoring with auto-fix and auto-merge** — CI status bar in Desktop shows check results; toggle auto-fix to have Claude fix failing checks, or auto-merge to squash-merge when all checks pass (ide)
- **Code review in diff view** — "Review code" button in diff toolbar asks Claude to evaluate diffs and leave inline comments on compile errors, logic bugs, and security issues (ide)
- **Preview server configuration reference** — full `.claude/launch.json` schema: `runtimeExecutable`, `runtimeArgs`, `port`, `cwd`, `env`, `autoPort`, `program`, `args` fields with examples for Next.js, monorepos, and Node.js scripts (ide)

### Changed
- **Permission mode names updated** — "Ask" is now "Ask permissions", "Code" is now "Auto accept edits", "Act" is now "Bypass permissions", "Plan" is now "Plan mode" throughout Desktop docs (ide)
- **Windows ARM64 fully supported** — no longer limited to remote-only sessions; ARM64 limitation notice removed (ide)
- **Cowork tab available on Windows** — previously Apple Silicon only; now available on all supported Windows hardware (ide)
- **`MAX_THINKING_TOKENS` on Opus** — ignored except for `0` because adaptive reasoning controls thinking depth instead (ide)
- **Managed settings key shortened** — `permissions.disableBypassPermissionsMode` changed to `disableBypassPermissionsMode`; docs now reference `allowManagedPermissionRulesOnly` and `allowManagedHooksOnly` (ide)
- **Git required for Windows Code tab** — clarified that Git must be installed on Windows for local sessions to start (ide)
- Minor wording/formatting updates across best-practices, getting-started, operations docs

## 26.2.20

**17 references updated across 11 skills:** best-practices, cli, features, getting-started, hooks, ide, operations, plugins, security, settings, sub-agents

### New
- **ConfigChange hook event** — new lifecycle hook that fires when settings, policy, or skill files change during a session; supports blocking changes via exit code 2 or JSON decision (hooks)
- **`--worktree` / `-w` CLI flag** — built-in worktree support: `claude -w feature-auth` creates isolated worktree at `.claude/worktrees/<name>` with auto-cleanup on exit (cli, best-practices)
- **Desktop notifications guide** — new section on setting up OS-native notifications via the `Notification` hook event (best-practices)

### Changed
- **Worktrees documentation rewritten** — manual `git worktree` workflow replaced with first-class `--worktree` flag; old multi-step guide moved to "manual" subsection (best-practices)
- **`disableAllHooks` respects managed hierarchy** — user/project/local `disableAllHooks` cannot override admin-managed hooks (hooks)
- **Changelog updated** with latest release notes (operations)
- Minor wording/formatting updates across plugins, VS Code, settings, sub-agents, security, features docs
