#!/bin/sh

set -e -x

buildroot="buildroot-2022.02.1"
buildroot_downloads="https://buildroot.uclibc.org/downloads"

external_dir="$(pwd)"
buildroot_dir="$external_dir/../$buildroot"

download=
version=
board=

######################################
### Parse the command line options ###
######################################
while getopts "b:dv:" option
do
    case $option in
        b | --board)
            board=$OPTARG
            ;;
        d | --download)
            download=1
            ;;
        v | --version)
            version=$OPTARG
            ;;
        \?)
            exit 1
            ;;
    esac
done

echo $external_dir
echo $buildroot_dir
echo $board
echo $download
echo $version

#############################################################
### Download and install the buildroot package (optional) ###
#############################################################
if ! ${download}
then
    cd ..

    echo "Downloading buildroot..."
    wget $buildroot_downloads/$buildroot.tar.gz 

    echo "Unpacking buildroot..."
    tar xzf $buildroot.tar.gz

    echo "Removing temporary files..."
    rm $buildroot.tar.gz

    echo "Download complete"
fi

####################
### Add git hash ###
####################


################################
### Specify a version number ###
################################


#latest_tag=`git tag --sort=-creatordate | head -n 1`
#sed -i "s/0.0.0/$latest_tag/g" board/pumpkin-mbm2/linux.config

#echo "Building $latest_tag"

#cd .. #cd out of the kubos-linux-build directory

#git init 
#git config --local url."https://".insteadOf git://

###############################################################
### Tell buildroot about this external tree and config file ###
###############################################################

# Buildroot will automatically look in the "configs" subfolder 
# for the specified default configuration file.  Buildroot will 
# remember this tree exists, so you don't have to tell it each 
# time you call make.
echo "Adding this tree to buildroot for board: $board..."
cd $buildroot_dir
make BR2_EXTERNAL="${external_dir}" ${board}_defconfig

##################
### End tidily ###
##################

# Return the original directory and end
cd $external_dir
echo "Done setting up"






