

# LoCo Linux

This repository is adapted from the Kubos linux configuration (https://github.com/kubos/kubos-linux-build).  It contains an external configuration for Buildroot (https://buildroot.org/) that creates a disk image containing linux and the U-Boot loader for the Pumpkin MBM2 based on the BeagleBone Black single board computer.  

The disk and linux image it creates is configured as follows:
* Disk Contents:
    * Master boot record:  Contains partuuid and partition table
    * Parittion 1 (~16 MB): Boot (U-Boot binary, linux kernel binary, flattened device tree)
    * Partition 2 (~64 MB): Linux root filesystem (mounted as "/")
    * Partition 3 (~256 MB): U-Boot upgrade (*.itb) and environment storage (mounted as "/upgrade")
    * Partition 4 (~3000 MB): Rest of disk as ext4 (mounted as "/home")
* U-Boot
    * Configuration is identical to Kubos version (github.com/kubos/uboot) initially and will be modified for desired behavior soon.
* Linux 
    * Kernel 4.19
    * User accounts:  Only user account is "root", which has no password
    * BusyBox provides most of the standard command line functions, but some additional executables are included (e.g. parted)
    * USB ethernet gadget is enabled so that it appears as a USB Ethernet adapater when connected to host computer by USB.  Ethernet address of USB adapter is 192.168.7.2
    * Root filesystem contains key configurations:
        * /etc/default/dropbear: Configuration file to allow root login over SSH without password
        * /etc/dropbear/dropbear_ecdsa_host_key: Default SSH host key so it doesn't change each time loco-linux is installed
        * /etc/fstab.mmc*: Template mount tables for installation on mmc0 or mmc1.  One of these is copied to /etc/fstab during installation. 
        * /etc/inittab: Configuration of init, which runs during startup and performs disk checks and other operations before monit is started
        * /etc/init.d:  Startup and shutdown scripts, e.g, Kubos script needed for tracking U-boot upgrade status, script that disables the user LEDs on startup, etc.
        * /etc/monitrc: Configuration of monit to manage services
        * /usr/sbin/install-os: Shell script used during installation of loco-linux on target device
    * Home partition:
        * A symbolic link at /var/log points to /home/system/log.  Monit stores its logs here.


## Installation 

Download this repository by cloning it with git:

    $ git clone https://github.com/ASU-cubesat/loco-linux.git
    
Change directories to go inside loco-linux and run the setup script.  The setup script requires the board name as a command line argument and accepts several options.  Use ./setup.sh -h for details.  Typically, it is called as:

    $ cd loco-linux
    $ ./setup.sh -d -c pumpkin-mbm2
    
This will automatically download Buildroot and install it in the parent directory above loco-linux and add the loco-linux git hash to the compiled linux distribution (accessible at /proc/version on the target).   The only board currently supported is the pumpkin-mbm2.   The script regitsters the loco-linux directory with Buildroot using Buildroot's BR2_EXTERNAL make argument.

To start the build, change directories into Buildroot and call make:

    $ cd ../buildroot-2022.02.3/
    $ make
    
Buildroot will download all needed packages and compile.  The process can be lengthy and may take many minutes.

## Output

The principal output when the build completes will be in:

    buildroot-2022.02.3/output/images
    
Several files will be in this directory, but the three main output files are:

* os.img: Uncompressed disk image suitable for installing on an bootable (micro)SD card that can be used in the target device.
* os.img.gz: Compressed disk image suitable for copying to the target device and installing from an already running system.
* system.itb: Compressed partial disk image used by U-Boot to upgrade the boot (p1) and root filesystem (p2) partitions.  This can be copied to the upgrade partition (p3) of a target device that already has loco-linux running.  U-boot can then be used to install the upgrade.  
    
## Installing onto the Pumpkin-MBM2 / BeagleBone

### Method 1: Bootable micro-SD card

1. Install the os.img file onto a bootable micro-SD card.
2. Insert the card into the BeagleBone Black and power on the device.  Hold down any key during boot to enter into the U-boot command line terminal.
3. Enter the following:

        $ setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 ext4 rootwait; fatload mmc 0:1 <span>$</span>{fdtaddr} /pumpkin-mbm2.dtb; fatload mmc 0:1 ${loadaddr} /kernel; bootm <span>$</span>{loadaddr} - <span>$</span>{fdtaddr}
    
4. Enter "reset" to reboot 
5. loco-linux should boot up, running from the micro-SD card (mmc0).  
6. You should see the linux user prompt.  Enter "root".  There is no password.
7. After loggin in, the final step is to install loco-linux on the internal flash (mmc1): 

        $ install-os -i /mmcblk0 -o 1 -d -r 

### Method 2: Compressed disk image

If you already have linux (loco-linux or another reasonably functional linux) running on the BeagleBone, you can use the compressed image file to avoid having to use a micro-SD card.  

1. Copy os.img.gz to the running linux on the target, make sure it is not on the disk (mmc0 or mmc1) that you want to overwrite.
2. Run the following, replacing \<target mmc\> with either 0 or 1 for micro-SD card or internal flash, respectively.
    
        $ install-os -i ./os.img.gz -o <target mmc> -d -r 
        
### Method 3: U-Boot upgrade

To upgrade only the boot (partition 1) and root filesystem (partition 2) on an already running loco-linux installation, you can use the system.itb file:

1. Rename the file with a specific version number, e.g. system-1.0.1.itb
2. Copy the .itb file to the device and place it in /upgrade.  Note that the upgrade parition is fairly small and you made need to delete an existing lder system.itb file to make room for the new one.  
3. Set the U-Boot environment to tell it to install the new version on the next reboot:

        $ fw_setenv kubos_updatefile system-1.0.1.itb

4. Reboot
  
##   

