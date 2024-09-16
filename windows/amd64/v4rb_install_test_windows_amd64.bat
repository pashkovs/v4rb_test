@echo on
setlocal enabledelayedexpansion

REM Check if the VERSION parameter is provided
if "%~1"=="" (
    echo Please provide the VERSION to download as the first parameter.
    exit /b 1
)

set "scriptPath=%~dp0"

REM Assign the VERSION parameter to a variable
set VERSION=%~1

REM Extract the major VERSION from the provided VERSION
for /f "tokens=1 delims=." %%a in ("%VERSION%") do set MAJOR_VERSION=%%a

REM Construct the EXE file name
set EXE_FILE=v4rb_%MAJOR_VERSION%_win.exe
set EXE_PATH=%~dp0v4rb_%MAJOR_VERSION%_win.exe

REM Download the specified VERSION of the V4RB for Windows
powershell -Command "Invoke-WebRequest -Uri https://valentina-db.com/download/prev_releases/%VERSION%/win_32/%EXE_FILE% -OutFile %EXE_PATH%"

REM Install the V4RB package silently

powershell -Command "Start-Process -FilePath '%EXE_PATH%' -ArgumentList '/SILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -NoNewWindow -PassThru | Wait-Process -Timeout 30"

REM Define the Valentina plugin default installation directory
set V4RB_INSTALL_DIR=%USERPROFILE%\Documents\Paradigma Software\V4RB_%MAJOR_VERSION%

REM Unzip ValentinaPlugin.xojo_plugin to a subfolder
if exist "%V4RB_INSTALL_DIR%\ValentinaPlugin.xojo_plugin" (
	REN "%V4RB_INSTALL_DIR%\ValentinaPlugin.xojo_plugin" ValentinaPlugin.zip
    powershell -Command "Expand-Archive -Path '%V4RB_INSTALL_DIR%\ValentinaPlugin.zip' -DestinationPath '%V4RB_INSTALL_DIR%\ValentinaPlugin'"
) else (
    echo "Error: ValentinaPlugin.xojo_plugin not found!"
    exit /b 1
)

REM Copy the V4RB DLL to the test project (adjust paths as necessary)
copy "%V4RB_INSTALL_DIR%\ValentinaPlugin\ValentinaPlugin.xojo_plugin\Valentina\Build Resources\Windows x86-64\v4rb_x64.dll" "windows/amd64/TestProjectConsole/TestProjectConsole Libs"

REM Run the V4RB application and capture the output
set OUTPUT_FILE=output.txt
set PATH=%PATH%;%ProgramFiles%\Paradigma Software\vcomponents_win_vc\

echo %PATH%

"windows/amd64/TestProjectConsole/TestProjectConsole.exe" > %OUTPUT_FILE%

REM Extract the Valentina Version from the output using findstr
for /f "tokens=2 delims=:" %%a in ('findstr /C:"Valentina Version" %OUTPUT_FILE%') do set VAL_VERSION=%%a
set VAL_VERSION=%VAL_VERSION: =%

echo Valentina Version: '%VAL_VERSION%'
echo Expected Version: '%VERSION%'

REM Compare the extracted version with the passed parameter
if not "%VAL_VERSION%"=="%VERSION%" (
    echo Error: Valentina Version (%VAL_VERSION%) does not match the specified version (%VERSION%).
    exit /b 1
)

endlocal
