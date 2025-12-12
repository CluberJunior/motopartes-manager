# Script de Despliegue Manual
# Ejecuta este script en el servidor para desplegar cambios manualmente

Write-Host "🚀 Iniciando despliegue..." -ForegroundColor Cyan

Set-Location C:\inetpub\wwwroot\motopartes-manager

Write-Host "📥 Descargando cambios desde GitHub..." -ForegroundColor Yellow
git pull

Write-Host "📦 Instalando dependencias del frontend..." -ForegroundColor Yellow
npm install

Write-Host "🏗️ Construyendo aplicación frontend..." -ForegroundColor Yellow
npm run build

Write-Host "📦 Instalando dependencias del backend..." -ForegroundColor Yellow
Set-Location whatsapp-backend
npm install
Set-Location ..

Write-Host "🔄 Reiniciando servicio backend..." -ForegroundColor Yellow
pm2 restart motopartes-backend

Write-Host ""
Write-Host "✅ ¡Despliegue completado exitosamente!" -ForegroundColor Green
Write-Host "🌐 Tu aplicación está disponible en: http://18.219.228.50" -ForegroundColor Cyan
