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
		/* NSString *description = [controller description]; */
		// if ([controller isMemberOfClass:%c(CCUIToggleViewController)]) {
		// 	CCUIToggleModule *module = ((CCUIToggleViewController *)controller).module;
		// 	description = [module description];
		// }
		/* HBLogWarn(@"Controller: %@", description); */

		if (([controller isKindOfClass:%c(HUCCModuleContentViewController)] || [controller isKindOfClass:%c(CCUIAppLauncherViewController)]) && layer.contents != nil) {
			// App Launchers and Home Module
			return [UIColor.yellowColor CGColor];

		} else if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)]) {
			// Toggle Modules
			if ([((CCUIButtonModuleViewController*)controller) isSelected]) {
				return [UIColor.magentaColor CGColor];
			} else {
				// Default white
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
