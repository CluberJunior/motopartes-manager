# Deployment completo de la aplicacion en AWS EC2
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"
$repoUrl = "https://github.com/Clubaru/motopartes-manager.git"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Deployment de Aplicacion" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
    param($repoUrl)
    
    $appDir = "C:\inetpub\wwwroot\motopartes-manager"
    $env:Path = "C:\Program Files\nodejs;C:\Program Files\Git\cmd;$env:Path"
    
    Write-Host "[SERVIDOR] Instalando Git si es necesario..." -ForegroundColor Cyan
    
    # Verificar si Git esta instalado  
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    if (-not (Test-Path $gitPath)) {
        Write-Host "  Descargando Git..." -ForegroundColor Yellow
        $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
        $gitInstaller = "C:\Temp\git-installer.exe"
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Start-Process $gitInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
        Write-Host "  Git instalado" -ForegroundColor Green
        Start-Sleep -Seconds 10
        $env:Path = "C:\Program Files\Git\cmd;$env:Path"
    }
    else {
        Write-Host "  Git ya instalado" -ForegroundColor Green
    }
    
    Write-Host "`n[SERVIDOR] Clonando repositorio..." -ForegroundColor Cyan
    
    # Limpiar directorio si existe
    if (Test-Path $appDir) {
        Remove-Item -Path $appDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $appDir -Force | Out-Null
    
    # Clonar repositorio
    Set-Location $appDir
    $env:GIT_REDIRECT_STDERR = '2>&1'
    & $gitPath clone $repoUrl . 2>&1 | Write-Host
    
    if (Test-Path "package.json") {
        Write-Host "  Repositorio clonado exitosamente" -ForegroundColor Green
    }
    else {
        Write-Host "  ERROR: No se pudo clonar el repositorio" -ForegroundColor Red
        return
    }
    
    Write-Host "`n[SERVIDOR] Instalando dependencias..." -ForegroundColor Cyan
    & "C:\Program Files\nodejs\npm.cmd" install 2>&1 | Write-Host
    
    Write-Host "`n[SERVIDOR] Compilando frontend..." -ForegroundColor Cyan
    & "C:\Program Files\nodejs\npm.cmd" run build 2>&1 | Write-Host
    
    Write-Host "`n[SERVIDOR] Configurando backend con PM2..." -ForegroundColor Cyan
    Set-Location "$appDir\whatsapp-backend"
    & "C:\Program Files\nodejs\npm.cmd" install 2>&1 | Out-Null
    
    # Iniciar backend con PM2
    $pm2Path = "C:\Users\Administrator\AppData\Roaming\npm\pm2.cmd"
    & $pm2Path delete motopartes-backend 2>&1 | Out-Null
    & $pm2Path start server.js --name motopartes-backend
    & $pm2Path save
    & $pm2Path list
    
    Write-Host "`n[SERVIDOR] Configurando IIS..." -ForegroundColor Cyan
    
    # Importar modulo IIS
    Import-Module WebAdministration
    
    # Eliminar sitio default
    Remove-WebSite -Name "Default Web Site" -ErrorAction SilentlyContinue
    
    # Crear nuevo sitio
    $siteName = "MotoPartes"
    $distPath = "$appDir\dist"
    
    if (Get-WebSite -Name $siteName -ErrorAction SilentlyContinue) {
        Remove-WebSite -Name $siteName
    }
    
    New-WebSite -Name $siteName -Port 80 -PhysicalPath $distPath -Force
    Start-WebSite -Name $siteName
    
    Write-Host "  Sitio IIS configurado y activo" -ForegroundColor Green
    
} -ArgumentList $repoUrl

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Deployment Completado!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nURL de acceso: http://$serverDNS" -ForegroundColor Yellow
