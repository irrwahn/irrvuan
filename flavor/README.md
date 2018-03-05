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

* `boot` -- directory
> Either empty, or containing configuration and supplemental files
> like `isolinux.cfg` or `syslinux.cfg` to be used when creating
> ISO9660 or USB live images.


## Settings defined in `config`

### 1. Parameters affecting disk image generation

* `IMAGE_PRE` -- string
> initial portion of the disk image file name

* `IMAGE_VER` -- string
> version tag to be used in image file name

**Note:**
Alternatively you can set the internal `$IMGNAME` variable directly,
in which case the `IMAGE_PRE` and `IMAGE_VER` settings are ignored
and the script will not compose an image file name for you. You may
reference the internal variables `$FLAVOR` (containing the flavor
name) and `$START` (an ISO8601 time stamp representing the start
date and time of the build process) in any of the image name
settings mentioned above.

* `IMAGE_SIZE` -- integer
> overall size of the disk image in MiB (megabytes base 2)

* `BOOTP_SIZE` -- integer
> size of the boot partition in MiB (megabytes base 2)

* `BOOTP_LABEL` -- string
> boot partition label

* `BOOTP_FS` -- string
> file system to use for boot partition; one of: `ext2`, `ext3`,
> `ext4`, `fat`, `msdos`, `vfat`.

* `ROOTP_SIZE` -- integer
> size of the root partition in MiB (megabytes base 2)

* `ROOTP_LABEL` -- string
> root partition label

* `ROOTP_FS` -- string
> file system to use for boot partition; one of: `ext2`, `ext3`,
> `ext4`, `fat`, `msdos`, `vfat`.


### 2. Parameters controlling `debootstrap` operation

* `ARCH` -- string
> target system architecture, e.g. `amd64` or `i386`.

**Note:** As the build script expects the second stage of
`debootstrap` to run automatically and later executes a shell in a
`chroot` environment, only architectures that are binary compatible
with the build system can reasonably be used here.

* `KERNEL` -- string
> kernel package to install

* `BASEPKG` -- string
> comma separated list of packages to include during `debootstrap`
> operation

* `COMPONENTS` -- string
> comma separated list of repository components to include, e.g.
> `main,contrib`

* `VARIANT` -- string
> usually empty (debootstrap default), or one of `minbase`,
> `buildd`, `fakechroot` (consult the `debootstrap` man page for
> further information)

* `SUITE` -- string
> codename of the OS suite to install, e.g. `jessie` or `ascii`

* `MIRURL` -- string
> URL of the repository mirror to use, see `debootstrap` man page
> for details

* `DEBSTR_XTRA` -- string
> optional: additional arguments to pass to `debootstrap` verbatim


### 3. Parameters used for target system configuration

* `ROOTPW` -- string
> password to set for the root account; leave empty to disable root
> login; a special value of '!' enables single-user-mode emergency
> login with empty root password

* `USERNM` -- string
> name to use for the unprivileged user account

* `USERPW` -- string
> password to set for the unprivileged user account

* `HOSTNAME` -- string
> target system name (goes into `/etc/hostname`); is sanitized to
> comply with the RFC rules for host names

* `DOMAIN` -- string
> optional: domain the target system will be part of

* `APTGETOPT` -- string
> optional: additional command line parameters to pass to `apt-get`
> during `pkglist` processing

* `OPENCHROOTSH` -- boolean
> boolean; start an interactive `bash` session in chroot after all
> automated tasks ran to completion, right before unmounting the
> partitions


### 4. Parameters for live image generation

**Note:** For any of the following to have any effect the live-boot
package must be installed on the target system and the syslinux
package must be installed on the build system.


* `LIVEVOLID` -- string
> volume ID for live image(s)

* `SYSLINUXMOD` -- string
> full path of directory containing the `syslinux` modules; if
> omitted, the script will try to locate it automatically in the
> `/usr` hierarchy of the build system

* `ISOCREATE` -- boolean
> create a bootable ISO9660 image from generated target system

* `ISOLINUXBIN` -- string
> full path of `isolinux.bin` file; if omitted, the script will try
> to locate it automatically in the `/usr` hierarchy of the build
> system

* `ISOGENCMD` -- string
> utility to generate ISO9660 image, e.g. `xorrisofs`, `mkisofs` or
> `genisoimage`; if omitted, the script will try to locate a suitable
> command

* `USBCREATE` -- boolean
> create a FAT32 formatted USB image with support for file backed
> persistence

* `USBSIZE` -- integer
> size of USB image in MiB (megabytes base 2); the size of the
> persistence file will be ~100MB less than the available space on
> this image size and at most 4096MB


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
> set to the loop device node on the build system associated with
> the target image (crucial for MBR boot loader installation)

* `$_OVL_BOOTP_`
> set to the build systems's device node associated with the target
> boot partition

* `$_OVL_ROOTP_`
> set to the build system's device node associated with the target
> root partition

* `$_OVL_APTGETOPT_`
> set to `$APTGETOPT`, see above


## Isolinux variable substitution

The following variables are substituted in all files in the merged
boot folder:

* `$_LIVE_KERNEL_`
> set to the path of the kernel image (relative to image root)

* `$_LIVE_INITRD_`
> set to the path of the initrd image (relative to image root)

* `$_LIVE_SQFS_`
> set to the path of the squashfs image (relative to kernel)


------------------------------------------------------------------------
