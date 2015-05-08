################################################################################
#
# broadcom-bluetooth
#
################################################################################

BROADCOM_BLUETOOTH_VERSION = v1.0
BROADCOM_BLUETOOTH_SITE = $(call github,mixtile,broadcom-bluetooth,$(BROADCOM_BLUETOOTH_VERSION))
#BROADCOM_BLUETOOTH_LICENSE = 
#BROADCOM_BLUETOOTH_LICENSE_FILES = COPYING

define BROADCOM_BLUETOOTH_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		-C $(@D) all
endef

define BROADCOM_BLUETOOTH_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/brcm_patchram_plus $(TARGET_DIR)/usr/bin/brcm_patchram_plus
	$(INSTALL) -D -m 0755 $(@D)/brcm_patchram_plus_h5 $(TARGET_DIR)/usr/bin/brcm_patchram_plus_h5
	$(INSTALL) -D -m 0755 $(@D)/brcm_patchram_plus_usb $(TARGET_DIR)/usr/bin/brcm_patchram_plus_usb
endef

$(eval $(generic-package))
