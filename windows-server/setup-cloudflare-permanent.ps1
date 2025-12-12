$securePass = ConvertTo-SecureString "Jomoponse_1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("Administrador", $securePass)

Write-Host "Configurando Cloudflare Tunnel permanente..." -ForegroundColor Cyan

Invoke-Command -ComputerName 192.168.1.104 -Credential $cred -ScriptBlock {
    # Detener procesos anteriores
    Get-Process | Where-Object { $_.ProcessName -like "*cloudflared*" -or ($_.ProcessName -eq "node") } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 2
    
    # Crear directorio para logs
    $logDir = "C:\inetpub\wwwroot\motopartes-manager\logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Iniciar cloudflared con output redirigido
    $logFile = "$logDir\cloudflared-output.txt"
    Write-Host "Iniciando Cloudflare Tunnel..." -ForegroundColor Green
    Write-Host "Log: $logFile" -ForegroundColor Yellow
    
    # Iniciar en background
    $process = Start-Process -FilePath "C:\Program Files\cloudflared\cloudflared.exe" `
        -ArgumentList "tunnel --url http://localhost:80" `
        -WindowStyle Hidden `
        -RedirectStandardOutput $logFile `
        -PassThru
    
    Write-Host "Proceso iniciado (PID: $($process.Id))" -ForegroundColor Green
    Write-Host "Esperando 15 segundos para que se genere la URL..." -ForegroundColor Yellow
    
    Start-Sleep -Seconds 15
    
    # Leer el archivo de log
    if (Test-Path $logFile) {
        $content = Get-Content $logFile -Raw
        Write-Host "`n=== OUTPUT DE CLOUDFLARE TUNNEL ===" -ForegroundColor Green
        Write-Host $content
        Write-Host "===================================" -ForegroundColor Green
        
        # Buscar la URL específicamente
        $urlMatch = $content | Select-String -Pattern "https://[a-z0-9-]+\.trycloudflare\.com" -AllMatches
        if ($urlMatch) {
            Write-Host "`n URL PUBLICA ENCONTRADA:" -ForegroundColor Cyan
            $urlMatch.Matches | ForEach-Object {
                Write-Host $_.Value -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "ERROR: No se creo el archivo de log" -ForegroundColor Red
    }
}

Write-Host "`nProceso completado" -ForegroundColor Green
