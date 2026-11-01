# ISO build notes

This path is for building a lab USB that contains both Windows 10 Pro and Windows 11 Pro in one media set. It is optional. Autopilot works fine from stock Microsoft media.

## Download stock ISOs

1. Windows 10: https://www.microsoft.com/en-us/software-download/windows10
2. Windows 11: https://www.microsoft.com/software-download/windows11

Rename them to `Win10.iso` and `Win11.iso`. Place both under `C:\temp\ISO\`.

## Merge Pro editions into one folder tree

1. Run `MergeISO-ESD.bat` or `MergeISO-WIM.bat` as administrator, depending on whether your media uses `install.esd` or `install.wim`.
2. Confirm DISM lists only Windows 10 Pro and Windows 11 Pro when the script finishes.
3. Source index `6` is the usual Pro index on retail media, but always check with `DISM /Get-WimInfo` on your files before you trust it.

## Add the unattend template

1. Copy `unattend.template.xml` and edit the organisation name, timezone, and locale values for your lab.
2. Place the edited file in the root of `C:\temp\ISO\CustomizedISO\` as `unattend.xml`.
3. Keep `ei.cfg` next to the sources folder if you want the edition selection behaviour described in the Microsoft OEM docs.

The sample organisation value is `Contoso Lab`. Do not leave a real employer name in this file.

## Optional offline image surgery

Useful DISM patterns while the WIM is mounted:

1. List provisioned AppX packages, then remove the ones you do not want on a business style image.
2. Enable .NET Framework 3.5 from the media `sxs` folder when an older line of business app needs it.
3. Inject lab printer or NIC drivers with `/Add-Driver` and `/Recurse`.

Always commit the mount with `/unmount-wim` when you are done. A dirty mount wastes an afternoon.

## Burn the folder tree to ISO and USB

1. Use ImgBurn or equivalent to build an ISO from `C:\temp\ISO\CustomizedISO\`.
2. Use Rufus to write that ISO to a USB stick.
3. Boot a test VM from the stick and confirm OOBE picks up your unattend values.

## Licensing reminder

Custom media does not grant you Windows licences. Use genuine keys or subscription activation that matches your lab devices.
