#!/usr/bin/env bash
# sync-refs.sh — Sync skill-map.json with llms.txt, download references, clean orphans.
# Usage: sync-refs.sh [project-root] [plugin-root]
#   project-root: absolute path to the project (default: $PWD)
#   plugin-root:  relative path within project to the skills dir (default: skills)

set -euo pipefail

PROJECT_ROOT="${1:-$PWD}"
PLUGIN_ROOT="${2:-skills}"
SKILL_MAP="$PROJECT_ROOT/.claude/skills/crawl/skill-map.json"
BASE_DIR="$PROJECT_ROOT/$PLUGIN_ROOT"

if [[ ! -f "$SKILL_MAP" ]]; then
  echo "Error: skill-map.json not found at $SKILL_MAP" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed" >&2
  exit 1
fi

# ── Phase 1: Sync skill-map.json with llms.txt ──────────────────────────────

echo "=== Phase 1: Syncing skill-map.json with llms.txt ==="

LLMS_URL="https://code.claude.com/docs/llms.txt"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Fetch llms.txt and extract all code.claude.com URLs from markdown links
curl -sL "$LLMS_URL" \
  | grep -oE 'https://code\.claude\.com/[^)]+' \
  | sort -u > "$tmpdir/llms_urls.txt"

llms_count=$(wc -l < "$tmpdir/llms_urls.txt" | tr -d ' ')
echo "  Fetched llms.txt: $llms_count URLs"

if [[ "$llms_count" -eq 0 ]]; then
  echo "Error: llms.txt returned no URLs — aborting sync" >&2
  exit 1
fi

# Extract code.claude.com URLs from skill-map.json
jq -r '.skills[][] | .url' "$SKILL_MAP" \
  | grep '^https://code\.claude\.com/' \
  | sort -u > "$tmpdir/map_cc_urls.txt"

# New: in llms.txt but not in skill-map.json
comm -23 "$tmpdir/llms_urls.txt" "$tmpdir/map_cc_urls.txt" > "$tmpdir/new_urls.txt"

# Removed: in skill-map.json but not in llms.txt
comm -13 "$tmpdir/llms_urls.txt" "$tmpdir/map_cc_urls.txt" > "$tmpdir/removed_urls.txt"

new_count=$(wc -l < "$tmpdir/new_urls.txt" | tr -d ' ')
removed_count=$(wc -l < "$tmpdir/removed_urls.txt" | tr -d ' ')

if [[ "$new_count" -gt 0 ]]; then
  echo ""
  echo "  NEW URLs (in llms.txt, not in skill-map.json):"
  while IFS= read -r url; do
    echo "    + $url"
  done < "$tmpdir/new_urls.txt"
fi

if [[ "$removed_count" -gt 0 ]]; then
  echo ""
  echo "  REMOVED URLs (in skill-map.json, not in llms.txt):"
  while IFS= read -r url; do
    echo "    - $url"
  done < "$tmpdir/removed_urls.txt"

  # Remove stale entries from skill-map.json
  # Build a jq filter that removes all removed URLs in one pass
  jq_filter='.'
  while IFS= read -r url; do
    jq_filter="$jq_filter | .skills |= with_entries(.value |= map(select(.url != \"$url\")))"
  done < "$tmpdir/removed_urls.txt"
  # Clean up empty skill arrays
  jq_filter="$jq_filter | .skills |= with_entries(select(.value | length > 0))"

  # Use jq args array approach instead — safer with special chars
  removed_json=$(jq -R -s 'split("\n") | map(select(length > 0))' < "$tmpdir/removed_urls.txt")
  jq --argjson removed "$removed_json" '
    .skills |= with_entries(
      .value |= map(select(.url as $u | ($removed | index($u)) == null))
    ) | .skills |= with_entries(select(.value | length > 0))
  ' "$SKILL_MAP" > "$tmpdir/skill-map-updated.json"

  mv "$tmpdir/skill-map-updated.json" "$SKILL_MAP"
  echo "  Updated skill-map.json: removed $removed_count stale entries"
fi

if [[ "$new_count" -eq 0 && "$removed_count" -eq 0 ]]; then
  echo "  skill-map.json is up to date with llms.txt"
fi

echo ""

# ── Phase 2: Download references + cleanup ───────────────────────────────────

echo "=== Phase 2: Downloading references ==="

downloaded=0
failed=0
deleted=0
declare -a expected_files=()

for skill in $(jq -r '.skills | keys[]' "$SKILL_MAP"); do
  ref_dir="$BASE_DIR/$skill/references"
  mkdir -p "$ref_dir"

  count=$(jq -r ".skills[\"$skill\"] | length" "$SKILL_MAP")
  for i in $(seq 0 $((count - 1))); do
    url=$(jq -r ".skills[\"$skill\"][$i].url" "$SKILL_MAP")
    file=$(jq -r ".skills[\"$skill\"][$i].file" "$SKILL_MAP")
    dest="$ref_dir/$file"

    expected_files+=("$PLUGIN_ROOT/$skill/references/$file")

    if curl -sL --fail "$url" -o "$dest" 2>/dev/null; then
      if [[ -s "$dest" ]]; then
        ((downloaded++))
      else
        echo "WARNING: Empty file from $url" >&2
        ((failed++))
      fi
    else
      echo "FAILED: curl $url" >&2
      ((failed++))
    fi
  done
done

# Build expected set as newline-separated string for grep lookup
expected_set=""
for f in "${expected_files[@]}"; do
  expected_set="$expected_set
$f"
done

# Find and delete orphans
while IFS= read -r actual_file; do
  [[ -z "$actual_file" ]] && continue
  rel_path="${actual_file#"$PROJECT_ROOT"/}"
  if ! echo "$expected_set" | grep -qxF "$rel_path"; then
    rm "$actual_file"
    echo "DELETED orphan: $rel_path"
    ((deleted++)) || true
  fi
done < <(find "$BASE_DIR" -path '*/references/*.md' -type f)

# Remove empty skill directories (only if they have an empty references/ and no SKILL.md)
for dir in "$BASE_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  ref_dir="$dir/references"
  if [[ -d "$ref_dir" ]] && [[ -z "$(ls -A "$ref_dir" 2>/dev/null)" ]]; then
    rmdir "$ref_dir" 2>/dev/null || true
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
      rmdir "$dir" 2>/dev/null || true
      echo "REMOVED empty skill directory: ${dir#"$PROJECT_ROOT"/}"
    fi
  fi
done

echo ""
echo "=== Summary ==="
echo "  downloaded=$downloaded failed=$failed orphans_deleted=$deleted"
if [[ "$new_count" -gt 0 ]]; then
  echo "  unmapped_new_urls=$new_count (need manual assignment)"
fi