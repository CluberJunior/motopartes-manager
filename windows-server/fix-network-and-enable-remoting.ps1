# Script para verificar y habilitar PowerShell Remoting
# Ejecutar como Administrador

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Verificación y Configuración de WinRM" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar el perfil de red
Write-Host "📡 Paso 1: Verificando perfil de red actual..." -ForegroundColor Yellow
$networkProfile = Get-NetConnectionProfile
Write-Host ""
Write-Host "Nombre de red: $($networkProfile.Name)" -ForegroundColor White
Write-Host "Categoría: $($networkProfile.NetworkCategory)" -ForegroundColor $(if ($networkProfile.NetworkCategory -eq "Public") { "Red" } else { "Green" })
Write-Host ""

if ($networkProfile.NetworkCategory -eq "Public") {
    Write-Host "⚠️  ADVERTENCIA: Tu red está configurada como PÚBLICA" -ForegroundColor Red
    Write-Host "   Debes cambiarla manualmente a PRIVADA desde Configuración de Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Pasos:" -ForegroundColor Cyan
    Write-Host "   1. Win + I → Red e Internet" -ForegroundColor White
    Write-Host "   2. Clic en tu conexión (Wi-Fi o Ethernet)" -ForegroundColor White
    Write-Host "   3. Cambiar 'Perfil de red' de Público a Privado" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter después de cambiar la red a Privada..."
    
    # Verificar nuevamente
    $networkProfile = Get-NetConnectionProfile
    if ($networkProfile.NetworkCategory -eq "Public") {
        Write-Host "❌ La red sigue siendo Pública. No se puede continuar." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "✅ Red cambiada exitosamente a Privada" -ForegroundColor Green
    }
}

# Paso 2: Verificar estado del servicio WinRM
Write-Host ""
Write-Host "🔧 Paso 2: Verificando servicio WinRM..." -ForegroundColor Yellow
$winrmService = Get-Service -Name WinRM
Write-Host "Estado del servicio: $($winrmService.Status)" -ForegroundColor $(if ($winrmService.Status -eq "Running") { "Green" } else { "Red" })
Write-Host ""

# Paso 3: Habilitar PowerShell Remoting
Write-Host "🚀 Paso 3: Habilitando PowerShell Remoting..." -ForegroundColor Yellow
try {
    Enable-PSRemoting -Force -ErrorAction Stop
    Write-Host "✅ PowerShell Remoting habilitado correctamente" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error al habilitar PSRemoting: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Paso 4: Configurar TrustedHosts
Write-Host "🔐 Paso 4: Configurando hosts confiables..." -ForegroundColor Yellow
Write-Host "   NOTA: Permitir '*' es menos seguro pero más flexible" -ForegroundColor Gray
Write-Host ""
$choice = Read-Host "¿Deseas agregar una IP específica (1) o permitir todos los hosts (2)? [1/2]"

if ($choice -eq "1") {
    $serverIP = Read-Host "Ingresa la IP del servidor (ej: 10.0.2.15)"
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $serverIP -Force
    Write-Host "✅ IP $serverIP agregada a TrustedHosts" -ForegroundColor Green
}
else {
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    Write-Host "✅ Todos los hosts permitidos (TrustedHosts = *)" -ForegroundColor Green
}
Write-Host ""

# Paso 5: Reiniciar servicio WinRM
Write-Host "🔄 Paso 5: Reiniciando servicio WinRM..." -ForegroundColor Yellow
Restart-Service WinRM
Write-Host "✅ Servicio reiniciado" -ForegroundColor Green
Write-Host ""

# Paso 6: Verificar configuración
Write-Host "✅ Paso 6: Verificación final..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Estado del servicio WinRM:" -ForegroundColor Cyan
Get-Service WinRM | Select-Object Name, Status, StartType | Format-Table
Write-Host ""

Write-Host "TrustedHosts configurados:" -ForegroundColor Cyan
$trustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
Write-Host "  $trustedHosts" -ForegroundColor White
Write-Host ""

# Paso 7: Probar conexión (opcional)
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ¿Deseas probar la conexión al servidor?" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
$testConnection = Read-Host "¿Probar conexión? [S/N]"

if ($testConnection -eq "S" -or $testConnection -eq "s") {
    $serverIP = Read-Host "Ingresa la IP del servidor"
    
    Write-Host ""
    Write-Host "🧪 Probando conexión básica a $serverIP..." -ForegroundColor Yellow
    
    try {
        Test-WSMan -ComputerName $serverIP -ErrorAction Stop
        Write-Host "✅ ¡Conexión exitosa!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Ahora puedes conectarte con:" -ForegroundColor Cyan
        Write-Host "  Enter-PSSession -ComputerName $serverIP -Credential (Get-Credential)" -ForegroundColor White
    }
    catch {
        Write-Host "❌ No se pudo conectar" -ForegroundColor Red
        Write-Host ""
        Write-Host "Posibles causas:" -ForegroundColor Yellow
        Write-Host "  - El servidor no tiene WinRM habilitado" -ForegroundColor White
        Write-Host "  - El firewall del servidor bloquea el puerto 5985" -ForegroundColor White
        Write-Host "  - La IP es incorrecta o el servidor está apagado" -ForegroundColor White
        Write-Host ""
        Write-Host "Verifica que en el SERVIDOR hayas ejecutado:" -ForegroundColor Cyan
        Write-Host "  Enable-PSRemoting -Force" -ForegroundColor White
        Write-Host "  Enable-NetFirewallRule -Name 'WINRM-HTTP-In-TCP'" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  🎉 Configuración completada" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
