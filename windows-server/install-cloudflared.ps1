# Install and Configure Cloudflare Tunnel
# Makes the application accessible from Internet without Port Forwarding

Write-Host "Installing Cloudflare Tunnel..." -ForegroundColor Cyan
Write-Host ""

# Download cloudflared for Windows
$cloudflaredUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"
$cloudflaredPath = "C:\Program Files\cloudflared\cloudflared.exe"

# Create directory
New-Item -ItemType Directory -Path "C:\Program Files\cloudflared" -Force | Out-Null

Write-Host "Downloading cloudflared..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $cloudflaredUrl -OutFile $cloudflaredPath -UseBasicParsing
    Write-Host "Download complete!" -ForegroundColor Green
}
catch {
    Write-Host "Error downloading cloudflared: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Cloudflared installed successfully!" -ForegroundColor Green
Write-Host "Location: $cloudflaredPath" -ForegroundColor Cyan
Write-Host ""

# Test installation
Write-Host "Verifying installation..." -ForegroundColor Yellow
& $cloudflaredPath --version
Write-Host ""

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Start quick tunnel (temporary URL)" -ForegroundColor White
Write-Host "2. Or configure permanent tunnel with Cloudflare account" -ForegroundColor White
Write-Host ""
