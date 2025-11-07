ifdef PRODUCT_BOOTSCRIPT_TEMPLATE

$(info build boot.cmd with $(PRODUCT_BOOTSCRIPT_TEMPLATE)...)

boot_part := 6
recovery_part := 7
wifi_country := US
mtd := "sfc_nor:0x20000@0xe0000(env),0x200000@0x100000(uboot),0x100000@0x300000(splash),0xc00000@0x400000(firmware)"
target_board := $(PRODUCT_DEVICE)
target_dtb := $(PRODUCT_KERNEL_DTS)
emmc_boot_device := $(PRODUCT_BOOT_DEVICE)
sd_boot_device := $(PRODUCT_SDMMC_DEVICE)

intermediates := $(call intermediates-dir-for,FAKE,hardkernel_bootscript)
bootscript_cmd := $(intermediates)/boot.cmd
bootscript_scr := $(intermediates)/boot.scr

HARDKERNEL_BOOTSCRIPT_TOOLS := $(SOONG_HOST_OUT_EXECUTABLES)/bootscript_tools
BOOT_SCRIPT_TOOL := device/hardkernel/common/boot_script/mkbootscript.sh

$(bootscript_cmd) : $(PRODUCT_BOOTSCRIPT_TEMPLATE) $(HARDKERNEL_BOOTSCRIPT_TOOLS)
	@echo "Building boot.cmd $@."
	$(HARDKERNEL_BOOTSCRIPT_TOOLS) --input $(PRODUCT_BOOTSCRIPT_TEMPLATE) \
	--input_subscript $(PRODUCT_BOOTSCRIPT_INI_DTB_TEMPLATE) \
	--variant $(TARGET_BUILD_VARIANT) \
	--boot-part $(boot_part) \
	--recovery-part $(recovery_part) \
	--wifi-country $(wifi_country) \
	--mtd $(mtd) \
	--target-dtb $(target_dtb) \
	--target-board $(target_board) \
	--output $(bootscript_cmd) \
	--emmc-boot-device $(emmc_boot_device) \
	--sd-boot-device $(sd_boot_device)

$(bootscript_scr) : $(bootscript_cmd)
	prebuilts/tools-lineage/${HOST_OS}-x86/bin/mkimage -A arm64 -C none -T script -d $^ $(bootscript_scr)

INSTALLED_HK_BOOTSCRIPT := $(PRODUCT_OUT)/boot.cmd
$(INSTALLED_HK_BOOTSCRIPT) : $(bootscript_cmd)
	$(call copy-file-to-new-target-with-cp)

INSTALLED_HK_BOOTSCR := $(PRODUCT_OUT)/boot.scr
$(INSTALLED_HK_BOOTSCR) : $(bootscript_scr)
	$(call copy-file-to-new-target-with-cp)

INSTALLED_HK_VENDOR_BOOTSCR := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_VENDOR)/etc/boot.scr
$(INSTALLED_HK_VENDOR_BOOTSCR) : $(bootscript_scr)
	$(call copy-file-to-new-target-with-cp)

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_HK_BOOTSCRIPT) $(INSTALLED_HK_BOOTSCR) $(INSTALLED_HK_VENDOR_BOOTSCR)
endif
