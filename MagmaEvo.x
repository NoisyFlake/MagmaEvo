/*

	Magma Evo
	Your Control Center. Redefined.

	Copyright (C) 2019 by NoisyFlake

	All Rights Reserved

*/

#import "MagmaEvo.h"

%hook CALayer
	-(void)setBackgroundColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setBorderColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}

	-(void)setContentsMultiplyColor:(CGColorRef)arg1 {
		// Need to set overwriteEmpty to true in order to color App Launchers
		%orig(getColorForLayer(self, arg1, YES));
	}
%end

%hook CAShapeLayer
	-(void)setFillColor:(CGColorRef)arg1 {
		%orig(getColorForLayer(self, arg1, NO));
	}
%end

%hook CCUIButtonModuleView
	-(void)setGlyphState:(NSString *)arg1 {
		%orig;
		HBLogWarn(@"Forcing Layer Update");

		forceLayerUpdate(self.layer.sublayers);
	}
%end

static void forceLayerUpdate(NSArray *layers) {
	for (CALayer *sublayer in layers) {
		if ([sublayer isMemberOfClass:%c(CAShapeLayer)]) {
			CAShapeLayer *shapelayer = (CAShapeLayer *)sublayer;
			if (shapelayer.fillColor != nil) shapelayer.fillColor = shapelayer.fillColor;
		} else {
			if (sublayer.backgroundColor != nil) sublayer.backgroundColor = sublayer.backgroundColor;
			if (sublayer.borderColor != nil) sublayer.borderColor = sublayer.borderColor;
			if (sublayer.contentsMultiplyColor != nil) sublayer.contentsMultiplyColor = sublayer.contentsMultiplyColor;
		}

		forceLayerUpdate(sublayer.sublayers);
	}
}

static CGColorRef getColorForLayer(CALayer *layer, CGColorRef originalColor, BOOL overwriteEmpty) {
	if (!overwriteEmpty && (originalColor == nil || (CGColorGetNumberOfComponents(originalColor) >= 4 && CGColorGetComponents(originalColor)[3] == 0))) {
		return originalColor;
	}

	CALayer *currentLayer = layer;
	while(currentLayer.delegate == nil && currentLayer != currentLayer.superlayer && currentLayer.superlayer != nil) {
		currentLayer = currentLayer.superlayer;
	}

	if ([currentLayer.delegate respondsToSelector:@selector(_viewControllerForAncestor)]) {
		UIViewController *controller = [((UIView*)currentLayer.delegate) _viewControllerForAncestor];
		// NSString *description = [controller description];
		// HBLogWarn(@"Controller: %@", description);

		if ([controller isKindOfClass:%c(CCUIAppLauncherViewController)]) {
			return [UIColor.yellowColor CGColor];
		} else if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)]) {
			if ([((CCUIButtonModuleViewController*)controller) isSelected]) {
				return [UIColor.magentaColor CGColor];
			} else {
				// Default white
				return [[UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0] CGColor];
			}
		}
	}


	return originalColor;
}

