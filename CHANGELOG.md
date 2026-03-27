# Changelog

All notable upstream documentation changes detected by `/update` are documented here.

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
