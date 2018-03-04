# Irrvuan flavors explained

## Components of a flavor

Each flavor subdirectory may contain one or more of the following
elements:

* `base` -- text file
> Either empty, or consisting of a single line to specify the name
> (not path!) of another flavor to merge.

* `chrootinst` -- bash script
> Either empty, or containing instructions that are executed
> inside a `chroot` environment on the target system.
> Among other things it is responsible for setting up accounts,
> configuring console settings, processing `xtrapkg` and `pkglist`
> and installing the boot loader. The `chrootinst` script provided
> in the `basic` flavor sample should give a good impression of
> the tasks performed.
> Certain variables get substituted when the script is copied
> to the disk image, see below.

* `config` -- bash fragment
> Either empty or containing variable assignments to control the
> build process and define relevant settings in the target system.
> See below for a comprehensive list of available variables .

* `overlay` -- directory tree
> Either empty, or containing arbitrary files and folders to copy
> to the target system. Certain variables get substituted when
> files are copied, see below for a comprehensive list.

* `xtrapkg` -- flat directory
> Either empty, or containing additional `.deb` packages to
> install in the target system image.

* `pkglist` -- text file
> Either empty, or containing a flat list of package actions,
> one per line.
> A package action consists of one of the letters `i`, `p` or
> `c` followed by a blank and the name of a package to *install*
> via `apt-get` from the repository, to *purge* via `apg-get` from
> the installation, or to *reconfigure* via `dpkd-reconfigure`,
> respectively, in any order. For example:

                i a-package           # install 'a-package'
                p smelly-package      # purge 'smelly-package'
                i nice-package        # install 'nice-package'
                c you-know-the-drill  # configure 'you-know-the-drill'

* `isolinux` -- flat directory
> Either empty, or containing `isolinux.cfg` and / or `syslinux.cfg`
> configuration files, which are used when creating ISO or USB live
> images.


## Settings defined in `config`

### 1. Parameters affecting disk image generation

* IMAGE_PRE
> initial portion of the disk image file name

* IMAGE_VER
> version tag to be used in image file name

**Note:**
Alternatively you can set the internal `$IMGNAME` variable directly,
in which case the `IMAGE_PRE` and `IMAGE_VER` settings are ignored
and the script will not compose an image file name for you. You may
reference the internal variables `$FLAVOR` (containing the flavor
name) and `$START` (an ISO 8601 time stamp representing the start
date and time of the build process) in any of the image name
settings mentioned above.

* IMAGE_SIZE
> overall size of the disk image in MiB (megabytes base 2)

* BOOTP_SIZE
> size of the boot partition in MiB (megabytes base 2)

* BOOTP_LABEL
> boot partition label

* BOOTP_FS
> file system to use for boot partition; one of: `ext2`, `ext3`,
> `ext4`, `fat`, `msdos`, `vfat`.

* ROOTP_SIZE
> size of the root partition in MiB (megabytes base 2)

* ROOTP_LABEL
> root partition label

* ROOTP_FS
> file system to use for boot partition; one of: `ext2`, `ext3`,
> `ext4`, `fat`, `msdos`, `vfat`.


### 2. Parameters controlling `debootstrap` operation

* ARCH
> target system architecture, e.g. `amd64` or `i386`.

**Note:** As the build script expects the second stage of
`debootstrap` to run automatically and later executes a shell in a
`chroot` environment, only architectures that are binary compatible
with the host system can reasonably be used here.

* KERNEL
> kernel package to install

* BASEPKG
> comma separated list of packages to include during `debootstrap`
> operation

* COMPONENTS
> comma separated list of repository components to include, e.g.
> `main,contrib`

* VARIANT
> usually empty (debootstrap default), or one of `minbase`,
> `buildd`, `fakechroot` (consult the `debootstrap` man page for
> further information)

* SUITE
> codename of the OS suite to install, e.g. `jessie` or `ascii`

* MIRURL
> URL of the repository mirror to use, see `debootstrap` man page
> for details

* DEBSTR_XTRA
> optional: additional arguments to pass to `debootstrap` verbatim


### 3. Parameters used for target system configuration

* ROOTPW
> password to set for the root account; leave empty to disable root
> login; a special value of '!' enables single-user-mode emergency
> login with empty root password

* USERNM
> name to use for the unprivileged user account

* USERPW
> password to set for the unprivileged user account

* HOSTNAME
> target system name (goes into `/etc/hostname`)

* DOMAIN
> optional: domain the target system will be part of

* APTGETOPT
> optional: additional command line parameters to pass to `apt-get`
> during `pkglist` processing

* OPENCHROOTSH
> boolean; start an interactive `bash` session in chroot after all
> automated tasks ran to completion, right before unmounting the
> partitions


### 4. Parameters for live image generation

* ISOCREATE
> boolean; enable build step to produce a bootable live ISO image
> from target system; for this to work, the live-boot package must
> be installed in the target system

* ISOVOLID
> volume ID for live ISO image

* ISOGENCMD
> utility to generate ISO image, e.g. `xorrisofs`, `mkisofs` or
> `genisoimage`; if omitted, the script will try to pick a suitable
> command

* ISOLINUXBIN
> full path of `isolinux.bin` file; if omitted, the script will try
> to locate it automatically in the `/usr` hierarchy

* ISOLINUXMOD
> full path of directory containing the `syslinux` modules; if
> omitted, the script will try to locate it automatically in the
> `/usr` hierarchy

* USBCREATE
> boolean; in addition to the ISO image create an FAT32 formatted
> USB image with support for file backed persistent storage

* USBSIZE
> size of USB image in MiB (megabytes base 2); the size of the
> persistence file will be ~100MB less than this image size and
> at most 4096MB

* USBLABEL
> volume label for the FAT32 file system


## Overlay variable substitution

Below you find a comprehensive list of all special variables that get
automatically substituted when copying the `chrootinst` script as well
as all the files originating from the merged `overlay` directory:

* `$_OVL_HOSTNAME_`
> set to `$HOSTNAME`, see above

* `$_OVL_FQDN_`
> fully qualified domain name; composed from `$HOSTNAME` and
> `$DOMAIN`, see above

* `$_OVL_ROOTP_LABEL_`
> set to `$ROOTP_LABEL`, see above

* `$_OVL_ROOTP_FS_`
> set to `$ROOTP_FS`, see above

* `$_OVL_BOOTP_LABEL_`
> set to `$BOOTP_LABEL`, see above

* `$_OVL_BOOTP_FS_`
> set to `$BOOTP_FS`, see above

* `$_OVL_USERNM_`
> set to `$USERNM`, see above

* `$_OVL_USERPW_`
> set to `$USERPW`, see above

* `$_OVL_ROOTPW_`
> set to `$ROOTPW`, see above

* `$_OVL_LOOPD_`
> set to the loop device node on the host system associated with the
> target image (crucial for MBR boot loader installation)

* `$_OVL_BOOTP_`
> set to the host device node associated with the target boot partition

* `$_OVL_ROOTP_`
> set to the host device node associated with the target root partition

* `$_OVL_APTGETOPT_`
> set to `$APTGETOPT`, see above


## Isolinux variable substitution

The following variables are substituted in all files in the merged
isolinux folder:

* `$_ISO_KERNEL_`
> set to the path of the kernel image (relative to ISO root)

* `$_ISO_INITRD_`
> set to the path of the initrd image (relative to ISO root)

* `$_ISO_SQFS_`
> set to the path of the squashfs image (relative to kernel)


------------------------------------------------------------------------
