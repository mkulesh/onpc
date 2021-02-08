echo off
setlocal EnableDelayedExpansion

set /p VER = < VERSION.txt
echo Building onpc-v%VER%-release.win

:: The Window build can be currently done on master channel only
call flutter channel master
call flutter doctor
call flutter build windows --release

call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\msvcp140.dll" "..\build\windows\runner\Release"
call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\vcruntime140.dll" "..\build\windows\runner\Release"
call copy "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC142.CRT\vcruntime140_1.dll" "..\build\windows\runner\Release"
call move ..\build\windows\runner\Release onpc-v%VER%-release.win
