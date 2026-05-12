---
name: best-practices-doc
description: Complete official documentation for Claude Code best practices, common workflows, ultraplan, and ultrareview — context management, prompting patterns, CLAUDE.md setup, parallel sessions, permissions, verification strategies, and cloud-based planning and code review.
user-invocable: false
---

# Best Practices & Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, and cloud-based planning/review features (ultraplan and ultrareview).

## Quick Reference

### Core Constraint: Context Window

The context window is the most important resource to manage. LLM performance degrades as context fills. Every file read, message, and command output consumes tokens.

| Technique | When to Use |
| :--- | :--- |
| `/clear` | Between unrelated tasks to reset context |
| `/compact <instructions>` | Preserve key decisions while freeing space |
| `Esc + Esc` or `/rewind` | Restore previous conversation/code state |
| Subagents | Investigate codebases without filling main context |
| Plan mode | Read and plan without making edits |

### Verification Strategies

| Strategy | Vague Prompt | Specific Prompt |
| :--- | :--- | :--- |
| Provide test cases | "implement email validation" | "write validateEmail; test cases: user@example.com → true, invalid → false. run tests after" |
| Verify UI visually | "make dashboard look better" | "[screenshot] implement design, take screenshot, compare to original, fix differences" |
| Address root cause | "the build is failing" | "build fails with [error]. fix it, verify build succeeds, address root cause not symptom" |

### Explore → Plan → Implement → Commit Workflow

1. **Explore** (plan mode): read files, understand structure — no edits
2. **Plan** (plan mode): create a detailed implementation plan; press `Ctrl+G` to edit in text editor
3. **Implement** (default mode): let Claude code, verify against plan
4. **Commit**: ask Claude to commit with a descriptive message and open a PR

Use plan mode for multi-file changes or unfamiliar code. Skip it for small, clear tasks.

### CLAUDE.md Quick Guide

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can infer from code |
| Code style rules that differ from defaults | Standard language conventions |
| Testing instructions and preferred test runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks, required env vars | File-by-file codebase descriptions |

CLAUDE.md locations:
- `~/.claude/CLAUDE.md` — all sessions
- `./CLAUDE.md` — project root, check into git
- `./CLAUDE.local.md` — personal project notes, add to `.gitignore`
- Parent and child directories — loaded automatically or on demand

Import other files with `@path/to/file` syntax inside CLAUDE.md.

### Permission Modes

| Mode | How It Works | Best For |
| :--- | :--- | :--- |
| Default | Prompts for every write/command | Careful, step-by-step work |
| Auto mode (`--permission-mode auto`) | Classifier blocks risky actions; routine work proceeds | Trusted tasks without constant click-through |
| Allowlists (`/permissions`) | Permit specific safe commands (e.g. `npm run lint`) | Known-safe repeated commands |
| Sandboxing (`/sandbox`) | OS-level filesystem/network restrictions | Maximum isolation |

### Parallel & Automation Patterns

| Pattern | How | Use Case |
| :--- | :--- | :--- |
| Worktrees | `claude --worktree <name>` | Parallel sessions without edit collisions |
| Non-interactive | `claude -p "prompt"` | CI, pre-commit hooks, scripts |
| Structured output | `claude -p "..." --output-format json` | Parse results programmatically |
| Fan-out | Loop `claude -p` with `--allowedTools` | Large migrations across many files |
| Writer/Reviewer | Two sessions, one implements, one reviews | Quality-focused parallel workflow |
| Auto mode headless | `claude --permission-mode auto -p "..."` | Unattended execution with safety checks |

### Session Management Commands

| Command | Action |
| :--- | :--- |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Choose from list of sessions |
| `/rename` | Name the current session |
| `/clear` | Reset context window entirely |
| `/compact <instructions>` | Condense context with custom instructions |
| `Esc` | Stop Claude mid-action (context preserved) |
| `Esc + Esc` / `/rewind` | Open rewind menu to restore previous state |
| `/btw` | Ask a side question without entering it into context |

### Common Failure Patterns

