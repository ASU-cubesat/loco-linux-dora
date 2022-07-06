#!/bin/sh

#set -e -x

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

cd $SCRIPTPATH

buildroot="buildroot-2022.02.1"
buildroot_downloads="https://buildroot.uclibc.org/downloads"
buildroot_dir="$SCRIPTPATH/../$buildroot"
buildroot_make_args=

board=
download=
commit=
version=
localversion_string=
localversion_file=$SCRIPTPATH/linux-localversion.config


######################################
### Define the help message        ###
######################################
help_message="
  Configures buildroot to use this external tree by calling
  'make' from the buildroot directory (assumed to be in the
  parent directory) with the BR2_EXTERNAL flag set to this
  path and the board name set to the name specified using
  the -b option described below.  Buildroot will remember
  these settings until its 'make distclean' is called.

  After running setup.sh, change to the buildroot directory
  and execute 'make' (no command line options required) to
  start the build.

  Syntax: ./setup.sh [-b|c|d|h|v]
  options:
   -b name    (required) Specify board name, e.g. pumpking-mbmb2
   -c         Add the current git commit hash to the linux kernel
              local version info.  Overwrites the file:
              ./linux-localversion.config.  If used with -v, both
              will be added to the version info.
   -d         Download and unzip buildroot to the parent directory
   -h         Print this help
   -v text    Add a custom version string to the linux kernel
              local version info (must be shorter than 54 
              characters).  Overwrites the file:
              ./linux-localversion.config.  If used with -c, both
              will be added to the version info.
"

######################################
### Parse the command line options ###
######################################
while getopts ":b:cdhv:" option
do
    case $option in
        b)
            board=$OPTARG
            ;;
        c)
            commit=`git rev-parse --verify HEAD | head -c 8`
            ;;
        d)
            download=1
            ;;
        h)
            echo "$help_message"
            exit 0
            ;;
        v)
            version=$OPTARG
            ;;
        :)
            echo "Error:  Missing argument for -${OPTARG}." >&2
            echo "$help_message" >&2
            exit 1
            ;;
        \?)
            echo "Error:  Unrecognized argument ${OPTARG}." >&2
            echo "$help_message" >&2
            exit 1
            ;;
    esac
done

if [ -z "$board" ]
then
    echo "Error:  Argument -b must be provided." >&2
    echo "$help_message" >&2
    exit 1
fi

#######################################
### Do some local git configuration ###
#######################################

cd $SCRIPTPATH

echo "Configuring git to overlook changes in ${localversion_file}..."
git update-index --assume-unchanged $localversion_file

#cd ..
#git init 
#git config --local url."https://".insteadOf git://


#############################################################
### Download and install the buildroot package (optional) ###
#############################################################
if ! ${download}
then
    cd $SRIPTPATH/..

    echo "Downloading buildroot..."
    wget $buildroot_downloads/$buildroot.tar.gz 

    echo "Unpacking buildroot..."
    tar xzf $buildroot.tar.gz

    echo "Removing temporary files..."
    rm $buildroot.tar.gz

    echo "Download complete"

fi

#####################################
### Make the local version string ###
#####################################

#  Add the version number specified on the command line
if [ ! -z "$version" ]
then
    echo "Adding custom string \"${version}\" linux kernal version..."
    localversion_string="${localversion_string}-${version}"
fi

# Add the latest git commit for this repository (not the linux kernel source tree)
if [ ! -z "$commit" ]
then
    echo "Adding git commit hash ${commit} to linux kernal version..."
    localversion_string="${localversion_string}-${commit}"
fi

# Overwite the localversion_file with the new string
if [ ! -z "$localversion_string" ]
then
    echo "Creating ./linux-localversion.config with CONFIG_LOCALVERSION=\"${localversion_string}\""
    echo "# This file auto created by ./setup.sh on " `date -u` > $localversion_file
    echo "CONFIG_LOCALVERSION=\"${localversion_string}\"" >> $localversion_file
fi

###############################################################
### Tell buildroot about this external tree and config file ###
###############################################################

# Buildroot will automatically look in the "configs" subfolder 
# for the specified default configuration file.  Buildroot will 
# remember this tree exists, so you don't have to tell it each 
# time you call make.
echo "Adding this tree to buildroot for board: $board..."
cd $buildroot_dir

# Add the path to this external tree
buildroot_make_args="${buildroot_make_args} BR2_EXTERNAL=\"${SCRIPTPATH}\""

# End the buildroot make arguments with the default configuration file
buildroot_make_args="${buildroot_make_args} ${board}_defconfig"

# Call make so buildroot remembers these settings
echo "`pwd`"
echo "Calling: make ${buildroot_make_args}"
make $buildroot_make_args

##################
### End tidily ###
##################
echo "Done setting up"






