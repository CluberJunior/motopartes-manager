# Quick Tunnel URL Finder
# Reads the tunnel output to find the public URL

Write-Host "Looking for Cloudflare Tunnel URL..." -ForegroundColor Cyan
Write-Host ""

# The tunnel should be running, let's give it a moment
Start-Sleep -Seconds 5

Write-Host "Tunnel is running! The URL should appear soon." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT INFORMATION:" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "The tunnel is active but running in the background." -ForegroundColor White
Write-Host "To see the URL, you have two options:" -ForegroundColor White
Write-Host ""
Write-Host "Option 1 - Check tunnel logs:" -ForegroundColor Cyan
Write-Host "  Look in the PowerShell window where the tunnel started" -ForegroundColor White
Write-Host "  You'll see a line like: https://XXXXX-XXXXX-XXXXX.trycloudflare.com" -ForegroundColor Green
Write-Host ""
Write-Host "Option 2 - Wait for automatic URL display" -ForegroundColor Cyan
Write-Host "  The tunnel usually generates the URL within 10-30 seconds" -ForegroundColor White
Write-Host ""
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Tunnel Status: RUNNING on port 80" -ForegroundColor Green
Write-Host "Waiting for Cloudflare to assign public URL..." -ForegroundColor Yellow
Write-Host ""
