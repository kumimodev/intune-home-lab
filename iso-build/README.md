# ISO build helpers

Build a lab ISO that carries Windows 10 Pro and Windows 11 Pro together, then drop in a sanitised unattend file.

Full walkthrough: `docs/iso-build-notes.md`.

## Files

1. `MergeISO-ESD.bat` for media that ships `install.esd`.
2. `MergeISO-WIM.bat` for media that ships `install.wim`.
3. `unattend.template.xml` sample OOBE settings for a Contoso Lab style image.
4. `ei.cfg` channel marker used by some OEM style layouts.

Place `Win10.iso` and `Win11.iso` under `C:\temp\ISO\` before you run a merge script as administrator.
