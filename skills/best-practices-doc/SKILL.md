---
name: best-practices-doc
user-invocable: false
---

# Best Practices Documentation

This skill provides the complete official documentation for Claude Code best practices, common workflows, advanced planning and review features (ultraplan and ultrareview), dynamic workflows, and large codebase configuration.

## Quick Reference

### Core Best Practices

| Practice | Key Principle |
| :--- | :--- |
| **Give Claude a verification check** | Tests, build exit codes, linters, or screenshot diffs close the loop so Claude can self-correct without you watching |
| **Explore → Plan → Code → Commit** | Use plan mode to separate research from implementation; skip planning for small, clear-scope tasks |
| **Provide specific context** | Reference files with `@`, paste images, pipe data; scope tasks to files and scenarios |
| **Write an effective CLAUDE.md** | Short, human-readable; only include what Claude can't infer from code; run `/init` to generate a starter |
| **Manage context aggressively** | Use `/clear` between unrelated tasks; use `/compact`, `/rewind`, or `/btw` for fine-grained control |
| **Use subagents for investigation** | Delegate research so file reads don't fill your main context window |

### Verification Strategies

| Approach | Setup | Use when |
| :--- | :--- | :--- |
| In-prompt check | Ask Claude to run tests and iterate in the same message | Simple one-off tasks |
| `/goal` condition | A separate evaluator re-checks after every turn | Longer attended sessions |
| Stop hook | Script blocks turn from ending until check passes; 8-consecutive-block cap | Unattended runs |
| Verification subagent | Fresh model attempts to refute the result independently | Adversarial quality check |

### CLAUDE.md — What to Include vs. Exclude

| Include | Exclude |
| :--- | :--- |
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard language conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks (required env vars) | File-by-file descriptions of the codebase |
| Common gotchas or non-obvious behaviors | Self-evident practices like "write clean code" |

CLAUDE.md can import additional files using `@path/to/import` syntax. Load locations:

| Location | Scope |
| :--- | :--- |
| `~/.claude/CLAUDE.md` | All Claude sessions |
| `./CLAUDE.md` | Project root; check into git to share |
| `./CLAUDE.local.md` | Personal project-specific notes; add to `.gitignore` |
| Parent directories | Auto-pulled for monorepos |
| Child directories | Pulled on demand when Claude reads a file there |

### Permission Modes

| Mode | How it works | Best for |
| :--- | :--- | :--- |
| Default | Prompts for each potentially destructive action | Careful, attended work |
| Auto mode | Classifier reviews commands; blocks scope escalation/unknown infra | Trust-but-verify unattended runs |
| Allowlists | Permit specific safe tools (e.g., `npm run lint`, `git commit`) | Reducing repetitive prompts |
| Sandboxing | OS-level isolation restricting filesystem and network access | Maximum safety |

### Session Management Commands

| Command / Key | Effect |
| :--- | :--- |
| `Esc` | Stop Claude mid-action; context preserved for redirect |
| `Esc Esc` or `/rewind` | Open rewind menu; restore conversation, code, or both to a checkpoint |
| `/clear` | Reset context between unrelated tasks |
| `/compact <instructions>` | Compact with custom focus (e.g., `/compact Focus on the API changes`) |
| `/btw` | Ask a side question without it entering conversation history |
| `/rename` | Name the current session for later resumption |
| `claude --continue` | Resume most recent session in current directory |
| `claude --resume` | Choose from a list of saved sessions |

### Parallelization Options

| Option | Where it runs | Best for |
| :--- | :--- | :--- |
| Worktrees (`claude --worktree <name>`) | Local isolated git checkouts | Concurrent feature/bugfix sessions without collisions |
| Desktop app sessions | Local, visual management | Multiple local sessions in one UI |
| Claude Code on the web | Anthropic-managed cloud VMs | Sessions independent of your machine |
| Agent teams | Automated multi-session coordination | Long-running coordinated work with a team lead |

### Non-Interactive / CI Usage

```bash
# One-off query
claude -p "Explain what this project does"

# Structured output
claude -p "List all API endpoints" --output-format json

# Streaming
claude -p "Analyze this log file" --output-format stream-json --verbose

# Fan-out loop (restrict tools with --allowedTools)
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done

# Auto mode for unattended runs
claude --permission-mode auto -p "fix all lint errors"
```

### Common Failure Patterns to Avoid

