# Changelog

All notable changes to this project are listed here.

## Copy update, 1 Nov 2026

### Changed

1. Tidied the README opening lines so they read a bit more naturally.

## Version 0.3.1 (1 Nov 2026)

### Changed

1. Replaced the printer Win32 samples with a clean room set (`Register-HomeLabPrinter.ps1`, `Unregister-HomeLabPrinter.ps1`, `Test-HomeLabPrinter.ps1`) written against Microsoft printer cmdlets only.

## Version 0.3.0 (1 Nov 2026)

### Changed

1. Quality pass for portfolio readiness. PowerShell scripts now include comment based help, consistent Verb-Noun names where practical, and clear Intune exit codes.
2. Replaced Autopilot batch collector and dual merge scripts with `Get-AutopilotHardwareHash.ps1` and `Merge-AutopilotHardwareHash.ps1`.
3. Replaced fragile ISO merge batch files with parameterised `Merge-WindowsLabIso.ps1`.
4. Fixed Windows 10 taskbar helper so Default profile hive values are actually written.
5. Earlier printer installer work was later replaced by the clean room samples in 0.3.1.
6. Inbox app detection now matches package names reliably instead of relying on wildcards in `-Name`.

## Version 0.2.0 (1 Nov 2026)

### Changed

1. Moved general Windows and network helper scripts into the companion `it-admin-toolkit` repository.
2. Left a short pointer under `scripts/` so older links still make sense.

## Version 0.1.0 (1 Nov 2026)

### Added

1. First public draft of the Intune home lab samples.
2. Autopilot helpers, ISO build notes, remediations, Win32 printer and Office samples.
