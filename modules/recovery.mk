#
# Copyright 2021 Rockchip Limited
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

PRODUCT_PACKAGES += \
    update_engine \
    update_verifier	\
    cppreopts.sh

PRODUCT_PACKAGES += \
    update_engine_sideload \
    sg_write_buffer \
    f2fs_io \
    check_f2fs

PRODUCT_PACKAGES += \
    update_engine_client

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-service \
    android.hardware.boot@1.2-impl-rockchip \
    android.hardware.boot@1.2-impl-rockchip.recovery

PRODUCT_PACKAGES += \
    bootctrl.odroid \
    bootctrl.odroid.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# A/B OTA dexopt package
PRODUCT_PACKAGES += otapreopt_script

# A/B OTA dexopt update_engine hookup
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Always use header v2 for recovery image,
# - header v4 is using bootconfig, always override cmdline in recovery;
# - header v3+ is used for virtual A/B and GKI;
# - header v2 used for the device with recovery;
ifneq ($(strip $(TARGET_PREBUILT_RESOURCE)),)
  BOARD_RECOVERY_MKBOOTIMG_ARGS ?= --second $(TARGET_PREBUILT_RESOURCE) \
      --header_version 2 \
      --cmdline "$(BOARD_KERNEL_CMDLINE) $(ROCKCHIP_ANDROID_BOOT_CMDLINE)"
else
  BOARD_RECOVERY_MKBOOTIMG_ARGS ?= --header_version 2
endif
