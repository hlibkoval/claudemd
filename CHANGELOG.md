# Changelog

All notable upstream documentation changes detected by `/crawl` are documented here.

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
