# Test de Conexion a AWS EC2 - Version Corregida
$serverDNS = "ec2-18-219-228-50.us-east-2.compute.amazonaws.com"
$username = "Administrator"
$password = "KMu)YTrWnn(ssYs)EkhR3YUYc*vex?g3"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Test de Conexion AWS EC2" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Configurar TrustedHosts si es necesario
Write-Host "`nConfigurando TrustedHosts..." -ForegroundColor Yellow
try {
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $serverDNS -Force -Concatenate -ErrorAction SilentlyContinue
    Write-Host "   TrustedHosts configurado" -ForegroundColor Green
}
catch {
    Write-Host "   Advertencia: No se pudo configurar TrustedHosts" -ForegroundColor Yellow
}

Write-Host "`nServidor: $serverDNS" -ForegroundColor Yellow

# Crear credenciales
$securePass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $securePass)

# Opciones de sesion
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Test 1: Conectividad basica
Write-Host "`n1. Probando conectividad WinRM..." -ForegroundColor Cyan
try {
    $result = Test-WSMan -ComputerName $serverDNS -Authentication Default -ErrorAction Stop
    Write-Host "   OK - WinRM accesible" -ForegroundColor Green
}
catch {
    Write-Host "   ERROR - No se puede conectar: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Crear sesion remota
Write-Host "`n2. Creando sesion remota..." -ForegroundColor Cyan
try {
    $session = New-PSSession -ComputerName $serverDNS -Credential $cred -SessionOption $sessionOption -ErrorAction Stop
    Write-Host "   OK - Sesion creada" -ForegroundColor Green
    
    # Test 3: Ejecutar comando basico
    Write-Host "`n3. Probando ejecucion de comandos..." -ForegroundColor Cyan
    $hostname = Invoke-Command -Session $session -ScriptBlock {
        $env:COMPUTERNAME
    }
    Write-Host "   OK - Nombre del servidor: $hostname" -ForegroundColor Green
    
    # Test 4: Verificar permisos de administrador
    Write-Host "`n4. Verificando permisos de administrador..." -ForegroundColor Cyan
    $isAdmin = Invoke-Command -Session $session -ScriptBlock {
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    
    if ($isAdmin) {
        Write-Host "   OK - Permisos de administrador confirmados" -ForegroundColor Green
    }
    else {
        Write-Host "   ERROR - No tienes permisos de administrador" -ForegroundColor Red
        Remove-PSSession -Session $session
        exit 1
    }
    
    # Test 5: Informacion del sistema
    Write-Host "`n5. Informacion del sistema:" -ForegroundColor Cyan
    Invoke-Command -Session $session -ScriptBlock {
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        Write-Host "   OS: $($os.Caption)" -ForegroundColor White
        Write-Host "   Version: $($os.Version)" -ForegroundColor White
        Write-Host "   Arquitectura: $($os.OSArchitecture)" -ForegroundColor White
        Write-Host "   CPU: $($cpu.Name)" -ForegroundColor White
        Write-Host "   Cores: $($cpu.NumberOfCores)" -ForegroundColor White
    }
    
    # Cerrar sesion
    Remove-PSSession -Session $session
    
}
catch {
    Write-Host "   ERROR - No se puede crear sesion: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host "  Conexion Exitosa!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "`nEl servidor esta listo para deployment" -ForegroundColor Yellow
