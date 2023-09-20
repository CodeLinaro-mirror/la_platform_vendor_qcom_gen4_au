LOCAL_PATH := $(call my-dir)

#----------------------------------------------------------------------
# Compile (L)ittle (K)ernel bootloader and the nandwrite utility
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)
ifneq ($(strip $(TARGET_SIGNONLY_BOOTLOADER)),true)

# Compile
include bootable/bootloader/edk2/AndroidBoot.mk

$(INSTALLED_BOOTLOADER_MODULE): $(TARGET_EMMC_BOOTLOADER) | $(ACP)
else
TARGET_EMMC_BOOTLOADER := $(TARGET_BOARD_UNSIGNED_ABL_DIR)/unsigned_abl.elf
SIGN_ABL := $(PRODUCT_OUT)/abl.elf

SECTOOLSV2_BIN := $(QCPATH)/sectools/Linux/sectools
define sec-image-generate
        echo "Generating signed appsbl using secimagev2 tool"
        rm -rf $(PRODUCT_OUT)/abl.elf
        ( $(SECTOOLSV2_BIN) secure-image $(TARGET_EMMC_BOOTLOADER) \
                --outfile $(PRODUCT_OUT)/abl.elf \
                --image-id ABL \
                --security-profile $(SECTOOLS_SECURITY_PROFILE) \
                --sign \
                --signing-mode TEST \
                > $(PRODUCT_OUT)/secimage.log 2>&1 )
        echo "Completed secimagev2 signed appsbl (ABL) (logs in $(PRODUCT_OUT)/secimage.log)"
endef

$(SIGN_ABL): $(TARGET_EMMC_BOOTLOADER)
	$(call sec-image-generate)
$(INSTALLED_BOOTLOADER_MODULE): $(SIGN_ABL) | $(ACP)
endif

#   $(transform-prebuilt-to-target)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_BOOTLOADER_MODULE)

droidcore: $(INSTALLED_BOOTLOADER_MODULE)
droidcore-unbundled: $(INSTALLED_BOOTLOADER_MODULE)
endif

# Create firmware folder for graphics
$(shell mkdir -p $(TARGET_OUT_VENDOR)/firmware/)
#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
# include device/qcom/kernelscripts/kernel_definitions.mk

#----------------------------------------------------------------------
# Copy additional target-specific files
#----------------------------------------------------------------------
include $(CLEAR_VARS)
LOCAL_MODULE       := vold.fstab
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.target.rc
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)/init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := gpio-keys.kl
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_KEYLAYOUT)
include $(BUILD_PREBUILT)

ifneq ($(TARGET_BOARD_DERIVATIVE_SUFFIX), _km4)
ifeq ($(strip $(PRODUCT_USE_DYNAMIC_PARTITIONS)),true)
include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.qcom

LOCAL_MODULE_CLASS := ETC
ifeq ($(ENABLE_AB), true)
  LOCAL_SRC_FILES := fstab_AB_dynamic_partition_variant.qti
else
  LOCAL_SRC_FILES := fstab_non_AB_dynamic_partition_variant.qti
endif #ENABLE_AB
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
include $(BUILD_PREBUILT)
else
include $(CLEAR_VARS)
LOCAL_MODULE       := fstab.qcom
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_OUT_VENDOR_ETC)
ifeq ($(ENABLE_VENDOR_IMAGE), true)
LOCAL_POST_INSTALL_CMD := echo $(VENDOR_FSTAB_ENTRY) >> $(LOCAL_MODULE_PATH)/$(LOCAL_MODULE)
endif
include $(BUILD_PREBUILT)
endif #PRODUCT_USE_DYNAMIC_PARTITIONS

include device/qcom/vendor-common/MergeConfig.mk

#----------------------------------------------------------------------
# Radio image
#----------------------------------------------------------------------
ifeq ($(ADD_RADIO_FILES), true)
radio_dir := $(LOCAL_PATH)/radio
RADIO_FILES := $(shell cd $(radio_dir) ; ls)
$(foreach f, $(RADIO_FILES), \
	$(call add-radio-file,radio/$(f)))
endif
endif #TARGET_BOARD_DERIVATIVE_SUFFIX

#Add gsi key.
include $(CLEAR_VARS)
LOCAL_MODULE := qcar-gsi.avbpubkey
LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0
LOCAL_LICENSE_CONDITIONS := notice
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := ../../../test/vts-testcase/security/avb/data/qcar-gsi.avbpubkey
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/first_stage_ramdisk/avb
include $(BUILD_PREBUILT)

#----------------------------------------------------------------------
# extra images
#----------------------------------------------------------------------
include vendor/qcom/opensource/core-utils/build/AndroidBoardCommon.mk

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(strip $(BOARD_HAS_QCOM_WLAN)),true)
include device/qcom/wlan/gen4_au/AndroidBoardWlan.mk
endif
#----------------------------------------------------------------------
# override default make with prebuilt make path (if any)
#----------------------------------------------------------------------
ifneq (, $(wildcard $(shell pwd)/prebuilts/build-tools/linux-x86/bin/make))
    MAKE := $(shell pwd)/prebuilts/build-tools/linux-x86/bin/$(MAKE)
endif
