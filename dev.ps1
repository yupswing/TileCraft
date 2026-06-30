# Self-contained dev entry point: pins the Haxe 3.4.7 / Neko 32-bit toolchain
# regardless of the current shell's environment.
#
# Default action is "build" + direct launch of the resulting exe, NOT "lime test":
# this old lime (2.9.1) does a network version-check on every run that can
# intermittently fail loading ssl.ndll and get stuck retrying. Building, then
# launching the exe ourselves from PowerShell, sidesteps that.
#
# Usage:
#   .\dev.ps1                       # build neko -Dv2 -Dlegacy, then run the exe
#   .\dev.ps1 build neko -Dv2 -Dlegacy   # just build (passed through to lime)
#   .\dev.ps1 build windows -Dv2 -Dlegacy   # needs VS Build Tools (C++ workload)

$env:HAXEPATH = "C:\HaxeToolkit\haxe34"
$env:NEKOPATH = "C:\HaxeToolkit\neko32"
$env:Path = "C:\HaxeToolkit\haxe34;C:\HaxeToolkit\neko32;" + $env:Path

if ($args.Count -eq 0) {
    & "C:\HaxeToolkit\haxe34\lime.exe" build neko -Dv2 -Dlegacy
    if ($LASTEXITCODE -eq 0) {
        # Run in the foreground (not Start-Process) so trace() output stays
        # attached to this console instead of vanishing into a detached process.
        Push-Location "Export\windows\neko\bin"
        & ".\TileCraft.exe"
        Pop-Location
    }
} else {
    & "C:\HaxeToolkit\haxe34\lime.exe" @args
}
