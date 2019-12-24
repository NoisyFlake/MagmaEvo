#import "MagmaEvo.h"

%hook CCUIButtonModuleView
	-(void)setSelected:(BOOL)arg1 {
		%orig;

		forceLayerUpdate(self.layer.sublayers);

		if (!prefValueEquals(@"togglesOverlayMode", @"regular")) {
			for (UIView *subview in self.allSubviews) {
				if ([subview isKindOfClass:%c(MTMaterialView)]) {

					if (prefValueEquals(@"togglesOverlayMode", @"removeOverlay")) {
						subview.hidden = YES;
						break;
					} else if (prefValueEquals(@"togglesOverlayMode", @"colorOverlay")) {
						subview.backgroundColor = self.selectedGlyphColor ?: [UIColor RGBAColorFromHexString:@"#007AFF"]; // CALayer will handle it later, we just need to call the setter
						break;
					}

				}
			}
		}

	}

	-(void)layoutSubviews {
		%orig;

		// Seriously, fuck the stupid fucking piece of shit AirPlay label
		UIViewController *controller = self._viewControllerForAncestor;
		if ([controller isKindOfClass:%c(MPAVAirPlayMirroringMenuModuleViewController)]) {
			for (UIView *subview in controller.view.allSubviews) {
				if ([subview isKindOfClass:%c(UILabel)] && ![subview._ui_superview isKindOfClass:%c(BSUIEmojiLabelView)]) {
					UIColor *color = getToggleColor(controller);

					if (prefValueEquals(@"togglesOverlayMode", @"colorOverlay") && [((CCUIButtonModuleViewController*)controller) isSelected]) {
						((UILabel*)subview).textColor = [color isBrightColor] ? [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] : [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
					} else if (color != nil) {
						((UILabel*)subview).textColor = color;
					}
				}
			}
		}

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
		if (controller == nil || (prefBool(@"togglesHideContainer") && ([controller isKindOfClass:%c(CCUIButtonModuleViewController)] || [controller isKindOfClass:%c(HUCCModuleContentViewController)]))) {
			return;
		}

		%orig;
	}
%end

UIColor *getToggleColor(UIViewController *controller) {
	NSString *identifier = nil;
	if ([controller isKindOfClass:%c(CCUIToggleViewController)]) {
		CCUIToggleModule *module = ((CCUIToggleViewController *)controller).module;
		CCUIContentModuleContext *context = [module contentModuleContext];
		identifier = context.moduleIdentifier;
	} else if ([controller isKindOfClass:%c(RPControlCenterModuleViewController)]) {
		identifier = @"com.apple.replaykit.controlcenter.screencapture";
	} else if ([controller isKindOfClass:%c(CCUIFlashlightModuleViewController)]) {
		identifier = @"com.apple.control-center.FlashlightModule";
	} else if ([controller isKindOfClass:%c(MTCCTimerViewController)]) {
		identifier = @"com.apple.mobiletimer.controlcenter.timer";
	} else if ([controller isKindOfClass:%c(HUCCModuleContentViewController)]) {
		identifier = @"com.apple.Home.ControlCenter";
	} else if([controller respondsToSelector:@selector(contentModuleContext)]) {
		CCUIContentModuleContext *context = [(CCUIButtonModuleViewController *)controller contentModuleContext];
		identifier = context.moduleIdentifier;
	}

	NSString *prefKey = nil;
	if ([controller respondsToSelector:@selector(isSelected)]) {
		prefKey = [NSString stringWithFormat:@"%@%@", identifier, [((CCUIButtonModuleViewController*)controller) isSelected] ? @"Enabled" : @"Disabled"];
	} else {
		prefKey = [NSString stringWithFormat:@"%@%@", identifier, @"Disabled"];
	}

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
	}

	return value ? [UIColor RGBAColorFromHexString:value] : nil;
}

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
