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

ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE ?= erofs

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)

# Add standalone vendor partition configrations
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)

# Add standalone odm partition configrations
TARGET_COPY_OUT_ODM := odm
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)

ifeq ($(BOARD_USES_SYSTEM_DLKMIMAGE), true)
  BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)
endif
ifeq ($(PRODUCT_BUILD_PRODUCT_IMAGE), true)
  BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)
endif
ifeq ($(PRODUCT_BUILD_SYSTEM_EXT_IMAGE), true)
  BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)
endif
ifeq ($(PRODUCT_BUILD_VENDOR_DLKM_IMAGE), true)
  BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)
endif
ifeq ($(PRODUCT_BUILD_ODM_DLKM_IMAGE), true)
  BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := $(ROCKCHIP_READ_ONLY_FILE_SYSTEM_TYPE)
endif

TARGET_USERIMAGES_USE_EXT4 ?= true
TARGET_USERIMAGES_USE_F2FS ?= false
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE ?= ext4

TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

# use ext4 cache for OTA
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE ?= ext4
# Add standalone metadata partition
BOARD_USES_METADATA_PARTITION ?= true

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
    include device/hardkernel/common/build/rockchip/PartitionSizesAB.mk
else
    include device/hardkernel/common/build/rockchip/PartitionSizes.mk
endif
include device/hardkernel/common/build/rockchip/PartitionSizesCommon.mk