| Failure | Fix |
| :--- | :--- |
| Kitchen-sink session (mixing unrelated tasks) | `/clear` between tasks |
| Correcting the same issue repeatedly | After two failed corrections, `/clear` and write a better initial prompt |
| Over-specified CLAUDE.md | Ruthlessly prune; convert stable rules to hooks |
| Trust-then-verify gap (no check after implementation) | Always provide verification — tests, scripts, or screenshots |
| Infinite exploration (unbounded "investigate" prompt) | Scope narrowly or delegate to a subagent |

---

### Common Workflow Recipes

| Task | Key steps |
| :--- | :--- |
| **Understand a new codebase** | Ask for high-level overview → dive into specific components → request architecture and data-model explanations |
| **Fix a bug** | Share error + reproduction steps → ask for fix recommendations → apply → verify |
| **Refactor** | Find deprecated usage → get recommendations → apply in small increments → run tests |
| **Write tests** | Identify untested code → generate scaffolding → add edge-case tests → run and fix |
| **Create a PR** | Summarize changes → `create a pr` → review and refine |
| **Run scheduled tasks** | Use Routines (cloud), desktop scheduled tasks (local), GitHub Actions (CI), or `/loop` (current session) |

### Reference / Rich Content Techniques

| Method | When to use |
| :--- | :--- |
| `@file` reference | Include file content without describing it; also pulls in parent CLAUDE.md files |
| `@dir` reference | Get a directory listing |
| Paste images (drag-drop or Ctrl+V) | Screenshots of errors, UI designs, diagrams |
| `cat file | claude` | Send file contents directly via stdin |
| `@server:resource` | Fetch from connected MCP servers |

---

### Ultraplan — Cloud-Based Planning

Ultraplan hands a planning task to a Claude Code on the web session in plan mode. Your terminal stays free while the cloud session drafts the plan.

**Launch methods:**
- `/ultraplan <prompt>` — explicit command
- Include the word `ultraplan` in a normal prompt
- From a finished local plan: choose "No, refine with Ultraplan on Claude Code on the web"

**Status indicators in CLI:**

| Status | Meaning |
| :--- | :--- |
| `◇ ultraplan` | Drafting in progress |
| `◇ ultraplan needs your input` | Open the session link to answer a clarifying question |
| `◆ ultraplan ready` | Plan ready to review in browser |

**Execution options after browser review:**
- **Approve and start coding** — implements in the same cloud session; create a PR from the web UI
- **Approve and teleport back to terminal** — sends plan to local CLI; choose "Implement here", "Start new session", or "Cancel" (saves to file)

Requires Claude Code on the web account and a GitHub repository. Not available on Bedrock, Vertex AI, or Microsoft Foundry.

---

### Ultrareview — Deep Cloud Code Review

Invoked with `/code-review ultra` (or alias `/ultrareview`). Launches a fleet of reviewer agents in a remote sandbox to find and independently verify bugs before merging.

**Review scope:**
- No arguments → reviews diff between current branch and default branch (including uncommitted/staged changes)
- `/code-review ultra 1234` → reviews a GitHub pull request by number

**Command comparison:**

| | `/code-review` | `/review <pr>` | `/code-review ultra` |
| :--- | :--- | :--- | :--- |
| Target | Working diff | GitHub PR | Working diff or PR |
| Runs | Locally | Locally | Remote sandbox |
| Depth | Scales with effort arg | Medium | Multi-agent fleet + verification |
| Duration | Seconds–minutes | A few minutes | ~5–10 minutes |
| Cost | Normal usage | Normal usage | Free runs, then ~$5–$20 per review |

**Pricing:**

| Plan | Free runs | After |
| :--- | :--- | :--- |
| Pro / Max | 3 (one-time) | Usage credits |
| Team / Enterprise | 0 | Usage credits |

**CI / non-interactive:**
```bash
claude ultrareview           # current branch vs default
claude ultrareview 1234      # PR number
claude ultrareview --json    # machine-readable output
```

Exit codes: 0 = success (findings or not), 1 = launch failure or timeout, 130 = Ctrl-C.

---

### Dynamic Workflows

A dynamic workflow is a JavaScript script that orchestrates subagents at scale. Claude writes the script; a runtime executes it in the background.

**When to use workflows vs. alternatives:**

| | Subagents | Skills | Agent teams | Workflows |
| :--- | :--- | :--- | :--- | :--- |
| Who decides next step | Claude, turn by turn | Claude, following prompt | Lead agent | The script |
| Intermediate results | Claude's context | Claude's context | Shared task list | Script variables |
| Scale | A few per turn | Same | A handful of peers | Dozens to hundreds of agents |
| Repeatable | Worker definition | Instructions | Team definition | Orchestration itself |

