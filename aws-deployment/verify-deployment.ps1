# Verificar estado actual del servidor y corregir deployment
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "Verificando estado actual del servidor..." -ForegroundColor Cyan

$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
    Write-Host "`n[VERIFICACION] Estado actual:" -ForegroundColor Yellow
    
    # Verificar IIS
    $iis = Get-Service W3SVC
    Write-Host "  IIS: $($iis.Status)" -ForegroundColor $(if ($iis.Status -eq 'Running') { 'Green' } else { 'Red' })
    
    # Verificar sitios web
    Import-Module WebAdministration
    $sites = Get-WebSite
    Write-Host "`n  Sitios web:" -ForegroundColor Yellow
    $sites | ForEach-Object {
        Write-Host "    - $($_.Name): $($_.State) (Puerto $($_.bindings.Collection[0].bindingInformation))" -ForegroundColor White
    }
    
    # Verificar directorio de aplicacion
    $appDir = "C:\inetpub\wwwroot\motopartes-manager"
    if (Test-Path $appDir) {
        $files = Get-ChildItem $appDir
        Write-Host "`n  Directorio de aplicacion ($appDir):" -ForegroundColor Yellow
        Write-Host "    Archivos/carpetas: $($files.Count)" -ForegroundColor White
        
        if (Test-Path "$appDir\package.json") {
            Write-Host "    package.json: Existe" -ForegroundColor Green
        }
        else {
            Write-Host "    package.json: NO existe" -ForegroundColor Red
        }
        
        if (Test-Path "$appDir\dist") {
            $distFiles = Get-ChildItem "$appDir\dist"
            Write-Host "    dist/: Existe ($($distFiles.Count) archivos)" -ForegroundColor Green
        }
        else {
            Write-Host "    dist/: NO existe" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`n  Directorio de aplicacion: NO existe" -ForegroundColor Red
    }
    
    # Verificar PM2
    $env:Path = "C:\Program Files\nodejs;$env:Path"
    $pm2Path = "C:\Users\Administrator\AppData\Roaming\npm\pm2.cmd"
    if (Test-Path $pm2Path) {
        Write-Host "`n  Procesos PM2:" -ForegroundColor Yellow
        & $pm2Path list 2>&1 | Write-Host
    }
    
    # Verificar Node.js
    $nodeVersion = & "C:\Program Files\nodejs\node.exe" --version 2>&1
    Write-Host "`n  Node.js: $nodeVersion" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
