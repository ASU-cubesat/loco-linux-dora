#!/bin/sh

BOARD_DIR="$(dirname $0)" # path to location of this file
CURR_DIR="$(pwd)"
UBOOT_BRANCH=$2
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
GENIMAGE_1="internal_mmc" # use image name from inside genimage.cfg
GENIMAGE_2="microsd"      # use image name from inside genimage.cfg
KERNEL_ITS="kernel.its"
KERNEL_ITB="kernel"
SYSTEM_ITS="system.its"
SYSTEM_ITB="system.itb"

#########################################################
### Create the kernel flattened image tree (FIT) file ###
#########################################################
echo "post_image.sh: Creating the kernel image tree blob..."

# Copy the ITS file to the buildroot images directory so it is in the same folder as zImage
cp ${BOARD_DIR}/${KERNEL_ITS} ${BINARIES_DIR}/

# Run u-boot's mkimage to create the image tree blob
${BASE_DIR}/build/uboot-${UBOOT_BRANCH}/tools/mkimage -f ${BINARIES_DIR}/${KERNEL_ITS} ${BINARIES_DIR}/${KERNEL_ITB}

############################################################################
### Create the system (kernel, rootfs, device_tree) flattened image file ###
############################################################################
echo "Creating the system (kernel, rootfs, device_tree) image tree blob..."

# Copy the ITS file to the buildroot images directory as kernel, rootfs, and dts files
cp ${BOARD_DIR}/${SYSTEM_ITS} ${BINARIES_DIR}/

# Run u-boot's mkimage to create the image tree blob and put it in the target 
# filesystem /upgrade directory so it is there when generating the microsd 
# disk image next.  This is so it is present in case u-boot needs to revert 
# to it if an attempted upgrade fails.
${BASE_DIR}/build/uboot-${UBOOT_BRANCH}/tools/mkimage -E -f ${BINARIES_DIR}/${SYSTEM_ITS} ${TARGET_DIR}/upgrade/${SYSTEM_ITB}

###########################
### Generate the images ###
###########################
echo "post_image.sh: Creating full disk images..."

mkdir ${TARGET_DIR}/microsd
cd ${CURR_DIR}
genimage \
    --rootpath "${TARGET_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"

###################################
### GZIP images to reduce space ###
###################################
echo "post_image.sh: Creating compressed (tar.gz) versions of disk images..."

tar -czf ${BINARIES_DIR}/${GENIMAGE_1}.tar.gz -C ${BINARIES_DIR} ${GENIMAGE_1}.img
tar -czf ${BINARIES_DIR}/${GENIMAGE_2}.tar.gz -C ${BINARIES_DIR} ${GENIMAGE_2}.img

###############
### Cleanup ###
###############
echo "post_image.sh: Cleaning up..."

# Move the SYSTEM_ITB blob from the binaries folder in case it is needed for an upgrade
mv ${TARGET_DIR}/upgrade/${SYSTEM_ITB} ${BINARIES_DIR}/

# What was this for???
rmdir ${TARGET_DIR}/microsd

# Remove the partition images to free up disk space since these are included in 
# the full disk images
rm ${BINARIES_DIR}/user
rm ${BINARIES_DIR}/aux-user
rm ${BINARIES_DIR}/upgrade

# Remove the uncompressed full disk images to free up disk space since we have
# the gzip compressed versions
rm ${BINARIES_DIR}/${GENIMAGE_1}.img
rm ${BINARIES_DIR}/${GENIMAGE_2}.img

# Remove genimage temporary files
rm -rf "${GENIMAGE_TMP}"

echo "post_image.sh: Done."

