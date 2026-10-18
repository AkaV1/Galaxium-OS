#!/usr/bin/env bash
# GALAXIUMOS para Zorin OS: aplica el tema Frutiger Aero sobre tu Zorin ya instalado.
#
#   ./galaxium-zorin.sh              instala y aplica (NO uses sudo; lo pide solo si hace falta)
#   ./galaxium-zorin.sh --uninstall  vuelve a como estaba antes
#
# Todo se instala solo en tu usuario (~/.themes, ~/.local/share), salvo paquetes opcionales.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_THEME="$DIR/config/includes.chroot/usr/share/themes/Galaxium-Aero"
SRC_WALL="$DIR/config/includes.chroot/usr/share/backgrounds/galaxium-aero.svg"
THEME_DST="$HOME/.themes/Galaxium-Aero"
WALL_DIR="$HOME/.local/share/backgrounds"
BACKUP="$HOME/.config/galaxiumos-backup.txt"

if [[ $EUID -eq 0 ]]; then
  echo "No ejecutes esto con sudo: se aplicaría al usuario root. Usa: ./galaxium-zorin.sh" >&2
  exit 1
fi
command -v gsettings >/dev/null || { echo "No encuentro gsettings (¿estás en Zorin con GNOME?)." >&2; exit 1; }

gget() { gsettings get "$1" "$2" 2>/dev/null || true; }

if [[ "${1:-}" == "--uninstall" ]]; then
  if [[ -f "$BACKUP" ]]; then
    while IFS='|' read -r schema key value; do
      [[ -n "$schema" ]] && gsettings set "$schema" "$key" "$value" || true
    done < "$BACKUP"
    echo "Ajustes anteriores restaurados."
  else
    echo "No hay copia de seguridad; restableciendo a valores por defecto."
    gsettings reset org.gnome.desktop.interface gtk-theme || true
    gsettings reset org.gnome.desktop.interface icon-theme || true
    gsettings reset org.gnome.desktop.background picture-uri || true
    gsettings reset org.gnome.desktop.background picture-uri-dark || true
  fi
  rm -rf "$THEME_DST" "$WALL_DIR/galaxium-aero".*
  echo "GALAXIUMOS desinstalado de este usuario."
  exit 0
fi

[[ -d "$SRC_THEME" && -f "$SRC_WALL" ]] || {
  echo "Ejecuta el script desde la carpeta 'galaxiumos' descomprimida (faltan archivos del tema)." >&2
  exit 1
}

# 1) Copia de seguridad de lo que vamos a cambiar
if [[ ! -f "$BACKUP" ]]; then
  mkdir -p "$(dirname "$BACKUP")"
  {
    for pair in \
      "org.gnome.desktop.interface gtk-theme" \
      "org.gnome.desktop.interface icon-theme" \
      "org.gnome.desktop.interface font-name" \
      "org.gnome.desktop.background picture-uri" \
      "org.gnome.desktop.background picture-uri-dark" \
      "org.gnome.desktop.background picture-options"; do
      set -- $pair
      v="$(gget "$1" "$2")"
      [[ -n "$v" ]] && echo "$1|$2|$v"
    done
  } > "$BACKUP"
  echo "Copia de seguridad guardada en $BACKUP"
fi

# 2) Tema GTK
mkdir -p "$HOME/.themes"
rm -rf "$THEME_DST"
cp -r "$SRC_THEME" "$THEME_DST"
echo "Tema instalado en $THEME_DST"

# 3) Fondo (PNG si hay conversor; si no, el SVG directo)
mkdir -p "$WALL_DIR"
WALL="$WALL_DIR/galaxium-aero.svg"
cp "$SRC_WALL" "$WALL"
if command -v rsvg-convert >/dev/null; then
  rsvg-convert -w 1920 -h 1080 -o "$WALL_DIR/galaxium-aero.png" "$SRC_WALL" && WALL="$WALL_DIR/galaxium-aero.png"
elif command -v convert >/dev/null; then
  convert -background none "$SRC_WALL" -resize 1920x1080 "$WALL_DIR/galaxium-aero.png" 2>/dev/null && WALL="$WALL_DIR/galaxium-aero.png"
fi

# 4) Iconos Papirus (opcional, combina con el tema)
if ! dpkg -s papirus-icon-theme >/dev/null 2>&1; then
  echo "Instalando iconos Papirus (pide tu contraseña)..."
  sudo apt-get install -y papirus-icon-theme || echo "No se pudo instalar Papirus; se mantienen tus iconos."
fi

# 5) Firefox como navegador nativo
if ! command -v firefox >/dev/null && ! snap list firefox >/dev/null 2>&1; then
  echo "Instalando Firefox (pide tu contraseña)..."
  sudo apt-get install -y firefox || echo "No se pudo instalar Firefox automáticamente."
fi
for desk in firefox.desktop firefox_firefox.desktop firefox-esr.desktop; do
  if [[ -f "/usr/share/applications/$desk" || -f "/var/lib/snapd/desktop/applications/$desk" ]]; then
    xdg-settings set default-web-browser "$desk" 2>/dev/null || true
    xdg-mime default "$desk" x-scheme-handler/http x-scheme-handler/https text/html 2>/dev/null || true
    echo "Firefox ($desk) es ahora el navegador predeterminado."
    break
  fi
done

# 6) Aplicar
gsettings set org.gnome.desktop.interface gtk-theme "Galaxium-Aero"
dpkg -s papirus-icon-theme >/dev/null 2>&1 && gsettings set org.gnome.desktop.interface icon-theme "Papirus"
gsettings set org.gnome.desktop.background picture-options "zoom"
gsettings set org.gnome.desktop.background picture-uri "file://$WALL"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALL"

echo
echo "Listo. Cierra sesión y vuelve a entrar para que todo se aplique bien."
echo "Para deshacer:  ./galaxium-zorin.sh --uninstall"
