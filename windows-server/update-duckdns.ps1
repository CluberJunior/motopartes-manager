# Script de Actualizacion de DuckDNS
# Se ejecuta cada 5 minutos via Tarea Programada

# Cargar configuracion
$configPath = "C:\DuckDNS\duckdns-config.ps1"
if (-not (Test-Path $configPath)) {
    Write-Error "No se encontro archivo de configuracion: $configPath"
    exit 1
}

. $configPath

# Directorio de logs
$logFile = "C:\DuckDNS\duckdns.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Funcion para escribir logs
function Write-Log {
    param([string]$Message)
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logFile -Value $logEntry
    Write-Host $logEntry
}

# Obtener IP publica actual
try {
    $publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=text" -TimeoutSec 10).Trim()
    Write-Log "IP publica detectada: $publicIp"
}
catch {
    Write-Log "ERROR: No se pudo obtener IP publica - $($_.Exception.Message)"
    exit 1
}

# Leer ultima IP actualizada
$lastIpFile = "C:\DuckDNS\last-ip.txt"
$lastIp = ""
if (Test-Path $lastIpFile) {
    $lastIp = Get-Content $lastIpFile -Raw
    $lastIp = $lastIp.Trim()
}

# Verificar si la IP cambio
if ($publicIp -eq $lastIp) {
    Write-Log "IP no cambio ($publicIp) - No se requiere actualizacion"
    exit 0
}

# Actualizar DuckDNS
try {
    $updateUrl = "$($DuckDNSConfig.UpdateUrl)$publicIp"
    $response = Invoke-RestMethod -Uri $updateUrl -TimeoutSec 15
    
    if ($response -eq "OK") {
        Write-Log "SUCCESS: DuckDNS actualizado correctamente"
        Write-Log "Dominio: $($DuckDNSConfig.Domain).duckdns.org -> $publicIp"
        
        # Guardar ultima IP
        Set-Content -Path $lastIpFile -Value $publicIp
    }
    elseif ($response -eq "KO") {
        Write-Log "ERROR: DuckDNS respondio KO - Verifica tu token y dominio"
        exit 1
    }
    else {
        Write-Log "WARNING: Respuesta inesperada de DuckDNS: $response"
    }
}
catch {
    Write-Log "ERROR: Fallo al actualizar DuckDNS - $($_.Exception.Message)"
    exit 1
}

# Limpiar logs antiguos (mantener ultimos 1000 registros)
$logLines = Get-Content $logFile
if ($logLines.Count -gt 1000) {
    $logLines | Select-Object -Last 1000 | Set-Content $logFile
    Write-Log "Log limpiado - Manteniendo ultimos 1000 registros"
}

exit 0
