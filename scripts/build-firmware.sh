#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UBOOT="$ROOT/src/u-boot"
TFA="$ROOT/src/trusted-firmware-a"
PATCH="$ROOT/patches/u-boot-x96q-lpddr3.patch"
OUT="$ROOT/out/firmware"

[[ -d "$UBOOT/.git" && -d "$TFA/.git" && -s "$PATCH" ]]
[[ "$(git -C "$UBOOT" rev-parse HEAD)" == ece349ade2973e220f524ce59e59711cc919263f ]]
[[ "$(git -C "$TFA" rev-parse HEAD)" == 1d5aa939bc8d3d892e2ed9945fa50e36a1a924cc ]]
mkdir -p "$OUT"

# Apply only the board-specific source patch, not the Armbian build framework.
if ! git -C "$UBOOT" apply --reverse --check "$PATCH" >/dev/null 2>&1; then
  git -C "$UBOOT" apply --check "$PATCH"
  git -C "$UBOOT" apply "$PATCH"
fi

make -C "$TFA" CROSS_COMPILE=aarch64-linux-gnu- PLAT=sun50i_h616 DEBUG=1 bl31
BL31="$TFA/build/sun50i_h616/debug/bl31.bin"
[[ -s "$BL31" ]]

make -C "$UBOOT" x96q_lpddr3_defconfig
make -C "$UBOOT" -j"$(nproc)" CROSS_COMPILE=aarch64-linux-gnu- BL31="$BL31" SCP=/dev/null

BIN="$UBOOT/u-boot-sunxi-with-spl.bin"
[[ -s "$BIN" ]]
install -m 0644 "$BIN" "$OUT/u-boot-sunxi-with-spl-x96q-lpddr3.bin"
{
  echo "U-Boot tag: v2026.07"
  echo "U-Boot commit: $(git -C "$UBOOT" rev-parse HEAD)"
  echo "U-Boot patch SHA-256: $(sha256sum "$PATCH" | awk '{print $1}')"
  echo "TF-A tag: v2.14.0"
  echo "TF-A commit: $(git -C "$TFA" rev-parse HEAD)"
  echo "TF-A BL31 SHA-256: $(sha256sum "$BL31" | awk '{print $1}')"
  echo "Firmware SHA-256: $(sha256sum "$OUT/u-boot-sunxi-with-spl-x96q-lpddr3.bin" | awk '{print $1}')"
  echo "Firmware bytes: $(stat -c %s "$OUT/u-boot-sunxi-with-spl-x96q-lpddr3.bin")"
} | tee "$OUT/manifest.txt"
file "$OUT/u-boot-sunxi-with-spl-x96q-lpddr3.bin"
