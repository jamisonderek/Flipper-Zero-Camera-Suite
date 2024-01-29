@echo off
setlocal EnableDelayedExpansion

rem λ

set CLI_TEMP=%TEMP%\arduino-cli
set ARDUINO_CLI_CONFIG_FILE=--config-file %CD%\firmware\arduino-cli.yaml
set CLI_FOUND_FOLLOW_UP=0
set GITHUB_HOOKS_FOLDER=%CD%\.github\hooks
set GIT_HOOKS_FOLDER=%CD%\.git\hooks

chcp 65001 > nul
echo ┏┓   ┓    ┏┳┓  ┓
echo ┃ ┏┓┏┫┓┏   ┃ ┏┓┃┏┓┏┓┏┓
echo ┗┛┗┛┗┻┗┫   ┻ ┗┛┗┗ ┛┗┗
echo        ┛  https://github.com/CodyTolene
echo.
echo Flipper Zero - ESP32-CAM Development Packages - Windows 10+
echo https://github.com/CodyTolene/Flipper-Zero-Camera-Suite
echo.
echo ------------------------------------------------------------------------------
echo This will install all assets needed to get you started with ESP32-CAM firmware
echo development. These files will be installed to the following directory:
echo.
echo "%CLI_TEMP%"
echo.
echo Once installed, you can add them to the "Include path" in your IDE of choice.
echo.
echo Notes: 
echo - You must have Git installed to use this script. If you do not have Git
echo   installed, please install it from the following link:
echo.
echo   https://git-scm.com/downloads
echo.
echo - Temp files will take up approximately 6GB of storage space.
echo - You can reinstall or delete the temp files be re-running this script.
echo ------------------------------------------------------------------------------
echo.
pause
echo.
echo Initializing...

:checkCLI
if not exist "arduino-cli.exe" (
    echo.
    echo The "arduino-cli.exe" file cannot be found. Please download it manually from the following link: 
    echo https://arduino.github.io/arduino-cli/latest/installation/#download
    echo Extract the "arduino-cli.exe" file to the same directory as this script.
    echo.
    echo When the file is ready, press any key to check again.
    set /a CLI_FOUND_FOLLOW_UP+=1
    if %CLI_FOUND_FOLLOW_UP% geq 2 (
        echo If you are still having issues, feel free to open a ticket at the following link:
        echo https://github.com/CodyTolene/Flipper-Zero-Camera-Suite/issues
    )
    pause
    goto :checkCLI
)
if %CLI_FOUND_FOLLOW_UP% geq 1 (
    echo File "arduino-cli.exe" found successfully. Continuing...
)

echo Checking configs...
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.data %CLI_TEMP%\data
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.downloads %CLI_TEMP%\downloads
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.user %CLI_TEMP%\user %*

echo Fetching assets...

set DATA_FLAG=0
if not exist "%CLI_TEMP%\data" (
    set /a "DATA_FLAG+=1"
)
if not exist "%CLI_TEMP%\downloads" (
    set /a "DATA_FLAG+=1"
)
if %DATA_FLAG% gtr 0 (
    arduino-cli %ARDUINO_CLI_CONFIG_FILE% core update-index
    arduino-cli %ARDUINO_CLI_CONFIG_FILE% core install esp32:esp32
    echo Cloning ESPAsyncWebServer repository...
    git clone https://github.com/me-no-dev/ESPAsyncWebServer.git "%CLI_TEMP%\data\ESPAsyncWebServer"
    echo Cloning espressif Arduino ESP32 repository, a dependency of ESPAsyncWebServer...
    git clone https://github.com/espressif/arduino-esp32.git "%CLI_TEMP%\data\arduino-esp32"
    echo Cloning ESP8266 repository, a dependency of ESPAsyncWebServer...
    git clone https://github.com/esp8266/Arduino.git "%CLI_TEMP%\data\ESP8266-Arduino"
    echo Cloning AsyncTCP repository, a dependency of ESPAsyncWebServer...
    git clone https://github.com/me-no-dev/AsyncTCP.git "%CLI_TEMP%\data\AsyncTCP"
    echo Cloning ESPAsyncTCP repository, a dependency of ESPAsyncWebServer...
    git clone https://github.com/me-no-dev/ESPAsyncTCP.git "%CLI_TEMP%\data\ESPAsyncTCP"
) else (
    echo.
    set /p DELETE_TEMP="Assets already installed. Reinstall? (Y/N): "
    if /i "!DELETE_TEMP!"=="Y" (
        rmdir /s /q %CLI_TEMP%
        arduino-cli %ARDUINO_CLI_CONFIG_FILE% core update-index
        arduino-cli %ARDUINO_CLI_CONFIG_FILE% core install esp32:esp32
        echo Cloning ESPAsyncWebServer repository...
        git clone https://github.com/me-no-dev/ESPAsyncWebServer.git "%CLI_TEMP%\data\ESPAsyncWebServer"
        echo Cloning espressif Arduino ESP32 repository, a dependency of ESPAsyncWebServer...
        git clone https://github.com/espressif/arduino-esp32.git "%CLI_TEMP%\data\arduino-esp32"
        echo Cloning ESP8266 repository, a dependency of ESPAsyncWebServer...
        git clone https://github.com/esp8266/Arduino.git "%CLI_TEMP%\data\ESP8266-Arduino"
        echo Cloning AsyncTCP repository, a dependency of ESPAsyncWebServer...
        git clone https://github.com/me-no-dev/AsyncTCP.git "%CLI_TEMP%\data\AsyncTCP"
        echo Cloning ESPAsyncTCP repository, a dependency of ESPAsyncWebServer...
        git clone https://github.com/me-no-dev/ESPAsyncTCP.git "%CLI_TEMP%\data\ESPAsyncTCP"
        goto :wrapUp
    )
    echo.
    set /p DELETE_TEMP="Would you like to remove the previously installed dependencies? (Y/N): "
    if /i "!DELETE_TEMP!"=="Y" (
        rmdir /s /q %CLI_TEMP%
        goto :end
    )
)

:wrapUp
echo.
echo Configuring Git hooks...
copy /Y "%GITHUB_HOOKS_FOLDER%" "%GIT_HOOKS_FOLDER%"
echo.
echo Resetting arduino-cli config back to defaults...
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.data C:\temp\arduino-cli\data
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.downloads C:\temp\arduino-cli\staging
arduino-cli %ARDUINO_CLI_CONFIG_FILE% config set directories.user C:\temp\arduino-cli\user
echo.
echo The ESP32-CAM development dependencies were installed successfully.
echo.
echo ------------------------------------------------------------------------------
echo.
echo You can now add the following path to your IDEs "Include path" setting:
echo.
echo "%CLI_TEMP%\data\**"
echo.

:end
echo ------------------------------------------------------------------------------
echo.
echo Fin. Happy programming, friend.
echo.
pause
exit /b
