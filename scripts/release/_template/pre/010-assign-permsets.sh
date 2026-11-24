#!/usr/bin/env bash
# Example pre-deploy step: assign permission sets the new fields need. Safe to rerun.
# Users not found are reported, not fatal (risk #7).
set -uo pipefail
PERMSET="Hauling_Dispatcher"
USERS=("dispatcher1@example.com.qa" "dispatcher2@example.com.qa")
for u in "${USERS[@]}"; do
  sf org assign permset --name "$PERMSET" --on-behalf-of "$u" --target-org "$TARGET_ORG" \
    || echo "::warning::Could not assign $PERMSET to $u"
done
