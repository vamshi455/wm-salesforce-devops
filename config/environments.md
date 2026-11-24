# Environment values

Named credential endpoints and other per-environment values are tokens in Git, such as `{{ERP_ENDPOINT}}`.
The real values live in **GitHub → Settings → Environments** (`integration`, `qa`, `production`) as variables or secrets,
and `scripts/replace-tokens.sh` swaps them in before each deploy. Never commit real secrets.

| Token | Integration | QA | Production |
|---|---|---|---|
| `ERP_ENDPOINT` | vars.ERP_ENDPOINT | vars.ERP_ENDPOINT | vars.ERP_ENDPOINT |
| `ROUTING_API_ENDPOINT` | vars.ROUTING_API_ENDPOINT | … | … |

Per-environment custom metadata records go in `config/qa/` and `config/prod/` and are deployed by the matching stage.
Custom settings values are loaded as data in the post-deploy steps.
