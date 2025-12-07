# PowerShell script to capture Flutter logs

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Flutter Log Capture Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Create logs directory if it doesn't exist
if (-not (Test-Path "./logs")) {
    New-Item -ItemType Directory -Path "./logs" | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Method 1: Pull app's log file
Write-Host "[1] Pulling app log file from device..." -ForegroundColor Yellow
adb pull /storage/emulated/0/Android/data/com.furfrienddiary.app/files/flutter_logs.txt "./logs/flutter_logs_$timestamp.txt" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✓ App log file saved" -ForegroundColor Green
} else {
    Write-Host "    ✗ Could not pull app log file (app may not be installed)" -ForegroundColor Red
}
Write-Host ""

# Method 2: Capture current logcat
Write-Host "[2] Capturing current logcat..." -ForegroundColor Yellow
adb logcat -d -v time | Out-File -FilePath "./logs/logcat_$timestamp.txt" -Encoding UTF8
if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✓ Logcat saved" -ForegroundColor Green
} else {
    Write-Host "    ✗ Could not capture logcat" -ForegroundColor Red
}
Write-Host ""

# Method 3: Capture Flutter-specific logs
Write-Host "[3] Capturing Flutter-specific logs..." -ForegroundColor Yellow
adb logcat -d -v time flutter:V *:S | Out-File -FilePath "./logs/flutter_only_$timestamp.txt" -Encoding UTF8
if ($LASTEXITCODE -eq 0) {
    Write-Host "    ✓ Flutter logs saved" -ForegroundColor Green
} else {
    Write-Host "    ✗ Could not capture Flutter logs" -ForegroundColor Red
}
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Logs saved to ./logs/ folder" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Files created:" -ForegroundColor Yellow
Get-ChildItem "./logs/*.txt" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
