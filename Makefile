DEBUG=0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SortingSwipe

SortingSwipe_FILES = Tweak.xm UIImage+UIImageAverageColorAddition.m
SortingSwipe_FRAMEWORKS = GameplayKit 
SortingSwipe_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
