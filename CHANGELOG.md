# Changelog

All notable upstream documentation changes detected by `/crawl` are documented here.

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
