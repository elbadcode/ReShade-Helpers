setlocal EnableDelayedExpansion
set destination=%cd%
set source="%~dp0Setup" 
start /wait "" ".\Setup\ReShade.exe" "%cd%\Setup\ReShade.exe" --api d3d11 --state modify --elevated
start /wait "" robocopy %source% "%destination%" /MOVE /XF "%~dp0Setup\d3d11.dll" "%~dp0Setup\ReShade.exe" /E 
