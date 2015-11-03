################################################################################
#
# cc-tool
#
################################################################################

CC_TOOL_VERSION = 0.26
CC_TOOL_SOURCE = cc-tool-$(CC_TOOL_VERSION)-src.tgz
CC_TOOL_SITE = http://downloads.sourceforge.net/project/cctool/
CC_TOOL_DEPENDENCIES = host-pkgconf
CC_TOOL_LICENSE = GNUGPLv2
CC_TOOL_LICENSE_FILES = COPYING

$(eval $(autotools-package))
