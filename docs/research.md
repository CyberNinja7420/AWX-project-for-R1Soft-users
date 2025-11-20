# Research notes for SBM automation

## Vendor API access
- **SOAP/WSDL**: The Server Backup Manager UI exposes SOAP APIs under `https://<sbm>:<port>/ServerBackupManager/` (commonly `9443`). The built-in WSDL advertised at `/ServerBackupManager/api?wsdl` works on both 6.16.x and 6.18.x+ when `php-soap` is available and TLS certificate validation is relaxed for automation controllers.
- **API samples**: Linux installations ship vendor samples in `/usr/sbin/r1soft/apisamples`. Typical files used for user management include:
  - `Volumes_With_Limits_Power_User_With_Sub_User_Allowed.php` – creates a volume, Power-User, and allows sub-users.
  - `Power_User_No_Sub_User_Allowed.php` – variant for environments that forbid sub-users.
  - `Disable_Power_User_And_Subusers.php` – disables a Power-User and iterates sub-users/policies.
- **Authentication**: SOAP calls require SBM credentials; AWX should inject these via credentials or survey variables. TLS validation can be disabled for lab environments but should be enabled with trusted certificates in production.

## LDAP/AD support
- SBM supports LDAP/AD authentication. Required fields typically include server URI (e.g., `ldaps://ad.example.com`), bind DN/password, base DN, user filter, and optional group mapping for Power-User or Administrator roles.
- When LDAP is enabled for a user, local passwords are ignored. Account existence and disablement still occur through the SBM API.

## Compatibility matrix

| Feature | 6.16.x | 6.18.x+ | Notes / breaking changes |
| --- | --- | --- | --- |
| Vendor API samples | ✅ Available on Linux at `/usr/sbin/r1soft/apisamples` | ✅ Available; filenames unchanged | Ensure `php-cli`/`php-soap` installed. |
| SOAP API (`/ServerBackupManager/api?wsdl`) | ⚠️ Works but may have stricter TLS defaults | ✅ Works; newer schema versions | Disable certificate validation for testing only. |
| Power-User create/update | ✅ via samples; SOAP stable | ✅ | Sub-user allowance handled by sample selection. |
| Power-User disable | ✅ via `Disable_Power_User_And_Subusers.php` | ✅ | Output strings normalized by wrapper. |
| LDAP auth fields | ✅ Supported | ✅ | Same fields; prefer LDAPS. |
| Data Center Console (DCC) | ⚠️ Deprecated; present <=6.16.5 | ⚠️ Removed | We only warn when DCC requested on <6.18. |

## References
- Live API docs (per-manager): `https://<sbm>:<port>/apidoc`
- Sample paths: `/usr/sbin/r1soft/apisamples`
- Known package requirements: `php-cli`, `php-soap`
