# GALAXIUMOS 1.0 "Aqua"

Sistema operativo basado en el **kernel Linux** (sobre Debian 12 "bookworm") con escritorio XFCE y un tema **Frutiger Aero** propio: vidrio translúcido, degradados aqua, brillos de gel, burbujas y cielo azul con colinas verdes.

## Qué incluye

| Componente | Detalle |
|---|---|
| Kernel | Linux (el de Debian, `linux-image-amd64`) |
| Escritorio | XFCE 4 + panel de cristal aqua |
| Dock | Plank |
| Efectos | Picom (transparencias, desenfoque, sombras azules, esquinas redondeadas) |
| Tema GTK | `Galaxium-Aero` (botones de gel, barras de progreso verdes, cabeceras brillantes) |
| Iconos | Papirus |
| Fondo | `galaxium-aero.svg` (cielo, nubes, burbujas, colinas) |
| Login | LightDM con el mismo fondo y tema |
| Instalador | Calamares |
| Usuario live | `galaxium` / contraseña `galaxium` |

## Navegador

**Firefox ESR** viene instalado y es el navegador predeterminado del sistema (enlaces http/https, HTML y PDF, `x-www-browser`, ayudante web de XFCE). Está anclado en el dock, sin página de bienvenida ni aviso de "hazlo predeterminado".

## Cómo compilar la ISO

### Opción A: en la nube con GitHub (sin instalar nada)

1. Sube esta carpeta a un repositorio tuyo en GitHub.
2. Ve a **Actions → Build GALAXIUMOS ISO → Run workflow**.
3. Al terminar (≈ 30–60 min), descarga `galaxiumos-iso` desde la sección *Artifacts*.

### Opción B: en tu propia máquina

Necesitas una máquina o VM con **Debian o Ubuntu** (≈ 20 GB libres y conexión a internet):

```bash
sudo apt install live-build
cd galaxiumos
sudo ./build.sh
```

Al terminar tendrás `galaxiumos-1.0-amd64.iso`. Pruébala en VirtualBox o QEMU:

```bash
qemu-system-x86_64 -m 4G -enable-kvm -cdrom galaxiumos-1.0-amd64.iso
```

Para grabarla en USB: `sudo dd if=galaxiumos-1.0-amd64.iso of=/dev/sdX bs=4M status=progress` (cambia `/dev/sdX` por tu USB, con cuidado).

## Estructura

```
galaxiumos/
├── build.sh                         # compila la ISO con live-build
└── config/
    ├── package-lists/               # paquetes a instalar
    ├── hooks/live/                  # branding (os-release), usuario, picom/plank
    └── includes.chroot/             # archivos que se copian al sistema
        ├── usr/share/themes/Galaxium-Aero/   # tema GTK3 + xfwm4
        ├── usr/share/backgrounds/            # fondo Frutiger Aero
        └── etc/{skel,lightdm}/               # configuración de XFCE y login
```

## Personalizar

- **Colores del tema:** edita las variables al inicio de `gtk.css`.
- **Fondo:** reemplaza `galaxium-aero.svg` (o agrega un PNG y cambia la ruta en `xfce4-desktop.xml`).
- **Paquetes:** añade o quita líneas en `galaxium.list.chroot`.

## Notas

- Es una distribución derivada de Debian: el kernel, los paquetes y la compatibilidad vienen de ahí.
- Falta (opcional) un tema de arranque Plymouth y los iconos/logo propios de la marca.
