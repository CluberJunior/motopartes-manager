# Verificar e instalar Node.js correctamente
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "Verificando y completando instalacion deNode.js..." -ForegroundColor Cyan

$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
    # Verificar si Node esta instalado
    $nodePath = "C:\Program Files\nodejs\node.exe"
    
    if (Test-Path $nodePath) {
        $env:Path = "C:\Program Files\nodejs;$env:Path"
        $nodeVersion = & $nodePath --version
        Write-Host "Node.js ya instalado: $nodeVersion" -ForegroundColor Green
        
        # Instalar PM2
        Write-Host "Instalando PM2 globalmente..." -ForegroundColor Yellow
        & "C:\Program Files\nodejs\npm.cmd" install pm2@latest -g --force
        
        $pm2Version = & "C:\Program Files\nodejs\pm2" --version 2>&1
        Write-Host "PM2 instalado: $pm2Version" -ForegroundColor Green
    }
    else {
        Write-Host "Node.js NO instalado. Instalando ahora..." -ForegroundColor Yellow
        Start-Process msiexec.exe -ArgumentList "/i C:\Temp\nodejs.msi /quiet /norestart" -Wait
        Write-Host "Instalacion completada" -ForegroundColor Green
    }
}

Write-Host "Proceso completado" -ForegroundColor Green