**Built-in workflow:**

| Command | What it does |
| :--- | :--- |
| `/deep-research <question>` | Fans out web searches, cross-checks sources, returns a cited report |

**Trigger methods:**
- Include the keyword `ultracode` in a prompt (or ask "use a workflow" in plain words)
- `/effort ultracode` — sets ultracode mode for the whole session; Claude decides when to use a workflow

**Workflow controls in `/workflows` view:**

| Key | Action |
| :--- | :--- |
| `↑`/`↓` | Select phase or agent |
| `Enter`/`→` | Drill into phase or agent |
| `Esc` | Back out one level |
| `p` | Pause or resume |
| `x` | Stop selected agent or whole workflow |
| `r` | Restart selected agent |
| `s` | Save run's script as a reusable command |

**Limits:** 16 concurrent agents; 1,000 agents total per run. No mid-run user input except permission prompts. File edits auto-approved inside workflows.

**Save a workflow:** press `s` in `/workflows`; save to `.claude/workflows/` (shared) or `~/.claude/workflows/` (personal). Runs as `/<name>` in future sessions.

**Disable workflows:**
- `/config` → toggle Dynamic workflows off
- `"disableWorkflows": true` in `~/.claude/settings.json`
- `CLAUDE_CODE_DISABLE_WORKFLOWS=1` environment variable

---

### Large Codebases and Monorepos

| Goal | Setting / Technique |
| :--- | :--- |
| Load only relevant CLAUDE.md per area | Per-directory CLAUDE.md files (layered at launch + on demand) |
| Exclude irrelevant CLAUDE.md files | `claudeMdExcludes` in `.claude/settings.local.json` (glob patterns) |
| Block reads of build output and vendored code | `Read` deny rules in `permissions.deny` |
| Jump to definitions without file scans | Code intelligence plugin (`/plugin install typescript-lsp@claude-plugins-official`) |
| Sparse worktree checkout | `worktree.sparsePaths` in `.claude/settings.json` |
| Avoid duplicating large dirs across worktrees | `worktree.symlinkDirectories` |
| Access sibling packages | `permissions.additionalDirectories` (settings) or `--add-dir` (runtime flag) |
| Per-area skills (load only when relevant) | `.claude/skills/` inside the subdirectory |

**Starting directory determines scope:**

| Start from | File access | CLAUDE.md loaded at launch |
| :--- | :--- | :--- |
| Repository root | Every file | Root only; subdirs load on demand |
| A subdirectory | That subtree only | That dir + every ancestor |

**Per-directory CLAUDE.md vs. path-scoped rules:**

| Approach | File location | Loads when |
| :--- | :--- | :--- |
| Per-directory `CLAUDE.md` | Inside the directory | At launch or on demand when Claude reads there |
| `.claude/rules/` path-scoped rule | Central repo root | When Claude works with a file matching the glob |

**`additionalDirectories` vs. `--add-dir`:**

| Added with | Loads CLAUDE.md and rules | Loads skills |
| :--- | :--- | :--- |
| `additionalDirectories` setting | Never | Never |
| `--add-dir` or `/add-dir` | Only with `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` | Yes |

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices for Claude Code](references/claude-code-best-practices.md) — Context management, verification strategies, CLAUDE.md authoring, permissions, subagents, parallel sessions, non-interactive mode, common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) — Step-by-step recipes: codebase exploration, bug fixing, refactoring, testing, PRs, documentation, images, scheduled tasks
- [Ultraplan](references/claude-code-ultraplan.md) — Launch, review, and execute cloud-drafted plans from CLI or browser
- [Ultrareview](references/claude-code-ultrareview.md) — Deep multi-agent code review in a remote sandbox, pricing, CI usage, comparison with local review commands
- [Dynamic workflows](references/claude-code-workflows.md) — Workflow runtime, bundled `/deep-research` command, writing and saving custom workflows, ultracode mode, cost and limits
- [Large codebases and monorepos](references/claude-code-large-codebases.md) — Per-directory CLAUDE.md, `claudeMdExcludes`, deny rules, code intelligence plugins, sparse worktrees, cross-package access, per-directory skills

## Sources

- Best practices for Claude Code: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
- Ultraplan: https://code.claude.com/docs/en/ultraplan.md
- Ultrareview (Find bugs with ultrareview): https://code.claude.com/docs/en/ultrareview.md
- Dynamic workflows: https://code.claude.com/docs/en/workflows.md
- Large codebases: https://code.claude.com/docs/en/large-codebases.md
