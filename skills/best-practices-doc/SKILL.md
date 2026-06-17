---
name: best-practices-doc
user-invocable: false
---

# Best Practices & Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, ultraplan, ultrareview, dynamic workflows, and working in large codebases.

## Quick Reference

### Core Principle: Context Window Is the Key Resource

Claude's context window holds every message, file read, and command output. Performance degrades as it fills. Most best practices flow from managing this constraint.

### Verify Claude's Work

| Verification method | How to use |
| :--- | :--- |
| **Inline check** | Ask Claude to run tests/lint in the same prompt and iterate until they pass |
| **`/goal` condition** | Set a check that a separate evaluator re-runs after every turn |
| **Stop hook** | A script that blocks the turn from ending until a check passes (overridden after 8 blocks) |
| **Verification subagent** | A fresh model tries to refute the result independently |

Always ask Claude to show evidence (test output, command results, screenshots) rather than assert success.

### Explore → Plan → Code → Commit Workflow

| Phase | Mode | Key action |
| :--- | :--- | :--- |
| **Explore** | Plan mode | Read files, answer questions, no edits |
| **Plan** | Plan mode | Create detailed implementation plan; press `Ctrl+G` to edit in editor |
| **Implement** | Default mode | Code against the plan; run tests |
| **Commit** | Default mode | Commit with descriptive message, open PR |

Skip planning when the diff can be described in one sentence. Use it when multiple files change or the approach is uncertain.

### Prompt Specificity Strategies

| Strategy | Vague | Specific |
| :--- | :--- | :--- |
| Scope the task | "add tests for foo.py" | "write a test for foo.py covering logged-out users; avoid mocks" |
| Point to sources | "why does ExecutionFactory have a weird API?" | "look through ExecutionFactory's git history and summarize" |
| Reference patterns | "add a calendar widget" | "look at HotDogWidget.php and follow the same pattern" |
| Describe symptoms | "fix the login bug" | "users report login fails after session timeout; check src/auth/" |

### Providing Rich Context

- Use `@filename` to reference files directly
- Paste images (copy/paste or drag-and-drop) for UI comparisons
- Pipe data: `cat error.log | claude`
- Give URLs for docs; use `/permissions` to allowlist domains
- Tell Claude to fetch context itself via Bash or MCP tools

### CLAUDE.md Quick Guide

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules differing from defaults | Standard conventions Claude already knows |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file codebase descriptions |

Run `/init` to generate a starter CLAUDE.md. Import files with `@path/to/file` syntax. Add emphasis ("IMPORTANT", "YOU MUST") for critical rules. Keep it concise — bloated files cause Claude to ignore instructions.

### CLAUDE.md File Locations

| Location | Scope |
| :--- | :--- |
| `~/.claude/CLAUDE.md` | All sessions (personal) |
| `./CLAUDE.md` (committed) | Project — shared with team |
| `./CLAUDE.local.md` (gitignored) | Project — personal only |
| Parent directories | Monorepo — pulled in automatically |
| Child directories | Loaded on demand when Claude reads files there |

### Permission Modes

| Mode | Description | Best for |
| :--- | :--- | :--- |
| **Default** | Prompt for each risky action | General interactive use |
| **Auto mode** | Classifier blocks risky commands; routine work proceeds | Trusted direction tasks without constant clicking |
| **Allowlists** | Permit specific tools (e.g., `npm run lint`) | Known-safe commands |
| **Sandboxing** | OS-level isolation for filesystem/network | Free Claude to work within defined boundaries |

### Session Management Commands

| Command | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved |
| `Esc Esc` or `/rewind` | Open rewind menu; restore conversation/code to a checkpoint |
| `/clear` | Reset context entirely between unrelated tasks |
| `/compact <instructions>` | Compact history with focus hint |
| `/btw` | Side question — answer appears in overlay, never enters history |
| `/rename` | Name the session (treat like a branch) |
| `claude --continue` | Resume most recent session |
| `claude --resume` | Choose from session list |

### Context Management Rules

- Use `/clear` frequently between unrelated tasks
- After two failed corrections on the same issue, `/clear` and write a better prompt
- Auto compaction preserves code patterns, file states, and key decisions
- Customize compaction with CLAUDE.md: `"When compacting, always preserve the full list of modified files"`
- Use subagents for investigation so file reads stay out of the main conversation

### Parallel & Automation Patterns

