# Irrvuan

Irrvuan is a set of crude and simple bash scripts to build Devuan
virtual disk images suitable for plugging into qemu or VirtualBox.


## Description

### Motivation

I wanted to have available a simple tool to mass produce Devuan
OS images for testing purposes. Plus, I needed to brush up my
rusty shell programming skills. ;-)

### What it is

* Irrvuan is basically a glorified wrapper script for debootstrap
  and some standard system tools.

* It allows for easy configurable scripted installation of the
  Devuan OS to a loop-mounted file to produce bootable disk images.
  It *should* work with genuine Debian and derived distributions,
  too. That, however, has not been tested by the author yet.

### What it is not

* Irrvuan is *not* intended to be a replacement for the Devuan
  installer, though it could probably be tweaked and (ab)used to
  install a system to a physical disk drive. Or one could simply
  `dd` the resulting image to a physical drive. Moreover, it is
  not very flexible with respect to the used partitioning scheme.

* Irrvuan is *not* a replacement for the
  [Devuan Simple Distro Kit](https://devuan.org/os/distro-kit),
  which is far more sophisticated and has a much broader range
  of possible applications.


## Installation

Clone the repository and `cd` into the `Irrvuan` directory. You
should perform all operations in this directory. So make sure to
have sufficient free space on the file system to hold the
generated image files!


## WARNING AND DISCLAIMER

A lot of operations performed by `build-image.sh` require
superuser permissions. A poor choice of configuration settings,
especially in `main.cfg`, can cause severe damage to the host
system! The author of this script takes no liability for any
damage caused by running it on your machine, you do so at your
own risk. **You have been warned!**

**NOTE:** The script uses `sudo` to gain root permissions when
needed. Thus you need to have `sudo` installed and configured
for your user, preferably with a decent password timeout. Or even
no password configured at all, if your personal security standards
would permit.


## Usage

### Overview

* The main script is called `build-image.sh`. It draws on several
  modules: `main.cfg`, `helper` and `stage_0` to `stage_3`. It
  expects at least one required argument, namely the name of a
  flavor to build. An alternative configuration file can be passed
  to the script by using the `-c` option.

* The `main.cfg` file contains the basic build environment
  settings. You should not modify it unless you really know what
  you're doing!

* The `build` directory is where the generated disk images are
  created. In a similar fashion the `log`, `mnt` and `tmp`
  directories are used to place log-files, mount-points and
  temporary files, respectively. If you want to tidy up your Irrvuan
  tree you can just delete everything inside these directories, or
  even the directories itself - they get recreated the next time
  the `build-image.sh` script is executed.

* The `flavor` directory is where you will do most of the work.
  It contains a subdirectory for each system configuration variant,
  called a *flavor*. Flavors can build up on one another, so you
  can easily create more elaborate configurations by building upon
  simpler ones without having to duplicate the entire configuration.
  Likewise, changes you make to a subordinate flavor will
  automatically propagate to those flavors that build upon it.

### Anatomy of a flavor

Each flavor subdirectory may contain the following elements:

> `overlay`
>>  a directory containing files and folders that will be copied
>>  to the resulting disk image during stage 3 (see below).

> `xtrapkg`
>>  a directory containing additional `.deb` packages to be
>>  installed during stage 3.

> `base`
>>  a file that should either be empty or consist of a single line
>>  that references another flavor the current one builds up on.

> `chrootinst`
>>  a script that is run via `chroot` inside the target system.

> `config`
>>  file containing bash variable definitions for various aspects
>>  of the system image to be generated. See the `flavor/README`
>>  file to learn more about the settings that are available in
>>  this file.

> `pkglist`
>>  list of additional packages to be installed or purged via
>>  `apt-get`, or to be configured by `dpgk-reconfigure`.

In theory all of the components mentioned above are optional.
However, it is advisable to have all of them present at least in
the basic flavor definitions you intend to use. In higher level
flavors on the other hand, it is common to omit components that
are not needed to add to or change any settings. (However, the
`base` file will of course always be present in such cases, as
it provides the required link to the next lower level flavor.)

### Script operation

When the `build-image.sh` script is run with the name of a flavor
as argument, it will first trace the chain of flavor dependencies
by evaluating the `base` files , merge the components of all linked
flavors in a temporary directory and then progresses through the
build phases outlined below to finally produce a single virtual
disk image file containing a complete system installation.

#### Stage 0: Merge and configure

Progressing along the flavor link chain from bottom to top, the
following operations take place:

* The `overlay` and `xtrapkg` folders of all linked flavors are
  amalgamated, i.e. they are copied on top of each other, to the
  effect that files in higher level flavors will potentially
  overwrite existing ones originating from subordinate flavors.

* The respective `chrootinst`, `pkglist` and `config` files of all
  flavors are concatenated, in order. The resulting files thus
  each contain all the information that was originally present in
  the individual files.

* The resulting `config` file is sourced to obtain a complete set
  of build variables. The build environment is then initialized
  accordingly.

#### Stage 1: Prepare the image file

The disk image file is created as prescribed by the build
configuration. A partition table is written and the image is then
associated with partition loop devices using `losetup`; the `boot`
and `root` file systems are initialized and mounted.

#### Stage 2: Debootstrap

The base system is installed by running `debootstrap` as configured.

#### Stage 3: Copy additional components, execute chroot

A defined set of special variables in `chrootinst` as well as in
all files in the merged `overlay` directory get substituted. All
of `overlay`, `xtrapkg`, `pkglist` and `chrootinst` is copied to
the loop device. The `chrootinst` script is executed inside a
chroot environment on the target system.

The `chrootinst` script is an essential component, as it is here
where vital tasks like e.g. password configuration, additional
package installation and final boot loader setup are performed.
You are encouraged to have a closer look at the included example
flavors, particularly the one named `basic`, to get a more detailed
notion of what this is about.


### What else?

* The supplemental `raw2cooked.sh` script can aid you in converting
the 'raw' disk images produced by `build-image.sh` into some more
common formats like e.g. `.qcow` or `.vdi`. It should be pretty
self-explanatory.


## License

Frelay is distributed under the Modified ("3-clause") BSD License.
See the `LICENSE` file for more information.