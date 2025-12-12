# 🌐 Guía Manual: Acceso Externo a la Aplicación

## 🚨 Problema Actual

Localtunnel está pidiendo una contraseña que no aparece en los logs remotos. Las opciones son:

---

## ✅ Opción 1: Usar Cloudflare Tunnel (RECOMENDADO)

Cloudflare Tunnel NO requiere contraseña y es más estable.

### En la VM (192.168.1.104):

1. **Abre PowerShell como Administrador en la VM**

2. **Ejecuta este comando:**
```powershell
& "C:\Program Files\cloudflared\cloudflared.exe" tunnel --url http://localhost:80
```

3. **Espera 10-20 segundos hasta que aparezca una línea como:**
```
https://xxxxx-xxxxx-xxxxx.trycloudflare.com
```

4. **Copia esa URL y pruébala desde tu teléfono**
   - NO pide contraseña
   - Funciona desde cualquier lugar
   - Mantén el PowerShell abierto mientras uses la aplicación

---

## ⚙️ Opción 2: Obtener Contraseña de Localtunnel

Si prefieres usar localtunnel (la URL actual es `https://tender-shrimps-grin.loca.lt`):

### En la VM (192.168.1.104):

1. **Abre PowerShell en la VM**

2. **Ejecuta:**
```powershell
Get-Content "C:\inetpub\wwwroot\motopartes-manager\localtunnel-output.txt"
```

3. **Busca una línea que diga:**
   - `your tunnel password is: XXXXX`
   - O puede mostrar solo un código/token

4. **Ingresa ese código en la página de localtunnel** que aparece en el navegador

---

## 🎯 Opción 3: Reiniciar Localtunnel con Verbosidad

### En la VM (192.168.1.104):

1. **Detén procesos anteriores:**
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "node"} | Stop-Process -Force
```

2. **Inicia localtunnel de nuevo:**
```powershell
cd C:\inetpub\wwwroot\motopartes-manager
npx localtunnel --port 80
```

3. **La contraseña aparecerá en pantalla** - algo como:
```
your url is: https://XXXXX.loca.lt
your tunnel password is: XXXXX
```

4. **Usa esa contraseña en el navegador**

---

## 🌟 Mi Recomendación

**Usa Cloudflare Tunnel (Opción 1)** porque:
- ✅ Sin contraseña
- ✅ Más estable
- ✅ Mejor rendimiento
- ✅ Ya está instalado en el servidor

---

## 📋 Siguiente Paso

Una vez que tengas la URL funcionando (de Cloudflare o Localtunnel), si quieres una solución PERMANENTE:

1. Crear cuenta gratuita en Cloudflare
2. Configurar un túnel permanente con nombre personalizado
3. Opcional: Comprar un dominio y usarlo con Cloudflare

---

## 🆘 Si Ninguna Funciona

Si ninguna opción funciona, dame el siguiente comando ejecutado DESDE LA VM:

```powershell
# Ejecuta en la VM y enviame el resultado completo
cd C:\inetpub\wwwroot\motopartes-manager
npx localtunnel --port 80 --print-requests
```

Eso mostrará toda la información incluyendo la contraseña.
