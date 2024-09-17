@echo on
setlocal enabledelayedexpansion

REM Check if the VERSION parameter is provided
if "%~1"=="" (
    echo Please provide the VERSION to download as the first parameter.
    exit /b 1
)

REM Assign the VERSION parameter to a variable
set VERSION=%~1

REM Extract the major VERSION from the provided VERSION
for /f "tokens=1 delims=." %%a in ("%VERSION%") do set MAJOR_VERSION=%%a

REM Construct the EXE file name
set EXE_FILE=vserver_x64_%MAJOR_VERSION%_win.exe
set EXE_PATH=%~dp0%EXE_FILE%

REM Download the specified VERSION of the VServer for Windows
powershell -Command "Invoke-WebRequest -Uri https://valentina-db.com/download/prev_releases/%VERSION%/win_64/%EXE_FILE% -OutFile %EXE_PATH%"

REM Install the VServer package silently

powershell -Command "Start-Process -FilePath '%EXE_PATH%' -ArgumentList '/SILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -NoNewWindow -PassThru | Wait-Process -Timeout 30"

REM VServer logs directory
set VSERVER_LOGS_DIR="%ProgramFiles%\Paradigma Software\VServer x64\vlogs"

dir %VSERVER_LOGS_DIR%

REM Get the latest log file from the VServer logs directory with name starting with "vserver_" and ending with ".log"
for /f "delims=" %%a in ('dir /b /o-d %VSERVER_LOGS_DIR%\vserver_*.log') do set "VSERVER_LOG_FILE=%%a" & goto :next
:next

REM Extract the Valentina Version from the log file using findstr
for /f "tokens=3 delims=: " %%a in ('findstr /C:"vServer version" %VSERVER_LOGS_DIR%\%VSERVER_LOG_FILE%') do set "VAL_VERSION=%%a"

echo "Valentina Version: %VAL_VERSION%"
echo "Expected Version: %VERSION%"

REM Compare the extracted version with the passed parameter
if not "%VAL_VERSION%"=="%VERSION%" (
    echo "Error: Valentina Version (%VAL_VERSION%) does not match the specified version (%VERSION%)."
    exit /b 1
)

REM Find Server started message in the log file
findstr /C:"Server started" %VSERVER_LOGS_DIR%\%VSERVER_LOG_FILE% >nul
if errorlevel 1 (
    echo "Error: Server did not start successfully."
    exit /b 1
)