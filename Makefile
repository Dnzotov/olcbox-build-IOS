TARGET := iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = iosApp Olcbox

TWEAK_NAME = OlcboxKeepAlive

OlcboxKeepAlive_FILES = Tweak.xm
OlcboxKeepAlive_CFLAGS = -fobjc-arc
OlcboxKeepAlive_FRAMEWORKS = Foundation UIKit AVFoundation MediaPlayer

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk