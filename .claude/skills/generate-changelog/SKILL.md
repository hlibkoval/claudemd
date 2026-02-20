---
name: generate-changelog
description: Analyze upstream documentation diffs and generate a CHANGELOG.md entry summarizing new features, changes, and removals.
context: fork
agent: general-purpose
allowed-tools: Read, Edit, Bash, Glob, Grep
---

# Generate Changelog Entry

Analyze changed reference documentation and add an entry to `CHANGELOG.md`.

## 1. Find changed references

```bash
git diff --name-only -- '*/references/*'
```

If no files changed, stop — there's nothing to log.

## 2. Map to skills

Extract skill names from paths (`skills/<skill-name>/references/...`). Collect the unique set.

## 3. Read the diffs

For each changed skill, read its reference diffs:

```bash
git diff -- 'skills/<skill-name>/references/*'
```

## 4. Analyze changes

Categorize each change:

- **New**: genuinely new features, sections, capabilities, or configuration options that didn't exist before
- **Changed**: substantive modifications — rewrites, behavior changes, new details added to existing sections
- **Removed**: content deleted from upstream docs
- **Trivial**: whitespace, formatting, link/image URL updates, typo fixes

## 5. Write the entry

Read `CHANGELOG.md` and insert a new entry after the header block (the `# Changelog` line and description paragraph). Use this format:

```markdown
## YY.M.D

**N references updated across M skills:** skill-a, skill-b, ...

### New
- **Feature name** — description (skill-name)

### Changed
- **What changed** — description (skill-name)

### Removed
- **What was removed** — description (skill-name)
```

## Rules

1. Use today's date in `YY.M.D` format (e.g., `26.2.20`) for the version header
2. Omit any section (New/Changed/Removed) that has no entries
3. Collapse trivial-only changes into a single line: `- Minor wording/formatting updates across skill-a, skill-b docs`
4. If ALL changes are trivial, write just: `Minor formatting updates only` instead of sections
5. Parenthetical at the end of each bullet indicates which skill(s) the change affects
6. Be specific about what changed — name the feature, flag, config key, or section
7. Keep bullets to one line each. No sub-bullets.
8. Do NOT modify reference files. Only edit `CHANGELOG.md`.
