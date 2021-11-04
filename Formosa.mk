#
# Realtek Semiconductor Corp.
#
# Tony Wu (tonywu@realtek.com)
# Aug. 15, 2015
#
DIR_ATF		:= $(shell pwd)/boot/atf
DIR_OPTEE	:= $(shell pwd)/../optee
DIR_OPTEE_OS	:= $(DIR_OPTEE)/optee_os
DIR_UBOOT	:= $(DIR_ROOT)/package/boot/uboot
DIR_ATF_BUILD	:= $(DIR_ATF)/build/sheipa/debug

UBOOT_CONFIG 	:= /dev/null

ifneq (,$(wildcard $(DIR_UBOOT)/.config))
UBOOT_CONFIG	:= $(DIR_UBOOT)/.config
endif

SPD		:= none

ifeq ($(CONFIG_BOOT_BL32_TSP),y)
SPD		:= tspd
endif

ATF_DEP_PKGS	:= boot/uboot

ifeq ($(CONFIG_BOOT_BL32_OPTEE),y)
ifeq ($(CONFIG_SOC_CPU_ARM),y)
AARCH32_SP	:= optee
endif
ifeq ($(CONFIG_SOC_CPU_ARM64),y)
SPD		:= opteed
endif
ATF_DEP_PKGS	+= boot/optee
endif

BL32 := $(DIR_OPTEE_OS)/out/arm/core/tee-header_v2.bin
BL32_EXTRA1 := $(DIR_OPTEE_OS)/out/arm/core/tee-pager_v2.bin
BL32_EXTRA2 := $(DIR_OPTEE_OS)/out/arm/core/tee-pageable_v2.bin

ifeq ($(CONFIG_BOOT_BL32_SP_MIN),y)
AARCH32_SP	:= sp_min
endif

ifeq ($(CONFIG_ARCH_atf),"aarch32")
NEED_BL32	:= yes
SPD		:= none
endif

ifeq ($(CONFIG_BOOT_BL33_UBOOT),y)
UBOOT_OF_CTRL	:= $(shell \
		     grep "^CONFIG_OF_CONTROL=*" $(UBOOT_CONFIG) | \
		     sed 's/.*=//g')

ifeq ($(UBOOT_OF_CTRL),y)
BL33		:= $(DIR_UBOOT)/u-boot-dtb.bin
else
BL33		:= $(DIR_UBOOT)/u-boot.bin
endif
endif

ifeq ($(CONFIG_SOC_CPU_ARMv7), y)
ARM_ARCH_MAJOR		:= 7
ARM_CORTEX_A7		:= $(if $(CONFIG_SOC_CPU_ARMA7),yes)
endif

ifeq ($(CONFIG_SOC_CPU_ARMA55), y)
HW_ASSISTED_COHERENCY	:= 1
USE_COHERENT_MEM	:= 0
endif

ifeq ($(CONFIG_SOC_CPU_ARMA75), y)
HW_ASSISTED_COHERENCY	:= 1
USE_COHERENT_MEM	:= 0
endif

BUILD_STRING	:= $(shell git log -1 --pretty=format:"%h")

$(eval $(call BuildPackage,boot/atf,$(ATF_DEP_PKGS)))

ifeq ($(LLVM),1)
define boot/uboot/compile
	$(call BUILD_EXEC,$(MAKE) -C $(DIR_ATF)				\
				  PATH=$(DIR_ICECC_CROSS):$(PATH)	\
				  CC=clang				\
				  V=$(FORMOSA_VERBOSE))
endef
endif

define boot/atf/romfs
endef

define boot/atf/image
	$(Q)$(call PKG_EXEC,make -C $(DIR_ATF) fiptool fip)
	$(DIR_ATF)/prepend_header.sh $(DIR_ATF_BUILD)/bl1_sram.bin __ca7_bl1_sram_start__ $(DIR_ATF_BUILD)/bl1/bl1_sym.map 
	$(DIR_ATF)/prepend_header.sh $(DIR_ATF_BUILD)/bl1.bin __ca7_bl1_dram_start__ $(DIR_ATF_BUILD)/bl1/bl1_sym.map
	cat $(DIR_ATF_BUILD)/bl1_sram_prepend.bin $(DIR_ATF_BUILD)/bl1_prepend.bin > $(DIR_ATF_BUILD)/bl1_all.bin
	$(DIR_ATF)/imagetool.sh $(IMAGE_TARGET_FOLDER)/bl1_all.bin
	
	$(DIR_ATF)/imagetool.sh $(IMAGE_TARGET_FOLDER)/fip.bin
	
	rm -rf $(DIR_ATF_BUILD)/*prepend.bin

	$(Q)mkdir -p $(DIR_IMAGE) && \
	cp -r $(DIR_ATF_BUILD)/bl1_all.bin $(DIR_IMAGE) && \
	cp -r $(DIR_ATF_BUILD)/fip.bin $(DIR_IMAGE)

endef

define boot/atf/clean
	$(Q)rm -rf $(DIR_ATF)/build
endef
