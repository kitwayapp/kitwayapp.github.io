#!/usr/bin/env bash
# Fails when a built page links an /assets/ or root file that the build did not write.
# Run after the build. On Linux (CI, GitHub Pages) the check is case-sensitive, as the live site is:
# a folder named Images under a link to /images/ fails here, although it works on a Mac.
set -euo pipefail
site="${1:-_Site}"
missing=0
while IFS= read -r ref; do
  path="${ref%%[?#]*}"
  [[ -f "$site$path" ]] && continue
  [[ -f "$site$path/index.html" ]] && continue
  echo "check-assets: $path is linked but missing" >&2
  missing=$((missing + 1))
done < <(grep -rhoE '(src|href)="/[^"/][^"]*\.(png|jpe?g|webp|svg|css|js|ico)"' "$site" --include='*.html' \
  | sed -E 's/^(src|href)="//; s/"$//' | sort -u)
if [[ $missing -gt 0 ]]; then
  echo "check-assets: $missing missing file(s)" >&2
  exit 1
fi
echo "check-assets: every linked asset exists"
