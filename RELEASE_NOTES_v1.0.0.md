# GetItcmdGUI v1.0.0

First public release of **GetItcmdGUI**.

## Highlights

- Dual list engines:
  - **GetItCmd** listing
  - **REST** listing
- Clear functional split between GetItCmd mode and REST mode.
- Faster and cleaner local filtering on REST data.
- Category-aware filtering and local sorting tools.
- Improved installed-state detection via registry scans.
- Better diagnostics with output/install logs and save support.

## What's New

- REST local filter stack includes:
  - text contains (3+ chars)
  - category
  - Delphi-only
  - latest-only
  - installed/not-installed
- Latest-version selection now uses `VersionTimestamp` with stable grouping (`base ID + vendor + libcode`).
- Added explicit warning popup when GetIt list command fails:
  - `GetIt list command failed, try REST.`
- Improved UI details:
  - clearer IDE-running warning dialog
  - more visible Output Log button

## Compatibility Notes

Tested in this project cycle on:

- BDS 37.0 (Delphi 13)
- BDS 23.0 (Delphi 12)
- BDS 22.0 (Delphi 11)
- BDS 21.0 (Delphi 10.4)
- BDS 20.0 (Delphi 10.3)

Known issue:

- On some BDS 20 setups, `GetItCmd` list/install may fail with server or access-violation errors despite correct syntax.
- In those scenarios, use REST for browsing/list operations.

## Attribution

This project started from the original AutoGetIt idea and implementation by **David Cornelius**:

- https://github.com/corneliusdavid/AutoGetIt
- License: MIT
