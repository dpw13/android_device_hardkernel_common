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

AB_OTA_UPDATER := true
TARGET_NO_RECOVERY := true

# Uboot does not belong here as (currently) the SPL is not slot aware
# TODO: verify that
AB_OTA_PARTITIONS += \
    boot

ifneq ($(strip $(BOARD_ROCKCHIP_TRUST_MERGE_TO_UBOOT)),true)
  AB_OTA_PARTITIONS += \
      trust
endif

ifeq ($(strip $(BOARD_AVB_ENABLE)),true)
  AB_OTA_PARTITIONS += \
      vbmeta
endif

# Even though dynamic partitions do not really get separate A/B partitions
# with virtual A/B, we still need to mark them for AB OTA
AB_OTA_PARTITIONS += \
    system \
    vendor \
    odm
ifneq ($(BOARD_USES_AB_LEGACY_RETROFIT),true)
AB_OTA_PARTITIONS += \
    system_dlkm \
    system_ext \
    vendor_dlkm \
    odm_dlkm \
    product
endif

BOARD_BOOT_HEADER_VERSION ?= 2

ifeq (true,$(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),3))
  # NOTE: Resource partition used for AVB, rockchip specific?
  AB_OTA_PARTITIONS += \
      vendor_boot

  ifeq (true,$(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),4))
    AB_OTA_PARTITIONS += \
        init_boot
  endif

endif

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

TARGET_RECOVERY_FSTAB := $(TARGET_DEVICE_DIR)/recovery.fstab_AB
