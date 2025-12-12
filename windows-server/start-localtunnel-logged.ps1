# Script para iniciar localtunnel con logging
$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Write-Host "🚀 Iniciando Localtunnel en el servidor..." -ForegroundColor Cyan

Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    # Detener procesos anteriores de localtunnel
    Get-Process | Where-Object { $_.ProcessName -eq "node" } | ForEach-Object {
        $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
        if ($cmdLine -like "*localtunnel*") {
            Write-Host "Deteniendo proceso anterior: $($_.Id)" -ForegroundColor Yellow
            Stop-Process -Id $_.Id -Force
        }
    }
    
    Start-Sleep -Seconds 2
    
    # Cambiar al directorio del proyecto
    Set-Location "C:\inetpub\wwwroot\motopartes-manager"
    
    # Iniciar localtunnel en background y capturar output
    $logFile = "C:\inetpub\wwwroot\motopartes-manager\localtunnel-output.txt"
    
    Write-Host "Iniciando localtunnel..." -ForegroundColor Green
    Write-Host "El output se guardará en: $logFile" -ForegroundColor Cyan
    
    # Iniciar el proceso en background
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c npx localtunnel --port 80 > $logFile 2>&1" -WindowStyle Hidden
    
    Write-Host "⏳ Esperando 10 segundos para que se genere la URL..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Leer el archivo de output
    if (Test-Path $logFile) {
        Write-Host "`n📄 OUTPUT DE LOCALTUNNEL:" -ForegroundColor Green
        Write-Host "================================" -ForegroundColor Green
        Get-Content $logFile
        Write-Host "================================" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️ El archivo de log aún no se ha creado" -ForegroundColor Red
    }
}

Write-Host "`n✅ Proceso completado. Revisa el output arriba para la URL." -ForegroundColor Green
