DEBUG = 0
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:11.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SortingSwipe

SortingSwipe_FILES = Tweak.xm Categories/NRFileManager.m Categories/UIImage+UIImageAverageColorAddition.m
SortingSwipe_FRAMEWORKS = GameplayKit
SortingSwipe_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
