################################################################################
#
# DORA
#
################################################################################

DORA_RUST_SITE = $(call qstrip,$(BR2_PACKAGE_DORA_REPO_URL))
DORA_RUST_SITE_METHOD = git
VERSION = $(call qstrip,$(BR2_PACKAGE_DORA_REPO_VERSION))

# If the version specified is a branch name, we need to go fetch the SHA1 for the branch's HEAD
ifeq ($(shell git ls-remote --heads $(DORA_RUST_SITE) $(VERSION) | wc -l), 1)
    DORA_RUST_VERSION := $(shell git ls-remote $(DORA_RUST_SITE) $(VERSION) | cut -c1-8)
else
    DORA_RUST_VERSION = $(VERSION)
endif

define DORA_RUST_INSTALL_TARGET_CMDS
    [ -d $(TARGET_DIR)/usr/bin/dora ] || mkdir $(TARGET_DIR)/usr/bin/dora; \

    [ -d $(TARGET_DIR)/home/dora ] || mkdir $(TARGET_DIR)/home/dora; \
	[ -d $(TARGET_DIR)/home/dora/logs ] || mkdir $(TARGET_DIR)/home/dora/logs; \
	[ -d $(TARGET_DIR)/home/dora/logs/telem ] || mkdir $(TARGET_DIR)/home/dora/logs/telem; \

	[ -d $(TARGET_DIR)/home/dora/status ] || mkdir $(TARGET_DIR)/home/dora/status; \
	[ -d $(TARGET_DIR)/home/dora/payload-schedules ] || mkdir $(TARGET_DIR)/home/dora/payload-schedules; \
	[ -d $(TARGET_DIR)/home/dora/payload-data ] || mkdir $(TARGET_DIR)/home/dora/payload-data; \
	[ -d $(TARGET_DIR)/home/dora/payload-data/fb ] || mkdir $(TARGET_DIR)/home/dora/fb; \
	[ -d $(TARGET_DIR)/home/dora/payload-data/sdr ] || mkdir $(TARGET_DIR)/home/dora/payload-data/sdr; \

	[ -d $(TARGET_DIR)/home/dora/cfdp ] || mkdir $(TARGET_DIR)/home/cfdp; \
	[ -d $(TARGET_DIR)/home/dora/cfdp/incoming ] || mkdir $(TARGET_DIR)/home/cfdp/incoming; \
	[ -d $(TARGET_DIR)/home/dora/cfdp/outgoing ] || mkdir $(TARGET_DIR)/home/cfdp/outgoing; \
	[ -d $(TARGET_DIR)/home/dora/cfdp/log ] || mkdir $(TARGET_DIR)/home/cfdp/log; \


    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/cfdp $(TARGET_DIR)/usr/bin/dora/cfdp; \
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/comms $(TARGET_DIR)/usr/bin/dora/comms; \
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/i2c-control $(TARGET_DIR)/usr/bin/dora/i2c-control; \
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/payload $(TARGET_DIR)/usr/bin/dora/payload; \
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/scheduler $(TARGET_DIR)/usr/bin/dora/scheduler; \

    $(INSTALL) -D -m 0755 $(@D)/dora_comms_config.toml $(TARGET_DIR)/home/dora/;\
	$(INSTALL) -D -m 0755 $(@D)/cfdpTestFile.txt $(TARGET_DIR)/home/dora/;\
	$(INSTALL) -D -m 0755 $(@D)/os/CALLSIGN.txt $(TARGET_DIR)/home/dora/;
	
endef

$(eval $(cargo-package))