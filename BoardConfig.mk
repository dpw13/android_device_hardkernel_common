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
TARGET_BOARD_PLATFORM ?= rk3568
TARGET_BOARD_HARDWARE ?= odroid
PRODUCT_KERNEL_VERSION ?= 6.1

TARGET_ARCH ?= arm
TARGET_ARCH_VARIANT ?= armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER ?= true
TARGET_CPU_ABI ?= armeabi-v7a
TARGET_CPU_ABI2 ?= armeabi
TARGET_CPU_VARIANT ?= cortex-a9
TARGET_CPU_SMP ?= true

BOARD_PLATFORM_VERSION := 12.0

# Enable android verified boot 2.0
BOARD_AVB_ENABLE ?= false
#ifeq ($(strip $(TARGET_BOARD_HARDWARE)), odroid)
#BOARD_BOOT_HEADER_VERSION ?= 1
#else
#BOARD_BOOT_HEADER_VERSION ?= 2
#endif
#BOARD_MKBOOTIMG_ARGS :=
#ifneq ($(strip $(TARGET_BOARD_HARDWARE)), odroid)
#BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_DEVICE_DIR)/dtbo.img
#endif
BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE ?= false
BOARD_SELINUX_ENFORCING ?= false
PRODUCT_KERNEL_ARCH ?= arm

#TWRP
BOARD_TWRP_ENABLE ?= false

# Android T requires thermal HAL.
BOARD_ROCKCHIP_THERMAL ?= true

ifeq ($(PRODUCT_FS_COMPRESSION), 1)
include device/hardkernel/common/build/rockchip/F2fsCompression.mk
endif

include device/hardkernel/common/build/rockchip/Partitions.mk

# Use the non-open-source parts, if they're present
ifeq ($(PRODUCT_KERNEL_ARCH), arm)
  # build/tasks/kernel.mk says BOARD_KERNEL_IMAGE_NAME should include "-dtb" to
  # the image name if including the DTB, but this appears to be obsolete.
  # Instead, it looks like BOARD_KERNEL_APPEND_DTBS can be used to do this automatically
  # but it doesn't appear to be actually used anywhere.
  BOARD_KERNEL_IMAGE_NAME ?= zImage
else # arm64
  BOARD_KERNEL_IMAGE_NAME ?= Image.gz
endif

TARGET_PREBUILT_RESOURCE ?= $(TARGET_KERNEL_SOURCE)/resource.img
PRODUCT_PARAMETER_TEMPLATE ?= device/hardkernel/common/scripts/parameter_tools/parameter.in
PRODUCT_BOOTSCRIPT_TEMPLATE ?= device/hardkernel/common/scripts/bootscript_tools/bootscript.in
PRODUCT_BOOTSCRIPT_INI_DTB_TEMPLATE := device/hardkernel/common/scripts/bootscript_tools/bootscript_dtb_ini.in
TARGET_BOARD_HARDWARE_EGL ?= mali

#Android GO configuration
BUILD_WITH_GO_OPT ?= false

# default.prop & build.prop split
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED ?= true

DEVICE_MANIFEST_FILE ?= device/hardkernel/common/manifests/manifest_level_$(PRODUCT_SHIPPING_API_LEVEL).xml
# TODO: this line appears to be causing `expr` syntax errors if inherit-product appears before it
#ifeq (true,$(call math_gt_or_eq,$(PRODUCT_SHIPPING_API_LEVEL),31)))
# Android S deprecate schedulerservice, use ioprio in init.rc
DEVICE_MATRIX_FILE   ?= device/hardkernel/common/manifests/compatibility_matrix_level_31.xml
#else
# For Android R and older versions.
#DEVICE_MATRIX_FILE   ?= device/hardkernel/common/manifests/compatibility_matrix.xml
#endif

# GPU configration
TARGET_BOARD_PLATFORM_GPU ?= mali-t760
GRAPHIC_MEMORY_PROVIDER ?= ump
USE_OPENGL_RENDERER ?= true
TARGET_DISABLE_TRIPLE_BUFFERING ?= false
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK ?= false

DEVICE_HAVE_LIBRKVPU ?= true

#rotate screen to 0, 90, 180, 270
#0:   ROTATION_NONE      ORIENTATION_0  : 0
#90:  ROTATION_RIGHT     ORIENTATION_90 : 90
#180: ROTATION_DOWN    ORIENTATION_180: 180
#270: ROTATION_LEFT    ORIENTATION_270: 270
# For Recovery Rotation
TARGET_RECOVERY_DEFAULT_ROTATION ?= ROTATION_NONE
# For Surface Flinger Rotation
SF_PRIMARY_DISPLAY_ORIENTATION ?= 0

