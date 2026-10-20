#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
KERNEL="$ROOT/out/kernel/Image-omw-arm64"
INITRD="$ROOT/out/initramfs/initramfs.cpio.gz"
QEMU=$(command -v qemu-system-aarch64 || true)
[[ -n "$QEMU" ]] || { echo "qemu-system-aarch64 is required" >&2; exit 1; }
[[ -s "$KERNEL" && -s "$INITRD" ]] || { echo "Build kernel and initramfs first" >&2; exit 1; }
LOG=$(mktemp)
ERR=$(mktemp)
trap 'rm -f "$LOG" "$ERR"' EXIT

# Generic QEMU ARM virt is NOT an Allwinner H313 or an X96Q.
# A serial file backend makes console capture independent of PTY behavior.
set +e
timeout 60s "$QEMU" \
  -machine virt -cpu cortex-a57 -m 512M \
  -kernel "$KERNEL" -initrd "$INITRD" \
  -append 'console=ttyAMA0,115200 rdinit=/init loglevel=7' \
  -display none -monitor none -serial "file:$LOG" -no-reboot 2>"$ERR"
status=$?
set -e
# Timeout is expected: the initramfs shell stays open awaiting serial input.
if [[ "$status" != 124 && "$status" != 0 ]]; then
  cat "$ERR" >&2
  [[ ! -s "$LOG" ]] || cat "$LOG"
  echo "QEMU exited unexpectedly with status $status" >&2
  exit 1
fi
tr -d '\r' <"$LOG" >"$LOG.normalized"
mv "$LOG.normalized" "$LOG"
for marker in \
  'Kernel command line: console=ttyAMA0,115200 rdinit=/init loglevel=7' \
  'OMW OS bring-up initramfs' \
  'This shell runs from RAM.' \
  'UART0 + MMC0 minimal test environment.'; do
  if ! grep -Fq "$marker" "$LOG"; then
    echo "QEMU serial log bytes: $(wc -c <"$LOG")" >&2
    cat "$LOG"
    cat "$ERR" >&2
    echo "Missing QEMU smoke-test marker: $marker" >&2
    exit 1
  fi
done
grep -E 'Kernel command line:|OMW OS bring-up initramfs|This shell runs from RAM|UART0 \+ MMC0' "$LOG"
echo 'PASS: generic ARM64 kernel entered OMW initramfs; serial shell remained active.'
echo 'LIMIT: does not emulate Allwinner H313, X96Q DRAM, U-Boot, or board peripherals.'
