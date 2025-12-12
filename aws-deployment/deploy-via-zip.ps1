# Deployment via ZIP - RAPIDO
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"
$localPath = "c:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Deployment via ZIP Comprimido" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Crear ZIP del código fuente (sin node_modules)
$zipPath = "$env:TEMP\motopartes-manager.zip"
Write-Host "`nComprimiendo codigo fuente..." -ForegroundColor Yellow

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Comprimir excluyendo node_modules, .git, dist
$excludes = @('node_modules', '.git', 'dist', '.vscode', 'aws-deployment', 'windows-server')
$files = Get-ChildItem -Path $localPath -Recurse | Where-Object {
    $exclude = $false
    foreach ($pattern in $excludes) {
        if ($_.FullName -like "*\$pattern\*" -or $_.FullName -like "*\$pattern") {
            $exclude = $true
            break
        }
    }
    -not $exclude
}

Compress-Archive -Path $files.FullName -DestinationPath $zipPath -Force
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Host "  ZIP creado: $zipSize MB" -ForegroundColor Green

# Crear credenciales
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Write-Host "`nCreando sesion remota..." -ForegroundColor Yellow
$session = New-PSSession -ComputerName $serverDNS -Credential $cred

try {
    # Transferir ZIP
    Write-Host "Transfiriendo ZIP al servidor..." -ForegroundColor Cyan
    Copy-Item -Path $zipPath -Destination "C:\Temp\motopartes-manager.zip" -ToSession $session -Force
    Write-Host "  ZIP transferido" -ForegroundColor Green
    
    # Descomprimir e instalar en el servidor
    Write-Host "`n[SERVIDOR] Descomprimiendo y configurando..." -ForegroundColor Cyan
    
    Invoke-Command -Session $session -ScriptBlock {
        $appDir = "C:\inetpub\wwwroot\motopartes-manager"
        $env:Path = "C:\Program Files\nodejs;$env:Path"
        
        # Limpiar directorio
        if (Test-Path $appDir) {
            Remove-Item -Path $appDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null
        
        # Descomprimir
        Write-Host "  Descomprimiendo..." -ForegroundColor Gray
        Expand-Archive -Path "C:\Temp\motopartes-manager.zip" -DestinationPath $appDir -Force
        
        Set-Location $appDir
        
        # Instalar dependencias del frontend
        Write-Host "  Instalando dependencias del frontend..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" install --legacy-peer-deps 2>&1 | Out-Null
        
        # Compilar frontend
        Write-Host "  Compilando frontend..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" run build 2>&1 | Out-Null
        
        if (Test-Path "$appDir\dist\index.html") {
            Write-Host "  Frontend compilado exitosamente" -ForegroundColor Green
        } else {
            Write-Host "  ERROR: No se pudo compilar el frontend" -ForegroundColor Red
        }
        
        # Backend
        $backendDir = "$appDir\whatsapp-backend"
        if (Test-Path $backendDir) {
            Set-Location $backendDir
            Write-Host "  Instalando dependencias del backend..." -ForegroundColor Gray
            & "C:\Program Files\nodejs\npm.cmd" install 2>&1 | Out-Null
            
            # PM2
            $pm2Path = "C:\Users\Administrator\AppData\Roaming\npm\pm2.cmd"
            if (Test-Path $pm2Path) {
                Write-Host "  Iniciando backend con PM2..." -ForegroundColor Gray
                & $pm2Path delete motopartes-backend 2>&1 | Out-Null
                & $pm2Path start server.js --name motopartes-backend 2>&1 | Out-Null
                & $pm2Path save --force 2>&1 | Out-Null
                Write-Host "  Backend iniciado con PM2" -ForegroundColor Green
            }
        }
        
        # Configurar IIS
        Import-Module WebAdministration
        Remove-WebSite -Name "Default Web Site" -ErrorAction SilentlyContinue
        
        $siteName = "MotoPartes"
        if (Get-WebSite -Name $siteName -ErrorAction SilentlyContinue) {
            Remove-WebSite -Name $siteName
        }
        
        New-WebSite -Name $siteName -Port 80 -PhysicalPath "$appDir\dist" -Force | Out-Null
        Start-WebSite -Name $siteName
        
        $siteState = (Get-WebSite -Name $siteName).State
        Write-Host "  Sitio IIS: $siteState" -ForegroundColor Green
    }
    
} finally {
    Remove-PSSession -Session $session
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETADO!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nURL: http://$serverDNS" -ForegroundColor Cyan

# Verificar acceso
Write-Host "`nVerificando acceso..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $response = Invoke-WebRequest -Uri "http://$serverDNS" -UseBasicParsing -TimeoutSec 10
    Write-Host "OK - Aplicacion ONLINE!" -ForegroundColor Green
} catch {
    Write-Host "Esperando a que IIS inicie completamente..." -ForegroundColor Yellow
}
