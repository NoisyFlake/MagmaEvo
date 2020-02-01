#import "MagmaEvo.h"

%hook _UIStatusBar
	-(void)setForegroundColor:(UIColor*)color {

		if ([settings valueForKey:@"miscStatusBarColor"] != nil) {
			UIView *parent = ((UIView* )self.parentFocusEnvironment).parentFocusEnvironment;

			if ([parent isKindOfClass:%c(CCUIStatusBar)] && ((CCUIStatusBar *)parent).leadingAlpha > 0) {
				color = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"miscStatusBarColor"]];
			}
		}

		%orig;
	}
%end

%hook CCUIModularControlCenterOverlayViewController
	-(void)presentAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 {
		%orig;

		if ([settings valueForKey:@"miscMainBackground"]) {
			self.overlayBackgroundView.backgroundColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"miscMainBackground"]];

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

		// Move the current scroll position to the bottom of the CC
		if ([[settings valueForKey:@"miscMainAlignment"] isEqual:@"bottom"] && self.overlayInterfaceOrientation == 1) {
			CGRect overlayScrollViewBounds = self.overlayScrollView.bounds;
	        overlayScrollViewBounds.origin.y = self.overlayContainerView.frame.size.height - self.overlayScrollView.frame.size.height;
	        self.overlayScrollView.bounds = overlayScrollViewBounds;
	    }
	}

	- (void)viewWillLayoutSubviews {
    	%orig;

    	// Either activate the blur on the status bar container or move it further down
    	if (![settings boolForKey:@"miscStatusBarHide"] && [[settings valueForKey:@"miscMainAlignment"] isEqual:@"bottom"] && self.overlayInterfaceOrientation == 1) {
	        if (self.overlayScrollView.bounds.origin.y > (self.overlayHeaderView.frame.size.height * -1)) {
	        	self.overlayHeaderView.backgroundAlpha = 1;
	    	} else {
	    		CGRect overlayHeaderViewFrame = self.overlayHeaderView.frame;
	    		overlayHeaderViewFrame.origin.y = (self.overlayScrollView.bounds.origin.y + self.overlayHeaderView.frame.size.height) * -1;
	    		self.overlayHeaderView.frame = overlayHeaderViewFrame;
	    	}
	    }
    }

    -(void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 {
    	// Make sure the status bar gets back to it's original place before disappearing to not mess up the animation
    	if (![settings boolForKey:@"miscStatusBarHide"] && [[settings valueForKey:@"miscMainAlignment"] isEqual:@"bottom"] && self.overlayInterfaceOrientation == 1) {
    		CGRect overlayHeaderViewFrame = self.overlayHeaderView.frame;
    		overlayHeaderViewFrame.origin.y = 0;
    		self.overlayHeaderView.frame = overlayHeaderViewFrame;
	    }

    	%orig;
    }

    -(CCUIHeaderPocketView *)overlayHeaderView {
    	if ([settings boolForKey:@"miscStatusBarHide"]) return nil;
    	return %orig;
    }

%end

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		%init;
	}
}
