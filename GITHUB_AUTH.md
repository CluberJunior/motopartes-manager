# 🔐 Autenticación con GitHub

El proyecto está listo para subir, pero Git necesita autenticación.

## ✅ Opción 1: GitHub Desktop (MÁS FÁCIL - Recomendado)

1. **Descarga GitHub Desktop**
   - Ve a: https://desktop.github.com/
   - Descarga e instala

2. **Login**
   - Abre GitHub Desktop
   - Click en "Sign in to GitHub.com"
   - Inicia sesión con tu cuenta

3. **Agregar el Proyecto**
   - File → Add Local Repository
   - Busca: `C:\Users\Amaury\.gemini\antigravity\scratch\motopartes-manager`
   - Click "Add Repository"

4. **Subir a GitHub**
   - Click en "Push origin" (arriba a la derecha)
   - ¡Listo! Ya está en GitHub

---

## Opción 2: Personal Access Token (Terminal)

1. **Generar Token**
   - Ve a GitHub: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Nombre: `MotoPartes Manager`
   - Expiration: No expiration (o el tiempo que prefieras)
   - Marca: ✅ `repo` (Full control of private repositories)
   - Click "Generate token"
   - **COPIA EL TOKEN** (solo lo verás una vez)

2. **Usar el Token**
   - Abre PowerShell o CMD en la carpeta del proyecto
   - Ejecuta:
     ```bash
     git push -u origin main
     ```
   - Username: `CluberJunior`
   - Password: **PEGA EL TOKEN** (no tu contraseña)

---

## Opción 3: SSH Keys (Avanzado)

Solo si eres familiar con SSH. Es más seguro pero más complejo de configurar.

---

## ¿Cuál Elegir?

- **🟢 GitHub Desktop**: Si quieres algo visual y fácil
- **🟡 Token**: Si prefieres línea de comandos
- **🔴 SSH**: Solo si ya sabes cómo funciona

**Recomendación: GitHub Desktop** (Opción 1) - Es lo más simple y rápido.
