#import "MagmaEvo.h"

%hook _UIStatusBar
	-(void)setForegroundColor:(UIColor*)color {

		if (prefValue(@"miscStatusBarColor") != nil || prefBool(@"miscStatusBarHide")) {
			UIView *parent = ((UIView* )self.parentFocusEnvironment).parentFocusEnvironment;

			if ([parent isKindOfClass:%c(CCUIStatusBar)] && ((CCUIStatusBar *)parent).leadingAlpha > 0) {
				if (prefValue(@"miscStatusBarColor") != nil) color = [UIColor evoRGBAColorFromHexString:prefValue(@"miscStatusBarColor")];
				if (prefBool(@"miscStatusBarHide")) self.alpha = 0;
			} else {
				if (prefBool(@"miscStatusBarHide")) self.alpha = 1;
			}
		}

		%orig;
	}
%end

%hook CCUIModularControlCenterOverlayViewController
	-(void)presentAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 {
		%orig;

		if (prefValue(@"miscMainBackground")) {
			self.overlayBackgroundView.backgroundColor = [UIColor evoRGBAColorFromHexString:prefValue(@"miscMainBackground")];

			NSArray *filters = self.overlayBackgroundView.layer.sublayers != nil ? self.overlayBackgroundView.layer.sublayers[0].filters : self.overlayBackgroundView.layer.filters;

			NSMutableArray *mutableFilters = [filters mutableCopy];
			for (CAFilter *filter in [mutableFilters reverseObjectEnumerator]) {
				if (![filter.name isEqual:@"gaussianBlur"]) {
					[mutableFilters removeObject:filter];
				}
			}

			if (self.overlayBackgroundView.layer.sublayers != nil) {
				self.overlayBackgroundView.layer.sublayers[0].filters = mutableFilters;
			} else {
				self.overlayBackgroundView.layer.filters = mutableFilters;
			}
		}
	}
%end

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
