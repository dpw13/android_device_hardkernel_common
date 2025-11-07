#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# TODO: this is probably better as build/rockchip/Partitions_AB.mk

AB_OTA_UPDATER := true
TARGET_NO_RECOVERY := true

BOARD_BOOT_HEADER_VERSION ?= 2
# After about Android 10, most devices appear to have moved to BOARD_USES_RECOVERY_AS_BOOT.
# If this is true, a "normal" non-recovery boot must pass androidboot.force_normal_boot=1
# to the kernel, resulting in a root pivot out of the recovery environment. The u-boot
# code from RK expects to be able to pass this, and the u-boot android boot code doesn't
# appear to handle a separate recovery environment (or at least we don't appear to have
# a recovery partition). Go with the path of least resistance and set this since a variety
# of code (from RK especially) seems to expect this behavior.

# UPDATE: See https://source.android.com/docs/core/architecture/partitions/generic-boot
# for an explanation of what files belong where for each boot mode. All of the HK/RK files
# assume no recovery partition and an init_boot partition with our configuration. Setting
# BOARD_USES_RECOVERY_AS_BOOT=true means no init_boot partition is produced. I don't
# completely understand why, but see build/core/board_config.mk:485 for some info.
#BOARD_USES_RECOVERY_AS_BOOT := true
#ifeq ($(BOARD_BUILD_GKI),true)
#BOARD_USES_RECOVERY_AS_BOOT :=
#endif

USE_AB_PARAMETER := $(shell test -f $(TARGET_DEVICE_DIR)/parameter_ab.txt && echo true)
ifeq ($(strip $(USE_AB_PARAMETER)), true)
    ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
        ifeq ($(PRODUCT_RETROFIT_DYNAMIC_PARTITIONS), true)
            BOARD_SUPER_PARTITION_METADATA_DEVICE := system
            BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor odm
            BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt system_a)
            BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt vendor_a)
            BOARD_SUPER_PARTITION_ODM_DEVICE_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt odm_a)

            BOARD_SUPER_PARTITION_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE) + $(BOARD_SUPER_PARTITION_ODM_DEVICE_SIZE))
            BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)
        else
            BOARD_SUPER_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt super)
            ifeq ($(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE), true)
                BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)
            else
                BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) / 2 - 4194304)
            endif
        endif
    else
        BOARD_SYSTEMIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt system_a)
        BOARD_VENDORIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt vendor_a)
        BOARD_ODMIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt odm_a)
    endif
    BOARD_CACHEIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt cache)
    BOARD_BOOTIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt boot_a)
    BOARD_DTBOIMG_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt dtbo_a)
    # Header V3, add vendor_boot
    ifneq ($(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),3),)
        BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := $(shell python3 device/hardkernel/common/get_partition_size.py $(TARGET_DEVICE_DIR)/parameter_ab.txt vendor_boot_a)
    endif
    #$(info Calculated BOARD_SYSTEMIMAGE_PARTITION_SIZE=$(BOARD_SYSTEMIMAGE_PARTITION_SIZE) use $(TARGET_DEVICE_DIR)/parameter_ab.txt)
else
    ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
        ifneq ($(PRODUCT_RETROFIT_DYNAMIC_PARTITIONS), true)
            ifeq ($(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE), true)
                ifeq ($(BUILD_WITH_GO_OPT), true)
                    ifeq ($(strip $(TARGET_ARCH)), arm64) # arm64 go
                        BOARD_SUPER_PARTITION_SIZE := 2390753280
                    else # arm go
                        BOARD_SUPER_PARTITION_SIZE := 1971322880
                    endif
                else # non-go
                    BOARD_SUPER_PARTITION_SIZE := 3263168512
                endif
                BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)
            else
                BOARD_SUPER_PARTITION_SIZE := 5372903424
                BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) / 2 - 4194304)
            endif
        endif
    endif
    ifneq ($(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),3),)
        # init_boot partition size is recommended to be 8MB, it can be larger.
        # When this variable is set, init_boot.img will be built with the generic
        # ramdisk, and that ramdisk will no longer be included in boot.img.
        BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
    else
        BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
    endif
endif
TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_DIR)/recovery.fstab_AB
