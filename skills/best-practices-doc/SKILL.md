---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan, ultrareview, dynamic workflows, and large codebase configuration.
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, ultrareview, dynamic workflows, and large codebase / monorepo configuration.

## Quick Reference

### Core Constraint: Context Window

Every session — messages, file reads, command output — fills the context window. Performance degrades as it fills. Managing context is the most important resource concern.

### Workflow: Explore → Plan → Implement → Commit

| Phase | Mode | What to do |
|:------|:-----|:-----------|
| **Explore** | Plan mode | Read files without making changes |
| **Plan** | Plan mode | Ask Claude to create a detailed implementation plan; press `Ctrl+G` to edit the plan in your text editor |
| **Implement** | Default | Let Claude code, verifying against the plan |
| **Commit** | Default | Ask Claude to commit and open a PR |

Skip planning for small, obvious changes. Use it when scope spans multiple files or the approach is unclear.

### Verification Strategies

| Method | How | Setup cost |
|:-------|:----|:----------|
| **In the prompt** | Ask Claude to run the check and iterate | None |
| **`/goal` condition** | An evaluator re-checks after every turn | Low |
| **Stop hook** | Script blocks turn from ending until check passes | Medium |
| **Verification subagent** | Fresh model reviews the result independently | Medium |

Always ask Claude to show evidence (test output, screenshot, command result) rather than assert success.

### Prompting: Before vs. After

| Strategy | Weak | Strong |
|:---------|:-----|:-------|
| **Scope** | *"add tests for foo.py"* | *"write a test for foo.py covering the logged-out edge case, no mocks"* |
| **Point to sources** | *"why does ExecutionFactory have a weird api?"* | *"look through ExecutionFactory's git history and summarize how its api came to be"* |
| **Reference patterns** | *"add a calendar widget"* | *"look at HotDogWidget.php as a pattern, implement a calendar widget with month selection and year pagination, no new libraries"* |
| **Describe symptoms** | *"fix the login bug"* | *"login fails after session timeout; check src/auth/ token refresh; write a failing test then fix it"* |

### Providing Rich Context

- Use `@filename` to reference files (Claude reads before responding)
- Paste images directly (copy/paste or drag-and-drop)
- Give URLs; use `/permissions` to allowlist frequently-used domains
- Pipe data with `cat error.log | claude`

### CLAUDE.md Guidelines

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Things Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API documentation |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |

- Keep CLAUDE.md short and human-readable; bloated files cause instructions to be ignored
- Use `@path/to/file` import syntax to pull in other files
- Place at `~/.claude/CLAUDE.md` (global), `./CLAUDE.md` (project), `./CLAUDE.local.md` (personal, gitignored), or subdirectories
- Run `/init` to generate a starter based on your project structure

### Session Management

| Action | Command/Key | When to use |
|:-------|:------------|:------------|
| Stop Claude mid-action | `Esc` | Course-correct; context preserved |
| Rewind to a checkpoint | `Esc Esc` or `/rewind` | Restore conversation + code state |
| Reset context | `/clear` | Between unrelated tasks |
| Controlled compaction | `/compact <instructions>` | Summarize while preserving key context |
| Ask a side question | `/btw` | Quick questions that shouldn't accumulate in context |
| Resume last session | `claude --continue` | Pick up where you left off |
| Resume from a list | `claude --resume` | Choose among saved sessions |
| Resume a PR-linked session | `claude --from-pr <number>` | Continue work tied to a specific PR |

After two failed corrections on the same issue, use `/clear` and start with a better prompt — don't accumulate failed approaches.

### Scheduling Claude Tasks

| Option | Where it runs | Best for |
|:-------|:-------------|:---------|
| Routines | Anthropic-managed infrastructure | Tasks that should run even when your computer is off; also triggered by API calls or GitHub events |
| Desktop scheduled tasks | Your machine, via the desktop app | Tasks that need direct access to local files, tools, or uncommitted changes |
| GitHub Actions | Your CI pipeline | Tasks tied to repo events or cron schedules that should live with your workflow config |
| `/loop` | The current CLI session | Quick polling while a session is open |

