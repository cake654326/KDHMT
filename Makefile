
THEOS_BUILD_DIR = debs

export GO_EASY_ON_ME = 1
export THEOS_DEVICE_IP=192.168.1.125
export ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = kdhmt
kdhmt_FILES = Tweak.xm
kdhmt_FRAMEWORKS = UIKit CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += kdhmtsettings
include $(THEOS_MAKE_PATH)/aggregate.mk