| Pattern | Fix |
| :--- | :--- |
| Kitchen sink session (unrelated tasks mixed) | `/clear` between tasks |
| Correcting over and over (2+ failed attempts) | `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md (rules get ignored) | Ruthlessly prune; convert to hooks if needed |
| Trust-then-verify gap (no test criteria) | Always provide tests, scripts, or screenshots |
| Infinite exploration (hundreds of files read) | Scope investigations; use subagents |

### Common Workflow Prompt Recipes

| Task | Prompt Pattern |
| :--- | :--- |
| Codebase overview | "give me an overview of this codebase" |
| Find relevant code | "find the files that handle user authentication" |
| Fix a bug | "I'm seeing [error] when I run [command]. Suggest fixes for @file.ts" |
| Refactor | "refactor utils.js to use ES2024 features while maintaining the same behavior" |
| Add tests | "find functions in X not covered by tests; add tests for edge conditions" |
| Create PR | "summarize my changes and create a PR" |
| Let Claude interview you | "I want to build [X]. Interview me using AskUserQuestion. Keep asking until we've covered everything, then write a spec to SPEC.md." |

### Ultraplan

Cloud-based planning in a web session while your terminal stays free. Requires Claude.ai account and GitHub repo. Not available with Bedrock, Vertex AI, or Microsoft Foundry.

| Launch Method | How |
| :--- | :--- |
| Command | `/ultraplan <your prompt>` |
| Keyword | Include "ultraplan" in a normal prompt |
| From local plan | Choose "No, refine with Ultraplan on Claude Code on the web" |

Status indicators while remote session works:

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Claude is researching and drafting the plan |
| `◇ ultraplan needs your input` | Claude has a clarifying question |
| `◆ ultraplan ready` | Plan ready to review in browser |

After reviewing (inline comments, emoji reactions, outline sidebar), execute options:
- **Approve and start coding** — implements in the cloud session
- **Approve and teleport back to terminal** — sends plan to your waiting local terminal

Local terminal options after teleport: **Implement here**, **Start new session**, or **Cancel** (saves plan to file).

### Ultrareview

Deep multi-agent code review running in a remote cloud sandbox. Requires Claude.ai account. Not available with Bedrock, Vertex AI, Microsoft Foundry, or Zero Data Retention orgs.

| Command | What it reviews |
| :--- | :--- |
| `/ultrareview` | Diff between current branch and default branch (includes uncommitted changes) |
| `/ultrareview 1234` | GitHub pull request by number |
| `claude ultrareview` | Non-interactive (CI/scripts); blocks until done, prints findings to stdout |
| `claude ultrareview 1234` | Non-interactive PR review |
| `claude ultrareview origin/main` | Non-interactive diff against specific base branch |

Non-interactive flags:

| Flag | Description |
| :--- | :--- |
| `--json` | Print raw `bugs.json` payload instead of formatted findings |
| `--timeout <minutes>` | Max wait time; defaults to 30 |

Pricing: Pro/Max get 3 free runs (through May 5, 2026); after that, billed as extra usage (~$5–$20 per review). Team/Enterprise: no free runs, always extra usage. A run counts even if stopped early.

Review takes 5–10 minutes; runs as a background task. Use `/tasks` to monitor or stop. Each verified finding includes file location and issue explanation.

| | `/review` | `/ultrareview` |
| :--- | :--- | :--- |
| Runs | locally | remotely in cloud sandbox |
| Depth | single-pass | multi-agent with independent verification |
| Duration | seconds to minutes | ~5–10 minutes |
| Cost | normal usage | free runs, then ~$5–$20 extra usage |
| Best for | quick feedback while iterating | pre-merge confidence on substantial changes |

### Scheduled Tasks

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Routines | Anthropic-managed infrastructure | Tasks that run when computer is off; trigger on API/GitHub events too |
| Desktop scheduled tasks | Your machine via desktop app | Tasks needing local files or uncommitted changes |
| GitHub Actions | CI pipeline | Repo events (opened PRs) or cron schedules alongside workflow config |
| `/loop` | Current CLI session | Quick polling while session is open |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best Practices](references/claude-code-best-practices.md) — context management, verification, explore-plan-implement workflow, CLAUDE.md, permissions, communication, session management, automation, parallel sessions
- [Common Workflows](references/claude-code-common-workflows.md) — prompt recipes for exploring, debugging, refactoring, testing, PRs, documentation, images, file references, scheduled tasks
- [Ultraplan](references/claude-code-ultraplan.md) — cloud-based planning, browser review interface, executing on web vs. teleporting to terminal
- [Ultrareview](references/claude-code-ultrareview.md) — multi-agent cloud code review, pricing, non-interactive mode, comparison with `/review`

## Sources

- Best Practices: https://code.claude.com/docs/en/best-practices.md
- Common Workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview: https://code.claude.com/docs/en/ultrareview.md
