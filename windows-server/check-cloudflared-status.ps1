$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    Write-Host "Verificando procesos y logs..." -ForegroundColor Cyan
    
    # Ver procesos cloudflared
    $processes = Get-Process -Name cloudflared -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "Cloudflared corriendo (PID: $($processes.Id -join ', '))" -ForegroundColor Green
    }
    else {
        Write-Host "Cloudflared NO esta corriendo" -ForegroundColor Red
    }
    
    # Leer el archivo de log
    $logFile = "C:\inetpub\wwwroot\motopartes-manager\logs\cloudflared-output.txt"
    Write-Host "`nContenido de $logFile:" -ForegroundColor Yellow
    if (Test-Path $logFile) {
        Get-Content $logFile
    }
    else {
        Write-Host "Archivo no existe" -ForegroundColor Red
    }
    
    # Ver todos los archivos en el directorio de logs
    Write-Host "`nArchivos en directorio logs:" -ForegroundColor Yellow
    Get-ChildItem "C:\inetpub\wwwroot\motopartes-manager\logs" -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime
}
