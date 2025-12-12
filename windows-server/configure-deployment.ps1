# Deployment Configuration for MotoPartes Manager
# Remote deployment script for Windows Server

Write-Host "Configuring MotoPartes Manager deployment..." -ForegroundColor Cyan

# Variables
$appPath = "C:\inetpub\motopartes-manager"
$frontendPath = "$appPath\frontend"
$backendPath = "$appPath\backend"
$githubRepo = "https://github.com/YOUR_USERNAME/motopartes-manager.git"

# Create deployment info file
Write-Host "Creating deployment documentation..." -ForegroundColor Yellow

$deploymentInfo = @"
# MotoPartes Manager - Server Deployment

## Server Information
- Server IP: 192.168.1.104
- IIS Version: Installed and Running
- Node.js Version: v20.11.1
- NPM Version: 10.2.4
- PM2: Installed

## Directory Structure
- Application Root: $appPath
- Frontend: $frontendPath
- Backend: $backendPath

## Deployment Steps

### Manual Deployment (First Time)

1. Clone or upload the project:
   ```
   cd C:\inetpub
   git clone $githubRepo motopartes-manager
   ```

2. Install backend dependencies:
   ```
   cd $backendPath
   npm install
   ```

3. Install frontend dependencies and build:
   ```
   cd $frontendPath
   npm install
   npm run build
   ```

4. Configure environment variables:
   - Copy .env.example to .env
   - Update database connection strings
   - Update API URLs

5. Start backend with PM2:
   ```
   cd $backendPath
   pm2 start server.js --name motopartes-backend
   pm2 save
   ```

6. Configure IIS for frontend:
   - Create new site in IIS pointing to $frontendPath\dist
   - Configure URL Rewrite for SPA routing
   - Set up reverse proxy to backend (port 3000)

### Automated Updates

Use the provided PowerShell scripts:
- update-backend.ps1: Update and restart backend
- update-frontend.ps1: Update and rebuild frontend
- full-deployment.ps1: Complete deployment from scratch

## Network Configuration

### Firewall Rules
- HTTP (80): Enabled
- HTTPS (443): Enabled  
- Backend API (3000): Internal only

### Domain Configuration (Future)
1. Purchase domain name
2. Configure DNS A record to point to server's public IP
3. Install SSL certificate (Let's Encrypt recommended)
4. Configure HTTPS redirect in IIS

## Access Points
- Frontend: http://192.168.1.104
- Backend API: http://192.168.1.104:3000 (or via proxy)
- IIS Manager: Available on server

## PM2 Commands
- View status: pm2 status
- View logs: pm2 logs motopartes-backend
- Restart: pm2 restart motopartes-backend
- Stop: pm2 stop motopartes-backend
- Delete: pm2 delete motopartes-backend

## Troubleshooting

### Backend not starting
1. Check PM2 logs: pm2 logs
2. Verify database connection
3. Check environment variables

### Frontend not displaying
1. Verify IIS site is running
2. Check dist folder exists
3. Verify URL Rewrite module

### Can't access from outside network
1. Configure port forwarding on router
2. Check Windows Firewall
3. Verify public IP address

"@

$deploymentInfo | Out-File -FilePath "$appPath\DEPLOYMENT_GUIDE.md" -Encoding UTF8
Write-Host "Deployment guide created: $appPath\DEPLOYMENT_GUIDE.md" -ForegroundColor Green

# Create PM2 ecosystem file
Write-Host "Creating PM2 configuration..." -ForegroundColor Yellow

$pm2Config = @"
module.exports = {
  apps: [{
    name: 'motopartes-backend',
    cwd: '$backendPath',
    script: 'server.js',
    instances: 1,
    exec_mode: 'fork',
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '$backendPath\\logs\\error.log',
    out_file: '$backendPath\\logs\\output.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
"@

$pm2Config | Out-File -FilePath "$backendPath\ecosystem.config.js" -Encoding UTF8 -Force
Write-Host "PM2 configuration created" -ForegroundColor Green

# Create logs directory
New-Item -ItemType Directory -Path "$backendPath\logs" -Force | Out-Null

# Create update scripts
Write-Host "Creating deployment scripts..." -ForegroundColor Yellow

# Update backend script
$updateBackend = @'
# Update Backend Script
Write-Host "Updating MotoPartes Backend..." -ForegroundColor Cyan

cd C:\inetpub\motopartes-manager\backend

# Pull latest changes
git pull origin main

# Install dependencies
npm install

# Restart PM2
pm2 restart motopartes-backend

Write-Host "Backend updated successfully!" -ForegroundColor Green
'@

$updateBackend | Out-File -FilePath "$appPath\update-backend.ps1" -Encoding UTF8
Write-Host "Created: update-backend.ps1" -ForegroundColor Green

# Update frontend script  
$updateFrontend = @'
# Update Frontend Script
Write-Host "Updating MotoPartes Frontend..." -ForegroundColor Cyan

cd C:\inetpub\motopartes-manager\frontend

# Pull latest changes
git pull origin main

# Install dependencies
npm install

# Build production version
npm run build

Write-Host "Frontend updated successfully!" -ForegroundColor Green
Write-Host "Remember to refresh the browser cache!" -ForegroundColor Yellow
'@

$updateFrontend | Out-File -FilePath "$appPath\update-frontend.ps1" -Encoding UTF8
Write-Host "Created: update-frontend.ps1" -ForegroundColor Green

Write-Host ""
Write-Host "Deployment configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Upload or clone your project to: $appPath" -ForegroundColor White
Write-Host "2. Install dependencies (npm install)" -ForegroundColor White
Write-Host "3. Configure environment variables" -ForegroundColor White
Write-Host "4. Build frontend (npm run build)" -ForegroundColor White
Write-Host "5. Start backend with PM2" -ForegroundColor White
Write-Host "6. Configure IIS site" -ForegroundColor White
Write-Host ""
