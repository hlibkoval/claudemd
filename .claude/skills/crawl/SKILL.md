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

Review the output above. If there are **NEW unmapped URLs**, ask the user which skill to assign each to (show existing skill names as options, or let them create a new skill name). Auto-generate the `file` field as `claude-code-{slug}.md` where `{slug}` comes from the URL filename without extension. Add entries to `.claude/skills/crawl/skill-map.json`, then re-run the script to download the newly mapped references:

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