#Screen to Double, Single
#YES: Screen to Double
#NO: Screen to single
DOUBLE_SCREEN ?= NO

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali400)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/Mali400/lib/arm/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali450)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/Mali450/lib/x86/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t860)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT860/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t760)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT760/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t720)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT720/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), PVR540)
BOARD_EGL_CFG ?= vendor/rockchip/common/gpu/PVR540/egl.cfg
endif

VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

TARGET_BOOTLOADER_BOARD_NAME ?= rk30sdk
TARGET_NO_BOOTLOADER ?= true

TARGET_RELEASETOOLS_EXTENSIONS := device/hardkernel/common

# MAX-SIZE=512M, for generate out/.../system.img
BOARD_FLASH_BLOCK_SIZE := 131072


# Enable VNDK Check for Android P (MUST after P)
BOARD_VNDK_VERSION := current

# Recovery
#TARGET_NO_RECOVERY ?= false

# to flip screen in recovery
BOARD_HAS_FLIPPED_SCREEN ?= false

# Auto update package from USB
RECOVERY_AUTO_USB_UPDATE ?= false

# To use bmp as kernel logo, uncomment the line below to use bgra 8888 in recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_ROCKCHIP_PCBATEST ?= false
#TARGET_RECOVERY_UI_LIB ?= librecovery_ui_$(TARGET_PRODUCT)

TARGET_USES_MKE2FS ?= true

RECOVERY_BOARD_ID ?= false
# RECOVERY_BOARD_ID ?= true

# for drmservice
BUILD_WITH_DRMSERVICE :=true

# Audio
BOARD_USES_GENERIC_AUDIO ?= true

# Wifi&Bluetooth
# TODO: split wifi_bt_common into BoardConfig and device versions
# We need to set some board variables but we also need to add to
# PRODUCT_CFI_INCLUDE_PATHS which can only be done from the device side.
include device/hardkernel/common/wifi_bt_common.mk

#Camera flash
BOARD_HAVE_FLASH ?= true

#HDMI support
BOARD_SUPPORT_HDMI ?= true
BOARD_SUPPORT_HDMI_CEC ?= false

# gralloc 4.0
include device/hardkernel/common/gralloc.device.mk

# Can utils
include device/hardkernel/common/can_utils.mk

# google apps
BUILD_BOX_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET_ALL ?= false
BUILD_WITH_GOOGLE_GMS_EXPRESS ?= false
BUILD_WITH_GOOGLE_FRP ?= true

# define BUILD_NUMBER
#BUILD_NUMBER := $(shell $(DATE) +%H%M%S)

# Configs for lmkd/reclaim service/auto run control/performance/dexmetadata compile...
ROCKCHIP_OEM_CONFIG_FILE ?= device/hardkernel/common/configs/cfg_rockchip_default.xml
ROCKCHIP_OEM_CONFIG_PACKAGES ?= device/hardkernel/common/configs/rockchip_forbid_packages.xml

# face lock
BUILD_WITH_FACELOCK ?= false

# ebook
BUILD_WITH_RK_EBOOK ?= false

# Sensors
BOARD_SENSOR_ST ?= true
# if use akm8963
#BOARD_SENSOR_COMPASS_AK8963 ?= true
# if need calculation angle between two gsensors
#BOARD_SENSOR_ANGLE ?= true
# if need calibration
#BOARD_SENSOR_CALIBRATION ?= true
# if use mpu
#BOARD_SENSOR_MPU ?= true
#BOARD_USES_GENERIC_INVENSENSE ?= false

# readahead files to improve boot time
# BOARD_BOOT_READAHEAD ?= true

BOARD_BP_AUTO ?= true

# phone pad codec list
BOARD_CODEC_WM8994 ?= false
BOARD_CODEC_RT5625_SPK_FROM_SPKOUT ?= false
BOARD_CODEC_RT5625_SPK_FROM_HPOUT ?= false
BOARD_CODEC_RT3261 ?= false
BOARD_CODEC_RT3224 ?= false
BOARD_CODEC_RT5631 ?= false
BOARD_CODEC_RK616 ?= false

# Vold configrations
# if set to true m-user would be disabled and UMS enabled, if set to disable UMS would be disabled and m-user enabled
BUILD_WITH_UMS ?= false
# if set to true BUILD_WITH_UMS must be false.
BUILD_WITH_CDROM ?= false
BUILD_WITH_CDROM_PATH ?= /system/etc/cd.iso
# multi usb partitions
BUILD_WITH_MULTI_USB_PARTITIONS ?= false
# define tablet support NTFS
BOARD_IS_SUPPORT_NTFS ?= true

# pppoe for cts, you should set this true during pass CTS and which will disable  pppoe function.
BOARD_PPPOE_PASS_CTS ?= false

# ethernet
BOARD_HS_ETHERNET ?= false

# Save commit id into firmware
BOARD_RECORD_COMMIT_ID ?= false

# no battery
BUILD_WITHOUT_BATTERY ?= false

