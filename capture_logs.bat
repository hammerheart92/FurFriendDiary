@echo off
REM Batch script to capture Flutter logs from device

echo ============================================
echo Flutter Log Capture Script
echo ============================================
echo.

REM Method 1: Pull app's log file
echo [1] Pulling app log file from device...
adb pull /storage/emulated/0/Android/data/com.furfrienddiary.app/files/flutter_logs.txt ./logs/flutter_logs_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt
echo.

REM Method 2: Capture current logcat
echo [2] Capturing current logcat...
adb logcat -d -v time > ./logs/logcat_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt
echo.

echo ============================================
echo Logs saved to ./logs/ folder
echo ============================================
echo.
echo Files created:
dir /b logs\*.txt
echo.
pause
