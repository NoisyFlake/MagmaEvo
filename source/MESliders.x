#import "MagmaEvo.h"

%hook SliderClass
	-(void)didMoveToWindow {
		%orig;

		if ([self isKindOfClass:%c(SBElasticSliderView)] && ![settings boolForKey:@"slidersVolumeSystem"]) return;

		if (![self isKindOfClass:%c(SBElasticSliderView)]) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
				[self magmaEvoColorize];
				[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
			});
		} else {
			[self magmaEvoColorize];
			[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
		}
	}

	%new
	-(void)magmaEvoColorize {
		// iOS 13
		UIView *backgroundView = [self safeValueForKey:@"_backgroundView"];

		// iOS 12
		if (!backgroundView) {
			MTMaterialView *materialView = [self safeValueForKey:@"_continuousValueBackgroundView"];
			backgroundView = [materialView safeValueForKey:@"_backdropView"];
		}

		CCUICAPackageView *glyph = [self safeValueForKey:@"_compensatingGlyphPackageView"];
		if (glyph) {
			glyph.alpha = glyph.alpha; // Update opacity in CALayer
			forceLayerUpdate(@[glyph.layer]);
		}

		// Remove the two accessibility features from the sliders or they will be invisible
		if ([backgroundView.layer isKindOfClass:%c(MTMaterialLayer)]) {
			MTMaterialLayer *layer = (MTMaterialLayer *)backgroundView.layer;
			layer.reduceMotionEnabled = NO;
			layer.reduceTransparencyEnabled = NO;
		}

		// if ([backgroundView isKindOfClass:%c(_MTBackdropView)]) {
			// For absolutely no known reason, after the initial calling of this method, iOS 12 doesn't pass this calling of the setter to CALayer anymore, making our CALayer method useless.
			// Thus we have to manually set the color here already. This is so weird.
			// backgroundView.backgroundColor = [UIColor colorWithCGColor:getSliderColor(((UIView *)self)._viewControllerForAncestor, backgroundView)];
		// } else {
			backgroundView.backgroundColor = [UIColor clearColor]; // CALayer handles the actual color
		// }

		if ([self respondsToSelector:@selector(magmaEvoColorizeContainer)]) {
			[self magmaEvoColorizeContainer];
		}
	}
%end

%hook MediaControlsVolumeSliderView
	-(id)initWithFrame:(CGRect)arg1 {
		MediaControlsVolumeSliderView *orig = %orig;

		[self magmaEvoColorizeContainer];

		return orig;
	}

	%new
	-(void)magmaEvoColorizeContainer {
		if ([self isKindOfClass:%c(SBElasticSliderView)] && ![settings boolForKey:@"slidersVolumeSystem"]) return;

		[MagmaHelper colorizeMaterialView:[self valueForKey:@"_materialView"] forSetting:@"slidersContainerBackground"];
	}
%end

CGColorRef getSliderColor(UIViewController *controller, UIView *view) {
	NSString *identifier = nil;
	if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)]) identifier = @"slidersBrightness";
	if ([controller isKindOfClass:%c(MediaControlsVolumeViewController)] || [controller isKindOfClass:%c(CCUIAudioModuleViewController)] || [controller isKindOfClass:%c(SBElasticVolumeViewController)]) identifier = @"slidersVolume";
	if ([controller isKindOfClass:%c(CCRingerModuleContentViewController)]) identifier = @"slidersRinger";

	NSString *backgroundKey = [NSString stringWithFormat:@"%@Background", identifier];
	NSString *glyphKey = [NSString stringWithFormat:@"%@Glyph", identifier];

	NSString *backgroundValue = [settings valueForKey:backgroundKey];
	NSString *glyphValue = [settings valueForKey:glyphKey];

	if ([view isKindOfClass:%c(MTMaterialView)] && [view respondsToSelector:@selector(configuration)]) {

		// Ignore the container background of the iOS 13 volume slider (which also happens to be a MTMaterialView)
		if ([controller isKindOfClass:%c(MediaControlsVolumeViewController)] && view == [view.superview safeValueForKey:@"_materialView"]) return nil;

		if (backgroundValue) {
			((MTMaterialView *)view).configuration = 1;
			view.alpha = 1;
			return [[UIColor evoRGBAColorFromHexString:backgroundValue] CGColor];
		} else {
			((MTMaterialView *)view).configuration = 3;
			[((MTMaterialLayer *)view.layer) _updateForChangeInRecipeAndConfiguration];
			[((MTMaterialLayer *)view.layer) _setNeedsConfiguring];
			view.alpha = 1;
			return nil;
		}

	} else if ([view isKindOfClass:%c(_MTBackdropView)]) {

		if (backgroundValue) {
			((_MTBackdropView*)view).colorAddColor = nil;
			((_MTBackdropView*)view).brightness = 0;
			return [[UIColor evoRGBAColorFromHexString:backgroundValue] CGColor];
		} else {
			((_MTBackdropView *)view).colorAddColor = [UIColor colorWithWhite:1.0 alpha:0.25];
			((_MTBackdropView *)view).brightness = 0.52;
			return nil;
		}

	} else {
		// Note: We have to set it to clearColor instead of nil or a color with 0 alpha, otherwise we are unable to edit it on-the-fly afterwards again
		// No idea why this happens, but this workaround seems to work reliable
		if (glyphValue) {
			UIColor *selectedColor = [UIColor evoRGBAColorFromHexString:glyphValue];
			return CGColorGetComponents(selectedColor.CGColor)[3] == 0 ? UIColor.clearColor.CGColor : selectedColor.CGColor;
		} else {
			return [[UIColor clearColor] CGColor];
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
