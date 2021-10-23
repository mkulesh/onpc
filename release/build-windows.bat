echo off

set /p VER=<VERSION.txt
echo Build Windows app MusicControl-v%VER%-windows-x86_64

:: Prepare Yaml file
call copy ..\pubspec.yaml_desktop ..\pubspec.yaml

:: Prepare platform-specific files: enable flutter_libserialport
call copy ..\lib\utils\UsbSerial.dart.desktop ..\lib\utils\UsbSerial.dart

:: The Window build shall be currently done using:
:: Flutter version 2.2.2, Dart version 2.13.3
call del *.msix
call flutter clean
call flutter channel stable
call flutter doctor
call flutter build windows --release

:: Create msix installer
call flutter pub run msix:create
call move ..\build\windows\runner\Release\onpc.msix MusicControl-v%VER%-windows-x86_64.msix

:: Create native TAR
call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\msvcp140.dll" "..\build\windows\runner\Release"
call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\vcruntime140.dll" "..\build\windows\runner\Release"
call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\vcruntime140_1.dll" "..\build\windows\runner\Release"
call rename ..\build\windows\runner\Release\music_control.exe "Music Control.exe"
call move ..\build\windows\runner\Release MusicControl-v%VER%-windows-x86_64
call tar -acf MusicControl-v%VER%-windows-x86_64.zip MusicControl-v%VER%-windows-x86_64
