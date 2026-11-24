#!/usr/bin/env bash
# Copies the Kitway privacy policy into the site.
#
# The policy text lives only in the Kitway repository: docs/privacy/privacy-policy.{en,uk}.md.
# Each site page is: front matter, then the Kitway file without its first "# Title" line, byte for byte.
# The title moves into the front matter, because the page renders the front matter title as its heading.
# Kitway's Skills/scripts/check-privacy-site.sh compares the two and fails when they differ.
#
# Usage: scripts/sync-privacy.sh <path-to-Kitway-checkout>
set -euo pipefail

kitway="${1:?usage: scripts/sync-privacy.sh <path-to-Kitway-checkout>}"
site="$(cd "$(dirname "$0")/.." && pwd)"

sync_one() {
  local source="$kitway/docs/privacy/privacy-policy.$1.md" target="$site/Content/Pages/$2"
  [[ -f "$source" ]] || { echo "sync-privacy: $source not found" >&2; exit 1; }
  local first
  first="$(head -n 1 "$source")"
  [[ "$first" == "# "* ]] || { echo "sync-privacy: $source must start with a '# Title' line" >&2; exit 1; }
  local title="${first#\# }"
  {
    printf -- '---\n'
    printf 'id: "privacy"\n'
    printf 'title: "%s"\n' "${title//\"/\\\"}"
    printf 'slug: "privacy"\n'
    printf 'legalDocument: true\n'
    [[ "$1" != "en" ]] && printf 'originalLanguage: "en"\n'
    printf -- '---\n'
    tail -n +2 "$source"
  } >"$target"
  echo "sync-privacy: $target"
}

sync_one en Privacy.md
sync_one uk Privacy.uk.md
