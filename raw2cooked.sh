#!/bin/bash

if (( $# < 2 )) ; then
    echo "Convert raw disk images to one of several common formats."
    echo "Usage: $( basename "$0" ) <format> <raw-file> [cooked-file]"
    echo "  <format>  one of: qcow | qcow2 | qed | vdi | vpc=vhd | vmdk"
    echo "  Note:"
    echo "    uses qemu-img (preferred, all formats listed above)"
    echo "    or VBoxManage (fall-back, only vdi | vpc=vhd | vmdk)"
    exit 2
fi

IFMT="raw"
OFMT="$1"
IFILE="$2"
OFILE="$3"
if [ -z "$OFILE" ] ; then
    [ "$OFMT" == "vpc" ] && OEXT="vhd" || OEXT="$OFMT"
    OFILE="${IFILE%.*}.$OEXT"
fi

if command -pv qemu-img > /dev/null ; then
    echo "$IFILE --> $OFILE"
    [ "$OFMT" == "vhd" ] && OFMT="vpc"
    echo "qemu-img convert:"
    qemu-img convert -p -f "$IFMT" -O "$OFMT" "$IFILE" "$OFILE"
elif command -pv VBoxManage > /dev/null ; then
    case $OFMT in
        vdi) OFMT=VDI ;;
        vpc|vhd) OFMT=VHD ;;
        vmdk) OFMT=VMDK ;;
        *) echo "Format '$OFMT' not supported by VBoxManage" ; exit 3 ;;
    esac
    echo "VBoxManage convertfromraw:"
    VBoxManage convertfromraw "$IFILE" "$OFILE" --format "$OFMT"
else
    echo "No supported conversion tool detected."
    exit 4
fi

# EOF
