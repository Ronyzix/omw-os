#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BB="$ROOT/src/busybox"
OUT="$ROOT/out/initramfs"
ROOTFS="$OUT/root"
COMMIT=be7d1b7b1701d225379bc1665487ed0871b592a5

[[ -d "$BB/.git" ]]
[[ "$(git -C "$BB" rev-parse HEAD)" == "$COMMIT" ]]
mkdir -p "$OUT"
make -C "$BB" defconfig
sed -i \
  -e 's/^# CONFIG_STATIC is not set$/CONFIG_STATIC=y/' \
  -e 's/^# CONFIG_FEATURE_SH_STANDALONE is not set$/CONFIG_FEATURE_SH_STANDALONE=y/' \
  -e 's/^# CONFIG_FEATURE_PREFER_APPLETS is not set$/CONFIG_FEATURE_PREFER_APPLETS=y/' \
  -e 's/^CONFIG_SHA1_HWACCEL=y/# CONFIG_SHA1_HWACCEL is not set/' \
  -e 's/^CONFIG_SHA256_HWACCEL=y/# CONFIG_SHA256_HWACCEL is not set/' \
  -e 's/^CONFIG_TC=y/# CONFIG_TC is not set/' \
  "$BB/.config"
make -C "$BB" oldconfig </dev/null
cp "$BB/.config" "$OUT/busybox.config"
make -C "$BB" -j"$(nproc)"
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"/{bin,sbin,etc,proc,sys,dev,run,tmp,root,usr/bin,usr/sbin}
make -C "$BB" CONFIG_PREFIX="$ROOTFS" install
chmod 1777 "$ROOTFS/tmp"
cat > "$ROOTFS/etc/os-release" <<'EOF'
NAME="OMW OS"
ID=omw
PRETTY_NAME="OMW OS bring-up"
VERSION="0.0.1-dev2"
EOF
cat > "$ROOTFS/init" <<'EOF'
#!/bin/busybox sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH
mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true
printf '\nOMW OS 0.0.1-dev2 — inicializacao de teste\n'
printf 'Menu de recuperacao pelo console serial.\n'
printf 'Este sistema roda em RAM; nao monta nem grava o Android/eMMC.\n'
printf 'Kernel command line: '
cat /proc/cmdline 2>/dev/null || true
while :; do
  printf '\nOMW — escolha uma opcao:\n'
  printf '  1) Ver diagnostico (somente leitura)\n'
  printf '  2) Abrir terminal\n'
  printf '  3) Ajuda e limites desta imagem\n'
  printf '  4) Reiniciar\n'
  printf '  5) Desligar\n'
  printf 'Opcao: '
  IFS= read -r choice < /dev/console || choice=2
  case "$choice" in
    1)
      printf '\nOMW — diagnostico\n'
      printf 'Kernel: '; uname -a
      printf 'Linha de boot: '; cat /proc/cmdline 2>/dev/null || true
      printf '\nParticoes detectadas (leitura):\n'; cat /proc/partitions 2>/dev/null || true
      printf '\nMontagens atuais:\n'; cat /proc/mounts 2>/dev/null || true
      printf '\nA raiz e o initramfs em RAM; nenhum rootfs do eMMC foi montado.\n'
      printf 'Pressione Enter para voltar ao menu. '
      IFS= read -r _ < /dev/console || true
      ;;
    2)
      printf '\nTerminal de diagnostico. Digite exit para voltar ao menu.\n'
      /bin/sh -i </dev/console >/dev/console 2>&1
      ;;
    3)
      printf '\nEsta imagem ainda nao tem HDMI/area de trabalho grafica nem Wi-Fi habilitado.\n'
      printf 'Use somente como teste de boot serial; nao e uma imagem pronta para uso.\n'
      printf 'Pressione Enter para voltar ao menu. '
      IFS= read -r _ < /dev/console || true
      ;;
    4)
      printf '\nReiniciando...\n'
      /bin/busybox reboot -f
      ;;
    5)
      printf '\nDesligando...\n'
      /bin/busybox poweroff -f
      ;;
    *)
      printf 'Opcao invalida. Digite um numero de 1 a 5.\n'
      ;;
  esac
done
EOF
chmod 0755 "$ROOTFS/init"
# The initramfs must contain console device before the kernel starts /init.
if [[ ! -e "$ROOTFS/dev/console" ]]; then sudo mknod -m 600 "$ROOTFS/dev/console" c 5 1; fi
if [[ ! -e "$ROOTFS/dev/null" ]]; then sudo mknod -m 666 "$ROOTFS/dev/null" c 1 3; fi
(
  cd "$ROOTFS"
  find . -print0 | LC_ALL=C sort -z | cpio --null -o -H newc --owner=0:0 --quiet | gzip -9n > "$OUT/initramfs.cpio.gz"
)
{
  echo "BusyBox tag: 1_37_0"
  echo "BusyBox commit: $(git -C "$BB" rev-parse HEAD)"
  echo "BusyBox config SHA-256: $(sha256sum "$OUT/busybox.config" | awk '{print $1}')"
  echo "Initramfs bytes: $(stat -c %s "$OUT/initramfs.cpio.gz")"
  echo "Initramfs SHA-256: $(sha256sum "$OUT/initramfs.cpio.gz" | awk '{print $1}')"
} | tee "$OUT/manifest.txt"
file "$ROOTFS/bin/busybox" "$OUT/initramfs.cpio.gz"
ldd "$ROOTFS/bin/busybox" 2>&1 || true
