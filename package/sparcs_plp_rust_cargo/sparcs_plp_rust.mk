################################################################################
#
# SPARCS_PLP_RUST (sparcs-plp-rust)
#
################################################################################

SPARCS_PLP_RUST_VERSION = b29a047f8b61cae56cf6105579d774fcd7818be8
#$(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_VERSION))
#SPARCS_PLP_RUST_SOURCE = archive/$(SPARCS_RUST_VERSION).zip
SPARCS_PLP_RUST_SITE = https://github.com/ASU-cubesat/sparcs-plp-rust.git
#$(call qstrip,$(BR2_PACKAGE_SPARCS_PLP_RUST_REPO_URL))
SPARCS_PLP_RUST_SITE_METHOD = git

#define SPARCS_PLP_RUST_BUILD_CMDS
#    $(@D)/custom_cargo.sh
#endef
#
#define SPARCS_PLP_RUST_INSTALL_TARGET_CMDS
#    #$(INSTALL) -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin
#endef

#$(eval $(generic-package))
$(eval $(cargo-package))
