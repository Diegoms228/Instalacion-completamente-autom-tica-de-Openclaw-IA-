# ============================================================
# BLOQUE 0 — PAQUETES NECESARIOS PARA NODE.JS
# ============================================================

# Lista de paquetes según github.com/nodejs/node/BUILDING.md
# Formato: Nombre visible, ID de winget, comando que deja en PATH
$paquetes = @(
    @{ Nombre = "Git for Windows";          Id = "Git.Git";            Cmd = "git"    },
    @{ Nombre = "Python";                   Id = "Python.Python.3.12"; Cmd = "python" },
    @{ Nombre = "NetWide Assembler (NASM)"; Id = "NASM.NASM";          Cmd = "nasm"   }
)

foreach ($paquete in $paquetes) {
    Write-Host "`nComprobando $($paquete.Nombre)..." -ForegroundColor Cyan

    if (Get-Command $paquete.Cmd -ErrorAction SilentlyContinue) {
        Write-Host "$($paquete.Nombre) ya está instalado. Comprobando actualizaciones..." -ForegroundColor Green

        # Captura la salida de winget como texto para detectar el resultado real
        $salidaUpgrade = winget upgrade --id $paquete.Id --silent `
            --accept-package-agreements --accept-source-agreements 2>&1

        if ($salidaUpgrade -match "No hay paquetes disponibles" -or
            $salidaUpgrade -match "No applicable upgrade" -or
            $salidaUpgrade -match "already installed") {
            Write-Host "$($paquete.Nombre) ya está en la última versión." -ForegroundColor Green
        } else {
            Write-Host "$($paquete.Nombre) actualizado correctamente." -ForegroundColor Green
        }
    } else {
        Write-Host "$($paquete.Nombre) no encontrado. Instalando..." -ForegroundColor Yellow
        winget install --id $paquete.Id --silent `
            --accept-package-agreements --accept-source-agreements
        Write-Host "$($paquete.Nombre) instalado correctamente." -ForegroundColor Green
    }
}

# Visual Studio se comprueba por ruta porque no deja comando en PATH
Write-Host "`nComprobando Visual Studio 2022..." -ForegroundColor Cyan
$vsInstalado = Test-Path "C:\Program Files\Microsoft Visual Studio\2022"

if ($vsInstalado) {
    Write-Host "Visual Studio 2022 ya está instalado. Comprobando actualizaciones..." -ForegroundColor Green

    $salidaVS = winget upgrade --id Microsoft.VisualStudio.2022.Community --silent `
        --accept-package-agreements --accept-source-agreements 2>&1

    if ($salidaVS -match "No hay paquetes disponibles" -or
        $salidaVS -match "No applicable upgrade" -or
        $salidaVS -match "already installed") {
        Write-Host "Visual Studio 2022 ya está en la última versión." -ForegroundColor Green
    } else {
        Write-Host "Visual Studio 2022 actualizado correctamente." -ForegroundColor Green
    }
} else {
    Write-Host "Visual Studio 2022 no encontrado. Instalando..." -ForegroundColor Yellow
    winget install --id Microsoft.VisualStudio.2022.Community --silent `
        --accept-package-agreements --accept-source-agreements
    Write-Host "Visual Studio 2022 instalado correctamente." -ForegroundColor Green
}

# ============================================================
# BLOQUE 1 — COMPROBACIÓN E INSTALACIÓN/ACTUALIZACIÓN DE NODE.JS
# ============================================================

$ultimaVersion = (Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" |
    Where-Object { $_.lts -ne $false } |
    Select-Object -First 1).version.TrimStart("v")

Write-Host "`nÚltima versión LTS de Node.js disponible: $ultimaVersion" -ForegroundColor Cyan

if (Get-Command node -ErrorAction SilentlyContinue) {
    $versionActual = (node --version).TrimStart("v")
    Write-Host "Node.js instalado: v$versionActual" -ForegroundColor Green

    if ($versionActual -eq $ultimaVersion) {
        Write-Host "Node.js ya está en la última versión. No se hace nada." -ForegroundColor Green
    } else {
        Write-Host "Versión desactualizada. Actualizando Node.js a v$ultimaVersion..." -ForegroundColor Yellow
        winget upgrade --id OpenJS.NodeJS.LTS --silent `
            --accept-package-agreements --accept-source-agreements
        Write-Host "Node.js actualizado correctamente a v$ultimaVersion." -ForegroundColor Green
    }
} else {
    Write-Host "Node.js no encontrado. Instalando v$ultimaVersion..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS --silent `
        --accept-package-agreements --accept-source-agreements
    Write-Host "Node.js instalado correctamente." -ForegroundColor Green
}

# ============================================================
# BLOQUE 2 — COMPROBACIÓN E INSTALACIÓN DE OPENCLAW
# ============================================================

$maxIntentos = 3
$intento = 0
$instalado = $false

if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Write-Host "OpenClaw ya está instalado correctamente." -ForegroundColor Green
    $instalado = $true
} else {
    Write-Host "OpenClaw no encontrado. Instalando..." -ForegroundColor Yellow

    while ($intento -lt $maxIntentos -and -not $instalado) {
        $intento++
        Write-Host "Intento $intento de $maxIntentos..." -ForegroundColor Cyan

        try {
            iwr -useb https://openclaw.ai/install.ps1 | iex

            if (Get-Command openclaw -ErrorAction SilentlyContinue) {
                $instalado = $true
                Write-Host "Instalación completada correctamente." -ForegroundColor Green
            } else {
                throw "El comando 'openclaw' no se encontró tras la instalación."
            }
        } catch {
            Write-Host "Error en el intento $intento : $_" -ForegroundColor Red

            if ($intento -lt $maxIntentos) {
                Write-Host "Reintentando instalación desde cero..." -ForegroundColor Yellow
            }
        }
    }
}

if ($instalado) {
    Write-Host "Lanzando el asistente de configuración..." -ForegroundColor Cyan
    openclaw onboard --install-daemon

    Write-Host "Comprobando estado del Gateway..." -ForegroundColor Cyan
    openclaw status
} else {
    Write-Host "No se pudo instalar OpenClaw tras $maxIntentos intentos. Revisa los errores anteriores." -ForegroundColor Red
}