---
name: ide-doc
description: Documentation for using Claude Code in graphical environments — the Claude Desktop app (Code tab), the VS Code/Cursor extension, the JetBrains plugin, the Chrome browser integration, and CLI computer use for screen control.
user-invocable: false
---

# IDE & Desktop Documentation

This skill provides the complete official documentation for Claude Code's IDE and desktop integrations: the Claude Desktop app, the VS Code extension, the JetBrains plugin, the Chrome browser integration, and computer use from the CLI.

## Quick Reference

### Surfaces at a glance

| Surface | Platforms | Install | Notes |
| ------- | --------- | ------- | ----- |
| Desktop app (Code tab) | macOS, Windows | Download from claude.com/download | GUI for Claude Code with parallel sessions, diff view, preview, terminal pane. Includes Claude Code (no Node/CLI install needed). |
| VS Code extension | VS Code 1.98+ / Cursor | `vscode:extension/anthropic.claude-code` or Extensions view | Native panel with @-mentions, plan review, multi-tab sessions. Includes the CLI. |
| JetBrains plugin | IntelliJ, PyCharm, Android Studio, WebStorm, PhpStorm, GoLand | JetBrains Marketplace ("Claude Code \[Beta]") | Quick-launch, IDE diff viewer, selection/diagnostics sharing. Requires `claude` CLI installed separately. |
| Chrome integration | Chrome / Edge | Claude in Chrome extension v1.0.36+ | Browser automation via `--chrome` flag or `/chrome`. Beta. Direct Anthropic plans only. |
| Computer use (CLI) | macOS only | `/mcp` → enable `computer-use` | Pro/Max only, interactive sessions only, v2.1.85+. For Desktop computer use see Desktop doc. |

### Permission modes (Desktop Code tab)

| Mode | Settings key | Behavior |
| ---- | ------------ | -------- |
| Ask permissions | `default` | Approve every edit/command. Recommended for new users. |
| Auto accept edits | `acceptEdits` | Auto-accepts file edits and common fs commands; still asks for other terminal commands. |
| Plan mode | `plan` | Reads/explores then proposes a plan without editing source. |
| Auto | `auto` | Background safety checks; research preview. Team/Enterprise/API plans. Sonnet 4.6 / Opus 4.6 only. |
| Bypass permissions | `bypassPermissions` | No prompts (equivalent to `--dangerously-skip-permissions`). Sandbox/VM only. |

`dontAsk` is CLI-only. Remote sessions support only Auto accept edits and Plan mode.

### Desktop keyboard shortcuts (macOS — use Ctrl on Windows)

| Shortcut | Action |
| -------- | ------ |
| Cmd+/ | Show all keyboard shortcuts |
| Cmd+N / Cmd+W | New / close session |
| Ctrl+Tab / Ctrl+Shift+Tab | Cycle sessions |
| Esc | Stop Claude's response |
| Cmd+Shift+D / P | Toggle diff / preview pane |
| Cmd+Shift+S | Select element in preview |
| Ctrl+\` | Toggle terminal pane |
| Cmd+\\ | Close focused pane |
| Cmd+; | Open side chat (also `/btw`) |
| Ctrl+O | Cycle view modes (Normal / Verbose / Summary) |
| Cmd+Shift+M / I / E | Open permission mode / model / effort menu |

### Desktop view modes

| Mode | Shows |
| ---- | ----- |
| Normal | Tool calls collapsed, full text responses |
| Verbose | Every tool call, file read, intermediate step |
| Summary | Only Claude's final responses and changes |

### Desktop environments

| Env | Where it runs | Notes |
| --- | ------------- | ----- |
| Local | Your machine, direct file access | Requires Git on Windows; supports terminal, file pane, side chats, @mentions. |
| Remote | Anthropic cloud (same as Claude Code on the web) | Continues if you close the app. Multi-repo. Auto-accepts edits. No @mention, terminal, file pane, Bypass mode, or Ask mode. |
| SSH | Remote machine you manage | Requires Claude Code installed on remote. Supports terminal, file pane, side chats. |

### Preview server config (`.claude/launch.json`)

| Field | Type | Description |
| ----- | ---- | ----------- |
| `name` | string | Unique identifier |
| `runtimeExecutable` | string | Command (e.g. `npm`, `yarn`, `node`) |
| `runtimeArgs` | string[] | Arguments passed to executable |
| `port` | number | Server port (default 3000) |
| `cwd` | string | Working dir relative to project root |
| `env` | object | Env vars; do NOT put secrets here |
| `autoPort` | boolean | true=find free port, false=hard-fail, unset=ask |
| `program` | string | Standalone script run with `node` |
| `args` | string[] | Args for `program` |

Top-level `autoVerify: false` disables auto-verification of edits.

### Computer use app permission tiers (Desktop)

| Tier | Claude can | Applies to |
| ---- | ---------- | ---------- |
| View only | See in screenshots | Browsers, trading platforms |
| Click only | Click and scroll, no typing/shortcuts | Terminals, IDEs |
| Full control | Click, type, drag, shortcuts | Everything else |

Computer use trust order: connector/MCP → Bash → Chrome → computer use (broadest, slowest).

### VS Code extension key features

- **Open**: Spark icon in editor toolbar, Activity Bar sessions list, Status Bar, or Command Palette ("Claude Code: Open in New Tab/Window").
- **@mentions**: type `@` for fuzzy file/folder match. `Option+K` (Mac) / `Alt+K` (Win/Linux) inserts an @-mention with selected line range (e.g. `@app.ts#5-10`).
- **Permission modes**: normal, Plan (markdown plan with inline comments), auto-accept. Set default via `claudeCode.initialPermissionMode`.
- **Multi-conversation**: open additional conversations as tabs/windows; tab dot indicator shows pending permission (blue) or finished (orange).
- **Terminal mode**: enable `claudeCode.useTerminal` for CLI-style interface inside VS Code.
- **Plugins UI**: `/plugins` opens the Manage plugins dialog with install scopes (user / project / local).
- **Resume remote**: Past Conversations → Remote tab pulls in claude.ai web sessions (requires Claude.ai Subscription sign-in).

