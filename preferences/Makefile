TARGET = iphone:clang:latest
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MagmaEvo

MagmaEvo_FILES = $(wildcard *.m *.xm CustomCells/*.m ../source/UIColor+MagmaEvo.m)
MagmaEvo_INSTALL_PATH = /Library/PreferenceBundles
MagmaEvo_FRAMEWORKS = UIKit
MagmaEvo_PRIVATE_FRAMEWORKS = Preferences
MagmaEvo_CFLAGS = -fobjc-arc
MagmaEvo_LIBRARIES = sparkcolourpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MagmaEvo.plist$(ECHO_END)
