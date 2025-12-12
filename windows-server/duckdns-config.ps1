# Configuracion de DuckDNS
# Edita estos valores con tu informacion

# Tu subdominio en DuckDNS (sin .duckdns.org)
# Ejemplo: si tu dominio es "motopartes.duckdns.org", pon solo "motopartes"
$DUCKDNS_DOMAIN = "motopartes-manager"

# Tu token de DuckDNS (obtenlo de https://www.duckdns.org)
# Ejemplo: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
$DUCKDNS_TOKEN = "1de86b09-2e6b-4b69-ae4e-4442ac392929"

# NO MODIFICAR ABAJO DE ESTA LINEA
$DUCKDNS_URL = "https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip="

# Exportar configuracion
$Global:DuckDNSConfig = @{
    Domain    = $DUCKDNS_DOMAIN
    Token     = $DUCKDNS_TOKEN
    UpdateUrl = $DUCKDNS_URL
}
