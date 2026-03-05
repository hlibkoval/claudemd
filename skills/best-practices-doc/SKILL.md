---
name: best-practices-doc
description: Complete best practices and common workflows documentation for Claude Code — context window management, verification strategies, Plan Mode, CLAUDE.md authoring, prompt specificity, permission configuration, CLI tools, MCP servers, hooks, skills, subagents, plugins, session management (/clear, /compact, /rewind, --continue, --resume), parallel sessions, non-interactive mode, fan-out patterns, worktrees, extended thinking, debugging workflows, refactoring, testing, pull requests, image handling, and common failure patterns. Load when discussing effective Claude Code usage, workflow optimization, or prompting strategies.
user-invocable: false
---

# Best Practices & Common Workflows Documentation

This skill provides the complete official documentation for Claude Code best practices and everyday workflow recipes.

## Quick Reference

### Core Principle: Manage the Context Window

Claude's context window is the most important resource. Performance degrades as it fills. Track usage with a custom status line and use `/clear` between unrelated tasks.

### Highest-Leverage Practices

| Practice | Why it matters |
|:---------|:---------------|
| Provide verification criteria | Tests, screenshots, or expected outputs let Claude self-check |
| Explore first, plan, then code | Separate research from implementation to avoid solving the wrong problem |
| Give specific context | Reference files, mention constraints, point to example patterns |
| Run `/clear` between tasks | Prevents context pollution from unrelated work |
| Use subagents for investigation | Research runs in separate context, keeping main conversation clean |

### Prompt Improvement Patterns

| Strategy | Vague (avoid) | Specific (prefer) |
|:---------|:--------------|:-------------------|
| Verification | "implement email validation" | "write validateEmail, test with these cases, run the tests after" |
| Root cause | "the build is failing" | "build fails with [error]. Fix and verify build succeeds" |
| Scoped tasks | "add tests for foo.py" | "test foo.py covering logged-out edge case, avoid mocks" |
| Existing patterns | "add a calendar widget" | "look at HotDogWidget.php, follow the pattern for a calendar widget" |

### Providing Rich Content

- `@file.ts` -- reference files directly in prompts
- Paste or drag images into the prompt
- Give URLs for docs/API references
- Pipe data: `cat error.log | claude`
- Let Claude fetch context itself via Bash/MCP/Read

### Environment Configuration Checklist

| Setup | How |
|:------|:----|
| CLAUDE.md | `/init` to generate, then prune regularly |
| Permissions | `/permissions` to allowlist safe commands; `/sandbox` for OS isolation |
| CLI tools | Install `gh`, `aws`, `gcloud`, etc. for context-efficient external access |
| MCP servers | `claude mcp add` to connect Notion, Figma, databases |
| Hooks | `/hooks` for deterministic actions (linting after edits, blocking writes) |
| Skills | `.claude/skills/` for domain knowledge and reusable workflows |
| Subagents | `.claude/agents/` for specialized assistants with isolated context |
| Plugins | `/plugin` to browse the marketplace |

### CLAUDE.md Best Practices

| Include | Exclude |
|:--------|:--------|
| Bash commands Claude can't guess | Anything Claude can figure out from code |
| Code style rules differing from defaults | Standard language conventions |
| Testing instructions and preferred runners | Detailed API docs (link instead) |
| Repo etiquette (branch naming, PRs) | Frequently changing information |
| Architectural decisions | Long explanations or tutorials |
| Developer environment quirks | File-by-file codebase descriptions |

Keep CLAUDE.md concise. If Claude ignores a rule, the file is probably too long. Use `@path/to/import` syntax to import additional files.

### Session Management

| Action | How |
|:-------|:----|
| Stop mid-action | `Esc` |
| Rewind / restore checkpoint | `Esc + Esc` or `/rewind` |
| Undo changes | "Undo that" |
| Reset context | `/clear` |
| Compact context | `/compact <instructions>` or auto-compaction |
| Summarize from point | `Esc + Esc`, select message, choose "Summarize from here" |
| Resume last session | `claude --continue` |
| Pick a session | `claude --resume` |
| Name a session | `/rename <name>` |

### Plan Mode

