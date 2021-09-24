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
cd boot/atf

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

KM4_IMG_DIR=../../../../project_hp/asdk/image
KM0_IMG_DIR=../../../../project_lp/asdk/image
CA7_IMG_DIR=build/sheipa/debug

if [ "$IMAGE_FILENAME" == "km0_image2_all.bin" ] || [ "$IMAGE_FILENAME" == "km4_image2_all.bin" ]; then
	if [ -f $KM0_IMG_DIR/km0_image2_all.bin ]; then
		cp $KM0_IMG_DIR/km0_image2_all.bin $KM4_IMG_DIR
	fi
	
	if [ ! -f $KM4_IMG_DIR/km4_image2_all.bin ]; then
		exit
	fi
	
	if [ ! -f $KM4_IMG_DIR/km0_image2_all.bin ]; then
		exit
	fi

	rm -rf $KM4_IMG_DIR/km4_image2_all_en.bin || true
	rm -rf $KM4_IMG_DIR/km0_image2_all_en.bin || true

	cat $KM4_IMG_DIR/km0_image2_all.bin $KM4_IMG_DIR/km4_image2_all.bin > $KM4_IMG_DIR/km0_km4_image2_tmp.bin
	$ELF2BIN manifest manifest_img2.json key_img2.json $KM4_IMG_DIR/km0_km4_image2_tmp.bin $KM4_IMG_DIR/manifest.bin
	$ELF2BIN rsip $KM4_IMG_DIR/km0_image2_all.bin $KM4_IMG_DIR/km0_image2_all_en.bin 0x0c000000 manifest_img2.json
	$ELF2BIN rsip $KM4_IMG_DIR/km4_image2_all.bin $KM4_IMG_DIR/km4_image2_all_en.bin 0x0e000000 manifest_img2.json
	$ELF2BIN cert cert.json key_cert.json $KM4_IMG_DIR/cert.bin 0 key_img2.json 1 key_img3.json 2 key_ca7_bl1.json

	if [ -f $KM4_IMG_DIR/km0_image2_all_en.bin ] && [ -f $KM4_IMG_DIR/km4_image2_all_en.bin ]; then
		rm -rf $KM4_IMG_DIR/km0_km4_image2_tmp.bin
		cat $KM4_IMG_DIR/km0_image2_all_en.bin $KM4_IMG_DIR/km4_image2_all_en.bin > $KM4_IMG_DIR/km0_km4_image2_tmp.bin
		cat $KM4_IMG_DIR/cert.bin $KM4_IMG_DIR/manifest.bin $KM4_IMG_DIR/km0_km4_image2_tmp.bin > $KM4_IMG_DIR/km0_km4_image2.bin
	else
		cat $KM4_IMG_DIR/cert.bin $KM4_IMG_DIR/manifest.bin $KM4_IMG_DIR/km0_km4_image2_tmp.bin > $KM4_IMG_DIR/km0_km4_image2.bin
	fi

	rm -rf $KM4_IMG_DIR/km0_km4_image2_tmp.bin
	
fi

if [ "$IMAGE_FILENAME" == "km4_boot_all.bin" ]; then
	rm -rf $KM4_IMG_DIR/km4_boot_all_en.bin || true

	$ELF2BIN manifest manifest_boot.json key_boot.json $KM4_IMG_DIR/km4_boot_all.bin $KM4_IMG_DIR/manifest.bin
	$ELF2BIN rsip $KM4_IMG_DIR/km4_boot_all.bin $KM4_IMG_DIR/km4_boot_all_en.bin 0x08001000 manifest_boot.json

	if [ -f $KM4_IMG_DIR/km4_boot_all_en.bin ]; then
		cat $KM4_IMG_DIR/manifest.bin $KM4_IMG_DIR/km4_boot_all_en.bin > $KM4_IMG_DIR/km4_boot_all_tmp.bin
	else
		cat $KM4_IMG_DIR/manifest.bin $KM4_IMG_DIR/km4_boot_all.bin > $KM4_IMG_DIR/km4_boot_all_tmp.bin
	fi

	mv $KM4_IMG_DIR/km4_boot_all_tmp.bin $KM4_IMG_DIR/km4_boot_all.bin
fi

if [ "$IMAGE_FILENAME" == "ram_1_prepend.bin" ]; then
	$ELF2BIN manifest manifest_boot.json key_boot.json $KM4_IMG_DIR/ram_1_prepend.bin $KM4_IMG_DIR/manifest.bin
	cat $KM4_IMG_DIR/ram_1_prepend.bin $KM4_IMG_DIR/manifest.bin > $KM4_IMG_DIR/imgtool_flashloader_amebad2.bin
fi

if [ "$IMAGE_FILENAME" == "km4_image3_all.bin" ]; then
	$ELF2BIN manifest manifest_img3.json key_img3.json $KM4_IMG_DIR/km4_image3_all.bin $KM4_IMG_DIR/manifest.bin
	$ELF2BIN rdp enc manifest_img3.json $KM4_IMG_DIR/km4_image3_all.bin $KM4_IMG_DIR/km4_image3_all_tmp.bin
	cat $KM4_IMG_DIR/manifest.bin $KM4_IMG_DIR/km4_image3_all_tmp.bin > $KM4_IMG_DIR/km4_image3_all.bin
	rm -rf $KM4_IMG_DIR/km4_image3_all_tmp.bin
fi

if [ "$IMAGE_FILENAME" == "bl1_all.bin" ]; then
	$ELF2BIN manifest manifest_ca7_bl1.json key_ca7_bl1.json $CA7_IMG_DIR/bl1_all.bin $CA7_IMG_DIR/manifest.bin
	cat $CA7_IMG_DIR/manifest.bin $CA7_IMG_DIR/bl1_all.bin > $CA7_IMG_DIR/bl1_all_tmp.bin
	mv $CA7_IMG_DIR/bl1_all_tmp.bin $CA7_IMG_DIR/bl1_all.bin
fi