| Pattern | How |
| :--- | :--- |
| Non-interactive CI | `claude -p "prompt" --output-format stream-json --verbose` |
| Parallel worktrees | `claude --worktree feature-name` in separate terminals |
| Fan-out migration | Loop `claude -p` per file with `--allowedTools "Edit,Bash(git commit *)"` |
| Auto mode unattended | `claude --permission-mode auto -p "fix all lint errors"` |
| Writer/Reviewer | Session A implements; Session B reviews the diff in a fresh context |
| Adversarial review | Subagent reviews diff against plan; reports gaps not style preferences |

### Common Failure Patterns

| Failure | Fix |
| :--- | :--- |
| Kitchen sink session (unrelated tasks mixed) | `/clear` between tasks |
| Repeated corrections (>2) | `/clear` + better initial prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert to hooks what must be enforced |
| Trust-then-verify gap | Always provide tests/scripts/screenshots |
| Infinite exploration | Scope narrowly or delegate to subagents |

### Common Workflow Recipes

| Task | Key prompts |
| :--- | :--- |
| **Codebase overview** | "give me an overview of this codebase" → "explain the main architecture patterns" |
| **Find code** | "find the files that handle user authentication" → "trace the login process from front-end to database" |
| **Fix bugs** | Share error → "suggest a few ways to fix" → "update file to add the null check" |
| **Refactor** | "find deprecated API usage" → "suggest how to refactor X" → "run tests for the refactored code" |
| **Tests** | "find untested functions in X" → "add tests" → "add edge case tests" → "run and fix failures" |
| **Pull requests** | "summarize my changes" → "create a pr" → "enhance description with more context" |
| **Documentation** | "find functions without JSDoc in auth module" → "add JSDoc comments" → "improve with examples" |

### Schedule Recurring Tasks

| Option | Runs on | Best for |
| :--- | :--- | :--- |
| **Routines** | Anthropic infrastructure | Tasks that run when your computer is off; supports API/GitHub triggers |
| **Desktop scheduled tasks** | Your machine | Tasks needing local files, tools, or uncommitted changes |
| **GitHub Actions** | CI pipeline | Tasks tied to repo events or cron alongside workflow config |
| **`/loop`** | Current CLI session | Quick polling while session is open |

---

### Ultraplan

Launch from CLI in three ways: `/ultraplan <prompt>`, include the word `ultraplan` in a prompt, or choose "Refine with Ultraplan" from a local plan approval dialog.

| Status indicator | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching and drafting |
| `◇ ultraplan needs your input` | Clarifying question — open the session link |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Execution choices (from browser):**
- **Approve and start coding** — implements in the same cloud session; create PR from web interface
- **Approve and teleport back to terminal** — sends plan to your waiting CLI

**Terminal dialog options (after teleport):**
- **Implement here** — inject plan into current conversation
- **Start new session** — fresh context with plan only (prints `claude --resume` command)
- **Cancel** — saves plan to a file

Ultraplan requires a Claude Code on the web account and a GitHub repo. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

---

### Ultrareview (`/code-review ultra`)

Deep multi-agent code review running on cloud infrastructure. Every finding is independently reproduced and verified before being reported.

| | `/review` | `/code-review ultra` |
| :--- | :--- | :--- |
| Runs | Locally in your session | Remotely in a cloud sandbox |
| Depth | Single-pass review | Multi-agent fleet with independent verification |
| Duration | Seconds to a few minutes | ~5–10 minutes |
| Cost | Normal usage | 3 free runs, then ~$5–20 per review as usage credits |
| Best for | Quick feedback while iterating | Pre-merge confidence on substantial changes |

**Usage:**
- `/code-review ultra` — reviews diff between current branch and default branch (includes uncommitted/staged)
- `/code-review ultra 1234` — reviews a GitHub PR by number (PR mode; clones from GitHub)
- `claude ultrareview` — non-interactive subcommand for CI; blocks until done, prints findings to stdout

