# Intune policy ideas for a home lab

These are patterns worth recreating in a personal trial tenant. They came from private lab notes that also held workplace names, passwords, and directory ids. None of that workplace detail belongs here.

## Configuration profiles to try

1. Block USB storage for a pilot user group.
2. Block the Microsoft Store on a pilot device group, or allow only a whitelist of apps.
3. OneDrive silent sign in for Entra joined users.
4. Autopilot style hostname template such as `LAB-PC-%RAND:3%`.
5. Windows LAPS for the built in local administrator on Entra joined devices.

## Compliance settings that work well on lab devices

1. BitLocker required.
2. Secure Boot required.
3. Code integrity required.
4. Minimum OS build that matches your current Windows 11 lab image.
5. Firewall, TPM, antivirus, antispyware, and Defender real time protection required.
6. Password required to unlock mobile devices, with an expiry that fits your lab comfort level.

## Apps that are useful to package once

1. Microsoft 365 Apps as required.
2. Adobe Acrobat Reader as required.
3. Google Chrome Enterprise as optional.
4. Company Portal as required.
5. Remote Help as required.
6. 7 Zip as optional.

Keep vendor installers out of GitHub. Store them in a private Drive or blob location and reference them from your Win32 packages.

## Inbox apps people often remove

Feedback Hub, Clipchamp, Bing News, Solitaire, Bing Weather, Xbox pieces, Films and TV, Media Player, People, and Get Help. See `remediations/remove-inbox-apps/` for a detect and remediate pair.

## Dynamic device group idea

Create a dynamic Entra group for company owned Windows devices and assign most device profiles there. Keep a separate pilot group for early testing.

## What you must not copy from private notes

1. Real passwords or one time codes.
2. Real printer host names or private office LAN addresses.
3. Real tenant group object ids.
4. Employer folder names, VPN names, or account names.
5. Anything that names a current or former workplace.
