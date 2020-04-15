#import "MagmaEvo.h"

%hook CCUIButtonModuleView
	-(void)didMoveToWindow {
		%orig;

		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];

		// Update layers after a respring (because only now some modules will have an identifier)
		forceLayerUpdate(self.layer.sublayers);
	}

	-(void)setSelected:(BOOL)arg1 {
		%orig;

		[self magmaEvoColorize];
	}

	%new
	-(void)magmaEvoColorize {
		forceLayerUpdate(self.layer.sublayers);

		// iOS 13
		UIView *backgroundView = [self safeValueForKey:@"_highlightedBackgroundView"];

		// iOS 12
		if ([backgroundView safeValueForKey:@"_backdropView"]) backgroundView = [backgroundView safeValueForKey:@"_backdropView"];

		backgroundView.hidden = [[settings valueForKey:@"togglesOverlayMode"] isEqual:@"removeOverlay"];

		if ([[settings valueForKey:@"togglesOverlayMode"] isEqual:@"colorOverlay"]) {
			backgroundView.backgroundColor = [UIColor redColor]; // CALayer will handle the actual color
		}

	}
%end

%hook HUCCHomeButton
	-(void)didMoveToWindow {
		%orig;

		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoUpdateLayers) name:@"com.noisyflake.magmaevo/reload" object:nil];
	}

	%new
	-(void)magmaEvoUpdateLayers {
		forceLayerUpdate(self.layer.sublayers);
	}

%end

%hook AXCCIconViewController
	-(id)initWithImage:(id)image {
		id orig = %orig;

		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoUpdateLayers) name:@"com.noisyflake.magmaevo/reload" object:nil];

		return orig;
	}

	%new
	-(void)magmaEvoUpdateLayers {
		forceLayerUpdate(@[self.view.layer]);
	}
%end

%hook UILabel
	-(void)setTextColor:(UIColor *)arg1 {

		// Fix the stupid AirPlay label color
		if ([self._viewControllerForAncestor isKindOfClass:%c(MPAVAirPlayMirroringMenuModuleViewController)]) {
			[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
			arg1 = [self magmaEvoGetLabelColor];
		}

		%orig;
	}

	%new
	-(void)magmaEvoColorize {
		[self setTextColor:[UIColor redColor]];
	}

	%new
	-(UIColor *)magmaEvoGetLabelColor {
		UIColor *color = getToggleColor(self._viewControllerForAncestor);

		if ([self._viewControllerForAncestor isSelected] && [[settings valueForKey:@"togglesOverlayMode"] isEqual:@"colorOverlay"]) {
			return [color evoIsBrightColor] ? [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] : [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
		} else {
			return color ?: [UIColor whiteColor];
		}
	}
%end

%hook CCUIMenuModuleViewController
	-(void)willTransitionToExpandedContentMode:(BOOL)arg1 {
		%orig;
		forceLayerUpdate(self.view.layer.sublayers);
	}
%end

%hook WAWeatherPlatterViewController
-(void)viewDidLayoutSubviews {
	%orig;

	if ([settings boolForKey:@"betterCCXIFix"]) {
		self.backgroundView.backgroundColor = UIColor.clearColor;
	}
}
%end

UIColor *getToggleColor(UIViewController *controller) {
	NSString *identifier = nil;

	UIViewController *parentController = controller.parentViewController;
	if ([parentController isKindOfClass:%c(CCUIContentModuleContainerViewController)]) {
		identifier = ((CCUIContentModuleContainerViewController *)parentController).moduleIdentifier;
	} else if ([parentController.parentViewController isKindOfClass:%c(CCUIContentModuleContainerViewController)]) {
		identifier = ((CCUIContentModuleContainerViewController *)parentController.parentViewController).moduleIdentifier;
	} else if ([controller.parentFocusEnvironment isKindOfClass:%c(PrysmButtonView)]) {
		identifier = ((PrysmButtonView *)controller.parentFocusEnvironment).identifier;
	} else if ([controller isKindOfClass:%c(HACCIconViewController)]) {
		identifier = @"com.apple.accessibility.controlcenter.hearingdevices";
	} else if ([controller isKindOfClass:%c(AXCCIconViewController)]) {
		identifier = @"com.apple.accessibility.controlcenter.text.size";
	} else if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
		// TV Remote on iOS 12 has no unique way to identify it, so let's assume this is it
		identifier = @"com.apple.control-center.AppleTVRemoteModule";
	}

	if (identifier == nil) return nil;

	NSString *prefKey = nil;
	if ([controller respondsToSelector:@selector(isSelected)]) {
		prefKey = [NSString stringWithFormat:@"%@%@", identifier, [((CCUIButtonModuleViewController*)controller) isSelected] ? @"Enabled" : @"Disabled"];
	} else {
		prefKey = [NSString stringWithFormat:@"%@%@", identifier, @"Disabled"];
	}

	return getColorForPrefKey(prefKey);
}

UIColor *getColorForPrefKey(NSString *prefKey) {
	NSString *value = [settings valueForKey:prefKey];
	if (value == nil) {
		if ([prefKey isEqual:@"com.apple.control-center.OrientationLockModuleEnabled"]) value = @"#FF5A63";
		if ([prefKey isEqual:@"com.apple.donotdisturb.DoNotDisturbModuleEnabled"]) value = @"#5E67D6";
		if ([prefKey isEqual:@"com.apple.control-center.CarModeModuleEnabled"]) value = @"#5E67D6";
		if ([prefKey isEqual:@"com.apple.control-center.LowPowerModuleEnabled"]) value = @"#FFCC00";
		if ([prefKey isEqual:@"com.apple.replaykit.controlcenter.screencaptureEnabled"]) value = @"#FF0000";
		if ([prefKey isEqual:@"com.apple.control-center.FlashlightModuleEnabled"]) value = @"#007AFF";
		if ([prefKey isEqual:@"com.apple.mediaremote.controlcenter.airplaymirroringEnabled"]) value = @"#007AFF";
		if ([prefKey isEqual:@"com.apple.control-center.AppearanceModuleEnabled"]) value = @"#000000";
		if ([prefKey isEqual:@"com.apple.mobiletimer.controlcenter.timerEnabled"]) value = @"#FF9500";
		if ([prefKey isEqual:@"com.apple.control-center.MuteModuleEnabled"]) value = @"#FF0000";
	}

	if (value) {
		UIColor *selectedColor = [UIColor evoRGBAColorFromHexString:value];
		return (CGColorGetComponents(selectedColor.CGColor)[3] == 0) ? UIColor.clearColor : selectedColor;
	}

	return nil;
}

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		[[NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/HomeControlCenterModule.bundle/"] load];
		[[NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/AccessibilityTextSizeModule.bundle"] load];
		%init;
	}
}
