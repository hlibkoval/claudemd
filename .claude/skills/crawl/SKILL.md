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

### 1. Fetch and parse llms.txt

Download the canonical doc index:

```bash
curl -sL https://code.claude.com/docs/llms.txt
```

Parse all markdown link entries matching `- [title](url)`. Extract the URL from each. This gives the set of **llms.txt URLs**.

### 2. Sync skill-map.json

Read the current skill-map at `.claude/skills/crawl/skill-map.json`.

Build the set of **map URLs** — every `url` field across all skills in the map.

Compare the two sets, **excluding external URLs** (any URL whose host is NOT `code.claude.com`) from the comparison:

- **Existing**: URL is in both llms.txt and the map → no action
- **New**: URL is in llms.txt but not in the map → unmapped, needs assignment
- **Removed**: URL is in the map but not in llms.txt (and is a `code.claude.com` URL) → flag for removal

Print a sync report table:

| Status | URL | Skill (if mapped) |
|--------|-----|-------------------|
| existing | .../hooks.md | hooks |
| NEW | .../new-feature.md | — |
| REMOVED | .../old-doc.md | settings |

**Handle removed docs:** Remove entries from skill-map.json for any REMOVED URLs.

**Handle new docs:** For each NEW URL, ask the user which skill to assign it to (show existing skill names as options, or let them create a new skill name). Auto-generate the `file` field as `claude-code-{slug}.md` where `{slug}` comes from the URL filename without extension. Add the entry to skill-map.json.

Write the updated skill-map.json.

### 3. Download references + cleanup

Run the sync script to download all references and delete orphans:

```bash
bash .claude/skills/crawl/sync-refs.sh "$CLAUDE_PROJECT_DIR" "skills"
```

The script reads skill-map.json, curls every reference, and deletes any on-disk files not in the map. Report any failures from the script output.

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
for dir in $CLAUDE_PROJECT_DIR/skills/*/references; do
  skill_dir="$(dirname "$dir")"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    echo "MISSING: $skill_dir/SKILL.md"
  fi
done
```

Add those to the set of skills needing (re)generation.

### 5. Report status

Print a summary table:

| Skill | Refs Changed | SKILL.md | Action |
|-------|-------------|----------|--------|
| hooks | 2 files | exists | regenerate |
| mcp | 1 file | missing | generate |
| skills | 0 files | exists | skip |

### 6. Regenerate changed skills

For each skill that needs (re)generation:

1. Delete the existing SKILL.md if present:
   ```bash
   rm "$CLAUDE_PROJECT_DIR/skills/<skill-name>/SKILL.md"
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

- If `$ARGUMENTS` is provided (e.g., `/crawl hooks plugins`), only process those specific skills instead of all skills in the map. The llms.txt sync (Steps 1-2) still runs fully, but Step 3 onward only processes the named skills.
- Never commit automatically. The user will review and commit.