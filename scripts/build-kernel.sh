#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
LINUX="$ROOT/src/linux"
BOARD_DTS="$ROOT/patches/omw-sun50i-h313-x96q-lpddr3.dts"
OUT="$ROOT/out/kernel"
COMMIT=25442251cbda7590d87d8203a8dc1ddf2c93de61
DTB=sun50i-h313-x96q-lpddr3

[[ -d "$LINUX/.git" && -s "$BOARD_DTS" ]]
[[ "$(git -C "$LINUX" rev-parse HEAD)" == "$COMMIT" ]]
mkdir -p "$OUT"
install -m 0644 "$BOARD_DTS" "$LINUX/arch/arm64/boot/dts/allwinner/$DTB.dts"
DTB_MAKEFILE="$LINUX/arch/arm64/boot/dts/allwinner/Makefile"
grep -qxF "dtb-\$(CONFIG_ARCH_SUNXI) += $DTB.dtb" "$DTB_MAKEFILE" || \
  printf '\ndtb-$(CONFIG_ARCH_SUNXI) += %s.dtb\n' "$DTB" >> "$DTB_MAKEFILE"

make -C "$LINUX" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
"$LINUX/scripts/config" --file "$LINUX/.config" \
  --enable SERIAL_8250 \
  --enable SERIAL_8250_CONSOLE \
  --enable SERIAL_8250_DW \
  --enable MMC \
  --enable MMC_SUNXI \
  --enable EXT4_FS \
  --enable DEVTMPFS \
  --enable DEVTMPFS_MOUNT \
  --disable DEBUG_INFO \
  --enable DEBUG_INFO_NONE
make -C "$LINUX" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig

# Build only the kernel image and this board DTB. No distribution image/rootfs is involved.
make -C "$LINUX" -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image
make -C "$LINUX" -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
  "allwinner/$DTB.dtb"

install -m 0644 "$LINUX/arch/arm64/boot/Image" "$OUT/Image-omw-arm64"
install -m 0644 "$LINUX/arch/arm64/boot/dts/allwinner/$DTB.dtb" "$OUT/$DTB.dtb"
{
  echo "Linux tag: v6.18.1"
  echo "Linux commit: $(git -C "$LINUX" rev-parse HEAD)"
  echo "Board DTS SHA-256: $(sha256sum "$BOARD_DTS" | awk '{print $1}')"
  echo "Kernel config SHA-256: $(sha256sum "$LINUX/.config" | awk '{print $1}')"
  echo "Image bytes: $(stat -c %s "$OUT/Image-omw-arm64")"
  echo "Image SHA-256: $(sha256sum "$OUT/Image-omw-arm64" | awk '{print $1}')"
  echo "DTB bytes: $(stat -c %s "$OUT/$DTB.dtb")"
  echo "DTB SHA-256: $(sha256sum "$OUT/$DTB.dtb" | awk '{print $1}')"
} | tee "$OUT/manifest.txt"
file "$OUT/Image-omw-arm64" "$OUT/$DTB.dtb"
