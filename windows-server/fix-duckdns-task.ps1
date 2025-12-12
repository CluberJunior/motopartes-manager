$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)
$serverIP = "192.168.1.104"

Write-Host "Corrigiendo tarea programada de DuckDNS..." -ForegroundColor Cyan

Invoke-Command -ComputerName $serverIP -Credential $cred -ScriptBlock {
    # Eliminar tarea existente
    Get-ScheduledTask -TaskName "DuckDNS Update" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
    
    # Crear tarea con configuracion corregida
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\DuckDNS\update-ip.ps1"
    
    # Trigger cada 5 minutos - corregido
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 5)
    
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 3)
    
    Register-ScheduledTask -TaskName "DuckDNS Update" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    
    Write-Host "Tarea programada corregida" -ForegroundColor Green
    
    # Verificar estado
    $task = Get-ScheduledTask -TaskName "DuckDNS Update"
    Write-Host "Estado de la tarea: $($task.State)" -ForegroundColor Yellow
    
    # Ejecutar manualmente para verificar
    Write-Host "`nEjecutando actualizacion manual..." -ForegroundColor Cyan
    & "C:\DuckDNS\update-ip.ps1"
    
    # Mostrar ultimas lineas del log
    Write-Host "`nUltimas lineas del log:" -ForegroundColor Cyan
    Get-Content "C:\DuckDNS\duckdns.log" -Tail 5
}

Write-Host "`nTarea programada corregida y funcionando" -ForegroundColor Green
