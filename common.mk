# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Installs gsi keys into ramdisk, to boot a GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# A/B support
ifeq ($(TARGET_IS_VAB),true)
PRODUCT_PACKAGES += \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# tell update_engine to not change dynamic partition table during updates
# needed since our qti_dynamic_partitions does not include
# vendor and odm and we also dont want to AB update them
TARGET_ENFORCE_AB_OTA_PARTITION_LIST := true
endif # TARGET_IS_VAB

# API
PRODUCT_SHIPPING_API_LEVEL := 29

# Boot control HAL
ifeq ($(TARGET_IS_VAB),true)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
    android.hardware.boot@1.0-impl-wrapper.recovery \
    android.hardware.boot@1.0-impl-wrapper \
    android.hardware.boot@1.0-impl.recovery \
    bootctrl.$(PRODUCT_PLATFORM) \
    bootctrl.$(PRODUCT_PLATFORM).recovery
endif # TARGET_IS_VAB

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# qcom decryption
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe

# Recovery
ifeq ($(TARGET_IS_VAB),true)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab/twrp_AB.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags
else
PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab/twrp.flags:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/twrp.flags
endif

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(COMMON_PATH)

# Vibrator
ifneq ($(TARGET_HAS_NO_VIBRATOR),true)
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service.xiaomi_kona

PRODUCT_COPY_FILES += \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/vendor/bin/hw/vendor.qti.hardware.vibrator.service.xiaomi_kona:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/vendor.qti.hardware.vibrator.service.xiaomi_kona \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/vendor/etc/init/vendor.qti.hardware.vibrator.service.xiaomi_kona.rc:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/init/vendor.qti.hardware.vibrator.service.xiaomi_kona.rc \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/vendor/etc/vintf/manifest/vendor.qti.hardware.vibrator.service.xiaomi_kona.xml:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/vintf/manifest/vendor.qti.hardware.vibrator.service.xiaomi_kona.xml \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/vendor/lib64/libqtivibratoreffect.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/libqtivibratoreffect.so \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/vendor/lib64/vendor.qti.hardware.vibrator.impl.xiaomi_kona.so:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib64/vendor.qti.hardware.vibrator.impl.xiaomi_kona.so
endif

# OEM otacerts
#PRODUCT_EXTRA_RECOVERY_KEYS += \
## Reserved

# Apex libraries
ifneq (1,$(filter 1,$(shell echo "$$(( $(PLATFORM_SDK_VERSION) >= 31 ))" )))
PRODUCT_COPY_FILES += \
    $(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/obj/SHARED_LIBRARIES/libandroidicu_intermediates/libandroidicu.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libandroidicu.so
endif

# Vendor blobs
ifneq ($(wildcard vendor/xiaomi/sm8250-common/proprietary/),)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/xiaomi/sm8250-common/proprietary/,$(TARGET_COPY_OUT_RECOVERY)/root/)
endif

# Extras
$(call inherit-product-if-exists, vendor/extras/product.mk)