When writing prompts for scheduled tasks, be explicit about what success looks like — the task runs autonomously and cannot ask clarifying questions.

### Scaling and Parallelism

| Approach | Flag / command | Best for |
|:---------|:--------------|:---------|
| Non-interactive CI | `claude -p "prompt"` | CI, pre-commit hooks, scripts |
| Parallel worktrees | `claude --worktree <name>` | Isolated feature branches |
| Agent teams | `/team` | Multi-session coordinated work |
| Fan-out batch jobs | Loop calling `claude -p` with `--allowedTools` | Large migrations across many files |
| Auto mode unattended | `claude --permission-mode auto -p "..."` | Autonomous runs with classifier safety checks |

### Common Failure Patterns

| Pattern | Fix |
|:--------|:----|
| Kitchen-sink session (mixing tasks) | `/clear` between unrelated tasks |
| Correcting over and over | After two fails, `/clear` and write a better prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert enforced rules to hooks |
| No verification step | Always provide tests, scripts, or screenshots |
| Infinite exploration | Scope narrowly or delegate to a subagent |

---

## Common Workflow Recipes

### Codebase exploration prompts

```
give me an overview of this codebase
explain the main architecture patterns used here
find the files that handle user authentication
trace the login process from front-end to database
```

### Bug fixing

```
I'm seeing an error when I run npm test
suggest a few ways to fix the @ts-ignore in user.ts
update user.ts to add the null check you suggested
```

### Refactoring

```
find deprecated API usage in our codebase
refactor utils.js to use ES2024 features while maintaining the same behavior
run tests for the refactored code
```

### Testing

```
find functions in NotificationsService.swift that are not covered by tests
add tests for the notification service
add test cases for edge conditions in the notification service
run the new tests and fix any failures
```

### Pull requests

When a PR is created with `gh pr create`, the session is automatically linked. Return to it with `claude --from-pr <number>` or by pasting the PR URL into the `/resume` picker search.

### Images

- Drag and drop, or copy/paste with `Ctrl+V` (not `Cmd+V`)
- Provide an image path: `Analyze this image: /path/to/image.png`
- `Cmd+Click` / `Ctrl+Click` image references like `[Image #1]` to open them

### @ references

- `@src/utils/auth.js` — includes full file content
- `@src/components/` — provides directory listing
- `@github:repos/owner/repo/issues` — fetches from a connected MCP server

---

## Ultraplan

Ultraplan hands a planning task from your CLI to a Claude Code on the web session running in plan mode. The cloud session drafts the plan while your terminal stays free.

### Launch Ultraplan

| Method | How |
|:-------|:----|
| Command | `/ultraplan <prompt>` |
| Keyword | Include `ultraplan` anywhere in a prompt |
| From local plan | In the plan approval dialog, choose **No, refine with Ultraplan** |

### Status Indicators

| Indicator | Meaning |
|:----------|:--------|
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Claude has a clarifying question |
| `◆ ultraplan ready` | Plan is ready to review in browser |

### Browser Review

- **Inline comments**: highlight any passage and comment for Claude to address
- **Emoji reactions**: signal approval or concern without writing a full comment
- **Outline sidebar**: jump between sections

### Execution Choices (from browser)

| Option | What happens |
|:-------|:------------|
| **Approve and start coding** | Claude implements in the cloud session; review diff and open PR from web |
| **Approve and teleport to terminal** | Web session archives; plan appears in terminal with Implement / Start new session / Cancel |

Requires Claude Code on the web and a GitHub repository. Not available on Bedrock, Vertex AI, or Foundry.

---

## Ultrareview (`/code-review ultra`)

Deep multi-agent code review running in a remote sandbox. Each finding is independently verified.

### Commands

```
/code-review ultra          # Review current branch vs. default branch
/code-review ultra 1234     # Review a GitHub PR by number
claude ultrareview          # Non-interactive (CI); blocks until done
claude ultrareview 1234
claude ultrareview origin/main
```

### Local `/review` vs. `/code-review ultra`

