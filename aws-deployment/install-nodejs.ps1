# Instalacion de Node.js y PM2 en AWS EC2
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Instalacion de Node.js y PM2" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Crear credenciales
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
    Write-Host "`n[SERVIDOR] Descargando Node.js..." -ForegroundColor Cyan
    
    $tempDir = "C:\Temp"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    # URL de Node.js LTS
    $nodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
    $nodePath = "$tempDir\nodejs.msi"
    
    try {
        Write-Host "  Descargando desde$nodeUrl..." -ForegroundColor Gray
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodePath -UseBasicParsing
        Write-Host "  Descarga completada" -ForegroundColor Green
        
        Write-Host "`n[SERVIDOR] Instalando Node.js..." -ForegroundColor Cyan
        Start-Process msiexec.exe -ArgumentList "/i $nodePath /quiet /norestart" -Wait
        Write-Host "  Node.js instalado" -ForegroundColor Green
        
        # Esperar a que se actualicen las variables de entorno
        Start-Sleep -Seconds 5
        
        # Actualizar PATH en la sesion actual
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verificar instalacion de Node.js
        Write-Host "`n[SERVIDOR] Verificando Node.js..." -ForegroundColor Cyan
        $nodeVersion = & "C:\Program Files\nodejs\node.exe" --version 2>&1
        $npmVersion = & "C:\Program Files\nodejs\npm.cmd" --version 2>&1
        Write-Host "  Node.js: $nodeVersion" -ForegroundColor Green
        Write-Host "  NPM: $npmVersion" -ForegroundColor Green
        
        # Instalar PM2 globalmente
        Write-Host "`n[SERVIDOR] Instalando PM2..." -ForegroundColor Cyan
        $env:Path = "C:\Program Files\nodejs;$env:Path"
        & "C:\Program Files\nodejs\npm.cmd" install -g pm2 2>&1 | Out-Null
        Write-Host "  PM2 instalado" -ForegroundColor Green
        
        # Configurar PM2 como servicio de Windows
        Write-Host "`n[SERVIDOR] Configurando PM2 como servicio..." -ForegroundColor Cyan
        & "C:\Program Files\nodejs\npm.cmd" install -g pm2-windows-service 2>&1 | Out-Null
        & "C:\Program Files\nodejs\node_modules\pm2\bin\pm2.cmd" startup 2>&1 | Out-Null
        Write-Host "  PM2 configurado como servicio" -ForegroundColor Green
        
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Node.js y PM2 Instalados" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
