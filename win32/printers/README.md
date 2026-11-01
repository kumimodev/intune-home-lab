# Home lab TCP printer Win32 package

Clean room samples that call only Microsoft documented printer tooling (`pnputil`, `Add-PrinterDriver`, `Add-PrinterPort`, `Add-Printer`, `Remove-Printer`, `Remove-PrinterPort`, `Get-Printer`).

| Script | Role |
| --- | --- |
| `Register-HomeLabPrinter.ps1` | Install |
| `Unregister-HomeLabPrinter.ps1` | Uninstall |
| `Test-HomeLabPrinter.ps1` | Detection for Intune |

## Package layout

Put the scripts next to the vendor driver INF inside the folder you feed to IntuneWinAppUtil, for example:

```text
LabPrinterPackage/
  Register-HomeLabPrinter.ps1
  Unregister-HomeLabPrinter.ps1
  Test-HomeLabPrinter.ps1
  driver/
    contoso.inf
    (and the rest of the driver files)
```

Build the Win32 app:

```text
IntuneWinAppUtil.exe -c .\LabPrinterPackage -s Register-HomeLabPrinter.ps1 -o .\out
```

## Intune Win32 commands

Replace names and the INF relative path for your lab. Use a placeholder host such as `printer.lab.local` or `10.0.0.50`.

Install command:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Register-HomeLabPrinter.ps1 -PrinterName "Lab Floor Printer" -DriverName "Contoso Laser Class Driver" -InfPath ".\driver\contoso.inf" -PortHost "printer.lab.local"
```

Uninstall command:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Unregister-HomeLabPrinter.ps1 -PrinterName "Lab Floor Printer" -PortName "IP_printer_lab_local" -RemovePort
```

Detection: upload `Test-HomeLabPrinter.ps1` as the detection script, or use:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Test-HomeLabPrinter.ps1 -PrinterName "Lab Floor Printer"
```

Detection exit codes follow Win32 rules. `0` means installed. `1` means not installed.

## Notes

1. Scripts relaunch through SysNative when Intune starts a 32 bit PowerShell host on 64 bit Windows.
2. Setup and removal append logs under `%ProgramData%\IntuneHomeLab\PrinterSetup\`.
3. Re running register refreshes an existing printer of the same name so the package stays idempotent.
