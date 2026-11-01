# ISO build

| File | Purpose |
| --- | --- |
| `Merge-WindowsLabIso.ps1` | Merge Windows 10 Pro and Windows 11 Pro into one lab media folder |
| `unattend.template.xml` | Sample unattend for lab imaging |
| `ei.cfg` | Sample edition configuration |

Confirm DISM image indexes with `/Get-WimInfo` before you trust the default index values. Paths are parameters. Nothing here points at a real production share.
