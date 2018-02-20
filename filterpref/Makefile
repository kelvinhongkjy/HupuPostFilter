include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HupuFilterPref
HupuFilterPref_FILES = HPHRootListController.m
HupuFilterPref_INSTALL_PATH = /Library/PreferenceBundles
HupuFilterPref_FRAMEWORKS = UIKit
HupuFilterPref_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HupuFilterPref.plist$(ECHO_END)