**Non-interactive flags:**

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` payload |
| `--timeout <minutes>` | Max wait time (default: 30) |

Use `/tasks` to track running reviews. Stopping a review archives the session; partial findings are not returned.

---

### Dynamic Workflows

A JavaScript script that orchestrates subagents at scale. Claude writes the script; a runtime executes it in the background.

| | Subagents | Skills | Agent teams | Workflows |
| :--- | :--- | :--- | :--- | :--- |
| Who decides next step | Claude, turn by turn | Claude, following prompt | Lead agent | The script |
| Where results live | Claude's context | Claude's context | Shared task list | Script variables |
| Scale | A few per turn | Same as subagents | Handful of long-running peers | Dozens to hundreds per run |
| Repeatable | Worker definition | Instructions | Team definition | Orchestration itself |

**Trigger a workflow:**
- `/deep-research <question>` — bundled workflow for multi-source research
- Include keyword `ultracode` in any prompt (or say "use a workflow")
- `/effort ultracode` — session-level setting; Claude plans a workflow for every substantive task

**Approval options (CLI):**

| Option | Effect |
| :--- | :--- |
| Yes, run it | Start the run |
| Yes, and don't ask again for `<name>` in `<path>` | Start and skip future prompts for this workflow here |
| View raw script | Inspect before deciding |
| No | Cancel |

**Progress view keys (`/workflows`):**

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Select phase or agent |
| `Enter` or `→` | Drill into phase/agent |
| `Esc` | Back out one level |
| `p` | Pause or resume run |
| `x` | Stop selected agent or whole workflow |
| `r` | Restart selected running agent |
| `s` | Save run's script as a command |

**Limits:** up to 16 concurrent agents; 1,000 agents total per run. Runs are resumable within the same session. To disable: toggle in `/config`, set `"disableWorkflows": true` in settings, or set `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

---

### Large Codebases & Monorepos

**Settings at a glance:**

| Goal | Setting / Mechanism |
| :--- | :--- |
| Load only conventions for code you touch | Per-directory CLAUDE.md files |
| Exclude irrelevant CLAUDE.md files | `claudeMdExcludes` in settings |
| Block reads of build output / vendored code | `Read` deny rules in `permissions.deny` |
| Find symbols without scanning files | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Check out only needed directories in worktrees | `worktree.sparsePaths` |
| Read/edit sibling packages | `additionalDirectories` or `--add-dir` flag |
| Give Claude procedures for one area | Per-directory `.claude/skills/` |
| Centralize conventions across repos | Plugin in an internal marketplace |

**Common split for CLAUDE.md in a monorepo:**
- **Root CLAUDE.md**: repo layout, coding standards, commit conventions
- **Per-package CLAUDE.md**: stack-specific commands, env vars, test runners

**Worktree sparse checkout example:**
```json
{
  "worktree": {
    "sparsePaths": [".claude", "packages/api", "packages/shared"],
    "symlinkDirectories": ["node_modules"]
  }
}
```

**claudeMdExcludes example:**
```json
{
  "claudeMdExcludes": [
    "**/packages/admin-dashboard/**",
    "**/packages/legacy-*/**"
  ]
}
```

**Read deny rules example:**
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

**`--add-dir` vs `additionalDirectories`:**

| | `additionalDirectories` | `--add-dir` / `/add-dir` |
| :--- | :--- | :--- |
| Loads CLAUDE.md and rules | Never | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` |
| Loads skills | Never | Yes |

**Starting directory matters:** project settings in `.claude/settings.json` load only from the starting directory, not inherited from parents (unlike CLAUDE.md files). Per-package `.claude/settings.json` must be self-contained.

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices for Claude Code](references/claude-code-best-practices.md) — Core patterns: verification, explore-plan-code, prompting, CLAUDE.md, permissions, session management, automation, and common failure patterns
- [Common Workflows](references/claude-code-common-workflows.md) — Step-by-step recipes for codebase exploration, bug fixing, refactoring, testing, PRs, documentation, images, scheduling, and more
- [Ultraplan](references/claude-code-ultraplan.md) — Cloud-based planning: launch methods, status indicators, inline comments, browser review, execution choices (web vs terminal teleport)
- [Ultrareview (Find Bugs)](references/claude-code-ultrareview.md) — Deep multi-agent code review: usage, pricing, tracking, non-interactive subcommand, comparison with local `/review`
- [Dynamic Workflows](references/claude-code-workflows.md) — Orchestrate subagents at scale: when to use workflows, bundled `/deep-research`, writing and saving workflows, runtime behavior, limits, and cost
- [Monorepos and Large Codebases](references/claude-code-large-codebases.md) — Layered CLAUDE.md files, excludes, deny rules, code intelligence plugins, sparse worktrees, additional directories, per-directory skills, centralization patterns

## Sources

- Best Practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
- Dynamic Workflows: https://code.claude.com/docs/en/workflows.md
- Monorepos and Large Codebases: https://code.claude.com/docs/en/large-codebases.md
