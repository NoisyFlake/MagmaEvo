#import "MagmaEvo.h"

%hook CCUILabeledRoundButtonViewController
	-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {

		if (prefValueEquals(@"connectivityMode", @"glyphOnly")) {
			arg2 = [UIColor clearColor];
		} else {
			NSString *prefKey = [NSString stringWithFormat:@"%@Enabled", NSStringFromClass([self class])];
			if (prefValue(prefKey)) arg2 = [UIColor RGBAColorFromHexString:prefValue(prefKey)];
		}

		return %orig;
	}
	-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {

		if (prefValueEquals(@"connectivityMode", @"glyphOnly")) {
			arg2 = [UIColor clearColor];
		} else {
			NSString *prefKey = [NSString stringWithFormat:@"%@Enabled", NSStringFromClass([self class])];
			if (prefValue(prefKey)) arg2 = [UIColor RGBAColorFromHexString:prefValue(prefKey)];
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

		if (prefValueEquals(@"connectivityModeDisabled", @"glyphOnly")) {
			self.normalStateBackgroundView.alpha = 0;
		}

		if (self.glyphPackageView == nil) {
			// Only need to update the selectedGlyphView because the regular one is already colored after a respring
			forceLayerUpdate(@[self.selectedGlyphView.layer]);
		} else {
			// WiFi & Bluetooth buttons
			forceLayerUpdate(self.glyphPackageView.layer.sublayers);
		}

	}
%end

%hook CCUIContentModuleContentContainerView
	-(void)_configureModuleMaterialViewIfNecessary {
		%orig;

		NSString *module = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).moduleIdentifier;
		HBLogWarn(@"MagmaEvo Got module: %@", module);

		if ([module isEqual:@"com.apple.control-center.FlashlightModule"]) {
			/* self.moduleMaterialView.alpha = 0; */
			HBLogWarn(@"MagmaEvo Disabled");
		}

	}
%end

CGColorRef getConnectivityColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = [NSString stringWithFormat:@"%@%@", NSStringFromClass([controller class]), [controller isEnabled] ? @"Enabled" : @"Disabled"];
	UIColor *color = [UIColor RGBAColorFromHexString:prefValue(prefKey)];

	if (prefValueEquals(@"connectivityMode", @"glyphOnly") || ![controller isEnabled]) {
		if (color != nil) return [color CGColor];
	}	else if([controller isEnabled]) {
		if (color != nil && [color isBrightColor]) return [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor];
	}

	return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
}

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
