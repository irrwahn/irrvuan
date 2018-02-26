#!/bin/bash

######################################################################
# This file is part of the Irrvuan OS image builder script suite.
#
# Copyright 2018 Urban Wallasch <irrwahn35@freenet.de>
#
# See LICENSE file for more details.
#

SCRIPT_VERSION=0.0.1

set -o pipefail

# Figure out the canonical path to this very script:
WDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WDIR=$(readlink -f "$WDIR")

# Evaluate command line:
if [ "$1" == "-c" ] ; then
    shift
    MAINCFG="$1"
    shift
else
    MAINCFG="$WDIR/main.cfg"
fi
FLAVOR="$1"
if [ -z "$MAINCFG" ] || [ ! -r "$MAINCFG" ] || [ -z "$FLAVOR" ] ; then
    echo "Usage:  $(basename $0) [-c main_config] flavor"
    exit 11
fi

# Source main configuration and modules:
. "$MAINCFG"
. "$WDIR/helper"
. "$WDIR/stage_0"
. "$WDIR/stage_1"
. "$WDIR/stage_2"
. "$WDIR/stage_3"

# Trap signals to facilitate graceful abort:
trap_sig sig_handler INT QUIT TERM ERR

# Run the build stages:
START=$(ts_now)
Stage_0     # Configure build settings
Stage_1     # Prepare and loop-mount the image file
Stage_2     # Debootstrap the base system
Stage_3     # Prepare and work in chroot
cleanup     # Clean up in reverse order
log "Done, build took $(( $(datediff "$(ts_now)" "$START") / 60 )) min."
exit 0

# EOF
