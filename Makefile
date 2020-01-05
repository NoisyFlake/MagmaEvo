TARGET = iphone:clang:11.2:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MagmaEvo

MagmaEvo_FILES = source/MagmaEvo.x $(wildcard source/*.x source/*.m)
MagmaEvo_CFLAGS = -fobjc-arc
MagmaEvo_FRAMEWORKS = GameplayKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
