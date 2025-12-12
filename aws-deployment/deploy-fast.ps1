# Deployment RAPIDO - Sin copiar node_modules
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"
$localPath = "c:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Deployment RAPIDO (sin node_modules)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Write-Host "`nCreando sesion remota..." -ForegroundColor Yellow
$session = New-PSSession -ComputerName $serverDNS -Credential $cred

try {
    $remotePath = "C:\inetpub\wwwroot\motopartes-manager"
    
    # Limpiar directorio remoto
    Invoke-Command -Session $session -ScriptBlock {
        param($path)
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    } -ArgumentList $remotePath
    
    Write-Host "  Directorio remoto preparado" -ForegroundColor Green
    
    # Copiar solo archivos necesarios (SIN node_modules)
    Write-Host "`nCopiando archivos (excluyendo node_modules)..." -ForegroundColor Cyan
    
    $itemsToCopy = @()
    
    # Archivos raiz
    Get-ChildItem -Path $localPath -File | Where-Object {
        $_.Name -notlike "*.md" -and $_.Name -notlike "*.bat"
    } | ForEach-Object {
        $itemsToCopy += $_.FullName
    }
    
    # Carpetas (excluyendo node_modules, dist, .git)
    Get-ChildItem -Path $localPath -Directory | Where-Object {
        $_.Name -notin @('node_modules', 'dist', '.git', '.vscode', 'aws-deployment', 'windows-server')
    } | ForEach-Object {
        $itemsToCopy += $_.FullName
    }
    
    foreach ($item in $itemsToCopy) {
        $itemName = Split-Path $item -Leaf
        Write-Host "  Copiando $itemName..." -ForegroundColor Gray
        Copy-Item -Path $item -Destination $remotePath -ToSession $session -Recurse -Force
    }
    
    Write-Host "`nArchivos copiados exitosamente" -ForegroundColor Green
    
    Write-Host "`n[SERVIDOR] Instalando y compilando..." -ForegroundColor Cyan
    
    Invoke-Command -Session $session -ScriptBlock {
        $appDir = "C:\inetpub\wwwroot\motopartes-manager"
        $env:Path = "C:\Program Files\nodejs;$env:Path"
        Set-Location $appDir
        
        Write-Host "  Instalando dependencias del frontend (esto tarda 2-3 min)..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" install --legacy-peer-deps 2>&1 | Out-Null
        
        Write-Host "  Compilando frontend..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" run build 2>&1 | Out-Null
        
        if (Test-Path "$appDir\dist\index.html") {
            Write-Host "  Frontend compilado exitosamente"  -ForegroundColor Green
        }
        else {
            Write-Host "  ERROR: No se pudo compilar" -ForegroundColor Red
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
                & $pm2Path start server.js --name motopartes-backend --watch 2>&1 | Out-Null
                & $pm2Path save --force 2>&1 | Out-Null
                Write-Host "  Backend iniciado" -ForegroundColor Green
            }
        }
        
        # IIS
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
    
}
finally {
    Remove-PSSession -Session $session
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETADO!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nURL de acceso:" -ForegroundColor Yellow
Write-Host "http://$serverDNS" -ForegroundColor Cyan

# Verificar acceso
Write-Host "`nVerificando acceso..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $response = Invoke-WebRequest -Uri "http://$serverDNS" -UseBasicParsing -TimeoutSec 10
    Write-Host "OK - Aplicacion accesible!" -ForegroundColor Green
}
catch {
    Write-Host "Esperando a que IIS inicie..." -ForegroundColor Yellow
}
