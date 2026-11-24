#!/usr/bin/env bash
# Wait until a ServiceNow change request is approved (CAB gate).
# Usage: servicenow-cab-check.sh <CHG number> [max minutes]
# Env: SN_INSTANCE (e.g. willowmere.service-now.com), SN_USER, SN_PASSWORD
set -euo pipefail
chg="${1:?CHG number}"; max="${2:-60}"
for i in $(seq 1 "$max"); do
  state=$(curl -sf -u "$SN_USER:$SN_PASSWORD" \
    "https://$SN_INSTANCE/api/now/table/change_request?sysparm_query=number=$chg&sysparm_fields=approval,state" \
    | python3 -c 'import sys,json; r=json.load(sys.stdin)["result"]; print(r[0]["approval"] if r else "missing")')
  echo "$chg approval: $state"
  case "$state" in
    approved) exit 0 ;;
    rejected|missing) echo "::error::$chg is $state"; exit 1 ;;
  esac
  sleep 60
done
echo "::error::$chg not approved within $max minutes (risk #8: record approval manually or move the window)"; exit 1
