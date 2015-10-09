#############################################################
#
# Build the ext4a root filesystem image
#
#############################################################

EXT4A_OPTS :=

ifneq ($(strip $(BR2_TARGET_ROOTFS_EXT4A_SIZE)),0)
EXT4A_OPTS += -l $(BR2_TARGET_ROOTFS_EXT4A_SIZE)M
endif

EXT4A_OPTS += -s

define ROOTFS_EXT4A_CMD
	PATH=$(BR_PATH) fs/ext4a/make_ext4fs $(EXT4A_OPTS) $@ $(TARGET_DIR) ; \
	echo $(TARGETS) ; \
	echo $(TARGET_PATH)
endef

ifndef LICHEE_GEN_ROOTFS
$(eval $(call ROOTFS_TARGET,ext4a))
else
ifeq ($(strip $(LICHEE_GEN_ROOTFS)), y)
$(eval $(call ROOTFS_TARGET,ext4a))
endif
endif



