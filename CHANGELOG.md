# Changelog

All notable changes to this project are listed here.

## Version 0.2.0 (1 Nov 2026)

### Changed

1. Moved general Windows and network helper scripts into the companion `it-admin-toolkit` repository.
2. Left a short pointer under `scripts/` so older links still make sense.
3. Kept Autopilot, ISO build, remediations, Win32 and Intune docs in this repo only.

### Notes from Drive review

1. The completed `intune from laptop` Drive folder was mostly vendor installers, workplace decks and personal exports. Almost nothing Intune specific was added from it.
2. Edge settings exports and InPrivate allow lists stayed private because they reflected a live workplace allow list.

## Version 0.1.0 (1 Nov 2026)

### Added

1. First public draft of the Intune home lab samples.
2. Autopilot helpers for hardware hash collection and CSV merge.
3. ISO build notes and merge scripts for Windows 10 Pro and Windows 11 Pro media.
4. Remediation pairs for localisation, consumer Teams, and inbox apps.
5. Taskbar cleanup samples for Windows 10 and Windows 11.
6. Generic printer Win32 install pattern with sample addresses only.
7. Microsoft 365 Apps configuration XML with a lab company name.
8. Support scripts for OS updates, winget, Defender signatures, and the Virtual Machine Platform feature.
9. Secure local lab user sample that prompts for a password instead of storing one.
10. Broader inbox app remediation list based on a private Drive removebloat sample.
11. Secure scan share sample based on private Drive scan scripts, with no stored password.
12. Sanitised Intune policy ideas guide based on private Drive notes.