| | `/review` | `/code-review ultra` |
|:-|:----------|:---------------------|
| Runs | Locally in session | Remote cloud sandbox |
| Depth | Single-pass | Multi-agent fleet with independent verification |
| Duration | Seconds to a few minutes | ~5–10 minutes |
| Cost | Normal usage | 3 free runs (Pro/Max), then ~$5–$20 as usage credits |
| Best for | Fast feedback while iterating | Pre-merge confidence on substantial changes |

### Non-interactive Flags

| Flag | Description |
|:-----|:------------|
| `--json` | Print raw `bugs.json` instead of formatted findings |
| `--timeout <minutes>` | Max wait time (default 30) |

Requires Claude.ai authentication. Not available on Bedrock, Vertex AI, Foundry, or with Zero Data Retention.

---

## Dynamic Workflows

A dynamic workflow is a JavaScript script that orchestrates subagents at scale. Claude writes the script; a runtime executes it in the background.

### Comparison: Subagents vs. Workflows vs. Agent Teams

| | Subagents | Skills | Agent teams | Workflows |
|:-|:----------|:-------|:------------|:----------|
| Who holds the plan | Claude, turn by turn | Claude, following instructions | Lead agent | The script |
| Intermediate results | Claude's context | Claude's context | Shared task list | Script variables |
| Scale | A few tasks/turn | Same | Handful of peers | Dozens–hundreds of agents |
| Interruption | Restarts the turn | Restarts the turn | Teammates keep running | Resumable in same session |

### Triggering a Workflow

- Include `ultracode` in a prompt, or say "use a workflow" / "run a workflow"
- `/effort ultracode` — sets session-level ultracode mode (combines `xhigh` reasoning effort with automatic workflow orchestration); Claude plans a workflow for every substantive task
- `/deep-research <question>` — built-in workflow for multi-source research

### `/deep-research` Built-in

Fans out web searches, fetches and cross-checks sources, votes on each claim, returns a cited report with unverified claims filtered out. Requires the WebSearch tool.

### Watching a Run

```
/workflows    # List running and completed workflows; select to open progress view
```

| Key | Action |
|:----|:-------|
| `↑` / `↓` | Select phase or agent |
| `Enter` or `→` | Drill into phase or agent |
| `Esc` | Back out |
| `p` | Pause / resume |
| `x` | Stop agent or whole workflow |
| `r` | Restart selected agent |
| `s` | Save script as a reusable command |

### Saving Workflows for Reuse

Save a run's script from `/workflows` by pressing `s`. Two save locations:
- `.claude/workflows/` in your project (shared with the repo)
- `~/.claude/workflows/` in your home directory (personal, available in every project)

Saved workflows run as `/<name>` in future sessions. Pass input via the `args` parameter; the script accesses it as the `args` global.

### Behavior and Limits

| Constraint | Value |
|:-----------|:------|
| Max concurrent agents | 16 (fewer on resource-limited machines) |
| Max agents per run | 1,000 |
| Mid-run user input | Not supported (only permission prompts can pause) |
| Session resumability | Within same session only |

### Approval Flow by Permission Mode

