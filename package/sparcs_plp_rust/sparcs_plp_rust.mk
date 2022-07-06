################################################################################
#
# SPARCS_PLP_RUST (sparcs-plp-rust)
#
################################################################################


SPARCS_PLP_RUST_SITE = $(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_URL))
SPARCS_PLP_RUST_SITE_METHOD = git
VERSION = $(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_VERSION))

# If the version specified is a branch name, we need to go fetch the SHA1 for the branch's HEAD
ifeq ($(shell git ls-remote --heads $(SPARCS_PLP_RUST_SITE) $(VERSION) | wc -l), 1)
    SPARCS_PLP_RUST_VERSION := $(shell git ls-remote $(SPARCS_PLP_RUST_SITE) $(VERSION) | cut -c1-8)
else
    SPARC_PLP_RUST_VERSION = $(VERSION)
endif

define SPARCS_PLP_RUST_INSTALL_TARGET_CMDS
    mkdir $(TARGET_DIR)/usr/bin/sparcs; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/boot_counter $(TARGET_DIR)/usr/bin/sparcs/boot_counter; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/command-listener $(TARGET_DIR)/usr/bin/sparcs/command-listener; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/sparcam_bulk_config $(TARGET_DIR)/usr/bin/sparcs/sparcam_bulk_config; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/sparcam_debug $(TARGET_DIR)/usr/bin/sparcs/sparcam_debug; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/sparcs-payload-control $(TARGET_DIR)/usr/bin/sparcs/sparcs-payload-control; \
    $(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/sparcs-sci-obs $(TARGET_DIR)/usr/bin/sparcs/sparcs-sci-obs
endef


#$(eval $(generic-package))
$(eval $(cargo-package))
