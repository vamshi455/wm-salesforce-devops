#!/usr/bin/env bash
# Run the pre or post deployment steps for a release, in file-name order.
# Usage: run-release-steps.sh <release e.g. 2026-12> <pre|post> <org alias>
# Each step is an idempotent script (*.sh) or a data file (*.csv with a matching *.upsert config).
set -euo pipefail
rel="${1:?release}"; phase="${2:?pre|post}"; org="${3:?org alias}"
dir="scripts/release/$rel/$phase"
[ -d "$dir" ] || { echo "No $phase steps for $rel"; exit 0; }
mkdir -p release-logs
for step in $(ls "$dir" | sort); do
  path="$dir/$step"
  echo "::group::$phase step $step"
  case "$step" in
    *.sh)  TARGET_ORG="$org" bash "$path" 2>&1 | tee "release-logs/$phase-$step.log" ;;
    *.csv) cfg="${path%.csv}.upsert"   # first line: SObject, second line: external ID field
           sobject=$(sed -n 1p "$cfg"); extid=$(sed -n 2p "$cfg")
           sf data upsert bulk --sobject "$sobject" --file "$path" --external-id "$extid" \
              --target-org "$org" --wait 30 2>&1 | tee "release-logs/$phase-$step.log" ;;
    *) echo "skip $step" ;;
  esac
  echo "::endgroup::"
done
