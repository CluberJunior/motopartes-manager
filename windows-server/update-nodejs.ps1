# Update Node.js to latest LTS
# Required for Vite build

Write-Host "Updating Node.js to latest LTS version..." -ForegroundColor Cyan

# Download Node.js 22.12.0 LTS
$nodeVersion = "22.12.0"
$nodeInstaller = "node-v$nodeVersion-x64.msi"
$nodeUrl = "https://nodejs.org/dist/v$nodeVersion/$nodeInstaller"
$installerPath = "C:\Temp\$nodeInstaller"

# Create temp directory
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null

Write-Host "Downloading Node.js v$nodeVersion..." -ForegroundColor Yellow

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download complete" -ForegroundColor Green
}
catch {
    Write-Host "Error downloading Node.js: $_" -ForegroundColor Red
    exit 1
}

# Install Node.js silently (upgrades existing installation)
Write-Host "Installing Node.js v$nodeVersion..." -ForegroundColor Yellow
$installArgs = "/i `"$installerPath`" /quiet /norestart ADDLOCAL=ALL"
Start-Process msiexec.exe -ArgumentList $installArgs -Wait -NoNewWindow

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Node.js updated successfully!" -ForegroundColor Green

# Verify version
Start-Sleep -Seconds 3
$newVersion = & "C:\Program Files\nodejs\node.exe" --version
Write-Host "New Node.js version: $newVersion" -ForegroundColor Cyan

# Clean up
Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue

Write-Host "Node.js update complete. You may need to restart PM2 if it was running." -ForegroundColor Yellow
