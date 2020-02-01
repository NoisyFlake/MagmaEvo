#import "MagmaEvo.h"

%hook PrysmConnectivityModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;
	forceLayerUpdate(self.view.layer.sublayers);

	if ([settings boolForKey:@"connectivityHideContainer"]) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmSliderModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if ([settings valueForKey:@"slidersVolumeBackground"]) self.audioSlider.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersVolumeBackground"]];
	if ([settings valueForKey:@"slidersVolumeGlyph"]) self.audioSlider.overlayImageView.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersVolumeGlyph"]];

	if ([settings valueForKey:@"slidersBrightnessBackground"]) self.brightnessSlider.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersBrightnessBackground"]];
	if ([settings valueForKey:@"slidersBrightnessGlyph"]) self.brightnessSlider.overlayImageView.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"slidersBrightnessGlyph"]];

	if ([settings boolForKey:@"slidersHideContainer"]) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmMediaModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if ([settings valueForKey:@"mediaControlsLeftButton"]) self.rewindButton.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsLeftButton"]];
	if ([settings valueForKey:@"mediaControlsMiddleButton"]) self.playPauseButton.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsMiddleButton"]];
	if ([settings valueForKey:@"mediaControlsRightButton"]) self.skipButton.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRightButton"]];

	if ([settings valueForKey:@"mediaControlsPrimaryLabel"]) self.titleLabel.textColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsPrimaryLabel"]];
	if ([settings valueForKey:@"mediaControlsSecondaryLabel"]) self.subtitleLabel.textColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSecondaryLabel"]];

	if ([settings boolForKey:@"mediaControlsHideContainer"]) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmCardBackgroundViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if ([settings valueForKey:@"miscMainBackground"]) self.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"miscMainBackground"]];
}
%end

%hook PrysmButtonView
-(void)setBackgroundColor:(UIColor *)color {
	if (![self._viewControllerForAncestor isKindOfClass:%c(PrysmConnectivityModuleViewController)] && [settings boolForKey:@"togglesHideContainer"]) {
		color = [UIColor clearColor];
	}

	%orig(color);
}
%end

UIColor *getPrysmConnectivityColor(PrysmButtonView *view) {
	NSString *internalName = nil;
	PrysmConnectivityModuleViewController *parent = view._viewControllerForAncestor;
	if (view == parent.airdropButton) internalName = @"CCUIConnectivityAirDropViewController";
	if (view == parent.airplaneButton) internalName = @"CCUIConnectivityAirplaneViewController";
	if (view == parent.bluetoothButton) internalName = @"CCUIConnectivityBluetoothViewController";
	if (view == parent.cellularButton) internalName = @"CCUIConnectivityCellularDataViewController";
	if (view == parent.wifiButton) internalName = @"CCUIConnectivityWifiViewController";

	NSString *prefKey = [NSString stringWithFormat:@"%@%@", internalName, view.state ? @"Enabled" : @"Disabled"];
	UIColor *color = nil;

	if (view.state) {
		color = [[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] ? [UIColor clearColor] : getColorForPrefKey(prefKey);
	} else {
		color = [[settings valueForKey:@"connectivityModeDisabled"] isEqual:@"glyphOnly"] ? [UIColor clearColor] : nil;
	}

	return color;
}

UIColor *getPrysmConnectivityGlyphColor(UIImageView *view) {
	NSString *prefKey = nil;
	PrysmConnectivityModuleViewController *parent = view._viewControllerForAncestor;
	if (view == parent.airdropButton.altStateImageView) prefKey = @"CCUIConnectivityAirDropViewControllerEnabled";
	if (view == parent.airdropButton.imageView) prefKey = @"CCUIConnectivityAirDropViewControllerDisabled";

	if (view == parent.airplaneButton.altStateImageView) prefKey = @"CCUIConnectivityAirplaneViewControllerEnabled";
	if (view == parent.airplaneButton.imageView) prefKey = @"CCUIConnectivityAirplaneViewControllerDisabled";

	if (view == parent.bluetoothButton.altStateImageView) prefKey = @"CCUIConnectivityBluetoothViewControllerEnabled";
	if (view == parent.bluetoothButton.imageView) prefKey = @"CCUIConnectivityBluetoothViewControllerDisabled";

	if (view == parent.cellularButton.altStateImageView) prefKey = @"CCUIConnectivityCellularDataViewControllerEnabled";
	if (view == parent.cellularButton.imageView) prefKey = @"CCUIConnectivityCellularDataViewControllerDisabled";

	if (view == parent.wifiButton.altStateImageView) prefKey = @"CCUIConnectivityWifiViewControllerEnabled";
	if (view == parent.wifiButton.imageView) prefKey = @"CCUIConnectivityWifiViewControllerDisabled";

	if (([[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] && [prefKey containsString:@"Enabled"])
		|| [prefKey containsString:@"Disabled"]) {
		UIColor *color = getColorForPrefKey(prefKey);
		if (color == nil) {
			if ([prefKey isEqual:@"CCUIConnectivityAirDropViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
			if ([prefKey isEqual:@"CCUIConnectivityAirplaneViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#FF9500"];
			if ([prefKey isEqual:@"CCUIConnectivityBluetoothViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
			if ([prefKey isEqual:@"CCUIConnectivityCellularDataViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
			if ([prefKey isEqual:@"CCUIConnectivityHotspotViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#4CD964"];
			if ([prefKey isEqual:@"CCUIConnectivityWifiViewControllerEnabled"]) return [UIColor evoRGBAColorFromHexString:@"#007AFF"];
		}

		return color;
	}

	if (![[settings valueForKey:@"connectivityModeEnabled"] isEqual:@"glyphOnly"] && [prefKey containsString:@"Enabled"]) {
		return [getColorForPrefKey(prefKey) evoIsBrightColor] ? [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] : [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
	}

	return nil;
}

UIColor *getPrysmToggleColor(UIView *view) {
	PrysmButtonView *prysmView = getPrysmButtonView(view);

	if (prysmView == nil) return nil;

	NSString *prefKey = [NSString stringWithFormat:@"%@%@", prysmView.identifier, isPrysmButtonSelected(prysmView) ? @"Enabled" : @"Disabled"];

	return getColorForPrefKey(prefKey);
}

bool isPrysmButtonSelected(PrysmButtonView *view) {
	for (UIView *subview in view.allSubviews) {
		if ([subview isKindOfClass:%c(CCUIButtonModuleView)]) return ((UIControl *)subview).selected;
	}

	return NO;
}

PrysmButtonView *getPrysmButtonView(UIView *view) {
	while (view.superview != nil && ![view isKindOfClass:%c(PrysmButtonView)]) {
		view = view.superview;
	}

	if ([view isKindOfClass:%c(PrysmButtonView)]) return (PrysmButtonView *)view;
	return nil;
}

%ctor {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"] && [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib", RTLD_LAZY);
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmConnectivity.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmSlider.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmMedia.bundle/"] load];
		%init;
	}
}
