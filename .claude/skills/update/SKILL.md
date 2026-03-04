---
name: update
description: Run a full update cycle — crawl docs, bump version, commit and push.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Glob, Grep, Skill, Agent, AskUserQuestion
---

# Full Update Cycle

Crawl upstream docs, bump the calendar version, and ship.

## Steps

### 1. Crawl docs

Invoke the crawl skill to sync references and detect changes:

```
/crawl
```

This syncs all reference docs, detects changes via git diff, and reports a status table of which skills need regeneration. If no references changed and no SKILL.md files are missing, stop and tell the user nothing needs updating.

### 2. Regenerate changed skills

For each skill that `/crawl` reported as needing (re)generation:

1. Delete the existing SKILL.md if present:
   ```bash
   rm "skills/<skill-name>/SKILL.md"
   ```

2. Spawn a `general-purpose` Agent subagent to regenerate it:
   ```
   /skill-creator Create/regenerate SKILL.md for the `<skill-name>` skill. Read the project conventions at `.claude/skills/crawl/skill-md-conventions.md`. Read all reference docs in `skills/<skill-name>/references/`. This is an automated doc-sync regeneration — generate the skill directly, skip evals.
   ```

Launch all subagents in a single turn so they run in parallel.

### 3. Update CHANGELOG.md

Invoke the generate-changelog skill to analyze reference diffs and add an entry:

```
/generate-changelog
```

### 4. Extract version from CHANGELOG.md

The previous step generates a new changelog entry at the top of `CHANGELOG.md` with a `## YY.M.D` header using today's date. Read `CHANGELOG.md` and extract the version from the first `## ` heading. This is the version to use.

If the first `## ` heading version already matches the current version in `.claude-plugin/plugin.json`, the crawl produced no meaningful changes — stop and tell the user nothing needs updating.

### 5. Bump version

Update the version in both files to match the changelog version:

- `.claude-plugin/plugin.json` — `"version"` field
- `.claude-plugin/marketplace.json` — `"version"` field inside the `plugins` array

Use the `Edit` tool to update each file. Both must have the same version string.

### 6. Confirm with user

Use `AskUserQuestion` to show the user a summary of what changed and ask whether to commit and push. Include:

- The new version
- A brief summary of the changelog entry (skills affected, key changes)

If the user declines, stop here.

### 7. Commit and push

Stage all changes and commit. Build the commit message from the changelog entry:

- **Title line:** `Sync upstream docs and bump to <version>`
- **Body:** The full content of the changelog entry for this version (everything under the `## YY.M.D` header up to the next `## ` header or end of file), verbatim.

```bash
git add -A
```

Then push to origin.
