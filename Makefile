TARGET = iphone:clang:latest
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MagmaEvo

MagmaEvo_FILES = $(wildcard source/*.x source/*.m)
MagmaEvo_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
