#import "MagmaEvo.h"

%hook PrysmConnectivityModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;
	forceLayerUpdate(self.view.layer.sublayers);

	if (prefBool(@"connectivityHideContainer")) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmSliderModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if (prefValue(@"slidersVolumeBackground")) self.audioSlider.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:prefValue(@"slidersVolumeBackground")];
	if (prefValue(@"slidersVolumeGlyph")) self.audioSlider.overlayImageView.tintColor = [UIColor evoRGBAColorFromHexString:prefValue(@"slidersVolumeGlyph")];

	if (prefValue(@"slidersBrightnessBackground")) self.brightnessSlider.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:prefValue(@"slidersBrightnessBackground")];
	if (prefValue(@"slidersBrightnessGlyph")) self.brightnessSlider.overlayImageView.tintColor = [UIColor evoRGBAColorFromHexString:prefValue(@"slidersBrightnessGlyph")];

	if (prefBool(@"slidersHideContainer")) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmMediaModuleViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if (prefValue(@"mediaControlsLeftButton")) self.rewindButton.tintColor = [UIColor evoRGBAColorFromHexString:prefValue(@"mediaControlsLeftButton")];
	if (prefValue(@"mediaControlsMiddleButton")) self.playPauseButton.tintColor = [UIColor evoRGBAColorFromHexString:prefValue(@"mediaControlsMiddleButton")];
	if (prefValue(@"mediaControlsRightButton")) self.skipButton.tintColor = [UIColor evoRGBAColorFromHexString:prefValue(@"mediaControlsRightButton")];

	if (prefValue(@"mediaControlsPrimaryLabel")) self.titleLabel.textColor = [UIColor evoRGBAColorFromHexString:prefValue(@"mediaControlsPrimaryLabel")];
	if (prefValue(@"mediaControlsSecondaryLabel")) self.subtitleLabel.textColor = [UIColor evoRGBAColorFromHexString:prefValue(@"mediaControlsSecondaryLabel")];

	if (prefBool(@"mediaControlsHideContainer")) self.view.backgroundColor = [UIColor clearColor];
}
%end

%hook PrysmCardBackgroundViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if (prefValue(@"miscMainBackground")) self.overlayView.backgroundColor = [UIColor evoRGBAColorFromHexString:prefValue(@"miscMainBackground")];
}
%end

%hook PrysmButtonView
-(void)setBackgroundColor:(UIColor *)color {
	if (![self._viewControllerForAncestor isKindOfClass:%c(PrysmConnectivityModuleViewController)] && prefBool(@"togglesHideContainer")) {
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
		color = prefValueEquals(@"connectivityModeEnabled", @"glyphOnly") ? [UIColor clearColor] : getColorForPrefKey(prefKey);
	} else {
		color = prefValueEquals(@"connectivityModeDisabled", @"glyphOnly") ? [UIColor clearColor] : nil;
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

	if ((prefValueEquals(@"connectivityModeEnabled", @"glyphOnly") && [prefKey containsString:@"Enabled"])
		|| [prefKey containsString:@"Disabled"]) {
		return getColorForPrefKey(prefKey);
	}

	if (!prefValueEquals(@"connectivityModeEnabled", @"glyphOnly") && [prefKey containsString:@"Enabled"]) {
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

	if (prefBool(@"enabled") && [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib"]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/Prysm.dylib", RTLD_LAZY);
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmConnectivity.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmSlider.bundle/"] load];
		[[NSBundle bundleWithPath:@"/Library/Prysm/Bundles/com.laughingquoll.prysm.PrysmMedia.bundle/"] load];
		%init;
	}
}
