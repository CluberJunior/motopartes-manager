# Start Cloudflare Tunnel with output to file
# This will save the tunnel URL to a file

$cloudflaredPath = "C:\Program Files\cloudflared\cloudflared.exe"
$urlFile = "C:\inetpub\wwwroot\motopartes-manager\tunnel-url.txt"

Write-Host "Stopping any existing tunnel..." -ForegroundColor Yellow
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "Starting new tunnel..." -ForegroundColor Cyan

# Start tunnel in background and redirect output
$job = Start-Job -ScriptBlock {
    param($cfPath)
    & $cfPath tunnel --url http://localhost:80 2>&1
} -ArgumentList $cloudflaredPath

# Wait for URL to be generated
Write-Host "Waiting for tunnel URL (this may take 10-15 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Get the output
$output = Receive-Job -Job $job

# Find the URL in the output
$url = $output | Select-String -Pattern "https://.*\.trycloudflare\.com" | Select-Object -First 1

if ($url) {
    $urlText = $url.ToString().Trim()
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "  TUNNEL URL GENERATED!" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Your application is now accessible at:" -ForegroundColor Cyan
    Write-Host "  $urlText" -ForegroundColor White
    Write-Host ""
    Write-Host "======================================================" -ForegroundColor Green
    
    # Save to file
    $urlText | Out-File -FilePath $urlFile -Encoding UTF8
    Write-Host ""
    Write-Host "URL saved to: $urlFile" -ForegroundColor Yellow
}
else {
    Write-Host "URL not found in output yet. The tunnel is starting..." -ForegroundColor Yellow
    Write-Host "Check the job output with: Receive-Job -Id $($job.Id)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Job ID: $($job.Id) (tunnel running in background)" -ForegroundColor Gray
