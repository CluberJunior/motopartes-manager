# 🦆 Configuración de DuckDNS - Dominio Gratuito Permanente

DuckDNS es un servicio **100% gratuito** que te da un dominio como `motopartes.duckdns.org` y actualiza automáticamente tu IP pública.

---

## 📋 Requisitos Previos

Para que DuckDNS funcione completamente necesitas:

1. ✅ **Servidor funcionando** (Ya lo tienes - IIS corriendo)
2. ⏳ **IP Pública** de tu ISP (Telmex)
   - Sin esto, solo funcionará en red local
   - Necesitas llamar a Telmex para solicitarla
3. ⏳ **Port Forwarding** configurado en el router
   - Puerto 80 (HTTP) → 192.168.1.104
   - Puerto 443 (HTTPS) → 192.168.1.104

---

## 🚀 Paso 1: Registrarse en DuckDNS

1. **Ve a:** https://www.duckdns.org

2. **Inicia sesión con:**
   - Google
   - GitHub
   - Twitter
   - Reddit
   (Cualquiera funciona - recomiendo Google)

3. **Verás tu token:**
   ```
   token: abc123def456789 (ejemplo)
   ```
   ⚠️ **GUARDA ESTE TOKEN** - lo necesitarás después

---

## 🦆 Paso 2: Crear tu Subdominio

1. En la página de DuckDNS, en **"sub domain"** escribe:
   ```
   motopartes
   ```
   (O el nombre que prefieras)

2. Haz clic en **"add domain"**

3. Tu dominio será:
   ```
   motopartes.duckdns.org
   ```

4. En **"current ip"** verás tu IP pública actual
   - Si dice "No IP detected" es porque no tienes IP pública aún

---

## ⚙️ Paso 3: Configurar Script Automático en el Servidor

Ya creé un script que actualizará tu IP automáticamente cada 5 minutos.

### En tu PC Local:

1. **Edita el archivo de configuración:**

Abre: `windows-server\duckdns-config.ps1`

Y reemplaza:
```powershell
$DUCKDNS_DOMAIN = "motopartes"  # Tu subdominio (sin .duckdns.org)
$DUCKDNS_TOKEN = "TU-TOKEN-AQUI"  # El token de DuckDNS
```

2. **Copia el script al servidor:**

Ya está listo en: `windows-server\install-duckdns.ps1`

3. **Ejecuta el instalador:**

```powershell
# Desde tu PC
powershell -ExecutionPolicy Bypass -File "windows-server\install-duckdns.ps1"
```

Esto instalará:
- ✅ Script de actualización en el servidor
- ✅ Tarea programada que se ejecuta cada 5 minutos
- ✅ Log de actualizaciones en `C:\DuckDNS\duckdns.log`

---

## 🧪 Paso 4: Probar la Configuración

### Opción A: Si YA tienes IP Pública

1. **Verifica que DuckDNS tiene tu IP:**
   - Ve a https://www.duckdns.org
   - Deberías ver tu IP pública en "current ip"

2. **Prueba tu dominio:**
   ```
   http://motopartes.duckdns.org
   ```

3. **Si no carga:**
   - Verifica Port Forwarding en el router
   - Verifica que el firewall permite puertos 80/443
   - Lee los logs: `C:\DuckDNS\duckdns.log` en el servidor

### Opción B: Si NO tienes IP Pública aún

1. **El script está listo** y esperando
2. **Cuando obtengas IP pública de Telmex:**
   - El script detectará la IP automáticamente
   - DuckDNS se actualizará en 5 minutos
   - Tu dominio funcionará inmediatamente

---

## 📞 Paso 5: Solicitar IP Pública a Telmex

### Llamar a Telmex:

**Teléfono:** 800 123 2222

**Qué decir:**
> "Hola, necesito contratar una IP pública para mi servicio de Internet. Es para hospedar un servidor web."

**Lo que te preguntarán:**
- Número de cuenta
- Confirmación de identidad
- Si es plan residencial o empresarial

**Costo aproximado:**
- $200-300 MXN/mes adicionales
- Puede variar según tu plan actual

**Alternativa:**
Si no quieren darte IP pública en plan residencial, pregunta por **"Plan Empresarial"** o **"IP Pública Estática"**

---

## 🔧 Configuración Adicional

### SSL/HTTPS (Opcional - Recomendado)

Una vez que tu dominio funcione, puedo configurar:
- ✅ Certificado SSL gratuito (Let's Encrypt)
- ✅ HTTPS automático
- ✅ Renovación automática del certificado

---

## 📊 Verificar Estado

### En el Servidor:

```powershell
# Ver log de DuckDNS
Get-Content "C:\DuckDNS\duckdns.log" -Tail 20

# Ver tarea programada
Get-ScheduledTask -TaskName "DuckDNS Update"

# Forzar actualización manual
C:\DuckDNS\update-ip.ps1
```

### Desde Internet:

```bash
# Verificar que el dominio resuelve a tu IP
nslookup motopartes.duckdns.org

# Probar conectividad
curl http://motopartes.duckdns.org
```

---

## ✅ Ventajas de DuckDNS

- ✅ **100% Gratis** - Para siempre
- ✅ **Sin límites** - Actualizaciones ilimitadas
- ✅ **Múltiples subdominios** - Puedes crear hasta 5 gratis
- ✅ **Auto-renovación** - No caduca
- ✅ **API simple** - Fácil de automatizar
- ✅ **Sin dependencias** - Solo necesitas Internet

---

## 🎯 Resultado Final

Una vez configurado completamente:

### Antes (Red Local):
```
http://192.168.1.104 ← Solo funciona en tu WiFi
```

### Después (Internet):
```
http://motopartes.duckdns.org ← Funciona desde cualquier lugar
```

### Con SSL (Futuro):
```
https://motopartes.duckdns.org ← Seguro y profesional
```

---

## 🆘 Solución de Problemas

### Problema: "No IP detected" en DuckDNS
**Solución:** No tienes IP pública aún. Contacta a Telmex.

### Problema: Dominio no carga
**Causas posibles:**
1. Port Forwarding no configurado
2. Firewall bloqueando puertos
3. IIS no está corriendo
4. IP no actualizada en DuckDNS

**Verificación:**
```powershell
# En el servidor
Test-NetConnection -ComputerName localhost -Port 80
Get-Service W3SVC  # IIS debe estar "Running"
```

### Problema: Script no se ejecuta
**Solución:**
```powershell
# Verificar tarea programada
Get-ScheduledTask -TaskName "DuckDNS Update" | Get-ScheduledTaskInfo

# Ver errores
Get-Content "C:\DuckDNS\duckdns.log"
```

---

## 📝 Próximos Pasos

1. ✅ Regístrate en DuckDNS
2. ✅ Crea tu subdominio
3. ✅ Configura el script con tu token
4. ✅ Instala en el servidor
5. 📞 Llama a Telmex para IP pública
6. 🔧 Configura Port Forwarding
7. 🌐 ¡Tu aplicación accesible desde Internet!

---

**¿Todo listo?** Una vez que tengas tu token de DuckDNS, avísame y ejecuto los scripts automáticamente. 🚀
