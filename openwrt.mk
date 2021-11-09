include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2021.10

include $(INCLUDE_DIR)/atf.mk
include $(INCLUDE_DIR)/package.mk

define ATF/Default
  BUILD_TARGET:=amebad2
  ATF_IMAGE:=bl1_all.bin
  DEFAULT:=y

  #for fip img 
  FIP_TOOL_PATH := tools/fiptool 
  FIP_TOOL_BIN  := tools/fiptool/fiptool

  FIP_IMG_1 := ../../optee-generic/optee-2021.10/optee_os/out/arm/core/tee-pager_v2.bin
  FIP_IMG_2 := ../../optee-generic/optee-2021.10/optee_os/out/arm/core/tee-pageable_v2.bin
  FIP_IMG_3 := ../../optee-generic/optee-2021.10/optee_os/out/arm/core/tee-header_v2.bin
  FIP_IMG_4 := ../../u-boot-generic/u-boot-2021.10/u-boot-dtb.bin 
  FIP_IMG_5 := build/sheipa/debug/bl2.bin  

  #for bl1_all img 
  DUMP_TOOL_PATH := prepend_header.sh
  IMG_TOOL_PATH := imagetool.sh

  BLALL_IMG_1 := build/sheipa/debug/bl1_sram.bin
  BLALL_IMG_2 := build/sheipa/debug/bl1.bin
  BLALL_IMG_MAP := build/sheipa/debug/bl1/bl1_sym.map
  BLALL_IMG_11 := build/sheipa/debug/bl1_sram_prepend.bin
  BLALL_IMG_12 := build/sheipa/debug/bl1_prepend.bin

endef

define ATF/generic
  NAME:=amebad2
  BUILD_SUBTARGET:=generic
  ATF_CONFIG:=xxxx
endef

ATF_TARGETS := generic
ATF_MAKE_FLAGS:=DIR_RSDK=$(TOOLCHAIN_ROOT_DIR)

define Build/InstallDev
endef

$(eval $(call BuildPackage/ATF))


