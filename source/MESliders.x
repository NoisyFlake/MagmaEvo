#import "MagmaEvo.h"

%hook SliderClass
	-(void)didMoveToWindow {
		%orig;

		if ([self isKindOfClass:%c(SBElasticSliderView)] && ![settings boolForKey:@"slidersVolumeSystem"]) return;

		UIViewController *controller = [self _viewControllerForAncestor];

		// We usually need the first (and only) MTMaterialView, however for the iOS 13 volume slider we need the last one
		for (UIView *subview in ([controller isKindOfClass:%c(MediaControlsVolumeViewController)] || [controller isKindOfClass:%c(SBElasticVolumeViewController)] ? [((UIView *)self).allSubviews reverseObjectEnumerator] : ((UIView *)self).allSubviews)) {
			if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [subview isKindOfClass:%c(MTMaterialView)]) ||
				(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [subview isKindOfClass:%c(_MTBackdropView)])) {
				subview.backgroundColor = [UIColor clearColor]; // CALayer handles the actual color
				break;
			}
		}

		// iOS 13 tries to color the glyphs itself, however on 12 we need to manually color the layer
		if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
			for (UIView *subview in ((UIView *)self).allSubviews) {
				if ([subview isKindOfClass:%c(CCUICAPackageView)]) {
					forceLayerUpdate(@[subview.layer]);
				}
			}
		}

	}
%end

%hook CCUIContentModuleContentContainerView
	-(void)_configureModuleMaterialViewIfNecessary {

		UIViewController *controller = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).contentViewController;
		if (controller == nil ||
			([settings boolForKey:@"slidersHideContainer"] && (
				[controller isKindOfClass:%c(CCUIDisplayModuleViewController)] ||
				[controller isKindOfClass:%c(CCUIAudioModuleViewController)] ||
				[controller isKindOfClass:%c(CCRingerModuleContentViewController)]
				)
			)
		) {
			return;
		}

		%orig;
	}
%end

%hook MediaControlsVolumeSliderView
  -(id)initWithFrame:(CGRect)arg1 {
    MediaControlsVolumeSliderView *orig = %orig;

    // Hide the container background of the iOS 13 volume slider as it doesn't use _configureModuleMaterialViewIfNecessary
    if ([settings boolForKey:@"slidersHideContainer"]) {
    	for (UIView *subview in self.allSubviews) {
    		if ([subview isKindOfClass:%c(MTMaterialView)]) {
    			subview.alpha = 0;
    			break;
    		}
    	}
    }

    return orig;
  }
%end

CGColorRef getSliderColor(UIViewController *controller, UIView *view) {
	NSString *identifier = nil;
	if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)]) identifier = @"slidersBrightness";
	if ([controller isKindOfClass:%c(MediaControlsVolumeViewController)] || [controller isKindOfClass:%c(CCUIAudioModuleViewController)] || [controller isKindOfClass:%c(SBElasticVolumeViewController)]) identifier = @"slidersVolume";
	if ([controller isKindOfClass:%c(CCRingerModuleContentViewController)]) identifier = @"slidersRinger";

	NSString *backgroundKey = [NSString stringWithFormat:@"%@Background", identifier];
	NSString *glyphKey = [NSString stringWithFormat:@"%@Glyph", identifier];

	if ([settings valueForKey:backgroundKey] != nil) {
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [view isKindOfClass:%c(MTMaterialView)]) {
			((MTMaterialView *)view).configuration = 1;
			return [[UIColor evoRGBAColorFromHexString:[settings valueForKey:backgroundKey]] CGColor];
		}

		if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [view isKindOfClass:%c(_MTBackdropView)]) {
			((_MTBackdropView*)view).colorAddColor = nil;
			((_MTBackdropView*)view).brightness = 0;
			return [[UIColor evoRGBAColorFromHexString:[settings valueForKey:backgroundKey]] CGColor];
		}
	}

	if ([settings valueForKey:glyphKey] != nil) {
		if (![view isKindOfClass:%c(MTMaterialView)] && ![view isKindOfClass:%c(_MTBackdropView)]) {
			// This is the glyph inside the slider
			return [[UIColor evoRGBAColorFromHexString:[settings valueForKey:glyphKey]] CGColor];
		}
	}

	return nil;
}

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		Class cls = NSClassFromString(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") ? @"CCUIContinuousSliderView" : @"CCUIModuleSliderView");
		%init(SliderClass=cls);
	}
}
