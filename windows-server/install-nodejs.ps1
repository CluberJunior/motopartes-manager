# Node.js Installation Script for Windows Server
# Installs Node.js LTS and PM2 process manager

Write-Host "Installing Node.js and PM2..." -ForegroundColor Cyan

# Download Node.js LTS installer
$nodeVersion = "20.11.0"
$nodeInstaller = "node-v$nodeVersion-x64.msi"
$nodeUrl = "https://nodejs.org/dist/v$nodeVersion/$nodeInstaller"
$installerPath = "C:\Temp\$nodeInstaller"

# Create temp directory
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null

Write-Host "Downloading Node.js v$nodeVersion..." -ForegroundColor Yellow

# Download Node.js
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download complete" -ForegroundColor Green
}
catch {
    Write-Host "Error downloading Node.js: $_" -ForegroundColor Red
    exit 1
}

# Install Node.js silently
Write-Host "Installing Node.js..." -ForegroundColor Yellow
$installArgs = "/i `"$installerPath`" /quiet /norestart ADDLOCAL=ALL"
Start-Process msiexec.exe -ArgumentList $installArgs -Wait -NoNewWindow

# Refresh PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Node.js installed successfully" -ForegroundColor Green

# Wait a moment for installation to complete
Start-Sleep -Seconds 5

# Verify Node.js installation
Write-Host "Verifying Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersionOutput = & "C:\Program Files\nodejs\node.exe" --version
    $npmVersionOutput = & "C:\Program Files\nodejs\npm.cmd" --version
    Write-Host "Node.js version: $nodeVersionOutput" -ForegroundColor Green
    Write-Host "NPM version: $npmVersionOutput" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Could not verify Node.js installation" -ForegroundColor Yellow
}

# Install PM2 globally
Write-Host "Installing PM2..." -ForegroundColor Yellow
try {
    & "C:\Program Files\nodejs\npm.cmd" install -g pm2
    & "C:\Program Files\nodejs\npm.cmd" install -g pm2-windows-service
    Write-Host "PM2 installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error installing PM2: $_" -ForegroundColor Red
}

# Clean up installer
Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Node.js and PM2 installation complete!" -ForegroundColor Green
Write-Host "Node.js: C:\Program Files\nodejs" -ForegroundColor Cyan
Write-Host "NPM: C:\Program Files\nodejs\npm.cmd" -ForegroundColor Cyan
Write-Host ""
