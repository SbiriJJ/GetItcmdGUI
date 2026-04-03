# Changelog

All notable changes for the `GetItcmdGUI` variant are documented in this file.

This project is based on the original AutoGetIt work by David Cornelius:
- Original repository: https://github.com/corneliusdavid/AutoGetIt
- License: MIT

## [1.0.0] - 2026-04-03

First public release of `GetItcmdGUI`, with substantial functional, UX, and compatibility changes over the original baseline.

### Added
- Dual package listing workflows:
  - `List (GetItCmd)`
  - `List (REST)`
- REST local processing pipeline:
  - full list download once
  - in-memory filtering and sorting
- Category filter (`All` + discovered category names from registry mapping).
- Local sort menu (`ID`, `Version`, `Name`, `Vendor`, `Category`, `Date`).
- Install summary in install log:
  - per-package status (`OK`, `ERROR`, `UNKNOWN`, `ABORTED`)
  - warning/error counters
  - final totals
- Save support for logs (output/install diagnostics).
- Failure popup for GetIt list command:
  - `GetIt list command failed, try REST.`

### Changed
- Clear separation of GetItCmd vs REST behaviors to avoid mixed semantics.
- REST `contains` filter applied locally with a minimum of 3 characters (lag reduction).
- Default REST scope:
  - Delphi-only enabled
  - latest-only enabled
  - both user-toggleable
- Latest-version selection logic revised for inconsistent upstream version strings:
  - grouping key: base package ID + vendor + libcode
  - winner by `VersionTimestamp` (deterministic tie-breaks)
- Installed-state detection switched to `Id` matching (not `PackageId`).
- Installed package registry scan extended (read-only) to:
  - `HKCU\Software\Embarcadero\BDS\<version>\CatalogRepository`
  - `HKLM\SOFTWARE\WOW6432Node\Embarcadero\BDS\<version>\CatalogRepository`
- BDS 37 installed-state behavior refined (focus on `Packages\...\Versions`; ignore `Elements` as install signal).
- REST parameter support extended for older versions, including legacy mappings used by BDS 20/21/22/23 and BDS 37.
- IDE-running warning dialog redesigned to a clear standard warning popup (`Retry`/`Cancel`).
- Output log button updated to a clearly visible regular button.

### Refactored
- Removed unnecessary `Assigned(...)` guards and aligned initialization flow.
- Moved output-log synchronization responsibilities to output-log form logic.
- Consolidated runtime-created controls into design-time components where required for IDE visibility/maintenance.

### UI/Workflow
- GetItCmd mode:
  - applies command-line params from text/radio/installed controls
  - keeps list output semantics separate from REST filters
- REST mode:
  - always starts from full REST dataset
  - applies active filters locally (`contains`, category, scope, installed state)

### Known Notes
- `GetItCmd` behavior may vary by RAD Studio version and machine environment.
- On some BDS 20 setups, `GetItCmd` may fail (server/access-violation) even with correct command syntax.
- REST and GetItCmd lists are not guaranteed to be identical for all versions.
- Core IDE/internal packages found in registry but outside GetIt domain are intentionally excluded from marketplace-installed interpretation.
