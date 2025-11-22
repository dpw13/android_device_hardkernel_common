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

# Use this file as the source of truth for partition sizes. parameter.txt will
# be generated based on these values.

# Header V3, add vendor_boot
ifneq ($(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),3),)
  BOARD_BOOTIMAGE_PARTITION_SIZE ?= 67108864
  # With boot header v4 and Android 13+, this needs to fit recovery resources
  # as well as boot resources
  BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE ?= 100663296
  ifneq ($(strip $(TARGET_PREBUILT_RESOURCE)),)
    BOARD_RESOURCEIMAGE_PARTITION_SIZE ?= 16777216
  endif
else
  BOARD_BOOTIMAGE_PARTITION_SIZE ?= 41943040
endif
ifneq ($(call math_gt_or_eq,$(BOARD_BOOT_HEADER_VERSION),4),)
    # init_boot partition size is recommended to be 8MB, it can be larger.
    # When this variable is set, init_boot.img will be built with the generic
    # ramdisk, and that ramdisk will no longer be included in boot.img.
    BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
endif

ifneq ($(strip $(TARGET_BOARD_HARDWARE)), odroid)
  BOARD_CACHEIMAGE_PARTITION_SIZE ?= 402653184
else
  BOARD_CACHEIMAGE_PARTITION_SIZE ?= 1073741824
endif
