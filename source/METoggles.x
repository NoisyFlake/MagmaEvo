#import "MagmaEvo.h"

%hook CCUIButtonModuleView
	-(void)didMoveToWindow {
		%orig;

		// Update layers after a respring (because only now some modules will have an identifier)
		forceLayerUpdate(self.layer.sublayers);

		// Fix for the Apple TV Remote and Hearing overlay on iOS 12
		if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && prefBool(@"togglesHideContainer")) {
				for (UIView *subview in self.allSubviews) {
					if ([subview isKindOfClass:%c(MTMaterialView)]) {
						subview.alpha = 0;
						break;
					}
				}

				if ([self._viewControllerForAncestor isKindOfClass:%c(HACCIconViewController)]) {
					MTMaterialView *matView = self.parentFocusEnvironment;
					for (UIView *subview in matView.allSubviews) {
						if ([subview isKindOfClass:%c(_MTBackdropView)]) {
							subview.alpha = 0;
							break;
						}
					}
				}
		}

	}

	-(void)setSelected:(BOOL)arg1 {
		%orig;

		forceLayerUpdate(self.layer.sublayers);

		if (!prefValueEquals(@"togglesOverlayMode", @"regular")) {
			for (UIView *subview in self.allSubviews) {
				if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [subview isKindOfClass:%c(MTMaterialView)]) ||
						(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [subview isKindOfClass:%c(_MTBackdropView)])) {

					if (prefValueEquals(@"togglesOverlayMode", @"removeOverlay")) {
						subview.hidden = YES;
						break;
					} else if (prefValueEquals(@"togglesOverlayMode", @"colorOverlay")) {
						subview.backgroundColor = [UIColor redColor]; // CALayer will handle it later, we just need to call the setter
						break;
					}

				}
			}
		}

	}
%end

%hook UILabel
	-(void)setTextColor:(UIColor *)arg1 {

		// Fix the stupid AirPlay label color
		if ([self._viewControllerForAncestor isKindOfClass:%c(MPAVAirPlayMirroringMenuModuleViewController)]) {
			UIColor *color = getToggleColor(self._viewControllerForAncestor);
			if (color != nil) {
				if ([self._viewControllerForAncestor isSelected] && prefValueEquals(@"togglesOverlayMode", @"colorOverlay")) {
					arg1 = [color evoIsBrightColor] ? [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] : [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
				} else {
					arg1 = color;
				}
			}
		}

		%orig;
	}
%end

%hook CCUIMenuModuleViewController
	-(void)willTransitionToExpandedContentMode:(BOOL)arg1 {
		%orig;
		forceLayerUpdate(self.view.layer.sublayers);
	}
%end

%hook CCUIContentModuleContentContainerView
	-(void)_configureModuleMaterialViewIfNecessary {

		UIViewController *controller = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).contentViewController;
		if (controller == nil ||
			(prefBool(@"togglesHideContainer") && (
				[controller isKindOfClass:%c(CCUIButtonModuleViewController)] ||
				[controller isKindOfClass:%c(HUCCModuleContentViewController)] ||
				[controller isKindOfClass:%c(AXCCTextSizeModuleViewController)] ||
				[controller isKindOfClass:%c(HACCModuleViewController)] ||
				[controller isKindOfClass:%c(WSUIModuleContentViewController)]
				)
			)
		) {
			return;
		}

		%orig;
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
	NSString *value = prefValue(prefKey);
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

	return value ? [UIColor evoRGBAColorFromHexString:value] : nil;
}

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
