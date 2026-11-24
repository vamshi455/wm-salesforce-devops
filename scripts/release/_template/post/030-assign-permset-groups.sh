#!/usr/bin/env bash
# Example post-deploy step: assign a permission set group after deployment.
set -uo pipefail
sf org assign permset --name "Billing_Analyst_Group" --on-behalf-of "analyst1@example.com.qa" --target-org "$TARGET_ORG" \
  || echo "::warning::Assignment failed"
