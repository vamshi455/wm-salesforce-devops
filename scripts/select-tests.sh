#!/usr/bin/env bash
# Print the specified Apex tests for the changed components, space separated.
# Usage: select-tests.sh <delta-folder>
# Reads tests/manifests/*.txt (glob  TestClass). Fails if a changed Apex class has no mapped test (risk #4).
set -euo pipefail
delta="${1:?delta folder required}"
changed=$(cd "$delta" 2>/dev/null && find force-app -type f | sed 's#force-app/main/default/##' || true)
tests=(); unmapped=()
while read -r file; do
  [ -z "$file" ] && continue
  hit=0
  while read -r glob cls; do
    [[ -z "$glob" || "$glob" == \#* ]] && continue
    # shellcheck disable=SC2053
    if [[ "$file" == $glob ]]; then tests+=("$cls"); hit=1; fi
  done < <(cat tests/manifests/*.txt)
  if [[ $hit -eq 0 && "$file" == classes/*.cls && "$file" != *Test.cls ]]; then unmapped+=("$file"); fi
  [[ "$file" == classes/*Test.cls ]] && tests+=("$(basename "$file" .cls)")
done <<< "$changed"
if [ ${#unmapped[@]} -gt 0 ]; then
  printf '::error::No test mapped for %s\n' "${unmapped[@]}" >&2; exit 1
fi
printf '%s\n' "${tests[@]:-}" | sort -u | grep -v '^$' | tr '\n' ' '
