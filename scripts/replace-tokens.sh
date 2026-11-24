#!/usr/bin/env bash
# Replace {{TOKEN}} placeholders in a source folder with values from the environment.
# Usage: replace-tokens.sh <folder>   (tokens are read from env vars of the same name)
# Fails the build if any token is left unreplaced (risk #6).
set -euo pipefail
dir="${1:?folder required}"
[ -d "$dir" ] || { echo "No folder $dir, nothing to replace"; exit 0; }
mapfile -t tokens < <(grep -rhoE '\{\{[A-Z0-9_]+\}\}' "$dir" | sort -u | tr -d '{}' || true)
for t in "${tokens[@]}"; do
  val="${!t:-}"
  if [ -z "$val" ]; then echo "::error::No value for token $t in this environment"; exit 1; fi
  grep -rlF "{{$t}}" "$dir" | while read -r f; do
    python3 - "$f" "$t" "$val" <<'PY'
import sys; p,t,v=sys.argv[1:]; s=open(p).read(); open(p,'w').write(s.replace('{{'+t+'}}',v))
PY
  done
  echo "Replaced $t"
done
if grep -rqE '\{\{[A-Z0-9_]+\}\}' "$dir"; then echo "::error::Unreplaced tokens remain"; exit 1; fi
