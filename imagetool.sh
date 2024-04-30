#!/bin/bash 

################
# Library
################
Usage() {
    echo "Usage: $0 [Image Name]"
}

################
# Main
################
#if [ "$#" -lt 2 ]; then
#    Usage
#    exit 1
#fi

pwd

# Get Parameters
COMPILEOS=$(uname -o)

if [ "$COMPILEOS" == "GNU/Linux" ]; then
	IMAGE_FULLNAME=$1
else
	IMAGE_FULLNAME=$(realpath --relative-to=$(pwd) $1)
fi

IMAGE_FILENAME=$(basename $1)

if [ "$COMPILEOS" == "GNU/Linux" ]; then
	ELF2BIN=./elf2bin
else
	ELF2BIN=./elf2bin.exe
fi

CA32_IMG_DIR=build/amebasmart/debug


$ELF2BIN manifest manifest_ca7.json key_ca7.json $CA32_IMG_DIR/ap_image_all.bin $CA32_IMG_DIR/manifest.bin
cat $CA32_IMG_DIR/manifest.bin $CA32_IMG_DIR/ap_image_all.bin > $CA32_IMG_DIR/ap_image_all_tmp.bin
mv $CA32_IMG_DIR/ap_image_all_tmp.bin $CA32_IMG_DIR/ap_image_all.bin