### JetBrains plugin features

- **Quick launch**: `Cmd+Esc` (Mac) / `Ctrl+Esc` (Win/Linux) opens Claude Code from the editor.
- **File reference**: `Cmd+Option+K` (Mac) / `Alt+Ctrl+K` (Linux/Win) inserts a file reference (e.g. `@File#L1-99`).
- **Diff viewing** in the IDE viewer; **selection** and **diagnostics** automatically shared.
- **External terminal**: run `/ide` to connect Claude to the JetBrains IDE.
- **Settings** → Tools → Claude Code [Beta]: customize Claude command path, multi-line prompts, auto-update.
- **Remote Development**: install plugin on the remote host, not the local client.
- **WSL**: use `wsl -d Ubuntu -- bash -lic "claude"` as the Claude command.

### Chrome integration

- Start with `claude --chrome`, or run `/chrome` in an existing session. `/chrome` → "Enabled by default" makes it persistent (increases context usage).
- Requires Chrome or Edge, Claude in Chrome extension v1.0.36+, Claude Code v2.0.73+, direct Anthropic plan. Not available via Bedrock/Vertex/Foundry. No WSL, no Brave/Arc.
- Site permissions inherited from the Chrome extension settings.
- Run `/mcp` and select `claude-in-chrome` to view available browser tools.
- Use cases: live debugging via console, design verification, web app testing, authenticated apps (Gmail, Notion, Google Docs), data extraction, form automation, GIF recording.

### Computer use (CLI) requirements & guardrails

- macOS only, Pro or Max plan, Claude Code v2.1.85+, interactive session (no `-p`).
- Enable: `/mcp` → select `computer-use` → Enable. Persists per-project.
- macOS permissions: Accessibility (click/type/scroll) + Screen Recording (see screen). May require restart after granting Screen Recording.
- Per-app approval prompt with Allow for this session / Deny. Holds machine-wide lock — only one Claude session at a time.
- Other apps hidden while Claude works; terminal is excluded from screenshots. Press `Esc` anywhere (or `Ctrl+C` in terminal) to abort.
- Screenshots auto-downscaled (~1372×887 from 16" Retina); no setting to change.

### Desktop vs CLI computer use

| Feature | Desktop | CLI |
| ------- | ------- | --- |
| Platforms | macOS + Windows | macOS only |
| Enable | Settings > General > Desktop app > Computer use toggle | `/mcp` → enable `computer-use` |
| Denied apps list | Configurable in Settings | Not yet available |
| Auto-unhide toggle | Optional | Always on |
| Dispatch integration | Yes (30-min app approvals) | N/A |

## Full Documentation

For the complete official documentation, see the reference files:

- [Use Claude Code Desktop](references/claude-code-desktop.md) — full Desktop reference: sessions, panes, diff view, preview, computer use, connectors, plugins, environment config, troubleshooting.
- [Get started with the desktop app](references/claude-code-desktop-quickstart.md) — install Claude Desktop, open the Code tab, and run your first session.
- [Use Claude Code in VS Code](references/claude-code-vs-code.md) — VS Code/Cursor extension reference: prompt box, @mentions, permission modes, plugins UI, multi-tab sessions, browser automation.
- [JetBrains IDEs](references/claude-code-jetbrains.md) — JetBrains plugin install, configuration, shortcuts, WSL/Remote Development setup, troubleshooting.
- [Use Claude Code with Chrome (beta)](references/claude-code-chrome.md) — connect Claude Code to Chrome/Edge for browser automation, debugging, and web app testing.
- [Let Claude use your computer from the CLI](references/claude-code-computer-use.md) — enable and use the `computer-use` MCP server on macOS to control native apps from the CLI.

## Sources

- Use Claude Code Desktop: https://code.claude.com/docs/en/desktop.md
- Get started with the desktop app: https://code.claude.com/docs/en/desktop-quickstart.md
- Use Claude Code in VS Code: https://code.claude.com/docs/en/vs-code.md
- JetBrains IDEs: https://code.claude.com/docs/en/jetbrains.md
- Use Claude Code with Chrome (beta): https://code.claude.com/docs/en/chrome.md
- Let Claude use your computer from the CLI: https://code.claude.com/docs/en/computer-use.md
