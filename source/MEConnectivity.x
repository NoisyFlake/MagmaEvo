#import "MagmaEvo.h"

%hook CCUILabeledRoundButtonViewController
	-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
		if (prefBool(@"connectivityGlyphOnly")) {
			arg2 = [UIColor clearColor];
		} else if ([self isMemberOfClass:%c(CCUIConnectivityCellularDataViewController)]) {
			arg2 = [UIColor redColor];
		}

		return %orig;
	}
	-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {

		/* HBLogWarn(@"Class: %@", NSStringFromClass([self class])); */

		if (prefBool(@"connectivityGlyphOnly")) {
			arg2 = [UIColor clearColor];
		} else if ([self isMemberOfClass:%c(CCUIConnectivityBluetoothViewController)]) {
			arg2 = [UIColor orangeColor];
		} else if ([self isMemberOfClass:%c(CCUIConnectivityWifiViewController)]) {
			arg2 = [UIColor greenColor];
		}

		return %orig;
	}
%end

%hook CCUIRoundButton
	-(BOOL)useAlternateBackground {
		return NO;
	}
	-(void)_updateForStateChange {
		%orig;

		if (prefBool(@"connectivityGlyphOnly")) {
			self.normalStateBackgroundView.alpha = 0;

			if (self.glyphPackageView == nil) {
				// Only need to update the selectedGlyphView because the regular one is already colored after a respring
				forceLayerUpdate(@[self.selectedGlyphView.layer]);
			} else {
				// WiFi & Bluetooth buttons
				forceLayerUpdate(self.glyphPackageView.layer.sublayers);
			}
		}

	}
%end

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
