# Configurar TrustedHosts para AWS EC2
# IMPORTANTE: Este script debe ejecutarse como Administrador

$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"

Write-Host "Configurando TrustedHosts para AWS EC2..." -ForegroundColor Cyan

try {
    # Obtener hosts actuales
    $currentHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    
    if ($currentHosts -like "*$serverDNS*") {
        Write-Host "El servidor ya esta en TrustedHosts" -ForegroundColor Green
    }
    else {
        # Agregar servidor
        if ($currentHosts -eq "" -or $currentHosts -eq $null) {
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value $serverDNS -Force
        }
        else {
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$currentHosts,$serverDNS" -Force
        }
        Write-Host "Servidor agregado a TrustedHosts" -ForegroundColor Green
    }
    
    # Verificar
    $newHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    Write-Host "`nTrustedHosts actual: $newHosts" -ForegroundColor Yellow
    
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nEste script necesita ejecutarse como Administrador" -ForegroundColor Yellow
    exit 1
}
