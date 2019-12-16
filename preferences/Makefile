TARGET = iphone:clang:11.2:11.2
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MagmaEvo

MagmaEvo_FILES = $(wildcard *.m)
MagmaEvo_INSTALL_PATH = /Library/PreferenceBundles
MagmaEvo_FRAMEWORKS = UIKit
MagmaEvo_PRIVATE_FRAMEWORKS = Preferences
MagmaEvo_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MagmaEvo.plist$(ECHO_END)
