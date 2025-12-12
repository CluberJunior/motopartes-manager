# Complete Deployment Script
# Completes the deployment of MotoPartes Manager

$projectPath = "C:\inetpub\wwwroot\motopartes-manager"
$backendPath = "$projectPath\whatsapp-backend"

Write-Host "Starting MotoPartes Manager Deployment..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Build Frontend
Write-Host "=== Step 1: Building Frontend ===" -ForegroundColor Yellow
cd $projectPath

Write-Host "Running npm run build:prod..." -ForegroundColor White
& "C:\Program Files\nodejs\npm.cmd" run build:prod

if (Test-Path "$projectPath\dist") {
    Write-Host "Frontend built successfully!" -ForegroundColor Green
}
else {
    Write-Host "Frontend build failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Configure and Start Backend with PM2
Write-Host ""
Write-Host "=== Step 2: Starting Backend with PM2 ===" -ForegroundColor Yellow
cd $backendPath

# Check if .env exists, if not create from .env.production
if (-not (Test-Path "$backendPath\.env")) {
    Copy-Item "$backendPath\.env.production" "$backendPath\.env"
    Write-Host "Created .env from .env.production" -ForegroundColor Green
}

# Start with PM2
Write-Host "Starting backend with PM2..." -ForegroundColor White
& "C:\Program Files\nodejs\npm.cmd" exec pm2 start server.js --name "motopartes-backend"
& "C:\Program Files\nodejs\npm.cmd" exec pm2 save

Write-Host "Backend started!" -ForegroundColor Green

# Step 3: Configure IIS Site
Write-Host ""
Write-Host "=== Step 3: Configuring IIS ===" -ForegroundColor Yellow

Import-Module WebAdministration

# Create new website
$siteName = "MotoPartes-Manager"
$distPath = "$projectPath\dist"

# Stop and remove if exists
if (Get-Website -Name $siteName -ErrorAction SilentlyContinue) {
    Remove-Website -Name $siteName
}

# Create new site
New-Website -Name $siteName -PhysicalPath $distPath -Port 80 -Force
Start-Website -Name $siteName

Write-Host "IIS site created and started!" -ForegroundColor Green

# Step 4: Verify
Write-Host ""
Write-Host "=== Step 4: Verification ===" -ForegroundColor Yellow

Write-Host "PM2 Status:" -ForegroundColor Cyan
& "C:\Program Files\nodejs\npm.cmd" exec pm2 status

Write-Host ""
Write-Host "IIS Sites:" -ForegroundColor Cyan
Get-Website | Select-Object Name, State, PhysicalPath | Format-Table

Write-Host ""
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" }).IPAddress
Write-Host "=== Deployment Complete! ===" -ForegroundColor Green
Write-Host "Access your application at: http://$ip" -ForegroundColor Cyan
Write-Host "Backend API running on: http://localhost:3001" -ForegroundColor Cyan
Write-Host ""
