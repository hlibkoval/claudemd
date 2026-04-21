---
name: crawl
description: Crawl Claude Code documentation, download reference pages, and detect changes for the claudemd plugin.
allowed-tools: Bash, Read, Glob, Grep, Skill
---

# Crawl & Update claudemd Plugin

Update all reference documentation and regenerate skills that changed.

## Steps

### 1. Sync llms.txt, download references, cleanup orphans

Output from sync script:

!`bash .claude/skills/crawl/sync-refs.sh`

Review the output above. If there are **NEW unmapped URLs**, assign each one to a skill **autonomously — do not ask the user**. Use these rules:

1. Inspect the URL path and filename slug, then match against the existing skill groupings in `skill-map.json`.
2. Pick the best-fitting existing skill by topic. Heuristics:
   - `/docs/en/agent-sdk/*` → `agent-sdk-doc`
   - `/docs/en/whats-new/*`, `changelog.md`, `analytics.md`, `costs.md`, `monitoring-usage.md`, `troubleshooting.md` → `operations-doc`
   - `hooks*.md` → `hooks-doc`
   - `plugin*.md`, `discover-plugins.md` → `plugins-doc`
   - `mcp*.md` (non-SDK) → `mcp-doc`
   - `memory.md`, `claude-directory.md` → `memory-doc`
   - `settings.md`, `permissions*.md`, `env-vars.md`, `server-managed-settings.md` → `settings-doc`
   - `cli-reference.md`, `commands.md`, `interactive-mode.md`, `keybindings.md`, `terminal-config.md`, `tools-reference.md` → `cli-doc`
   - `overview.md`, `quickstart.md`, `setup.md`, `authentication.md`, `how-claude-code-works.md`, `platforms.md` → `getting-started-doc`
   - `best-practices.md`, `common-workflows.md`, `ultraplan.md` → `best-practices-doc`
   - `desktop*.md`, `vs-code.md`, `jetbrains.md`, `chrome.md`, `computer-use.md` → `ide-doc`
   - `amazon-bedrock.md`, `google-vertex-ai.md`, `microsoft-foundry.md`, `third-party-integrations.md`, `llm-gateway.md` → `cloud-providers-doc`
   - `github-actions.md`, `gitlab-ci-cd.md`, `slack.md`, `code-review.md`, `github-enterprise-server.md` → `ci-cd-doc`
   - `security.md`, `sandboxing.md`, `devcontainer.md`, `network-config.md`, `data-usage.md`, `legal-and-compliance.md`, `zero-data-retention.md` → `security-doc`
   - `headless.md`, `claude-code-on-the-web.md`, `web-quickstart.md` → `headless-doc`
   - `sub-agents.md`, `agent-teams.md` → `sub-agents-doc` / `agent-teams-doc` respectively
   - `skills.md`, skill specs → `skills-doc`
   - Anything else feature-ish (fast-mode, output-styles, statusline, checkpointing, routines, etc.) → `features-doc`
3. If no existing skill clearly fits, create a new skill with a `<topic>-doc` name derived from the URL slug.
4. Auto-generate the `file` field as `claude-code-{slug}.md` where `{slug}` is the URL path after `/docs/en/` with `/` replaced by `-` and `.md` stripped (e.g., `agent-sdk/hooks.md` → `claude-code-agent-sdk-hooks.md`; `hooks.md` → `claude-code-hooks.md`).

Add the new entries to `skill-map.json` directly using the `Edit` tool, preserving existing ordering and JSON formatting. Then re-run the script to download the newly mapped references:

```bash
bash .claude/skills/crawl/sync-refs.sh
```

### 2. Detect changes with git

After all downloads complete, run:

```bash
git diff --name-only -- '*/references/*'
```

This gives the list of changed reference files. Map each changed file back to its skill name by extracting the skill directory from the path (`skills/<skill-name>/references/...`).

Collect the **unique set of skill names** that have at least one changed reference.

Also check for skills that have reference files but NO `SKILL.md` yet:

```bash
for dir in skills/*/references; do
  skill_dir="$(dirname "$dir")"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "MISSING: $skill_dir/SKILL.md"
  fi
done
```

Add those to the set of skills needing (re)generation.

### 3. Report status

Print a summary table:

| Skill | Refs Changed | SKILL.md | Action |
|-------|-------------|----------|--------|
| hooks | 2 files | exists | regenerate |
| mcp | 1 file | missing | generate |
| skills | 0 files | exists | skip |

## Notes

- If `$ARGUMENTS` is provided (e.g., `/crawl hooks plugins`), only process those specific skills instead of all skills in the map. The llms.txt sync in Step 1 still runs fully, but Step 2 onward only processes the named skills.
- Never commit automatically. The user will review and commit.