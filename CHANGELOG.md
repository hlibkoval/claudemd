# Changelog

All notable upstream documentation changes detected by `/update` are documented here.

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
