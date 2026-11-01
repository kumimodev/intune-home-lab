# Lab overview

This write up is the map for the repo. It assumes you already have a Microsoft trial tenant and a couple of test devices or Hyper-V VMs.

## Why this lab exists

I wanted a place to practise Autopilot enrolment, proactive remediations, Win32 packaging, and a predictable Windows image. The scripts here are the ones I actually use in that lab after cleaning out anything that was tied to a real workplace.

## Suggested lab shape

1. One Microsoft Entra ID tenant used only for learning.
2. Licensing: EMS E3, or Intune Plan 1 plus Defender for Business.
3. Two Windows 11 Pro VMs and one Windows 10 Pro VM.
4. A USB stick or ISO built from `iso-build/` for clean installs.
5. A second admin account protected with MFA. Keep break glass offline notes somewhere safe.

## Enrolment path I use

1. Boot the device from clean media or a reset PC.
2. Run `autopilot/Get-AutopilotHardwareHash.ps1` as administrator.
3. Optionally run `windows/Get-LabDeviceInfo.ps1` from the companion `it-admin-toolkit` repo so you have username, hostname, and serial number in one text file.
4. Merge CSVs with `autopilot/Merge-AutopilotHardwareHash.ps1` if you collected more than one device.
5. Import the CSV into Intune Autopilot devices and assign a deployment profile.
6. Reset the device and let Autopilot enrol it into Entra ID and Intune.

## Remediations worth trying first

1. Localisation for `en-SG` and Singapore Standard Time.
2. Removal of the Windows 11 consumer Teams client.
3. Removal of a small set of inbox apps that get in the way of a business style desktop.

Each folder under `remediations/` has a detect script and a remediate script. Wire them as an Intune remediation. Detection exit code `0` means healthy. Exit code `1` means run remediation.

## Win32 and config samples

1. The printer script stages a driver from an INF, creates a TCP/IP port, and adds the printer. Sample addresses use `10.0.0.x` only.
2. The Office XML installs Microsoft 365 Apps for enterprise style clients with a few apps excluded. Change the company name before you use it.
3. The Start layout pins Explorer, Outlook, Edge, Company Portal, and Teams. Adjust AppUserModelIDs if your builds differ.

## Things this repo will not do for you

1. It will not create your tenant or buy licences.
2. It will not store secrets. Use LAPS or a prompt.
3. It will not document a real company directory, VPN, or printer estate.
4. It will not replace Microsoft Learn. Use this as a working scratch pad next to the official docs.

## Placeholders you must replace

| Placeholder | Meaning |
| --- | --- |
| `<YourTenant>` | Your trial tenant name, for example `contoso.onmicrosoft.com` |
| `contoso.local` | Example on premises style DNS name for notes only |
| `lab.example.com` | Example public style host name for notes only |
| `10.0.0.x` | Private lab addresses for printers and ports |
| `LabLocalUser` | Suggested local account name in the secure user script |

## Next reading

1. `docs/autopilot-enrolment.md`
2. `docs/iso-build-notes.md`
3. Folder README files next to the scripts
