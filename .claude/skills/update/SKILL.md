---
name: update
description: Run a full update cycle — crawl docs, bump version, commit and push.
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Glob, Grep, Skill, AskUserQuestion
---

# Full Update Cycle

Crawl upstream docs, bump the calendar version, and ship.

## Steps

### 1. Crawl docs

Invoke the crawl skill to sync references and regenerate changed skills:

```
/crawl
```

### 2. Extract version from CHANGELOG.md

The `/crawl` step generates a new changelog entry at the top of `CHANGELOG.md` with a `## YY.M.D` header using today's date. Read `CHANGELOG.md` and extract the version from the first `## ` heading. This is the version to use.

If the first `## ` heading version already matches the current version in `.claude-plugin/plugin.json`, the crawl produced no meaningful changes — stop and tell the user nothing needs updating.

### 3. Bump version

Update the version in both files to match the changelog version:

- `.claude-plugin/plugin.json` — `"version"` field
- `.claude-plugin/marketplace.json` — `"version"` field inside the `plugins` array

Use the `Edit` tool to update each file. Both must have the same version string.

### 4. Confirm with user

Use `AskUserQuestion` to show the user a summary of what changed and ask whether to commit and push. Include:

- The new version
- A brief summary of the changelog entry (skills affected, key changes)

If the user declines, stop here.

### 5. Commit and push

Stage all changes and commit. Build the commit message from the changelog entry:

- **Title line:** `Sync upstream docs and bump to <version>`
- **Body:** The full content of the changelog entry for this version (everything under the `## YY.M.D` header up to the next `## ` header or end of file), verbatim.

```bash
git add -A
```

Then push to origin.
