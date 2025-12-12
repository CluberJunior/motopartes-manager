# Test de Conexion AWS EC2 - Metodo Directo
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Test AWS EC2 - Metodo Directo" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Crear credenciales
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

Write-Host "`nIntentando conexion directa..." -ForegroundColor Yellow

try {
    # Intentar conexion simple
    $result = Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
        $env:COMPUTERNAME
    } -ErrorAction Stop
    
    Write-Host "OK - Conectado al servidor: $result" -ForegroundColor Green
    
    # Obtener informacion del sistema
    Write-Host "`nObteniendo informacion del sistema..." -ForegroundColor Cyan
    Invoke-Command -ComputerName $serverDNS -Credential $cred -ScriptBlock {
        $os = Get-CimInstance Win32_OperatingSystem
        Write-Host "  OS: $($os.Caption)" -ForegroundColor White
        Write-Host "  Version: $($os.Version)" -ForegroundColor White
        
        # Verificar IIS
        $iis = Get-Service W3SVC -ErrorAction SilentlyContinue
        if ($iis) {
            Write-Host "  IIS: Instalado ($($iis.Status))" -ForegroundColor White
        }
        else {
            Write-Host "  IIS: No instalado" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n=====================================" -ForegroundColor Green
    Write-Host "  Conexion Exitosa!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nDetalles del error:" -ForegroundColor Yellow
    Write-Host $_.Exception.GetType().FullName -ForegroundColor Gray
    
    if ($_.Exception.Message -like "*Acceso denegado*") {
        Write-Host "`nPosibles causas:" -ForegroundColor Yellow
        Write-Host "1. Las credenciales son incorrectas" -ForegroundColor White
        Write-Host "2. WinRM no esta configurado correctamente en el servidor" -ForegroundColor White
        Write-Host "3. El firewall del servidor bloquea la conexion" -ForegroundColor White
    }
    
    exit 1
}
