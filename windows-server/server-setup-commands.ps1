# ====================================================================
# Comandos para EJECUTAR EN EL SERVIDOR (10.0.2.15)
# ====================================================================
# 
# Instrucciones:
# 1. Conéctate al servidor vía RDP
# 2. Abre PowerShell como Administrador
# 3. Copia y pega estos comandos UNO POR UNO
#
# ====================================================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Configuración de WinRM en el Servidor" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Verificar perfil de red
Write-Host "📡 Paso 1: Verificando perfil de red..." -ForegroundColor Yellow
$networkProfile = Get-NetConnectionProfile
Write-Host "Nombre de red: $($networkProfile.Name)" -ForegroundColor White
Write-Host "Categoría: $($networkProfile.NetworkCategory)" -ForegroundColor White
Write-Host ""

# Si la red es Pública, cambiar a Privada
if ($networkProfile.NetworkCategory -eq "Public") {
    Write-Host "⚠️  La red es Pública. Cambiando a Privada..." -ForegroundColor Yellow
    try {
        Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction Stop
        Write-Host "✅ Red cambiada a Privada" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ No se pudo cambiar automáticamente. Cámbiala manualmente:" -ForegroundColor Red
        Write-Host "   Win + I → Red e Internet → Cambiar a Privada" -ForegroundColor Yellow
        Read-Host "Presiona Enter después de cambiarla..."
    }
}
else {
    Write-Host "✅ Red ya está en modo Privado" -ForegroundColor Green
}
Write-Host ""

# Paso 2: Habilitar PowerShell Remoting
Write-Host "🚀 Paso 2: Habilitando PowerShell Remoting..." -ForegroundColor Yellow
try {
    Enable-PSRemoting -Force -ErrorAction Stop
    Write-Host "✅ PowerShell Remoting habilitado" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Paso 3: Configurar TrustedHosts
Write-Host "🔐 Paso 3: Configurando hosts confiables..." -ForegroundColor Yellow
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
Write-Host "✅ TrustedHosts configurado" -ForegroundColor Green
Write-Host ""

# Paso 4: Configurar Firewall
Write-Host "🔥 Paso 4: Configurando reglas de firewall..." -ForegroundColor Yellow
try {
    # Habilitar regla predeterminada de WinRM
    Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue
    
    # Crear regla personalizada si no existe
    $existingRule = Get-NetFirewallRule -Name "WinRM-Custom-HTTP" -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        New-NetFirewallRule -Name "WinRM-Custom-HTTP" `
            -DisplayName "Windows Remote Management (HTTP-In) - Custom" `
            -Enabled True `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort 5985 `
            -Action Allow | Out-Null
        Write-Host "✅ Regla de firewall personalizada creada" -ForegroundColor Green
    }
    else {
        Write-Host "✅ Regla de firewall ya existe" -ForegroundColor Green
    }
}
catch {
    Write-Host "⚠️  Advertencia al configurar firewall: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# Paso 5: Reiniciar servicio WinRM
Write-Host "🔄 Paso 5: Reiniciando servicio WinRM..." -ForegroundColor Yellow
Restart-Service WinRM
Write-Host "✅ Servicio reiniciado" -ForegroundColor Green
Write-Host ""

# Paso 6: Verificación final
Write-Host "✅ Paso 6: Verificación final..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Estado del servicio WinRM:" -ForegroundColor Cyan
Get-Service WinRM | Select-Object Name, Status, StartType | Format-Table

Write-Host "Configuración de WinRM:" -ForegroundColor Cyan
winrm get winrm/config/service

Write-Host ""
Write-Host "Reglas de firewall activas:" -ForegroundColor Cyan
Get-NetFirewallRule -Name "*WinRM*" | Where-Object { $_.Enabled -eq $true } | Select-Object Name, DisplayName, Enabled | Format-Table

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  🎉 Configuración del servidor completada" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora desde tu PC local puedes ejecutar:" -ForegroundColor Cyan
Write-Host "  Test-WSMan -ComputerName $(hostname)" -ForegroundColor White
Write-Host "  Enter-PSSession -ComputerName $(hostname) -Credential (Get-Credential)" -ForegroundColor White
Write-Host ""
