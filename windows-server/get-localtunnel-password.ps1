# Script para obtener la contraseña de localtunnel
$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Write-Host "🔍 Buscando contraseña del túnel localtunnel..." -ForegroundColor Cyan

Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    Write-Host "`n📄 Leyendo output de localtunnel:" -ForegroundColor Yellow
    
    $logFile = "C:\inetpub\wwwroot\motopartes-manager\localtunnel-output.txt"
    
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Raw
        Write-Host $content
        
        # Buscar específicamente la línea con "password" o "IP"
        $lines = Get-Content $logFile
        $passwordLine = $lines | Where-Object { $_ -match "password|your tunnel password|IP whitelisting" }
        
        if ($passwordLine) {
            Write-Host "`n🔑 INFORMACIÓN DE ACCESO:" -ForegroundColor Green
            Write-Host "================================" -ForegroundColor Green
            $passwordLine | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
            Write-Host "================================" -ForegroundColor Green
        }
    }
    else {
        Write-Host "❌ No se encontró el archivo de log" -ForegroundColor Red
    }
    
    # También buscar en la IP pública asignada
    Write-Host "`n🌐 Verificando túnel activo:" -ForegroundColor Cyan
    $processes = Get-Process | Where-Object { $_.ProcessName -eq "node" }
    if ($processes) {
        Write-Host "✅ Localtunnel está corriendo (Proceso ID: $($processes.Id -join ', '))" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ No se encontró proceso de Node.js activo" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Búsqueda completada" -ForegroundColor Green
