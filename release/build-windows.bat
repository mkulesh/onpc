echo off

set /p VER=<VERSION.txt
echo Building MusicControl-v%VER%-windows-x86_64

:: The Window build can be currently done on master channel only
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
