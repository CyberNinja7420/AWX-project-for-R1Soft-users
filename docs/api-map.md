# SBM API capability map

| Method | Purpose | Required fields | Expected response / notes |
| --- | --- | --- | --- |
| `GetVersion` (SOAP) | Discover SBM version for compatibility checks. | Authenticated SOAP request. | Returns version string (e.g., `6.16.4`). Used for warnings about deprecated features. |
| `FindUserByName` (SOAP) | Determine whether a Power-User exists. | Target username. | Returns user record when present; 404/exception when missing. Wrapper interprets absence as "Already exists" state. |
| `CreatePowerUser` (SOAP) | Create Power-User with optional sub-user allowance. | Username, password (unless LDAP), email, full name, allow_subusers flag, optional volume placeholders. | Success returns new user object; wrapper emits `Successfully created power user`. |
| `UpdatePowerUser` (SOAP) | Update email/full_name or sub-user flag idempotently. | Username plus fields to update. | No change when identical data; wrapper outputs `Already exists`. |
| `DisablePowerUser` (SOAP) | Disable a Power-User and optionally related sub-users/policies. | Username. | Returns success flag; wrapper emits `Disabled` or `Already disabled`. |
| LDAP configuration (`SetLdapConfig`) | Configure LDAP/AD server-wide. | Server URL, bind DN/pass, base DN, optional group map. | Applied cluster-wide; playbook guards with dry-run and validation. |

> The direct API role (`roles/sbm_api_direct`) uses `ansible.builtin.uri` to send SOAP envelopes to `https://<sbm>:<port>/ServerBackupManager/api`. The vendor-sample path (`roles/sbm_api_samples`) wraps the packaged PHP examples to keep behavior aligned with upstream guidance.
