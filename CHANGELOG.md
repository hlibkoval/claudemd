# Changelog

All notable upstream documentation changes detected by `/crawl` are documented here.

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
