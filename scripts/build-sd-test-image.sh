#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FW="$ROOT/out/firmware/u-boot-sunxi-with-spl-x96q-lpddr3.bin"
KERNEL="$ROOT/out/kernel/Image-omw-arm64"
DTB="$ROOT/out/kernel/sun50i-h313-x96q-lpddr3.dtb"
INITRD="$ROOT/out/initramfs/initramfs.cpio.gz"
OUT="$ROOT/out/sd-test"
IMAGE="$OUT/OMW-X96Q-LPDDR3-v0.0.1-dev.img"
BOOTCMD="$OUT/boot.cmd"
BOOTSCRIPT="$OUT/boot.scr"
export SOURCE_DATE_EPOCH=1767225600
export MTOOLS_DATE_STRING='2026-01-01 00:00:00'

for f in "$FW" "$KERNEL" "$DTB" "$INITRD"; do [[ -s "$f" ]] || { echo "Missing build artifact: $f" >&2; exit 1; }; done
for c in mformat mcopy; do command -v "$c" >/dev/null || { echo "Missing build tool: $c" >&2; exit 1; }; done
[[ -x "$ROOT/src/u-boot/tools/mkimage" ]] || { echo "Missing U-Boot host tool: tools/mkimage" >&2; exit 1; }
mkdir -p "$OUT"

cat > "$BOOTCMD" <<'EOF'
echo OMW OS source-built bring-up image
setenv kernel_addr_r 0x42000000
setenv ramdisk_addr_r 0x48000000
setenv fdt_addr_r 0x4f000000
setenv bootargs 'console=ttyS0,115200 earlycon loglevel=7 rdinit=/init'
if fatload mmc 0:1 ${kernel_addr_r} /Image; then
  if fatload mmc 0:1 ${ramdisk_addr_r} /initramfs.cpio.gz; then
    setenv initrd_size ${filesize}
    if fatload mmc 0:1 ${fdt_addr_r} /sun50i-h313-x96q-lpddr3.dtb; then
      booti ${kernel_addr_r} ${ramdisk_addr_r}:${initrd_size} ${fdt_addr_r}
    fi
  fi
fi
echo OMW: falha ao carregar arquivos de boot do cartao SD
EOF

"$ROOT/src/u-boot/tools/mkimage" -A arm64 -O linux -T script -C none \
  -n 'OMW OS dev boot sequence' -d "$BOOTCMD" "$BOOTSCRIPT"

# Make a raw disk image file from scratch; 512-byte sectors.
# MBR sector 0, SPL/U-Boot starts at sector 16 (8 KiB), FAT32 starts at 32,768 (16 MiB).
START=32768
LENGTH=262144
TOTAL=$((START + LENGTH))
OFFSET=$((START * 512))
BYTES=$((TOTAL * 512))
truncate -s "$BYTES" "$IMAGE"
python3 - "$IMAGE" "$START" "$LENGTH" <<'PY'
import struct, sys
path, start, length = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
mbr = bytearray(512)
entry = bytearray(16)
entry[0] = 0x80                 # one active boot partition
entry[1:4] = b'\xfe\xff\xff'  # saturated legacy CHS, LBA fields are authoritative
entry[4] = 0x0c                 # FAT32 LBA
entry[5:8] = b'\xfe\xff\xff'
struct.pack_into('<II', entry, 8, start, length)
mbr[446:462] = entry
mbr[510:512] = b'\x55\xaa'
with open(path, 'r+b') as f:
    f.write(mbr)
PY

# U-Boot's documented Allwinner BootROM location is sector 16, byte offset 8192.
dd if="$FW" of="$IMAGE" bs=1024 seek=8 conv=notrunc status=none
mformat -i "$IMAGE@@$OFFSET" -F -v OMWBOOT -N 0x4f4d5701 ::
mcopy -i "$IMAGE@@$OFFSET" "$KERNEL" ::/Image
mcopy -i "$IMAGE@@$OFFSET" "$INITRD" ::/initramfs.cpio.gz
mcopy -i "$IMAGE@@$OFFSET" "$DTB" ::/sun50i-h313-x96q-lpddr3.dtb
mcopy -i "$IMAGE@@$OFFSET" "$BOOTSCRIPT" ::/boot.scr

{
  echo "Image: $IMAGE"
  echo "Image bytes: $(stat -c %s "$IMAGE")"
  echo "Image SHA-256: $(sha256sum "$IMAGE" | awk '{print $1}')"
  echo "U-Boot offset bytes: 8192"
  echo "U-Boot bytes: $(stat -c %s "$FW")"
  echo "FAT partition start sector: $START"
  echo "FAT partition sectors: $LENGTH"
  echo "FAT partition start bytes: $OFFSET"
  echo "Image contents: source-built U-Boot, Linux Image, minimal RAM initramfs, minimal X96Q LPDDR3 DTB, U-Boot boot script"
  echo "Hardware boot status: NOT TESTED"
} | tee "$OUT/manifest.txt"
(cd "$OUT" && sha256sum "$(basename "$IMAGE")" > "$(basename "$IMAGE").sha256")
mdir -i "$IMAGE@@$OFFSET" ::
python3 - "$IMAGE" "$FW" "$START" "$LENGTH" <<'PY'
import os, struct, sys
image, firmware, start, length = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
size = os.path.getsize(image)
with open(image, 'rb') as f:
    mbr = f.read(512)
assert mbr[510:512] == b'\x55\xaa'
p = mbr[446:462]
assert p[4] == 0x0c
assert struct.unpack_from('<II', p, 8) == (start, length)
assert 8192 + os.path.getsize(firmware) < start * 512
assert (start + length) * 512 == size
with open(image, 'rb') as f:
    f.seek(8192)
    assert f.read(os.path.getsize(firmware)) == open(firmware, 'rb').read()
print('PASS: MBR, FAT partition bounds and U-Boot offset validated in the raw file.')
PY
