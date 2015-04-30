include theos/makefiles/common.mk

BUNDLE_NAME = kdhmtsettings
kdhmtsettings_FILES = kdhmtsettings.mm
kdhmtsettings_INSTALL_PATH = /Library/PreferenceBundles
kdhmtsettings_FRAMEWORKS = UIKit
kdhmtsettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/kdhmtsettings.plist$(ECHO_END)
