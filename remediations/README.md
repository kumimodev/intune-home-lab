# Remediations

Detect and remediate pairs for Intune proactive remediations.

## Convention

1. Detection scripts exit `0` when the device is healthy.
2. Detection scripts exit `1` when remediation should run.
3. Remediation scripts should be idempotent where practical.

## Bundles

1. `localisation/` sets Singapore Standard Time and `en-SG` locale values.
2. `remove-consumer-teams/` clears the Windows 11 consumer Teams AppX package.
3. `remove-inbox-apps/` removes a short list of inbox apps that rarely belong on a business style desktop.
4. `taskbar-cleanup/` trims News, Search, Widgets, Chat, and Task View from the default user profile.
