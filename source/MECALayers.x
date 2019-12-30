#import "MagmaEvo.h"

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty);

%hook CALayer
	-(void)setBackgroundColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setBorderColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setContentsMultiplyColor:(CGColorRef)arg1 {
		// Need to set overwriteEmpty to true in order to color the (regularly uncolored) App Launchers
		%orig(getColorForLayer(self, arg1, YES));
	}
%end

%hook CAShapeLayer
	-(void)setFillColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}
%end

void forceLayerUpdate(NSArray *layers) {
	for (CALayer *sublayer in layers) {
		if ([sublayer isMemberOfClass:%c(CAShapeLayer)]) {
			CAShapeLayer *shapelayer = (CAShapeLayer *)sublayer;
			if (shapelayer.fillColor != nil) shapelayer.fillColor = shapelayer.fillColor;
		} else {
			if (sublayer.backgroundColor != nil) sublayer.backgroundColor = sublayer.backgroundColor;
			if (sublayer.borderColor != nil) sublayer.borderColor = sublayer.borderColor;
			if (sublayer.contentsMultiplyColor != nil) sublayer.contentsMultiplyColor = sublayer.contentsMultiplyColor;

			// Fix dark mode toggle being always white
			if (sublayer.filters != nil && [sublayer.name isEqual:@"outer"]) sublayer.filters = nil;
		}

		forceLayerUpdate(sublayer.sublayers);
	}
}

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty) {
	if (!overwriteEmpty &&
		(
			   originalColor == nil
			|| ([layer.compositingFilter isMemberOfClass:%c(CAFilter)] && [((CAFilter*)layer.compositingFilter).name isEqual:@"subtractS"]) // Fixes the dark mode toggle
			|| (CGColorGetNumberOfComponents(originalColor) >= 4 && CGColorGetComponents(originalColor)[3] == 0)
		)
	) {
		return originalColor;
	}

	CALayer *currentLayer = layer;
	while(currentLayer.delegate == nil && currentLayer != currentLayer.superlayer && currentLayer.superlayer != nil) {
		currentLayer = currentLayer.superlayer;
	}

	if ([currentLayer.delegate respondsToSelector:@selector(_viewControllerForAncestor)]) {
		UIViewController *controller = [((UIView*)currentLayer.delegate) _viewControllerForAncestor];

		if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)] || [controller isKindOfClass:%c(HUCCModuleContentViewController)] || [controller isKindOfClass:%c(AXCCIconViewController)]) {

			// Ugly fix to restore the default colors for expanded modules (TODO improve this?)
			if ([layer.compositingFilter isEqual:@"plusD"]) return prefBool(@"togglesHideContainer") ? [[UIColor clearColor] CGColor] : [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.05] CGColor];
			if ([((UIView*)currentLayer.delegate)._ui_superview isKindOfClass:%c(CCUIMenuModuleItemView)] || [((UIView*)currentLayer.delegate)._ui_superview isKindOfClass:%c(BSUIEmojiLabelView)]) return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00] CGColor];
			if ([currentLayer.delegate isKindOfClass:%c(MPAVHighlightedControl)]) return originalColor;

			UIColor *toggleColor = getToggleColor(controller);

			if (prefValueEquals(@"togglesOverlayMode", @"colorOverlay") && [controller respondsToSelector:@selector(isSelected)] && [((CCUIButtonModuleViewController*)controller) isSelected]) {
				if (toggleColor == nil) toggleColor = [UIColor colorWithCGColor:originalColor];

				if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(MTMaterialView)]) {
					((MTMaterialView*)currentLayer.delegate).configuration = 1;
					return [toggleColor CGColor];
				}

				if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && [currentLayer.delegate isKindOfClass:%c(_MTBackdropView)]) {
					((_MTBackdropView*)currentLayer.delegate).colorAddColor = nil;
					((_MTBackdropView*)currentLayer.delegate).brightness = 0;
					return [toggleColor CGColor];
				}

				return [toggleColor isBrightColor] ? [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0] CGColor] : [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}

			if (toggleColor != nil) return [toggleColor CGColor];

			// Reset to white for off state if no other color was chosen
			if (![controller respondsToSelector:@selector(isSelected)] || ![((CCUIButtonModuleViewController*)controller) isSelected]) {
				return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}

		} else if([controller isKindOfClass:%c(CCUILabeledRoundButtonViewController)]) {

			layer.opacity = ([layer.name isEqual:@"disabled"] || [layer.name isEqual:@"bluetoothdisabled"]) ? 0 : 1;
			return getConnectivityGlyphColor((CCUILabeledRoundButtonViewController*)controller);

		}	else if([controller isKindOfClass:%c(MRPlatterViewController)]) {

			if ([((UIView *)currentLayer.delegate).parentFocusEnvironment isKindOfClass:%c(MediaControlsTimeControl)]) {
				if (prefValue(@"mediaControlsSlider") && (!([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) || prefBool(@"mediaControlsColorLockscreen"))) {
					return [[UIColor RGBAColorFromHexString:prefValue(@"mediaControlsSlider")] CGColor];
				}
			}

		}

	}

	return originalColor;
}

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
