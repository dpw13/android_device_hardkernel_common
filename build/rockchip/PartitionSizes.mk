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

ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
  ifeq ($(BUILD_WITH_GO_OPT), true)
    BOARD_SUPER_PARTITION_SIZE ?= 2516582400
  else
    BOARD_SUPER_PARTITION_SIZE ?=  3263168512
  endif
  BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE ?= $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)
else
  BOARD_SYSTEMIMAGE_PARTITION_SIZE ?= 2726297600
  BOARD_VENDORIMAGE_PARTITION_SIZE ?= 536870912
  BOARD_ODMIMAGE_PARTITION_SIZE ?= 134217728
endif
BOARD_RECOVERYIMAGE_PARTITION_SIZE ?= 100663296
ifeq ($(BOARD_AVB_ENABLE),true)
  BOARD_DTBOIMG_PARTITION_SIZE ?= 4194304
endif
