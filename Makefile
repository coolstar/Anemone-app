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

$(THEOS_OBJ_DIR)/Anemone.app/Anemone:
	set -o pipefail; \
		xcodebuild -workspace 'Anemone.xcworkspace' -scheme 'Anemone' -configuration $(BUILD_CONFIG) -arch arm64 -sdk iphoneos \
		CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO PRODUCT_BUNDLE_IDENTIFIER="org.coolstar.Anemone" \
		CONFIGURATION_BUILD_DIR=$(THEOS_OBJ_DIR) OBJROOT=$(THEOS_OBJ_DIR) SYMROOT=$(THEOS_OBJ_DIR) \
		DSTROOT=$(THEOS_OBJ_DIR) $(XCPRETTY)
	$(TARGET_STRIP) $(THEOS_OBJ_DIR)/Anemone.app/Anemone
	$(TARGET_CODESIGN) -Sent.plist $(THEOS_OBJ_DIR)/Anemone.app/Anemone

all:: $(THEOS_OBJ_DIR)/Anemone.app/Anemone

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Applications/
	cp -r $(THEOS_OBJ_DIR)/Anemone.app $(THEOS_STAGING_DIR)/Applications/

internal-clean::
	$(MAKE) -C clean

.PHONY: $(THEOS_OBJ_DIR)/Anemone.app/Anemone
