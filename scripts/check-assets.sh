#!/usr/bin/env bash
# Fails when the built site links a file of its own that the build did not write.
#
# Checks the src/href/content references in the HTML (root-relative, or absolute to this site) and the url(...)
# references in the CSS. Run after the build. On Linux (CI, GitHub Pages) the check is case-sensitive, as the live
# site is: a folder named Images under a link to /images/ fails here, although it works on a Mac.
#
# Usage: scripts/check-assets.sh [site-dir]   (default _Site)
set -euo pipefail
site="${1:-_Site}"
base="https://kitwayapp.github.io"
ext='png|jpe?g|webp|svg|gif|ico|css|js|woff2?'

if [[ ! -d "$site" ]] || [[ -z "$(find "$site" -name '*.html' -print -quit)" ]]; then
  echo "check-assets: no built pages in $site" >&2
  exit 1
fi

refs="$(
  {
    grep -rhoE "(src|href|content)=\"($base)?/[^\"/][^\"]*\\.($ext)([?#][^\"]*)?\"" "$site" --include='*.html' \
      | sed -E "s/^(src|href|content)=\"//; s/\"\$//" || true
    grep -rhoE "url\\(['\"]?($base)?/[^)'\"]*\\.($ext)([?#][^)'\"]*)?['\"]?\\)" "$site" --include='*.css' \
      | sed -E "s/^url\\(['\"]?//; s/['\"]?\\)\$//" || true
  } | sed -E "s#^$base##; s/[?#].*\$//" | sort -u
)"

if [[ -z "$refs" ]]; then
  echo "check-assets: found no asset links in $site; the check would prove nothing" >&2
  exit 1
fi

missing=0
count=0
while IFS= read -r path; do
  count=$((count + 1))
  [[ -f "$site$path" ]] && continue
  echo "check-assets: $path is linked but missing" >&2
  missing=$((missing + 1))
done <<<"$refs"

if [[ $missing -gt 0 ]]; then
  echo "check-assets: $missing of $count linked file(s) missing" >&2
  exit 1
fi
echo "check-assets: all $count linked files exist"
