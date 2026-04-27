# Changelog

All notable upstream documentation changes detected by `/update` are documented here.

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
