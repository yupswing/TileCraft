@echo off
rem Builds a native Windows .exe (no Haxe/Neko needed to run it) via HXCPP.
rem Requires: Visual Studio Build Tools (Desktop development with C++ workload)
rem and hxcpp 3.4.64 (NOT 3.3.x or earlier -- Haxe 3.4.x requires hxcpp >= 3.4.49,
rem older hxcpp generates "hx::Ctx" constructor signatures the Haxe 3.4.7 compiler
rem no longer emits correctly).
rem
rem Usage: dev-native.bat   (run from the project root, or anywhere -- it cd's itself)

set PATH=C:\Program Files (x86)\Microsoft Visual Studio\Installer;%PATH%
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64_x86
if errorlevel 1 (
   echo Could not set up the MSVC x86 toolchain - is VS Build Tools installed?
   exit /b 1
)

rem Modern MSVC dropped the legacy "typeinfo.h" header that old hxcpp's
rem hxcpp.h still includes; this shim provides it without patching hxcpp itself.
set INCLUDE=C:\HaxeToolkit\msvc_compat_include;%INCLUDE%

set HAXEPATH=C:\HaxeToolkit\haxe34
set NEKOPATH=C:\HaxeToolkit\neko32
set HXCPP_COMPILE_THREADS=1
set PATH=C:\HaxeToolkit\haxe34;C:\HaxeToolkit\neko32;%PATH%

cd /d "%~dp0"
"C:\HaxeToolkit\haxe34\lime.exe" build windows -Dv2 -Dlegacy -Drelease -DHXCPP_MSVC_CUSTOM
if errorlevel 1 (
   echo Build failed.
   exit /b 1
)

echo.
echo Build succeeded: Export\windows\cpp\bin\TileCraft.exe
