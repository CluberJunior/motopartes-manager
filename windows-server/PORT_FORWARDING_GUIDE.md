# Guia de Port Forwarding para MotoPartes Manager

## Objetivo

Hacer que tu aplicacion sea accesible desde Internet configurando Port Forwarding en tu router.

---

## Paso 1: Obtener Informacion del Servidor

Ya tienes esta informacion:
- **IP Local del Servidor**: 192.168.1.104
- **Puertos necesarios**: 
  - Puerto 80 (HTTP)
  - Puerto 443 (HTTPS - futuro)
  - Puerto 3001 (backend - solo interno)

---

## Paso 2: Obtener IP del Router

1. **En tu PC**, abre PowerShell y ejecuta:
   ```powershell
   ipconfig
   ```

2. Busca la linea **"Puerta de enlace predeterminada"**
   - Ejemplo: `192.168.1.254` o `192.168.1.1`
   - Esta es la IP de tu router

---

## Paso 3: Acceder al Router

1. **Abre un navegador** (Chrome, Edge, Firefox)

2. **En la barra de direcciones**, escribe la IP del router:
   ```
   http://192.168.1.254
   ```
   (o la IP que obtuviste en el paso anterior)

3. **Ingresa usuario y contrasena**:
   - Usuales: admin/admin, admin/password
   - Si no sabes: revisa la etiqueta del router o manual
   - Proveedor comun (Mexico): Telmex usa "TELMEX" o "infinitum"

---

## Paso 4: Encontrar Port Forwarding

Una vez dentro del router, busca una seccion llamada:
- "Port Forwarding"
- "Virtual Server"
- "NAT"
- "Redireccion de puertos"
- "Aplicaciones y juegos" (algunos routers)

La ubicacion varia segun el modelo:
- **Telmex/Infinitum**: Avanzado > NAT > Port Forwarding
- **Totalplay**: Red > NAT > Port Forwarding
- **Megacable**: Firewall > Port Forwarding
- **TP-Link**: Forwarding > Virtual Servers
- **Netgear**: Advanced > Advanced Setup > Port Forwarding

---

## Paso 5: Agregar Reglas de Port Forwarding

Necesitas crear **2 reglas** (una para HTTP):

### Regla 1: HTTP (Puerto 80)

- **Nombre/Service Name**: MotoPartes-HTTP
- **Puerto Externo/External Port**: 80
- **Puerto Interno/Internal Port**: 80
- **IP Interna/Internal IP**: 192.168.1.104
- **Protocolo/Protocol**: TCP o TCP/UDP
- **Estado/Enable**: Si/Enabled

### Regla 2: HTTPS (Puerto 443 - Opcional por ahora)

- **Nombre/Service Name**: MotoPartes-HTTPS
- **Puerto Externo/External Port**: 443
- **Puerto Interno/Internal Port**: 443
- **IP Interna/Internal IP**: 192.168.1.104
- **Protocolo/Protocol**: TCP o TCP/UDP
- **Estado/Enable**: Si/Enabled

**IMPORTANTE**: NO agregues el puerto 3001, ese debe quedar interno.

---

## Paso 6: Guardar Configuracion

1. Haz clic en **"Guardar"** / **"Apply"** / **"Aceptar"**
2. Puede que el router se reinicie (tarda 1-2 minutos)

---

## Paso 7: Obtener tu IP Publica

Ahora necesitas saber tu IP publica para que otros puedan acceder.

### Opcion A: Desde tu PC

Abre navegador y ve a: **https://www.whatismyip.com**

Te mostrara algo como: `201.123.45.67`

### Opcion B: Desde PowerShell

```powershell
Invoke-RestMethod -Uri "https://api.ipify.org"
```

---

## Paso 8: Probar el Acceso

### Desde tu telefono (con datos moviles, NO WiFi):

Abre navegador y ve a:
```
http://TU_IP_PUBLICA
```

Ejemplo: `http://201.123.45.67`

Deberia cargar tu aplicacion MotoPartes Manager!

### Desde otra red:

Comparte la IP con alguien en otra ubicacion y que intente acceder.

---

## Consideraciones Importantes

### 1. IP Dinamica vs IP Estatica

**Problema**: Tu proveedor de internet puede cambiar tu IP publica periodicamente.

**Soluciones**:
- **Contratar IP estatica** con tu proveedor (costo mensual)
- **Usar servicio DNS dinamico** (No-IP, DuckDNS) - Gratis
- **Comprar dominio** y usar Cloudflare - Recomendado

### 2. Seguridad

**Recomendaciones**:
- Instalar certificado SSL (HTTPS) lo antes posible
- Cambiar contrasenas por defecto del router
- Mantener Windows Server actualizado
- Configurar firewall de Windows correctamente

### 3. Ancho de Banda

Tu conexion de internet sera el limite:
- Velocidad de subida (upload) es la importante
- Usuarios concurrentes dependen de tu plan de internet

---

## Troubleshooting

### No puedo acceder con la IP publica

**1. Verificar Port Forwarding**:
- Revisa que las reglas esten activas en el router
- IP interna correcta (192.168.1.104)
- Puertos correctos (80)

**2. Verificar Firewall del Router**:
- Algunos routers tienen firewall adicional
- Busca seccion "Firewall" y verifica que no bloquee puerto 80

**3. Probar desde fuera de tu red**:
- Usa datos moviles en tu telefono (NO WiFi de tu casa)
- O pide a alguien en otra ubicacion que pruebe

**4. Verificar que tu proveedor no bloquee puerto 80**:
- Algunos proveedores bloquean puerto 80 para planes residenciales
- Solucion: usar puerto alternativo (ej: 8080) y configurar en router

**5. Verificar IP publica**:
- Confirma que tu IP sea publica y no detras de CGNAT
- Si estas detras de CGNAT, Port Forwarding no funcionara
- Solucion: solicitar IP publica a tu proveedor o usar Cloudflare Tunnel

---

## Alternativa: Usar Puerto Diferente

Si el puerto 80 no funciona, puedes usar otro puerto:

### En el Router:
- Puerto Externo: **8080**
- Puerto Interno: **80**
- IP: 192.168.1.104

### Acceso:
```
http://TU_IP_PUBLICA:8080
```

---

## Siguiente Paso: Dominio Personalizado

Una vez funcionando con IP, puedes:

1. **Comprar dominio** (ej: motopartes-taller.com)
2. **Configurar DNS** A record → Tu IP publica
3. **Instalar SSL** para HTTPS
4. **Acceso final**: https://motopartes-taller.com

---

## Resumen de IPs

- **IP Router**: 192.168.1.254 (o similar)
- **IP Servidor Local**: 192.168.1.104
- **IP Publica**: La que obtuviste de whatismyip.com
- **Acceso Internet**: http://TU_IP_PUBLICA

---

## Ayuda Adicional

Si tienes problemas:
1. Indicame el modelo de tu router
2. Dame screenshot de la configuracion de Port Forwarding
3. Dime tu proveedor de internet (Telmex, Totalplay, etc.)
