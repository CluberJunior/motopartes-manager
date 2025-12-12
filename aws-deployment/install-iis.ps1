# Instalacion de IIS en AWS EC2
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Instalacion de IIS en AWS EC2" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Crear credenciales
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Write-Host "`nConectando al servidor..." -ForegroundColor Yellow

Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
    Write-Host "`n[SERVIDOR] Instalando IIS y componentes..." -ForegroundColor Cyan
    
    # Instalar IIS con todas las características necesarias
    $features = @(
        "Web-Server",
        "Web-WebServer",
        "Web-Common-Http",
        "Web-Default-Doc",
        "Web-Dir-Browsing",
        "Web-Http-Errors",
        "Web-Static-Content",
        "Web-Health",
        "Web-Http-Logging",
        "Web-Performance",
        "Web-Stat-Compression",
        "Web-Dyn-Compression",
        "Web-Security",
        "Web-Filtering",
        "Web-App-Dev",
        "Web-Net-Ext45",
        "Web-Asp-Net45",
        "Web-ISAPI-Ext",
        "Web-ISAPI-Filter",
        "Web-WebSockets",
        "Web-Mgmt-Tools",
        "Web-Mgmt-Console"
    )
    
    foreach ($feature in $features) {
        Write-Host "  Instalando $feature..." -ForegroundColor Gray
        Install-WindowsFeature -Name $feature -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Host "`n[SERVIDOR] Instalando URL Rewrite y ARR..." -ForegroundColor Cyan
    
    # Crear directorio temporal
    $tempDir = "C:\Temp"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    # Descargar URL Rewrite
    Write-Host "  Descargando URL Rewrite..." -ForegroundColor Gray
    $urlRewriteUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
    $urlRewritePath = "$tempDir\urlrewrite.msi"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $urlRewriteUrl -OutFile $urlRewritePath -UseBasicParsing -ErrorAction Stop
        Start-Process msiexec.exe -ArgumentList "/i $urlRewritePath /quiet /norestart" -Wait
        Write-Host "  URL Rewrite instalado" -ForegroundColor Green
    }
    catch {
        Write-Host "  Advertencia: No se pudo instalar URL Rewrite: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Configurar firewall
    Write-Host "`n[SERVIDOR] Configurando firewall..." -ForegroundColor Cyan
    New-NetFirewallRule -DisplayName "HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
    New-NetFirewallRule -DisplayName "HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  Firewall configurado (puertos 80, 443)" -ForegroundColor Green
    
    # Crear directorios de aplicacion
    Write-Host "`n[SERVIDOR] Creando directorios..." -ForegroundColor Cyan
    $appDir = "C:\inetpub\wwwroot\motopartes-manager"
    if (-not (Test-Path $appDir)) {
        New-Item -ItemType Directory -Path $appDir -Force | Out-Null
        Write-Host "  Directorio creado: $appDir" -ForegroundColor Green
    }
    
    # Verificar instalacion
    Write-Host "`n[SERVIDOR] Verificando instalacion..." -ForegroundColor Cyan
    $w3svc = Get-Service W3SVC -ErrorAction SilentlyContinue
    if ($w3svc) {
        if ($w3svc.Status -ne "Running") {
            Start-Service W3SVC
        }
        Write-Host "  IIS corriendo correctamente" -ForegroundColor Green
    }
    else {
        Write-Host "  ERROR: IIS no se instalo correctamente" -ForegroundColor Red
    }
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  IIS Instalado Exitosamente" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
