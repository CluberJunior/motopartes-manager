# Start tunnel with log output to file
# This will capture the URL in a log file

$cloudflaredPath = "C:\Program Files\cloudflared\cloudflared.exe"
$logFile = "C:\inetpub\wwwroot\motopartes-manager\tunnel-log.txt"

# Stop existing
Write-Host "Stopping existing tunnels..." -ForegroundColor Yellow
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start new tunnel with output redirection
Write-Host "Starting tunnel with logging..." -ForegroundColor Cyan
Start-Process -FilePath $cloudflaredPath -ArgumentList "tunnel", "--url", "http://127.0.0.1:80" -RedirectStandardOutput $logFile -RedirectStandardError $logFile -NoNewWindow

# Wait for tunnel to start
Write-Host "Waiting for tunnel to generate URL (15 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Read log file
if (Test-Path $logFile) {
    Write-Host "`nReading tunnel log..." -ForegroundColor Cyan
    $logContent = Get-Content $logFile -Raw
    
    # Extract URL
    if ($logContent -match 'https://[a-z0-9-]+\.trycloudflare\.com') {
        $url = $matches[0]
        Write-Host "`n==========================================" -ForegroundColor Green
        Write-Host "TUNNEL URL:" -ForegroundColor Green
        Write-Host "$url" -ForegroundColor White
        Write-Host "==========================================" -ForegroundColor Green
        
        # Save just the URL
        $url | Out-File "C:\inetpub\wwwroot\motopartes-manager\tunnel-url.txt" -Encoding UTF8
    }
    else {
        Write-Host "URL not found yet. Log content:" -ForegroundColor Yellow
        Write-Host $logContent
    }
}
else {
    Write-Host "Log file not created yet" -ForegroundColor Red
}

Write-Host "`nTunnel process running in background" -ForegroundColor Cyan