BOARD_CHARGER_ENABLE_SUSPEND ?= true
CHARGER_ENABLE_SUSPEND ?= true
CHARGER_DISABLE_INIT_BLANK ?= true
BOARD_CHARGER_DISABLE_INIT_BLANK ?= true

#stress test
BOARD_HAS_STRESSTEST_APP ?= true

#optimise mem
BOARD_WITH_MEM_OPTIMISE ?= false

#force app can see udisk
BOARD_FORCE_UDISK_VISIBLE ?= true


# disable safe mode to speed up boot time
BOARD_DISABLE_SAFE_MODE ?= true

#enable 3g dongle
BOARD_HAVE_DONGLE ?= true

#for boot and shutdown animation ringing
BOOT_SHUTDOWN_ANIMATION_RINGING ?= false

#for pms multi thead scan
BOARD_ENABLE_PMS_MULTI_THREAD_SCAN ?= false

#for WV keybox provision
ENABLE_KEYBOX_PROVISION ?= false

# product has follow sensors or not,if had override it in product's BoardConfig
BOARD_HAS_GPS ?= false
BOARD_NFC_SUPPORT ?= false
BOARD_GRAVITY_SENSOR_SUPPORT ?= false
BOARD_GSENSOR_MXC6655XA_SUPPORT ?= false
BOARD_COMPASS_SENSOR_SUPPORT ?= false
BOARD_GYROSCOPE_SENSOR_SUPPORT ?= false
BOARD_PROXIMITY_SENSOR_SUPPORT ?= false
BOARD_LIGHT_SENSOR_SUPPORT ?= false
BOARD_OPENGL_AEP ?= false
BOARD_PRESSURE_SENSOR_SUPPORT ?= false
BOARD_TEMPERATURE_SENSOR_SUPPORT ?= false
BOARD_USB_HOST_SUPPORT ?= false
BOARD_USB_ACCESSORY_SUPPORT ?= true
BOARD_CAMERA_SUPPORT ?= false
BOARD_BLUETOOTH_SUPPORT ?= true
BOARD_BLUETOOTH_LE_SUPPORT ?= true
BOARD_WIFI_SUPPORT ?= true

#for rk 4g modem
BOARD_HAS_RK_4G_MODEM ?= false

#for rk DLNA
PRODUCT_HAVE_DLNA ?= false

#USE_CLANG_PLATFORM_BUILD ?= true

#enable cpusets sched policy
ENABLE_CPUSETS := true

# Enable sparse system image
BOARD_USE_SPARSE_SYSTEM_IMAGE ?= false

#Use HWC2
TARGET_USES_HWC2 ?= true

# for gralloc 0.3
TARGET_RK_GRALLOC_VERSION ?= 1

# disable BOARD_SUPPORT_MULTIAUDIO default
BOARD_SUPPORT_MULTIAUDIO ?= false

#for Camera autofocus support
CAMERA_SUPPORT_AUTOFOCUS ?= false

# Enable UsbDevice to Mtp mode,default is charge mode
BOARD_USB_ALLOW_DEFAULT_MTP ?= false

BOARD_DEFAULT_CAMERA_HAL_VERSION ?=3.3

# rktoolbox
BOARD_WITH_RKTOOLBOX ?=true
BOARD_MEMTRACK_SUPPORT ?= false

PRODUCT_DEFAULT_DEV_CERTIFICATE := device/hardkernel/common/security/testkey

PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

BOARD_BASEPARAMETER_SUPPORT ?= true
BOARD_BASEPARAMETER_AUTO ?= true
ifeq ($(strip $(BOARD_BASEPARAMETER_SUPPORT)), true)
    ifneq ($(filter rk356x rk3588, $(strip $(TARGET_BOARD_PLATFORM))), )
        ifeq ($(strip $(BOARD_BASEPARAMETER_AUTO)), true)
            TARGET_BASE_PARAMETER_IMAGE ?= device/hardkernel/common/baseparameter/v2.0/baseparameter_auto.img
        else
            TARGET_BASE_PARAMETER_IMAGE ?= device/hardkernel/common/baseparameter/v2.0/baseparameter.img
        endif
    else
        TARGET_BASE_PARAMETER_IMAGE ?= device/hardkernel/common/baseparameter/v1.0/baseparameter.img
    endif
        BOARD_WITH_SPECIAL_PARTITIONS := baseparameter:1M
endif

# Export these makefile variables to soong config vars for graphics libs build rules
$(call soong_config_set,rockchip,gralloc_version,$(TARGET_RK_GRALLOC_VERSION))
$(call soong_config_set,rockchip,platform_gpu,$(TARGET_BOARD_PLATFORM_GPU))

ifneq ("$(wildcard vendor/gapps/arm64/arm64-vendor.mk)","")
#PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true
    $(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)
endif
