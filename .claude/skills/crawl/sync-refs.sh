#!/usr/bin/env bash
# sync-refs.sh — Download reference files from skill-map.json, clean up orphans.
# Usage: sync-refs.sh <project-root> <plugin-root>
#   project-root: absolute path to the project (e.g., /Users/x/Projects/claudemd)
#   plugin-root:  relative path within project to the skills dir (e.g., skills)

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <project-root> <plugin-root>" >&2
  exit 1
fi

PROJECT_ROOT="$1"
PLUGIN_ROOT="$2"
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

downloaded=0
failed=0
deleted=0
declare -a expected_files=()

# Download all references from skill-map.json
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

# Build expected set for fast lookup
declare -A expected_set
for f in "${expected_files[@]}"; do
  expected_set["$f"]=1
done

# Find and delete orphans
while IFS= read -r -d '' actual_file; do
  rel_path="${actual_file#"$PROJECT_ROOT"/}"
  if [[ -z "${expected_set["$rel_path"]+_}" ]]; then
    rm "$actual_file"
    echo "DELETED orphan: $rel_path"
    ((deleted++))
  fi
done < <(find "$BASE_DIR" -path '*/references/*.md' -type f -print0)

# Remove empty skill directories (only if they have an empty references/ and no SKILL.md)
for dir in "$BASE_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  ref_dir="$dir/references"
  if [[ -d "$ref_dir" ]] && [[ -z "$(ls -A "$ref_dir" 2>/dev/null)" ]]; then
    rmdir "$ref_dir" 2>/dev/null || true
    # Remove skill dir if it's now empty
    if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
      rmdir "$dir" 2>/dev/null || true
      echo "REMOVED empty skill directory: ${dir#"$PROJECT_ROOT"/}"
    fi
  fi
done

echo ""
echo "sync-refs summary: downloaded=$downloaded failed=$failed orphans_deleted=$deleted"