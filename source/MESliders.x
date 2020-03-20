#import "MagmaEvo.h"

%hook SliderClass
	-(void)didMoveToWindow {
		%orig;

		if ([self isKindOfClass:%c(SBElasticSliderView)] && ![settings boolForKey:@"slidersVolumeSystem"]) return;

		// iOS 13
		UIView *backgroundView = [self safeValueForKey:@"_backgroundView"];

		// iOS 12
		if (!backgroundView) {
			MTMaterialView *materialView = [self safeValueForKey:@"_continuousValueBackgroundView"];
			backgroundView = [materialView safeValueForKey:@"_backdropView"];

			// iOS 13 tries to color the glyphs itself, however on 12 we need to manually color the layer
			CCUICAPackageView *glyph = [self safeValueForKey:@"_compensatingGlyphPackageView"];
			if (glyph) forceLayerUpdate(@[glyph.layer]);
		}

		// Remove the two accessibility features from the sliders or they will be invisible
		if ([backgroundView.layer isKindOfClass:%c(MTMaterialLayer)]) {
			MTMaterialLayer *layer = (MTMaterialLayer *)backgroundView.layer;
			layer.reduceMotionEnabled = NO;
			layer.reduceTransparencyEnabled = NO;
		}

		backgroundView.backgroundColor = [UIColor clearColor]; // CALayer handles the actual color
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
		MTMaterialView *materialView = [self valueForKey:@"_materialView"];
		materialView.alpha = 0;
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
