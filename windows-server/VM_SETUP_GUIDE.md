# Guía de Configuración para VM Windows Server

## 🎯 Objetivo
Configurar PowerShell Remoting en tu VM Windows Server para administración remota desde Antigravity.

---

## 📋 Transferir el Script a la VM

### **Método 1: Copiar/Pegar (Más Simple)**

1. **En tu VM Windows Server:**
   - Abre PowerShell como **Administrador**
   - Ejecuta estos comandos:

```powershell
# Crear la carpeta para el script
New-Item -ItemType Directory -Path "C:\Setup" -Force

# Crear el archivo del script
notepad C:\Setup\configure-winrm.ps1
```

2. **Copia y pega este contenido en el Notepad:**

```powershell
# Configuración de WinRM para VM Windows Server
Write-Host "Configurando WinRM..." -ForegroundColor Cyan

# 1. Verificar y cambiar red a Privada si es necesaria
$network = Get-NetConnectionProfile
if ($network.NetworkCategory -eq "Public") {
    Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue
}

# 2. Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# 3. Configurar TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# 4. Configurar Firewall
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue
New-NetFirewallRule -Name "WinRM-Custom" -DisplayName "WinRM HTTP" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -ErrorAction SilentlyContinue

# 5. Reiniciar servicio
Restart-Service WinRM

# 6. Verificar
Write-Host "`nEstado del servicio WinRM:" -ForegroundColor Green
Get-Service WinRM | Format-Table -AutoSize

Write-Host "`nIP del servidor:" -ForegroundColor Green
(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress

Write-Host "`nConfiguración completada!" -ForegroundColor Green
```

3. **Guarda el archivo** (Ctrl+S) y cierra Notepad

4. **Ejecuta el script:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\Setup\configure-winrm.ps1
```

---

### **Método 2: Carpeta Compartida (Si ya tienes Guest Additions)**

Si tienes VirtualBox/VMware Guest Additions instalado:

1. **En VirtualBox/VMware:**
   - Configuración de la VM → Carpetas compartidas
   - Agregar carpeta compartida: `C:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager\windows-server`

2. **En la VM:**
   - La carpeta compartida aparecerá en "Red" o como unidad Z:
   - Navega a ella y ejecuta: `.\server-setup-commands.ps1`

---

### **Método 3: Comando Manual Directo**

Si prefieres, simplemente copia y pega **estos 5 comandos** uno por uno en PowerShell (Admin) de la VM:

```powershell
# 1. Cambiar red a Privada (si es necesario)
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue

# 2. Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# 3. Configurar TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# 4. Habilitar Firewall
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# 5. Reiniciar servicio
Restart-Service WinRM
```

---

## 🧪 Probar la Conexión

### **En la VM, obtén la IP:**
```powershell
ipconfig
# Anota la IPv4 (probablemente 10.0.2.15)
```

### **En tu PC local, prueba la conexión:**
```powershell
Test-WSMan -ComputerName 10.0.2.15
```

### **Si funciona, conéctate:**
```powershell
Enter-PSSession -ComputerName 10.0.2.15 -Credential (Get-Credential)
```

---

## 🚨 Troubleshooting para VM

### **Error de conexión - Configuración de Red de VirtualBox**

Si no puedes conectarte, verifica la configuración de red de la VM:

#### **Red NAT (Actual - 10.0.2.15):**
Necesitas configurar **Port Forwarding**:
1. VirtualBox → Configuración de VM → Red
2. Avanzado → Reenvío de puertos
3. Agregar regla:
   - Nombre: WinRM
   - Protocolo: TCP
   - Puerto anfitrión: 5985
   - Puerto invitado: 5985

Luego conéctate usando:
```powershell
Test-WSMan -ComputerName localhost -Port 5985
Enter-PSSession -ComputerName localhost -Port 5985 -Credential (Get-Credential)
```

#### **Red Adaptador Puente (Recomendado):**
Cambia a "Adaptador puente" para que la VM tenga IP en tu red local:
1. Apaga la VM
2. VirtualBox → Configuración → Red
3. Conectado a: **Adaptador puente**
4. Enciende la VM
5. En la VM, ejecuta `ipconfig` para ver la nueva IP (ej: 192.168.1.xxx)
6. Usa esa nueva IP para conectarte desde tu PC

---

## ✅ Verificación Final

Una vez configurado, deberías poder:

✅ Ver el servicio WinRM corriendo en la VM  
✅ Conectarte desde tu PC local con `Test-WSMan`  
✅ Establecer una sesión remota con `Enter-PSSession`  
✅ Administrar la VM completamente desde Antigravity  

---

## 🎯 Próximos Pasos Después de la Conexión

Una vez que la conexión funcione, podemos:
1. Instalar IIS en la VM
2. Configurar PM2 para Node.js
3. Hacer deployment del proyecto
4. Configurar dominio y SSL
5. Automatizar todo el proceso
