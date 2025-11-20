# R1Soft SBM Scanner – Test Plan
1) Path A (inventory): add one SBM into inventories/sbms.yml → run `make scan` with -e api_user/api_pass
2) Path B (CSV): edit data/sbms.csv → run `make scan_csv` with -e api_user/api_pass
3) Verify reports/ JSON+MD created; confirm HTTP/APIDOC/AUTH flags and version guesses
4) In AWX: run "SBM – Inventory Scan & Report (Inventory)" and "(CSV)" → download artifacts
5) Optional SSH vars on one host → confirm Samples/PHP SOAP flags
