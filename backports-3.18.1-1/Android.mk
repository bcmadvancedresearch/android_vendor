LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

IWL_ANDROID_SRC_BASE := $(LOCAL_PATH)
IWL_ANDROID_ROOT := $(CURDIR)
IWL_LINUXPATH = $(IWL_ANDROID_ROOT)/kernel_imx
IWL_CROSS_COMPILE = $(IWL_ANDROID_ROOT)/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-

mod_cleanup := $(IWL_ANDROID_ROOT)/$(IWL_ANDROID_SRC_BASE)/dummy

$(mod_cleanup) :
		$(MAKE) -C $(IWL_ANDROID_SRC_BASE) ARCH=arm CROSS_COMPILE=$(IWL_CROSS_COMPILE) KLIB_BUILE=$(IWL_LINUXPATH)  COMPAT_CURDIR=$(IWL_ANDROID_ROOT)/$(IWL_ANDROID_SRC_BASE) clean
		mkdir -p $(TARGET_OUT)/lib/modules

iwlwifi_module_file := drivers/net/wireless/iwlwifi/iwlwifi.ko
$(IWL_ANDROID_SRC_BASE)/$(iwlwifi_module_file):$(mod_cleanup) $(TARGET_PREBUILT_KERNEL)
	$(MAKE) -C $(IWL_ANDROID_SRC_BASE) O=$(IWL_LINUXPATH) ARCH=arm CROSS_COMPILE=$(IWL_CROSS_COMPILE) KLIB=$(IWL_LINUXPATH) KLIB_BUILD=$(IWL_LINUXPATH) COMPAT_CURDIR=$(IWL_ANDROID_ROOT)/$(IWL_ANDROID_SRC_BASE) defconfig-ath9k_iwlwifi_bt
	$(MAKE) -C $(IWL_ANDROID_SRC_BASE) O=$(IWL_LINUXPATH) ARCH=arm CROSS_COMPILE=$(IWL_CROSS_COMPILE) KLIB=$(IWL_LINUXPATH) KLIB_BUILD=$(IWL_LINUXPATH) COMPAT_CURDIR=$(IWL_ANDROID_ROOT)/$(IWL_ANDROID_SRC_BASE) -j4 modules
	find $(IWL_ANDROID_ROOT)/$(IWL_ANDROID_SRC_BASE) -name "*.ko" | xargs -i cp {} $(TARGET_OUT)/lib/modules


autocompiledriver:
	@echo compile drivers
	@make ARCH=arm CROSS_COMPILE=../prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi- KLIB_BUILD=../kernel_imx
	@echo copying driver files to destination folder
	@find . | grep ko$ | xargs -i cp {} $(TARGET_OUT)/lib/modules/

include $(CLEAR_VARS)
LOCAL_MODULE := iwlwifi.ko
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT)/lib/modules
LOCAL_SRC_FILES := $(iwlwifi_module_file)
include $(BUILD_PREBUILT)
