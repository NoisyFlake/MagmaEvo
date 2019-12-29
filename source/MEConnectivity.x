#import "MagmaEvo.h"

%hook CCUILabeledRoundButtonViewController
	-(id)initWithGlyphImage:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
		return %orig(arg1, [self evoGetToggleColor:arg2], arg3);
	}
	-(id)initWithGlyphPackageDescription:(id)arg1 highlightColor:(id)arg2 useLightStyle:(BOOL)arg3 {
		return %orig(arg1, [self evoGetToggleColor:arg2], arg3);
	}

	%new
	-(UIColor *)evoGetToggleColor:(UIColor *)color {
		if (prefValueEquals(@"connectivityModeEnabled", @"glyphOnly")) {
			color = [UIColor clearColor];
		} else {
			NSString *prefKey = [NSString stringWithFormat:@"%@Enabled", NSStringFromClass([self class])];
			if (prefValue(prefKey)) color = [UIColor RGBAColorFromHexString:prefValue(prefKey)];
		}

		return color;
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

		NSString *module = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).moduleIdentifier;
		if (module == nil || (prefBool(@"connectivityHideContainer") && [module isEqual:@"com.apple.control-center.ConnectivityModule"])) {
			return;
		}

		%orig;
	}
%end

CGColorRef getConnectivityGlyphColor(CCUILabeledRoundButtonViewController *controller) {
	NSString *prefKey = [NSString stringWithFormat:@"%@%@", NSStringFromClass([controller class]), [controller isEnabled] ? @"Enabled" : @"Disabled"];
	UIColor *color = (prefValue(prefKey) != nil) ? [UIColor RGBAColorFromHexString:prefValue(prefKey)] : nil;

	if (prefValueEquals(@"connectivityModeEnabled", @"glyphOnly") || ![controller isEnabled]) {
		if (color != nil) return [color CGColor];

		if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#FF9500"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#007AFF"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#4CD964"] CGColor];
		if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [[UIColor RGBAColorFromHexString:@"#007AFF"] CGColor];
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
