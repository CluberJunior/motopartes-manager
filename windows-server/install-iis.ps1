# IIS Installation Script for Windows Server
# Remote execution via PowerShell Remoting

Write-Host "Installing IIS and Web Features..." -ForegroundColor Cyan

# Install IIS with management tools
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Install additional features
$features = @(
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Default-Doc",
    "Web-Dir-Browsing",
    "Web-Http-Errors",
    "Web-Static-Content",
    "Web-Http-Redirect",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Performance",
    "Web-Stat-Compression",
    "Web-Dyn-Compression",
    "Web-Security",
    "Web-Filtering",
    "Web-Basic-Auth",
    "Web-Windows-Auth",
    "Web-App-Dev",
    "Web-Net-Ext45",
    "Web-Asp-Net45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-WebSockets",
    "Web-Mgmt-Tools",
    "Web-Mgmt-Console"
)

foreach ($feature in $features) {
    Install-WindowsFeature -Name $feature -ErrorAction SilentlyContinue
}

Write-Host "IIS features installed successfully" -ForegroundColor Green

# Start IIS service
$iisService = Get-Service -Name W3SVC
if ($iisService.Status -ne "Running") {
    Start-Service W3SVC
}

Write-Host "IIS service started" -ForegroundColor Green

# Import IIS module
Import-Module WebAdministration

# Stop default website
Stop-Website -Name "Default Web Site" -ErrorAction SilentlyContinue

# Create application directories
$appPath = "C:\inetpub\motopartes-manager"
$frontendPath = "$appPath\frontend"
$backendPath = "$appPath\backend"

New-Item -ItemType Directory -Path $appPath -Force | Out-Null
New-Item -ItemType Directory -Path $frontendPath -Force | Out-Null
New-Item -ItemType Directory -Path $backendPath -Force | Out-Null

Write-Host "Application directories created" -ForegroundColor Green

# Configure firewall
New-NetFirewallRule -Name "HTTP-Inbound" -DisplayName "HTTP Port 80" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -Name "HTTPS-Inbound" -DisplayName "HTTPS Port 443" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -ErrorAction SilentlyContinue

Write-Host "Firewall configured (ports 80 and 443)" -ForegroundColor Green

# Get server IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" }).IPAddress

Write-Host ""
Write-Host "IIS Installation Complete!" -ForegroundColor Green
Write-Host "Server IP: $ip" -ForegroundColor Cyan
Write-Host "Web access: http://$ip" -ForegroundColor Cyan
Write-Host "Application path: $appPath" -ForegroundColor Cyan
Write-Host ""
