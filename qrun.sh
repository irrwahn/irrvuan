#!/bin/sh

if [ -z "$1" ] ; then
    echo "Usage: $(basename "$0") [more_qemu_options] <image_file>"
    exit 1
fi

ARCH=$(uname -m)
case $ARCH in
    x86_64)
        QSYS=qemu-system-x86_64
        ;;
    i686)
        QSYS=qemu-system-i386
        ;;
    *)
        echo "unsupported arch: $ARCH"
        exit 2
        ;;
esac
NCORE=$(($(nproc) / 2))
[ "$NCORE" -eq 0 ] && NCORE=1
MEMSZ=$(($(grep MemFree /proc/meminfo | grep -oE '[0-9]+') / 2048))
[ "$MEMSZ" -eq 0 ] && MEMSZ=512

echo "ARCH=$ARCH"
echo "NCORE=$NCORE"
echo "MEMSZ=$MEMSZ"MB

$QSYS -m "$MEMSZ"M -cpu host -smp cores="$NCORE" -enable-kvm \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  "$@"