| Permission mode | When you're prompted |
|:----------------|:--------------------|
| Default, accept edits | Every run (unless **don't ask again** was selected) |
| Auto | First launch only; subsequent launches start without prompting |
| Bypass permissions, `claude -p`, Agent SDK | Never; run starts immediately |

### Disabling Workflows

```json
{ "disableWorkflows": true }
```

Or set `CLAUDE_CODE_DISABLE_WORKFLOWS=1`. Also available as a toggle in `/config` and an org-level admin setting.

---

## Large Codebases and Monorepos

### Settings Reference

| Goal | Setting / approach |
|:-----|:------------------|
| Load only relevant conventions | Per-directory `CLAUDE.md` files |
| Skip CLAUDE.md files you never touch | `claudeMdExcludes` in settings |
| Block reads of build output / vendored code | `Read` deny rules in `permissions.deny` |
| Jump-to-definition without scanning files | Code intelligence plugin |
| Sparse worktree checkout | `worktree.sparsePaths` |
| Access a sibling package from a subdirectory | `additionalDirectories` or `--add-dir` |
| Per-package skills that load on demand | Per-directory `.claude/skills/` |

### Where to Start Claude

| Start from | File access | CLAUDE.md loaded at launch |
|:-----------|:------------|:---------------------------|
| Repository root | Every file | Root only; subdirectory files load on demand |
| A subdirectory | That subtree only | That dir + every ancestor |

Project settings in `.claude/settings.json` load only from your starting directory (not inherited from parent directories).

### `claudeMdExcludes`

```json
{
  "claudeMdExcludes": [
    "**/packages/admin-dashboard/**",
    "**/packages/legacy-*/**"
  ]
}
```

Patterns match absolute file paths. Arrays merge across settings scopes. Managed policy CLAUDE.md files cannot be excluded.

### `Read` Deny Rules

```json
{
  "permissions": {
    "deny": [
      "Read(./**/dist/**)",
      "Read(./**/build/**)",
      "Read(./**/*.generated.*)",
      "Read(./vendor/**)"
    ]
  }
}
```

Covers Claude's built-in file tools and recognized Bash file commands (`cat`, `head`, `grep`, `find`). Does not filter denied paths out of recursive search output.

### Worktree Sparse Checkout

```json
{
  "worktree": {
    "sparsePaths": [".claude", "packages/api", "packages/shared"],
    "symlinkDirectories": ["node_modules"]
  }
}
```

`sparsePaths` paths are relative to repo root. Root-level files are always checked out alongside listed directories. `symlinkDirectories` symlinks instead of duplicating heavy directories across worktrees.

### `additionalDirectories` vs. `--add-dir`

| Added with | Loads CLAUDE.md + rules | Loads skills |
|:-----------|:------------------------|:-------------|
| `additionalDirectories` setting | Never | Never |
| `--add-dir` flag / `/add-dir` | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` | Yes |

### Per-Directory Skills

Place skills under `<subdir>/.claude/skills/<skill-name>/SKILL.md`. They load only when Claude works in that directory. Use the `paths:` frontmatter field to scope a root-level skill to specific file patterns (e.g., `**/migrations/**`).

When starting from the repository root, skills from every subdirectory Claude touches can accumulate. Keep descriptions short and front-loaded with keywords a request would contain so Claude selects the right skill.

### CLAUDE.md Placement and Per-Directory Split

Common two-level split:
- **Root `CLAUDE.md`**: repo-wide coding standards, commit conventions, layout
- **Per-subdirectory `CLAUDE.md`**: stack-specific commands, test runners, env vars, patterns

Both are committed to the repo. Per-directory files load on demand when Claude reads files in that directory.

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — context management, verify-your-work patterns, explore-plan-implement workflow, prompting strategies, CLAUDE.md, permissions, hooks, skills, subagents, session management, parallel sessions, automation, and common failure modes
- [Common workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring codebases, fixing bugs, refactoring, testing, PRs, documentation, images, @ references, scheduled tasks; resuming sessions, worktrees, plan mode, subagents, and piping Claude into scripts
- [Plan in the cloud with ultraplan](references/claude-code-ultraplan.md) — launching ultraplan, status indicators, reviewing and revising the plan in the browser, executing on the web vs. sending back to the terminal
- [Find bugs with ultrareview](references/claude-code-ultrareview.md) — running `/code-review ultra`, pricing and free runs, tracking reviews, non-interactive `claude ultrareview` subcommand, comparison with `/review`
- [Orchestrate subagents at scale with dynamic workflows](references/claude-code-workflows.md) — when to use workflows, running `/deep-research`, having Claude write a workflow, ultracode mode, approval flow, saving for reuse, passing input to saved workflows, run management, cost, and disabling workflows
- [Set up Claude Code in a monorepo or large codebase](references/claude-code-large-codebases.md) — per-directory CLAUDE.md layering, `claudeMdExcludes`, Read deny rules, code intelligence plugins, sparse worktrees, `additionalDirectories`, per-directory skills, skill discoverability, and centralized plugin conventions

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Plan in the cloud with ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Find bugs with ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Orchestrate subagents at scale with dynamic workflows: https://code.claude.com/docs/en/workflows.md
- Set up Claude Code in a monorepo or large codebase: https://code.claude.com/docs/en/large-codebases.md
