# Server Verification Script
# Checks all services and configurations

Write-Host "Verifying server configuration..." -ForegroundColor Cyan
Write-Host ""

# Check IIS
Write-Host "IIS Service:" -ForegroundColor Yellow
$iis = Get-Service W3SVC
Write-Host "  Status: $($iis.Status)" -ForegroundColor $(if ($iis.Status -eq "Running") { "Green" } else { "Red" })

# Check WinRM
Write-Host "WinRM Service:" -ForegroundColor Yellow
$winrm = Get-Service WinRM
Write-Host "  Status: $($winrm.Status)" -ForegroundColor $(if ($winrm.Status -eq "Running") { "Green" } else { "Red" })

# Check Node.js
Write-Host "Node.js:" -ForegroundColor Yellow
try {
    $nodeVersion = & "C:\Program Files\nodejs\node.exe" --version 2>$null
    Write-Host "  Version: $nodeVersion" -ForegroundColor Green
}
catch {
    Write-Host "  Not found" -ForegroundColor Red
}

# Check NPM
Write-Host "NPM:" -ForegroundColor Yellow
try {
    $npmVersion = & "C:\Program Files\nodejs\npm.cmd" --version 2>$null
    Write-Host "  Version: $npmVersion" -ForegroundColor Green
}
catch {
    Write-Host "  Not found" -ForegroundColor Red
}

# Check PM2
Write-Host "PM2:" -ForegroundColor Yellow
try {
    $pm2Version = & "C:\Program Files\nodejs\npm.cmd" list -g pm2 --depth=0 2>$null
    if ($pm2Version -match "pm2@") {
        Write-Host "  Installed" -ForegroundColor Green
    }
    else {
        Write-Host "  Not found" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  Not found" -ForegroundColor Red
}

# Check directories
Write-Host "Directories:" -ForegroundColor Yellow
$dirs = @(
    "C:\inetpub\motopartes-manager",
    "C:\inetpub\motopartes-manager\frontend",
    "C:\inetpub\motopartes-manager\backend"
)
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Write-Host "  $dir - OK" -ForegroundColor Green
    }
    else {
        Write-Host "  $dir - Missing" -ForegroundColor Red
    }
}

# Check firewall rules
Write-Host "Firewall Rules:" -ForegroundColor Yellow
$http = Get-NetFirewallRule -Name "HTTP-Inbound" -ErrorAction SilentlyContinue
$https = Get-NetFirewallRule -Name "HTTPS-Inbound" -ErrorAction SilentlyContinue
Write-Host "  HTTP (80): $(if ($http -and $http.Enabled) { 'Enabled' } else { 'Disabled' })" -ForegroundColor $(if ($http -and $http.Enabled) { "Green" } else { "Red" })
Write-Host "  HTTPS (443): $(if ($https -and $https.Enabled) { 'Enabled' } else { 'Disabled' })" -ForegroundColor $(if ($https -and $https.Enabled) { "Green" } else { "Red" })

# Get network info
Write-Host "Network Configuration:" -ForegroundColor Yellow
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" }).IPAddress
Write-Host "  IP Address: $ip" -ForegroundColor Cyan
Write-Host "  Web Access: http://$ip" -ForegroundColor Cyan

Write-Host ""
Write-Host "Verification complete!" -ForegroundColor Green
Write-Host ""
