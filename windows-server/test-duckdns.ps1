# Script de Prueba de DuckDNS
# Verifica que todo este configurado correctamente

$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)
$serverIP = "192.168.1.104"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Verificacion de DuckDNS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Leer configuracion local
$configLocal = "C:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager\windows-server\duckdns-config.ps1"
if (Test-Path $configLocal) {
    . $configLocal
    Write-Host "`nConfiguracion local:" -ForegroundColor Green
    Write-Host "  Dominio: $DUCKDNS_DOMAIN.duckdns.org" -ForegroundColor White
}
else {
    Write-Host "No se encuentra archivo de configuracion local" -ForegroundColor Yellow
}

Write-Host "`nVerificando servidor..." -ForegroundColor Cyan

Invoke-Command -ComputerName $serverIP -Credential $cred -ScriptBlock {
    
    Write-Host "`n1. Archivos instalados:" -ForegroundColor Yellow
    $files = @(
        "C:\DuckDNS\duckdns-config.ps1",
        "C:\DuckDNS\update-ip.ps1",
        "C:\DuckDNS\duckdns.log",
        "C:\DuckDNS\last-ip.txt"
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "  $file" -ForegroundColor Green -NoNewline
            Write-Host " - OK" -ForegroundColor White
        }
        else {
            Write-Host "  $file" -ForegroundColor Red -NoNewline
            Write-Host " - NO EXISTE" -ForegroundColor White
        }
    }
    
    Write-Host "`n2. Tarea programada:" -ForegroundColor Yellow
    $task = Get-ScheduledTask -TaskName "DuckDNS Update" -ErrorAction SilentlyContinue
    if ($task) {
        Write-Host "  Estado: " -ForegroundColor White -NoNewline
        Write-Host $task.State -ForegroundColor Green
        $taskInfo = Get-ScheduledTaskInfo -TaskName "DuckDNS Update"
        Write-Host "  Ultima ejecucion: $($taskInfo.LastRunTime)" -ForegroundColor White
        Write-Host "  Proxima ejecucion: $($taskInfo.NextRunTime)" -ForegroundColor White
    }
    else {
        Write-Host "  Tarea NO configurada" -ForegroundColor Red
    }
    
    Write-Host "`n3. IP publica actual:" -ForegroundColor Yellow
    try {
        $publicIp = Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 10
        Write-Host "  $publicIp" -ForegroundColor Green
    }
    catch {
        Write-Host "  ERROR: No se pudo obtener IP publica" -ForegroundColor Red
    }
    
    Write-Host "`n4. Ultima IP registrada en DuckDNS:" -ForegroundColor Yellow
    if (Test-Path "C:\DuckDNS\last-ip.txt") {
        $lastIp = Get-Content "C:\DuckDNS\last-ip.txt"
        Write-Host "  $lastIp" -ForegroundColor Green
    }
    else {
        Write-Host "  Aun no se ha actualizado" -ForegroundColor Yellow
    }
    
    Write-Host "`n5. Ultimas 10 lineas del log:" -ForegroundColor Yellow
    if (Test-Path "C:\DuckDNS\duckdns.log") {
        Get-Content "C:\DuckDNS\duckdns.log" -Tail 10 | ForEach-Object {
            if ($_ -match "ERROR") {
                Write-Host "  $_" -ForegroundColor Red
            }
            elseif ($_ -match "SUCCESS") {
                Write-Host "  $_" -ForegroundColor Green
            }
            else {
                Write-Host "  $_" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host "  No hay log aun" -ForegroundColor Yellow
    }
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "  Verificacion completada" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
