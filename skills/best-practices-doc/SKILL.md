---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices — context window management, verify-first workflow, explore/plan/implement/commit cycle, specific prompting, CLAUDE.md authoring, permissions, CLI tools, MCP, hooks, skills, subagents, plugins, session management, parallel sessions, non-interactive/headless mode, fan-out patterns, auto mode, adversarial review, common failure patterns, large codebases/monorepo configuration, ultraplan (cloud planning), and ultrareview (cloud multi-agent code review).
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, large-codebase configuration, ultraplan, and ultrareview.

## Quick Reference

### Core Constraint: Context Window

Claude's context window fills up fast and performance degrades as it fills. Manage it aggressively:

| Action | When to use |
| :--- | :--- |
| `/clear` | Between unrelated tasks; after two failed corrections |
| `/compact <instructions>` | Compact with guidance on what to preserve |
| `Esc + Esc` / `/rewind` | Restore previous conversation/code state, or summarize from a checkpoint |
| `/btw` | Side questions that must not enter conversation history |
| Use subagents for investigation | Exploration/research stays out of main context |

### Verify-First Workflow

| Strategy | Example prompt |
| :--- | :--- |
| Give success criteria up front | *"write validateEmail. test cases: user@example.com → true, invalid → false. run tests after."* |
| Verify UI changes visually | *"[paste screenshot] implement this design. screenshot the result and list differences."* |
| Show evidence, not assertions | Ask Claude to show test output or command result, not just say it passed |

### Explore → Plan → Implement → Commit

1. Enter plan mode (`Shift+Tab` or `--permission-mode plan`). Claude reads, does not edit.
2. Ask for a detailed plan; press `Ctrl+G` to open and edit the plan in your text editor.
3. Leave plan mode; implement with verification (tests, linter, screenshots).
4. Commit with a descriptive message and open a PR.

Skip planning when the change is one sentence to describe. Plan when scope is uncertain, change spans multiple files, or you are unfamiliar with the code.

### Specific Prompting

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Scope the task | *"add tests for foo.py"* | *"write a test for foo.py covering the logged-out edge case. avoid mocks."* |
| Point to sources | *"why is ExecutionFactory's API weird?"* | *"look through ExecutionFactory's git history and summarize how its API evolved"* |
| Reference patterns | *"add a calendar widget"* | *"see HotDogWidget.php for the pattern. implement a calendar widget following it."* |
| Describe symptoms | *"fix the login bug"* | *"login fails after session timeout. check src/auth/ token refresh. write a failing test, then fix it."* |

### Providing Rich Context

- Reference files with `@filename` — Claude reads the file before responding
- Paste images directly or drag-and-drop; use `Ctrl+V` (not `Cmd+V`) in CLI
- Give URLs for docs; use `/permissions` to allowlist frequently-used domains
- Pipe data: `cat error.log | claude`
- Let Claude fetch what it needs via Bash, MCP tools, or file reads