| Activation | Method |
|:-----------|:-------|
| During session | `Shift+Tab` (cycle through modes) |
| New session | `claude --permission-mode plan` |
| Headless | `claude --permission-mode plan -p "query"` |
| Default setting | `"permissions": {"defaultMode": "plan"}` in `.claude/settings.json` |

Best for multi-file changes, unfamiliar code, or uncertain approaches. Skip for small, clear-scope fixes. Press `Ctrl+G` to open the plan in your editor for direct editing.

### Parallel Sessions & Automation

| Pattern | Command / approach |
|:--------|:-------------------|
| Non-interactive mode | `claude -p "prompt"` |
| Structured output | `--output-format json` or `--output-format stream-json` |
| Fan-out across files | Loop `claude -p` per file with `--allowedTools` |
| Desktop app sessions | Each session gets its own isolated worktree |
| Web sessions | `claude.ai/code` on Anthropic cloud VMs |
| Agent teams | Automated coordination with shared tasks and messaging |
| Writer/Reviewer | Session A implements, Session B reviews in fresh context |
| Skip permissions | `--dangerously-skip-permissions` (sandbox only) |

### Git Worktrees

| Command | Effect |
|:--------|:-------|
| `claude --worktree feature-auth` | Creates `.claude/worktrees/feature-auth/` with new branch |
| `claude --worktree` | Auto-generates random worktree name |
| Subagent isolation | `isolation: worktree` in agent frontmatter |
| Cleanup | Auto-removed if no changes; prompted otherwise |

Add `.claude/worktrees/` to `.gitignore`.

### Extended Thinking

| Control | Method |
|:--------|:-------|
| Effort level | `/model` menu or `CLAUDE_CODE_EFFORT_LEVEL` env var |
| One-off deep reasoning | Include "ultrathink" in your prompt |
| Toggle on/off | `Option+T` (macOS) / `Alt+T` |
| Global default | `/config` |
| Limit budget | `MAX_THINKING_TOKENS` env var |
| View thinking | `Ctrl+O` (verbose mode) |

Opus 4.6 uses adaptive reasoning (dynamic token allocation based on effort level).

### Common Workflows

| Workflow | Key steps |
|:---------|:----------|
| Codebase exploration | Ask broad questions, narrow down, request glossary |
| Bug fixing | Share error + repro steps, get fix suggestions, apply and verify |
| Refactoring | Find deprecated usage, get recommendations, apply incrementally, test |
| Writing tests | Identify untested code, generate scaffolding, add edge cases, run |
| Pull requests | Summarize changes, `create a pr`, enhance description |
| Documentation | Find undocumented code, generate docs, verify against project standards |
| Working with images | Drag/drop or paste images, ask for analysis/CSS generation |
| File references | `@path` for files, `@dir` for listings, `@server:resource` for MCP |
| Unix-style piping | `cat file \| claude -p "prompt" > output.txt` |
| CI/CD linting | `claude -p "you are a linter..."` in build scripts |

### Common Failure Patterns

| Anti-pattern | Fix |
|:-------------|:----|
| Kitchen sink session (mixed unrelated tasks) | `/clear` between tasks |
| Repeated corrections (3+ attempts) | `/clear`, write a better initial prompt |
| Over-specified CLAUDE.md | Prune ruthlessly; convert to hooks where possible |
| Trust-then-verify gap | Always provide tests/scripts/screenshots |
| Infinite exploration | Scope investigations or delegate to subagents |

## Full Documentation

For the complete official documentation, see the reference files:

- [Best practices](references/claude-code-best-practices.md) -- context management, verification strategies, Plan Mode workflow, CLAUDE.md authoring, prompt specificity, environment configuration, session management, parallel sessions, automation, and common failure patterns
- [Common workflows](references/claude-code-common-workflows.md) -- step-by-step recipes for codebase exploration, bug fixing, refactoring, subagents, Plan Mode, testing, pull requests, documentation, images, file references, extended thinking, session resumption, worktrees, notifications, and Unix-style piping

## Sources

- Best practices: https://code.claude.com/docs/en/best-practices.md
- Common workflows: https://code.claude.com/docs/en/common-workflows.md
