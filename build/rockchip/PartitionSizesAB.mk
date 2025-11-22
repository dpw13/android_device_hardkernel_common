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

# Use this file as the source of truth for partition sizes. parameter.txt will
# be generated based on these values.

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
    else # No virtual AB
      BOARD_SUPER_PARTITION_SIZE := 5372903424
      BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) / 2 - 4194304)
    endif
  endif
endif
