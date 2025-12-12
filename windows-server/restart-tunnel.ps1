# Restart Cloudflare Tunnel with correct configuration

Write-Host "Fixing Cloudflare Tunnel configuration..." -ForegroundColor Cyan

# Stop existing tunnel
Write-Host "Stopping existing tunnel..." -ForegroundColor Yellow
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Start tunnel pointing to IIS site
$cloudflaredPath = "C:\Program Files\cloudflared\cloudflared.exe"

Write-Host "Starting tunnel with correct configuration..." -ForegroundColor Yellow

# Use 127.0.0.1 instead of localhost for better compatibility
& $cloudflaredPath tunnel --url http://127.0.0.1:80
