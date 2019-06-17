include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/null.mk

ifeq ($(call __executable,xcpretty),$(_THEOS_TRUE))
ifneq ($(_THEOS_VERBOSE),$(_THEOS_TRUE))
	XCPRETTY := | xcpretty
endif
endif

ifeq ($(call __theos_bool,$(DEBUG)),$(_THEOS_TRUE))
	BUILD_CONFIG := Debug
else
	BUILD_CONFIG := Release
endif

ANEMONE_APP_DIR = $(THEOS_OBJ_DIR)/install/Applications/Anemone.app

$(ANEMONE_APP_DIR):
	set -o pipefail; \
		xcodebuild -project 'Anemone.xcodeproj' -scheme 'Anemone' -configuration $(BUILD_CONFIG) -arch arm64 -sdk iphoneos \
		build install \
		CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_IDENTIFIER="com.anemoneteam.anemone" \
		DSTROOT=$(THEOS_OBJ_DIR)/install $(XCPRETTY)
	rm -rf $(ANEMONE_APP_DIR)/Frameworks/libswift*.dylib
	$(TARGET_CODESIGN) -Sent.plist $(ANEMONE_APP_DIR)/Anemone

all:: $(ANEMONE_APP_DIR)

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Applications/
	cp -a $(ANEMONE_APP_DIR) $(THEOS_STAGING_DIR)/Applications/

internal-clean::
	$(MAKE) -C clean

.PHONY: $(ANEMONE_APP_DIR)
