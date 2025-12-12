# Guía para Configurar Servidor Físico y Acceso Remoto para Antigravity

## 🎯 Objetivo

Cuando tengas tu **servidor físico Windows Server**, sigue estas instrucciones para configurarlo y permitir que Antigravity (yo) pueda conectarme remotamente para hacer deployment.

---

## 📋 Prerequisitos del Servidor Físico

Antes de empezar, asegúrate de tener:

- ✅ **Windows Server instalado** (cualquier versión 2016+)
- ✅ **Conexión a Internet** estable
- ✅ **Usuario Administrador** con contraseña
- ✅ **Conectado a tu red local** (mismo router que tu PC)

---

## 🔧 Parte 1: Configuración Inicial del Servidor (Tu Haces Esto)

### **Paso 1: Anotar Información del Servidor**

En el servidor físico, abre PowerShell como Administrador y ejecuta:

```powershell
# Obtener IP del servidor
ipconfig | Select-String "IPv4"

# Obtener nombre del servidor
hostname

# Verificar usuario administrador
whoami
```

**Anota esta información:**
- IP del servidor: `___________________`
- Nombre del servidor: `___________________`
- Usuario administrador: `___________________`
- Contraseña: `___________________`

---

### **Paso 2: Habilitar PowerShell Remoting en el Servidor**

En el servidor físico, ejecuta:

```powershell
# Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# Configurar TrustedHosts para aceptar conexiones
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Reiniciar servicio WinRM
Restart-Service WinRM

# Verificar estado
Get-Service WinRM
```

---

### **Paso 3: Configurar Firewall del Servidor**

```powershell
# Habilitar regla de firewall para WinRM
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# Verificar que el puerto 5985 esté abierto
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Select-Object Name, Enabled
```

---

### **Paso 4: Configurar Red como Privada (Importante)**

```powershell
# Ver perfil de red actual
Get-NetConnectionProfile

# Si sale "Public", cambiarlo a "Private" (requerido para WinRM)
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private

# Verificar cambio
Get-NetConnectionProfile
```

**Nota**: Cambia `"Ethernet"` por el nombre de tu adaptador de red si es diferente.

---

### **Paso 5: Probar Conexión Local**

En el servidor, verifica que WinRM funciona:

```powershell
Test-WSMan -ComputerName localhost
```

Si ves información XML, **está funcionando correctamente** ✅

---

## 💻 Parte 2: Configuración en Tu PC (Tu Haces Esto)

### **Paso 1: Habilitar PowerShell Remoting en tu PC**

En tu PC (Windows 11), abre PowerShell como Administrador:

```powershell
# Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# Configurar TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Reiniciar servicio
Restart-Service WinRM
```

---

### **Paso 2: Probar Conexión desde Tu PC al Servidor**

```powershell
# Reemplaza 192.168.1.XXX con la IP real de tu servidor
Test-WSMan -ComputerName 192.168.1.XXX
```

Si funciona, verás información XML ✅

---

### **Paso 3: Probar Sesión Remota**

```powershell
# Crear credenciales
$serverIP = "192.168.1.XXX"  # Reemplaza con IP del servidor
$cred = Get-Credential  # Ingresa usuario y contraseña del servidor

# Probar conexión
Enter-PSSession -ComputerName $serverIP -Credential $cred

# Si funciona, verás el prompt cambiar a [SERVIDOR-IP]: PS C:\Users\...
# Para salir: Exit-PSSession
```

---

## 🤖 Parte 3: Cómo Pedirme Ayuda (Qué Decirme)

Cuando tengas el servidor físico configurado, inicia una conversación con Antigravity y dime:

### **Mensaje Sugerido:**

```
Tengo mi servidor físico configurado y listo. Necesito que te conectes 
remotamente y hagas el deployment de [NOMBRE_PROYECTO].

Información del servidor:
- IP: 192.168.1.XXX
- Usuario: Administrador
- Contraseña: [TU_PASSWORD]
- Sistema: Windows Server 2022

PowerShell Remoting ya está habilitado y probado.

¿Puedes conectarte y hacer el deployment completo?
```

---

## 🚀 Parte 4: Lo Que Yo Haré (Antigravity)

Cuando me des esa información, automáticamente:

1. **Me conectaré remotamente** al servidor usando PowerShell Remoting
2. **Instalaré todo lo necesario**:
   - IIS (servidor web)
   - Node.js (si es necesario)
   - PM2 (gestor de procesos)
   - Git (si es necesario)
