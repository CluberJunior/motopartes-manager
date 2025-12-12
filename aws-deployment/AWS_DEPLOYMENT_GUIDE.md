# 📋 Guía: Deployment en AWS EC2 - Información Requerida

Para conectarme remotamente a tu servidor AWS EC2 y desplegar todo el proyecto MotoPartes Manager, necesito que me proporciones la siguiente información paso a paso.

---

## 📍 Paso 1: Información del Servidor EC2

### Necesito saber:

**A. Tipo de instancia:**
- ¿Es Windows Server? (Debe ser Windows Server 2016/2019/2022)
- ¿Qué región de AWS? (ej: us-east-1, us-west-2)

**B. Acceso público:**
- **DNS público** del EC2 (ejemplo: `ec2-54-123-45-67.compute-1.amazonaws.com`)
- O **IP Pública Elástica** si tienes una asignada

**Dónde encontrarlo:**
1. Ve a la consola de AWS EC2
2. Selecciona tu instancia
3. En la pestaña "Details" verás:
   - **Public IPv4 DNS**
   - **Public IPv4 address**

📝 **Cópiame uno de estos dos valores**

---

## 🔐 Paso 2: Credenciales de Administrador

### Opción A: Si usas archivo .pem (clave SSH)

Si creaste la instancia con un par de claves (.pem):

1. **Descarga tu archivo .pem** (si no lo tienes ya)
2. **Obtén la contraseña de administrador:**
   - En la consola EC2, click derecho en tu instancia
   - "Get Windows Password"
   - Sube tu archivo .pem
   - AWS te dará la contraseña de administrador

📝 **Dame:**
- Usuario: (usualmente es "Administrator")
- Contraseña: (la que AWS generó)

### Opción B: Si ya configuraste una contraseña

Si ya cambiaste la contraseña del administrador:

📝 **Dame:**
- Usuario: `Administrator` (o el que uses)
- Contraseña: `tu-contraseña-actual`

---

## 🔒 Paso 3: Configurar Security Group

Para que pueda conectarme remotamente, necesitas abrir estos puertos en el Security Group:

### Puertos requeridos:

| Puerto | Protocolo | Propósito | Origen |
|--------|-----------|-----------|--------|
| **3389** | TCP | RDP (opcional) | Tu IP / 0.0.0.0/0 |
| **5985** | TCP | PowerShell Remoting | Tu IP / 0.0.0.0/0 |
| **80** | TCP | HTTP | 0.0.0.0/0 |
| **443** | TCP | HTTPS | 0.0.0.0/0 |

### Cómo configurarlo:

1. **Ve a la consola EC2**
2. **Selecciona tu instancia**
3. **En la pestaña "Security"**, click en el Security Group
4. **Edit inbound rules**
5. **Agrega estas reglas:**

```
Type: Custom TCP
Port Range: 5985
Source: 0.0.0.0/0 (o tu IP específica)
Description: PowerShell Remoting

Type: HTTP
Port Range: 80
Source: 0.0.0.0/0
Description: Web Access

Type: HTTPS
Port Range: 443
Source: 0.0.0.0/0
Description: Secure Web Access
```

✅ **Una vez hecho, confirma que está configurado**

---

## 🖥️ Paso 4: Habilitar PowerShell Remoting en el EC2

Necesito que ejecutes estos comandos **DENTRO del servidor EC2** (conectándote por RDP):

### Conéctate al EC2:

1. **Remote Desktop Protocol (RDP):**
   - Usa tu cliente RDP
   - Host: `[DNS-PUBLICO-DE-AWS]`
   - Usuario: `Administrator`
   - Contraseña: `[la que obtuviste]`

2. **Una vez dentro, abre PowerShell como Administrador**

3. **Ejecuta estos comandos:**

```powershell
# 1. Habilitar PowerShell Remoting
Enable-PSRemoting -Force

# 2. Configurar TrustedHosts (permite conexiones remotas)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# 3. Configurar firewall para WinRM
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# 4. Reiniciar servicio WinRM
Restart-Service WinRM

# 5. Verificar que está corriendo
Get-Service WinRM

# 6. Cambiar red a Privada (si es necesario)
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
```

✅ **Confirma que todos los comandos se ejecutaron sin errores**

---

## 📝 Paso 5: Información para GitHub (Repositorio)

Tu código está en GitHub. Necesito saber:

**¿El repositorio es público o privado?**

### Si es PRIVADO:

Necesitarás crear un **Personal Access Token** en GitHub:

1. Ve a GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Selecciona: `repo` (acceso completo)
4. Copia el token generado

📝 **Dame el token** (lo usaré para clonar el repo en el servidor)

### Si es PÚBLICO:

✅ No necesito token, solo la URL del repositorio

---

## ✅ Resumen: Qué Necesito de Ti

Para que yo pueda conectarme y hacer todo automáticamente, dame:

### 1️⃣ Información del Servidor
```
DNS Público: ec2-XX-XXX-XX-XX.compute-1.amazonaws.com
(o IP Pública: X.X.X.X)
```

### 2️⃣ Credenciales
```
Usuario: Administrator
Contraseña: XXXXX
```

### 3️⃣ Confirmaciones
- ✅ Security Group configurado (puertos 5985, 80, 443 abiertos)
- ✅ PowerShell Remoting habilitado en el EC2
- ✅ (Opcional) Token de GitHub si el repo es privado

---

## 🚀 ¿Qué Haré Yo Automáticamente?

Una vez que me des esa información, yo haré TODO esto de forma automática:

1. ✅ **Conectarme remotamente** al servidor AWS
2. ✅ **Instalar IIS** con todas las características web
3. ✅ **Instalar Node.js** (v20 LTS)
4. ✅ **Instalar PM2** para gestionar el backend
5. ✅ **Clonar el proyecto** desde GitHub
6. ✅ **Instalar dependencias** (frontend y backend)
7. ✅ **Compilar el frontend** (npm run build)
8. ✅ **Configurar IIS** para servir el frontend
9. ✅ **Iniciar el backend** con PM2
10. ✅ **Configurar el proxy** para que todo funcione
11. ✅ **Verificar** que la aplicación funcione
12. ✅ **Darte la URL final** de AWS para acceder

**Tiempo estimado:** 15-20 minutos una vez que tenga la información.

---

## 🌐 URL Final

Tu aplicación quedará accesible en:

```
http://ec2-XX-XXX-XX-XX.compute-1.amazonaws.com
```

O si tienes dominio personalizado, puedo configurarlo también.

---

## 💡 Ventajas de AWS EC2 vs Servidor Local

- ✅ **Acceso 24/7** desde Internet (sin depender de tu conexión)
- ✅ **IP pública estable** (no necesitas DuckDNS)
- ✅ **Sin Port Forwarding** necesario
- ✅ **Escalable** si necesitas más recursos
- ✅ **Backups automáticos** con snapshots de AWS
- ✅ **DNS de AWS** incluido gratuitamente

---

## 📞 Siguiente Paso

**Dame la información de los Pasos 1-3 de arriba, y yo empiezo inmediatamente.** 🚀

Si tienes alguna duda sobre cómo obtener cualquiera de esos datos, dímelo y te guío paso a paso con screenshots si es necesario.
