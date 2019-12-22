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

		if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)] || [controller isKindOfClass:%c(HUCCModuleContentViewController)]) {

			// Ugly fix for the expanded view of some modules
			if ([controller respondsToSelector:@selector(isExpanded)] && [(CCUIButtonModuleViewController*)controller isExpanded]) {
				if (((UIView*)currentLayer.delegate).backgroundColor != nil) return [[UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.05] CGColor];
				if ([((UIView*)currentLayer.delegate)._ui_superview isKindOfClass:%c(CCUIMenuModuleItemView)]) return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00] CGColor];
				return originalColor;
			}

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
			}else if([controller respondsToSelector:@selector(contentModuleContext)]) {
				CCUIContentModuleContext *context = [(CCUIButtonModuleViewController *)controller contentModuleContext];
				identifier = context.moduleIdentifier;
			}

			NSString *prefKey = nil;
			if ([controller respondsToSelector:@selector(isSelected)]) {
				prefKey = [NSString stringWithFormat:@"%@%@", identifier, [((CCUIButtonModuleViewController*)controller) isSelected] ? @"Enabled" : @"Disabled"];
			} else {
				prefKey = [NSString stringWithFormat:@"%@%@", identifier, @"Disabled"];
			}

			if (prefValue(prefKey)) return [[UIColor RGBAColorFromHexString:prefValue(prefKey)] CGColor];

			// Reset to white for off state if no other color was chosen
			if (![controller respondsToSelector:@selector(isSelected)] || ![((CCUIButtonModuleViewController*)controller) isSelected]) {
				return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}

		} else if([controller isKindOfClass:%c(CCUILabeledRoundButtonViewController)]) {
			layer.opacity = ([layer.name isEqual:@"disabled"] || [layer.name isEqual:@"bluetoothdisabled"]) ? 0 : 1;
			return getConnectivityColor((CCUILabeledRoundButtonViewController*)controller);
		}

	}

	return originalColor;
}

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