3. **Clonaré o transferiré tu proyecto**
4. **Compilaré el frontend**
5. **Configuraré el backend**
6. **Iniciaré servicios con PM2**
7. **Configuraré IIS**
8. **Configuraré firewall**
9. **Te daré la URL para acceder**

Todo de forma **completamente automática y remota** 🎉

---

## 📝 Script Rápido de Verificación (Para el Servidor)

Guarda este script en el servidor como `verify-remote-access.ps1`:

```powershell
# Script de verificación rápida
Write-Host "=== Verificación de Acceso Remoto ===" -ForegroundColor Cyan

# 1. IP del servidor
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress
Write-Host "IP del servidor: $ip" -ForegroundColor Green

# 2. Nombre del servidor
Write-Host "Nombre: $env:COMPUTERNAME" -ForegroundColor Green

# 3. WinRM Status
$winrm = Get-Service WinRM
Write-Host "WinRM: $($winrm.Status)" -ForegroundColor $(if($winrm.Status -eq "Running"){"Green"}else{"Red"})

# 4. Firewall
$fw = Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue
Write-Host "Firewall WinRM: $(if($fw.Enabled){'Enabled'}else{'Disabled'})" -ForegroundColor $(if($fw.Enabled){"Green"}else{"Red"})

# 5. Network Profile
$profile = Get-NetConnectionProfile
Write-Host "Perfil de red: $($profile.NetworkCategory)" -ForegroundColor $(if($profile.NetworkCategory -eq "Private"){"Green"}else{"Yellow"})

# 6. Test local
try {
    Test-WSMan -ComputerName localhost -ErrorAction Stop | Out-Null
    Write-Host "Test WSMan: OK" -ForegroundColor Green
} catch {
    Write-Host "Test WSMan: FAILED" -ForegroundColor Red
}

Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
Write-Host "Si todo está en verde, el servidor está listo para acceso remoto!" -ForegroundColor White
Write-Host "`nComparte esta información con Antigravity:" -ForegroundColor Yellow
Write-Host "- IP: $ip"
Write-Host "- Usuario: $env:USERNAME"
Write-Host "- Password: [TU_PASSWORD]"
```

Ejecuta este script antes de pedirme ayuda para asegurarte de que todo está listo.

---

## ⚠️ Troubleshooting Común

### **Problema: "Access Denied" al conectar**
**Solución**: Verifica que el perfil de red sea "Private", no "Public"

### **Problema: "Cannot connect to remote server"**
**Solución**: 
1. Verifica que ambas máquinas estén en la misma red
2. Ping al servidor: `ping 192.168.1.XXX`
3. Verifica firewall de Windows

### **Problema: "TrustedHosts configuration"**
**Solución**: Ejecuta en tu PC:
```powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
```

---

## 🔒 Seguridad

**Para producción**, considera:

1. **Cambiar TrustedHosts** de `*` a la IP específica:
   ```powershell
   Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.XXX" -Force
   ```

2. **Usar certificados SSL** para PowerShell Remoting

3. **Crear usuario específico** para deployment (no usar Administrador principal)

4. **Habilitar WinRM solo cuando necesites** deployment

---

## ✅ Checklist Final Antes de Contactarme

Antes de pedirme que haga el deployment, verifica:

- [ ] Servidor físico encendido y conectado a la red
- [ ] PowerShell Remoting habilitado (`Enable-PSRemoting`)
- [ ] WinRM corriendo (`Get-Service WinRM`)
- [ ] Firewall configurado (puerto 5985 abierto)
- [ ] Perfil de red en "Private"
- [ ] Script de verificación ejecutado sin errores
- [ ] Puedes conectarte manualmente desde tu PC (`Enter-PSSession`)
- [ ] Tienes la información lista (IP, usuario, password)

---

## 🎯 Ejemplo de Conversación Completa

**TÚ:**
```
Hola Antigravity, tengo mi servidor físico listo.
IP: 192.168.1.150
Usuario: Administrador  
Password: MiPassword123
Sistema: Windows Server 2022

Ya habilité PowerShell Remoting y verifiqué la conexión.
Necesito deployment de MotoPartes Manager.
```

**YO (Antigravity):**
```
¡Perfecto! Me estoy conectando al servidor...
[Ejecuto comandos remotamente]
✅ IIS instalado
✅ Node.js instalado
✅ Proyecto desplegado
✅ Servicios iniciados

Tu aplicación está disponible en: http://192.168.1.150
¿Quieres que configure también Cloudflare Tunnel para acceso desde Internet?
```

---

¡Con esta guía, tu servidor físico estará listo para que yo pueda conectarme y hacer todo el deployment de forma remota y automática! 🚀
