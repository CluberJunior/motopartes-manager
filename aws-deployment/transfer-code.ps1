# Transferir codigo desde PC local al servidor AWS
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"
$localPath = "c:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Transferencia de Codigo" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Write-Host "`nCreando sesion remota..." -ForegroundColor Yellow
$session = New-PSSession -ComputerName $serverDNS -Credential $cred

try {
    Write-Host "Sesion creada exitosamente" -ForegroundColor Green
    
    Write-Host "`nTransfiriendo archivos al servidor..." -ForegroundColor Cyan
    Write-Host "(Esto puede tardar varios minutos...)" -ForegroundColor Gray
    
    # Transferir archivos importantes
    $filesToCopy = @(
        "package.json",
        "package-lock.json",
        "index.html",
        "vite.config.js",
        "tailwind.config.js",
        "postcss.config.js"
    )
    
    $foldersToCopy = @(
        "src",
        "public",
        "whatsapp-backend"
    )
    
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
    
    # Copiar archivos raiz
    foreach ($file in $filesToCopy) {
        $localFile = Join-Path $localPath $file
        if (Test-Path $localFile) {
            Write-Host "  Copiando $file..." -ForegroundColor Gray
            Copy-Item -Path $localFile -Destination $remotePath -ToSession $session -Force
        }
    }
    
    # Copiar carpetas
    foreach ($folder in $foldersToCopy) {
        $localFolder = Join-Path $localPath $folder
        if (Test-Path $localFolder) {
            Write-Host "  Copiando $folder/..." -ForegroundColor Gray
            Copy-Item -Path $localFolder -Destination $remotePath -ToSession $session -Recurse -Force
        }
    }
    
    Write-Host "`nArchivos transferidos exitosamente" -ForegroundColor Green
    
    Write-Host "`n[SERVIDOR] Instalando dependencias y compilando..." -ForegroundColor Cyan
    
    Invoke-Command -Session $session -ScriptBlock {
        $appDir = "C:\inetpub\wwwroot\motopartes-manager"
        $env:Path = "C:\Program Files\nodejs;$env:Path"
        Set-Location $appDir
        
        Write-Host "  Instalando dependencias del frontend..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" install --legacy-peer-deps 2>&1 | Out-Null
        
        Write-Host "  Compilando frontend..." -ForegroundColor Gray
        & "C:\Program Files\nodejs\npm.cmd" run build 2>&1 | Out-Null
        
        if (Test-Path "$appDir\dist") {
            Write-Host "  Frontend compilado exitosamente" -ForegroundColor Green
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
            
            # Iniciar con PM2
            $pm2Path = "C:\Users\Administrator\AppData\Roaming\npm\pm2.cmd"
            if (Test-Path $pm2Path) {
                & $pm2Path delete motopartes-backend 2>&1 | Out-Null
                & $pm2Path start server.js --name motopartes-backend
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
        Write-Host "  Sitio IIS configurado" -ForegroundColor Green
    }
    
}
finally {
    Remove-PSSession -Session $session
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Deployment Completado!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nURL: http://$serverDNS" -ForegroundColor Cyan
