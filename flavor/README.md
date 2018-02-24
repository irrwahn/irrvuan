# Irrvuan flavors explained

## Components of a flavor

Each flavor subdirectory may contain one or more of the following
elements:

> `base` -- text file
>>  Either empty, or consisting of a single line to specify the
>>  name of another flavor to merge.

> `chrootinst` -- bash script
>>  Either empty, or containing instructions that are executed
>>  inside a `chroot` environment on the target system.
>>  Among other things it is responsible for setting up accounts,
>>  configuring console settings, processing `xtrapkg` and `pkglist`
>>  and installing the boot loader. The `chrrotinst` script provided
>>  in the sample `basic` flavor should give a good impression of
>>  the tasks performed.
>>  Certain variables get substituted when the script is copied
>>  to the disk image, see below.

> `config` -- bash fragment
>>  Either empty or containing variable assignments to control the
>>  build process and define relevant settings in the target system.
>>  See below for a comprehensive list of variables .

> `overlay` -- directory tree
>>  Either empty, or containing arbitrary files and folders that
>>  get copied to the produced disk image.
>>  Certain variables get substituted when files are copied
>>  to the disk image, see below for a comprehensive list.

> `xtrapkg` -- flat directory
>>  Either empty, or containing additional `.deb` packages to
>>  install in the target system image.

> `pkglist` -- text file
>>  Either empty, or containing a flat list of package actions,
>>  one per line.
>>  A package action consists of one of the letters `i`, `p` or
>>  `c` followed by a blank and the name of a package to *install*
>>  via `apt-get` from the repository, to *purge* via `apg-get` from
>>  the installation, or to *reconfigure* via `dpkd-reconfigure`,
>>  respectively, in any order. For example:

                i a-package           # install 'a-package'
                p smelly-package      # purge 'smelly-package'
                i nice-package        # install 'nice-package'
                c you-know-the-drill  # configure 'you-know-the-drill'


## Settings defined in `config`

### 1. Parameters affecting disk image generation

> IMAGE_PRE
>>  initial portion of the disk image file name

> IMAGE_VER
>>  version tag to be used in image file name
>>
>>  **Note:**
>>  Alternatively, you can directly set the internal `$IMGNAME`
>>  variable, in which case the `IMAGE_PRE` and `IMAGE_VER` settings
>>  are ignored and the script will not compose an image file name
>>  for you.
>>  Furthermore, you may reference the internal variables `$FLAVOR`
>>  (containing the flavor name) and `$START` (containing an ISO 8601
>>  time stamp representing the start date and time of the build
>>  process) in any of the above image name settings.

> IMAGE_SIZE
>>  overall size of the disk image in MiB (megabytes base 2)

> BOOTP_SIZE
>>  size of the boot partition in MiB (megabytes base 2)

> BOOTP_LABEL
>>  boot partition label (used in `/etc/fstab`)

> BOOTP_FS
>>  file system to use for boot partition; one of: `ext2`, `ext3`,
>>  `ext4`, `fat`, `msdos`, `vfat`.

> ROOTP_SIZE
>>  size of the root partition in MiB (megabytes base 2)

> ROOTP_LABEL
>>  root partition label (used in `/etc/fstab`)

> ROOTP_FS
>>  file system to use for boot partition; one of: `ext2`, `ext3`,
>>  `ext4`, `fat`, `msdos`, `vfat`.


### 2. Parameters controlling `debootstrap` operation

> ARCH
>>  target system architecture, e.g. `amd64` or `i386`.
>>
>>  **Note:** As the build script expects the second stage of
>>  `debootstrap` to run automatically and later executes a shell
>>  in a `chroot` environment, only architectures that are binary
>>  compatible with the host system can reasonably be used here.

> KERNEL
>>  kernel package to install

> BASEPKG
>>  comma separated list of packages to include during `debootstrap`
>>  operation

> COMPONENTS
>> comma separated list of repository components to include, e.g.
>> `main,contrib`

> VARIANT
>>  usually empty (debootstrap default), or one of `minbase`,
>>  `buildd`, `fakechroot` (consult the `debootstrap` man page for
>>  further information)

> SUITE
>>  codename of the OS suite to install, e.g. `ascii`

> MIRURL
>>  URL of the repository mirror to use, see `debootstrap` man page
>>  for details

> DEBSTR_XTRA
>>  optional: additional arguments to pass to `debootstrap` verbatim


### 3. Parameters used for target system configuration

> ROOTPW
>>  password to set for the root account

> USER
>>  name to use for the unprivileged user account

> USERPW
>>  password to set for the unprivileged user account

> HOSTNAME
>>  target system name (goes into `/etc/hostname`)

> DOMAIN
>>  optional: domain the target system will be part of

> APTGETOPT
>>  optional: additional command line parameters to pass to `apt-get`
>>  during `pkglist` processing

> OPENCHROOTSH
>>  start an interactive `bash` session in chroot, after all automated
>>  tasks ran to completion, right before unmounting the partitions


## Variable substitution

Below you find a comprehensive list of all special variables that get
automatically substituted when copying the `chrootinst` script as well
as all the files originating from the merged `overlay` directory:

> `$_OVL_HOSTNAME_`
>>  set to `$HOSTNAME`, see above

> `$_OVL_FQDN_`
>>  fully qualified domain name; composed from `$HOSTNAME` and
>>  `$DOMAIN`, see above

> `$_OVL_ROOTP_LABEL_`
>>  set to `$ROOTP_LABEL`, see above

> `$_OVL_ROOTP_FS_`
>>  set to `$ROOTP_FS`, see above

> `$_OVL_BOOTP_LABEL_`
>>  set to `$BOOTP_LABEL`, see above

> `$_OVL_BOOTP_FS_`
>>  set to `$BOOTP_FS`, see above

> `$_OVL_USER_`
>>  set to `$USER`, see above

> `$_OVL_USERPW_`
>>  set to `$USERPW`, see above

> `$_OVL_ROOTPW_`
>>  set to `$ROOTPW`, see above

> `$_OVL_LOOPD_`
>>  set to the loop device node on the host system associated with the
>>  target image (crucial for MBR boot loader installation)

> `$_OVL_APTGETOPT_`
>>  set to `$APTGETOPT`, see above

