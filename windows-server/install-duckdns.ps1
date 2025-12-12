# Instalador de DuckDNS en el Servidor
# Ejecuta este script desde tu PC local

$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)
$serverIP = "192.168.1.104"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Instalador de DuckDNS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Verificar que el archivo de configuracion exista
$configLocal = "C:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager\windows-server\duckdns-config.ps1"
if (-not (Test-Path $configLocal)) {
    Write-Host "ERROR: No se encuentra duckdns-config.ps1" -ForegroundColor Red
    Write-Host "Por favor configura tu dominio y token primero" -ForegroundColor Yellow
    exit 1
}

# Leer configuracion y verificar
. $configLocal
if ($DUCKDNS_TOKEN -eq "TU-TOKEN-AQUI") {
    Write-Host "ERROR: Debes editar duckdns-config.ps1 con tu token de DuckDNS" -ForegroundColor Red
    Write-Host "1. Ve a https://www.duckdns.org" -ForegroundColor Yellow
    Write-Host "2. Inicia sesion y obten tu token" -ForegroundColor Yellow
    Write-Host "3. Edita duckdns-config.ps1 y reemplaza 'TU-TOKEN-AQUI'" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nConfiguracion detectada:" -ForegroundColor Green
Write-Host "  Dominio: $DUCKDNS_DOMAIN.duckdns.org" -ForegroundColor White
Write-Host "  Token: $($DUCKDNS_TOKEN.Substring(0,8))..." -ForegroundColor White

Write-Host "`nConectando al servidor $serverIP..." -ForegroundColor Cyan

Invoke-Command -ComputerName $serverIP -Credential $cred -ScriptBlock {
    param($domain, $token)
    
    Write-Host "Creando directorio C:\DuckDNS..." -ForegroundColor Yellow
    
    # Crear directorio
    $duckDnsDir = "C:\DuckDNS"
    if (-not (Test-Path $duckDnsDir)) {
        New-Item -ItemType Directory -Path $duckDnsDir -Force | Out-Null
    }
    
    # Crear archivo de configuracion
    $configContent = @"
# Configuracion de DuckDNS
`$DUCKDNS_DOMAIN = "$domain"
`$DUCKDNS_TOKEN = "$token"
`$DUCKDNS_URL = "https://www.duckdns.org/update?domains=`$DUCKDNS_DOMAIN&token=`$DUCKDNS_TOKEN&ip="

`$Global:DuckDNSConfig = @{
    Domain = `$DUCKDNS_DOMAIN
    Token = `$DUCKDNS_TOKEN
    UpdateUrl = `$DUCKDNS_URL
}
"@
    
    Set-Content -Path "$duckDnsDir\duckdns-config.ps1" -Value $configContent
    Write-Host "Archivo de configuracion creado" -ForegroundColor Green
    
    # Crear script de actualizacion (contenido inline para evitar problemas de transferencia)
    $updateScript = @'
# Script de Actualizacion de DuckDNS
$configPath = "C:\DuckDNS\duckdns-config.ps1"
. $configPath
$logFile = "C:\DuckDNS\duckdns.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param([string]$Message)
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logFile -Value $logEntry
}

try {
    $publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 10).Trim()
    Write-Log "IP publica: $publicIp"
} catch {
    Write-Log "ERROR: No se pudo obtener IP - $($_.Exception.Message)"
    exit 1
}

$lastIpFile = "C:\DuckDNS\last-ip.txt"
$lastIp = ""
if (Test-Path $lastIpFile) {
    $lastIp = (Get-Content $lastIpFile -Raw).Trim()
}

if ($publicIp -eq $lastIp) {
    Write-Log "IP sin cambios ($publicIp)"
    exit 0
}

try {
    $updateUrl = "$($DuckDNSConfig.UpdateUrl)$publicIp"
    $response = Invoke-RestMethod -Uri $updateUrl -TimeoutSec 15
    
    if ($response -eq "OK") {
        Write-Log "SUCCESS: DuckDNS actualizado - $($DuckDNSConfig.Domain).duckdns.org -> $publicIp"
        Set-Content -Path $lastIpFile -Value $publicIp
    } else {
        Write-Log "ERROR: DuckDNS respondio $response"
        exit 1
    }
} catch {
    Write-Log "ERROR: Fallo al actualizar - $($_.Exception.Message)"
    exit 1
}

$logLines = Get-Content $logFile -ErrorAction SilentlyContinue
if ($logLines -and $logLines.Count -gt 1000) {
    $logLines | Select-Object -Last 1000 | Set-Content $logFile
}
exit 0
'@
    
    Set-Content -Path "$duckDnsDir\update-ip.ps1" -Value $updateScript
    Write-Host "Script de actualizacion creado" -ForegroundColor Green
    
    # Crear tarea programada
    Write-Host "Configurando tarea programada..." -ForegroundColor Yellow
    
    # Eliminar tarea existente si existe
    $existingTask = Get-ScheduledTask -TaskName "DuckDNS Update" -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName "DuckDNS Update" -Confirm:$false
    }
    
    # Crear nueva tarea
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\DuckDNS\update-ip.ps1"
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    Register-ScheduledTask -TaskName "DuckDNS Update" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    
    Write-Host "Tarea programada configurada (cada 5 minutos)" -ForegroundColor Green
    
    # Ejecutar actualizacion inicial
    Write-Host "`nEjecutando primera actualizacion..." -ForegroundColor Yellow
    & "C:\DuckDNS\update-ip.ps1"
    
    Write-Host "`nLeyendo resultado:" -ForegroundColor Cyan
    if (Test-Path "$duckDnsDir\duckdns.log") {
        Get-Content "$duckDnsDir\duckdns.log" -Tail 5
    }
    
} -ArgumentList $DUCKDNS_DOMAIN, $DUCKDNS_TOKEN

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Instalacion Completada" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nTu dominio DuckDNS:" -ForegroundColor Cyan
Write-Host "  http://$DUCKDNS_DOMAIN.duckdns.org" -ForegroundColor Yellow
Write-Host "`nLa IP se actualizara automaticamente cada 5 minutos" -ForegroundColor White
Write-Host "`nPara verificar logs en el servidor:" -ForegroundColor White
Write-Host "  Get-Content C:\DuckDNS\duckdns.log -Tail 20" -ForegroundColor Gray
Write-Host "`nProximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Solicitar IP publica a Telmex" -ForegroundColor White
Write-Host "  2. Configurar Port Forwarding (puerto 80 -> 192.168.1.104)" -ForegroundColor White
Write-Host "  3. Probar: http://$DUCKDNS_DOMAIN.duckdns.org" -ForegroundColor White
