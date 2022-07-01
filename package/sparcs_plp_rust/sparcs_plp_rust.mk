################################################################################
#
# SPARCS_PLP_RUST (sparcs-plp-rust)
#
################################################################################

SPARCS_PLP_RUST_VERSION = $(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_VERSION))
SPARCS_PLP_RUST_SITE = $(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_URL))
SPARCS_PLP_RUST_SITE_METHOD = git

define SPARCS_PLP_RUST_BUILD_CMDS
    cd $(@D); ./custom_cargo.sh build --release --manifest-path /src/sparcs-plp-rust/Cargo.toml
endef

define SPARCS_PLP_RUST_INSTALL_TARGET_CMDS
    mkdir $(TARGET_DIR)/usr/bin/sparcs; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/boot_counter $(TARGET_DIR)/usr/bin/sparcs/boot_counter; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/command-listener $(TARGET_DIR)/usr/bin/sparcs/command-listener; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/sparcam_bulk_config $(TARGET_DIR)/usr/bin/sparcs/sparcam_bulk_config; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/sparcam_debug $(TARGET_DIR)/usr/bin/sparcs/sparcam_debug; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/sparcs-payload-control $(TARGET_DIR)/usr/bin/sparcs/sparcs-payload-control; \
    $(INSTALL) -D -m 0755 $(@D)/target/arm-unknown-linux-gnueabihf/release/sparcs-sci-obs $(TARGET_DIR)/usr/bin/sparcs/sparcs-sci-obs
endef

$(eval $(generic-package))
