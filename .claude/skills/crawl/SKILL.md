---
name: crawl
description: Crawl Claude Code documentation, download reference pages, detect changes, and regenerate SKILL.md files for the claudemd plugin.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep, Skill
---

# Crawl & Update claudemd Plugin

Update all reference documentation and regenerate skills that changed.

## Prerequisites

The plugin repo MUST be a git repo with a clean working tree before running.
If it isn't, initialize it:

```bash
cd $CLAUDE_PROJECT_DIR
git init && git add -A && git commit -m "baseline before crawl"
```

## Steps

### 1. Read the skill map

Read the skill map at `.claude/skills/crawl/skill-map.json`. This defines:
- `plugin_root`: directory containing plugin skills (default: `skills`)
- `skills`: object mapping skill names to arrays of `{url, file}` entries

### 2. Download all reference docs

For each skill in the map, for each doc entry:

```bash
mkdir -p "$CLAUDE_PROJECT_DIR/<plugin_root>/<skill-name>/references"
curl -sL "<url>" -o "$CLAUDE_PROJECT_DIR/<plugin_root>/<skill-name>/references/<file>"
```

Run all curl commands. Report any failures (non-zero exit or empty files).

### 3. Detect orphaned references

Compare what's on disk against the skill map to find orphaned files — references that were previously downloaded but are no longer listed in the map (e.g., a doc was removed, renamed, or reassigned to a different skill).

```bash
# List every file currently in any references/ directory
find "$CLAUDE_PROJECT_DIR/<plugin_root>" -path '*/references/*.md' -type f
```

For each file found, check whether it appears in `skill-map.json` for that skill. A file is **orphaned** if:
- It exists in `<plugin_root>/<skill-name>/references/<file>` but no entry in `skill-map.json` maps to that skill+file combination, OR
- The entire skill directory exists on disk but has no entry in `skill-map.json` at all

Collect orphaned files into a list. **Do not delete them automatically.** Report them in the status table so the user can decide.

### 4. Detect changes with git

After all downloads complete, run:

```bash
cd $CLAUDE_PROJECT_DIR
git diff --name-only -- '*/references/*'
```

This gives the list of changed reference files. Map each changed file back to its skill name by extracting the skill directory from the path (`<plugin_root>/<skill-name>/references/...`).

Collect the **unique set of skill names** that have at least one changed reference.

Also check for skills that have reference files but NO `SKILL.md` yet:

```bash
for dir in $CLAUDE_PROJECT_DIR/<plugin_root>/*/references; do
  skill_dir="$(dirname "$dir")"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "MISSING: $skill_dir/SKILL.md"
  fi
done
```

Add those to the set of skills needing (re)generation.

### 5. Report status

Print a summary table:

| Skill | Refs Changed | Orphaned Refs | SKILL.md | Action |
|-------|-------------|---------------|----------|--------|
| hooks | 2 files | — | exists | regenerate |
| mcp | 1 file | — | missing | generate |
| skills | 0 files | — | exists | skip |
| old-topic | — | 2 files | exists | ORPHANED |

If there are orphaned files, list them explicitly:

```
Orphaned references (not in skill-map.json):
  skills/old-topic/references/removed-doc.md
  skills/hooks/references/renamed-old-doc.md
```

Ask the user whether to delete orphaned files before proceeding with regeneration.

### 6. Regenerate changed skills

For each skill that needs (re)generation:

1. Delete the existing SKILL.md if present:
   ```bash
   rm "$CLAUDE_PROJECT_DIR/<plugin_root>/<skill-name>/SKILL.md"
   ```

2. Invoke the generate-skill-md skill with the skill name:
   ```
   /generate-skill-md <skill-name>
   ```

Process skills **one at a time** sequentially (each invocation is a forked context).

### 7. Final summary

After all regenerations complete, run:

```bash
cd $CLAUDE_PROJECT_DIR
git diff --stat
```

Report what changed overall.

## Notes

- If `$ARGUMENTS` is provided (e.g., `/crawl hooks plugins`), only process those specific skills instead of all skills in the map.
- Never commit automatically. The user will review and commit.
