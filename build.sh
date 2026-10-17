#!/usr/bin/env bash
# GALAXIUMOS - script de compilación de la ISO (base Debian + kernel Linux)
# Uso:  sudo ./build.sh
# Requisitos (en una máquina Debian/Ubuntu): sudo apt install live-build
set -euo pipefail

cd "$(dirname "$0")"

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta este script con sudo:  sudo ./build.sh" >&2
  exit 1
fi

command -v lb >/dev/null || { echo "Falta live-build:  apt install live-build" >&2; exit 1; }

lb clean --purge 2>/dev/null || true

lb config \
  --distribution bookworm \
  --architectures amd64 \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components quiet splash username=galaxium hostname=galaxiumos locales=es_MX.UTF-8 keyboard-layouts=latam timezone=America/Hermosillo" \
  --iso-application "GALAXIUMOS" \
  --iso-publisher "GALAXIUMOS Project" \
  --iso-volume "GALAXIUMOS" \
  --linux-flavours amd64 \
  --debian-installer live \
  --memtest none \
  --apt-recommends true

lb build 2>&1 | tee build.log

# Resultado: live-image-amd64.hybrid.iso
if [[ -f live-image-amd64.hybrid.iso ]]; then
  mv live-image-amd64.hybrid.iso galaxiumos-1.0-amd64.iso
  echo "Listo: galaxiumos-1.0-amd64.iso"
fi
