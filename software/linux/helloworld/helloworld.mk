HOST_HELLOWORLD_LICENSE = BSD-2-Clause

define HOST_HELLOWORLD_BUILD_CMDS
	$(HOSTCC) $(HOST_CFLAGS) $(HOST_LDFLAGS) \
		package/helloworld/helloworld.c \
		-o $(@D)/helloworld
endef

define HOST_HELLOWORLD_INSTALL_CMDS
	$(INSTALL) -D -m 755 $(@D)/helloworld $(HOST_DIR)/bin/helloworld
endef

$(eval $(host-generic-package))