### CLAUDE.md Authoring

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude cannot guess | Anything Claude can infer by reading code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API documentation (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | File-by-file codebase descriptions |
| Common gotchas or non-obvious behaviors | Self-evident practices ("write clean code") |

CLAUDE.md locations: `~/.claude/CLAUDE.md` (all sessions), `./CLAUDE.md` (project, check into git), `./CLAUDE.local.md` (personal, gitignore), parent dirs (monorepo root), child dirs (loaded on demand). Import other files with `@path/to/file` syntax.

Keep it short. If removing a line wouldn't cause mistakes, cut it. Add `IMPORTANT` or `YOU MUST` emphasis for rules that keep being ignored.

### Session Management

| Command / Key | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` / `/rewind` | Open rewind menu (restore code, conversation, or both; summarize from a checkpoint) |
| `/clear` | Reset context window entirely |
| `/compact <focus>` | Compact with guidance, e.g. `/compact Focus on API changes` |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose session from a list |
| `/rename` | Name sessions like branches for multi-sitting tasks |

### Automation and Scaling

| Technique | How |
| :--- | :--- |
| Non-interactive mode | `claude -p "prompt"` — use in CI, hooks, scripts |
| Output formats | `--output-format json` or `--output-format stream-json --verbose` |
| Fan-out | Loop `claude -p` per file; use `--allowedTools` to scope permissions |
| Auto mode | `claude --permission-mode auto -p "..."` — classifier reviews commands, blocks risky ones |
| Parallel sessions | Worktrees, Desktop app, Claude Code on the web, Agent teams |
| Writer/Reviewer pattern | Session A implements; Session B reviews with fresh context |
| Adversarial review | `use a subagent to review the diff against PLAN.md. report gaps, not style.` |

### Common Failure Patterns

| Anti-pattern | Fix |
| :--- | :--- |
| Kitchen-sink session (unrelated tasks stacked) | `/clear` between tasks |
| Correcting the same thing repeatedly | After two failures: `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert ignored rules to hooks |
| Trust-then-verify gap | Always provide verification (tests, scripts, screenshots) |
| Infinite exploration | Scope investigations or use subagents |

---

### Large Codebases / Monorepos

| Goal | Setting / Mechanism |
| :--- | :--- |
| Load only relevant conventions | Per-directory CLAUDE.md files (root + subdirectory) |
| Exclude other teams' CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` |
| Block reads of generated/vendored code | `Read` deny rules in `permissions.deny` |
| Symbol navigation without scanning files | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in `.claude/settings.json` |
| Share `node_modules` across worktrees | `worktree.symlinkDirectories` |
| Grant access to sibling packages | `additionalDirectories` in settings, or `--add-dir` at launch |
| Per-area skills | `.claude/skills/` inside each subdirectory; commit with code |
| Load CLAUDE.md from `--add-dir` path | Set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |

**Starting directory matters**: project settings in `.claude/settings.json` load only from your starting directory, not inherited from parents. Start from a subdirectory to scope CLAUDE.md, settings, and skills to that area.

**Skill discoverability tip**: keep descriptions short and front-load keywords a request would contain; long descriptions get truncated.

---

### Ultraplan (Cloud Planning)

Launch from CLI: `/ultraplan <prompt>`, include `ultraplan` in a prompt, or select **Refine with Ultraplan** from a local plan's approval dialog.

| Status indicator | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is drafting the plan in the cloud |
| `◇ ultraplan needs your input` | Open the session link to answer a question |
| `◆ ultraplan ready` | Plan ready to review in browser |

Review in browser: inline comments on sections, emoji reactions, outline sidebar. Iterate until ready, then choose:
- **Approve and start coding** — implement in the same cloud session; review diff and create PR from web.
- **Approve and teleport back to terminal** — send plan to local terminal; choose Implement here, Start new session, or Cancel (saves plan to file).

Requires: Claude Code on the web account + GitHub repo. Not available on Bedrock, Vertex AI, Foundry.

---

### Ultrareview (Cloud Multi-Agent Code Review)

Run: `/ultrareview` (reviews branch diff vs default branch) or `/ultrareview <PR-number>` (clones PR from GitHub).

- Multi-agent fleet independently reproduces and verifies every finding — focuses on real bugs, not style.
- Runs in remote sandbox; terminal stays free. Takes 5–10 minutes.
- Track with `/tasks`; each finding includes file location and explanation.

Non-interactive: `claude ultrareview [<PR-number>|<base-branch>]` — blocks until done, prints findings to stdout.

| Flag | Effect |
| :--- | :--- |
| `--json` | Print raw `bugs.json` payload |
| `--timeout <minutes>` | Max wait time (default 30) |

**Pricing**: Pro/Max get 3 free runs; after that, billed as usage credits (~$5–$20/review). Team/Enterprise: no free runs, usage credits only. Usage credits must be enabled.

**Requires**: claude.ai account (not API-key-only); not available on Bedrock, Vertex, Foundry, or with Zero Data Retention.

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | Locally in session | Remotely in cloud sandbox |
| Depth | Single-pass | Multi-agent with independent verification |
| Duration | Seconds to a few minutes | ~5–10 minutes |
| Cost | Normal usage | Free runs, then ~$5–$20 as usage credits |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context window management, verify-first, explore/plan/implement/commit, specific prompting, CLAUDE.md authoring, permissions, CLI tools, MCP, hooks, skills, subagents, plugins, session management, parallelization, auto mode, adversarial review, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for codebase exploration, bug fixing, refactoring, tests, PRs, documentation, images, scheduling; resume/worktrees/plan-mode/subagent delegation/piping how-tos
- [Large codebases and monorepos](references/claude-code-large-codebases.md) — per-directory CLAUDE.md layering, claudeMdExcludes, Read deny rules, code intelligence plugins, worktree sparsePaths/symlinkDirectories, additionalDirectories/--add-dir, per-directory skills, centralization with plugins
- [Ultraplan](references/claude-code-ultraplan.md) — launch from CLI, status indicators, browser review/revision, execute on web vs. teleport to terminal
- [Ultrareview](references/claude-code-ultrareview.md) — /ultrareview command, PR mode, pricing/free runs, /tasks tracking, non-interactive subcommand, comparison with /review

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Large codebases and monorepos: https://code.claude.com/docs/en/large-codebases.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
