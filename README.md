# 🦞 OpenClaw Auto-Installer para Windows

Script de PowerShell que automatiza por completo la instalación de OpenClaw en Windows.
De cero a listo en un solo clic.

---

## ¿Qué hace este script?

El script se encarga de todo en orden:

1. **Comprueba e instala los requisitos de Node.js**
   - Git for Windows
   - Python 3.12
   - NetWide Assembler (NASM)
   - Visual Studio 2022

2. **Comprueba e instala/actualiza Node.js LTS**
   - Consulta la versión más reciente directamente desde nodejs.org
   - Si ya está instalado y actualizado, no hace nada
   - Si está desactualizado, lo actualiza automáticamente

3. **Instala OpenClaw**
   - Si ya está instalado, lo detecta y lo notifica
   - Si falla, reintenta la instalación hasta 3 veces
   - Muestra el error exacto en cada intento fallido

4. **Lanza el asistente de configuración**
   - Una vez instalado, abre el asistente oficial de OpenClaw
   - Al terminar, muestra el estado del Gateway

---

## Requisitos previos

- Windows 10 o superior
- PowerShell 5 o superior
- Conexión a internet

---

## ¿Cómo usarlo?

1. Descarga el archivo `instalar-openclaw.ps1`
2. Abre PowerShell en la carpeta donde lo descargaste
3. Ejecuta el siguiente comando:

```powershell
powershell -ExecutionPolicy Bypass -File "instalar-openclaw.ps1"
```

---

## Fuentes oficiales

Este script usa únicamente información verificada de fuentes oficiales:

- [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw)
- [github.com/nodejs/node](https://github.com/nodejs/node)
- [nodejs.org](https://nodejs.org)

---

## Licencia

MIT — libre para usar, modificar y distribuir.
