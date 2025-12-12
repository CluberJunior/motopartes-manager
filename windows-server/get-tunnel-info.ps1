# Script para obtener información del túnel localtunnel
$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Write-Host "🔍 Conectando al servidor 192.168.1.104..." -ForegroundColor Cyan

# Buscar procesos de Node.js
Write-Host "`n📊 Procesos Node.js corriendo:" -ForegroundColor Yellow
Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    Get-Process | Where-Object { $_.ProcessName -eq "node" } | Select-Object Id, ProcessName, StartTime
}

# Intentar leer el archivo de log si existe
Write-Host "`n📄 Buscando logs de localtunnel:" -ForegroundColor Yellow
Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    $possiblePaths = @(
        "C:\inetpub\wwwroot\motopartes-manager\localtunnel.log",
        "C:\Users\Administrador\localtunnel.log",
        "C:\Windows\Temp\localtunnel.log"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Host "Encontrado: $path" -ForegroundColor Green
            Get-Content $path -Tail 30
            return
        }
    }
    
    Write-Host "No se encontraron archivos de log" -ForegroundColor Red
}

Write-Host "`n✅ Conexión completada" -ForegroundColor Green
