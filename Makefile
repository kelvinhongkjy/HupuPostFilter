THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:8.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HupuPostFilter
HupuPostFilter_FILES = FilterUtils.m Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 hupu"
SUBPROJECTS += filterpref
include $(THEOS_MAKE_PATH)/aggregate.mk
