#import "MagmaEvo.h"

%hook _UIStatusBar
	-(void)setForegroundColor:(UIColor*)color {

		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];

		if ([settings valueForKey:@"miscStatusBarColor"] != nil) {
			UIView *parent = ((UIView* )self.parentFocusEnvironment).parentFocusEnvironment;

			if ([parent isKindOfClass:%c(CCUIStatusBar)] && ((CCUIStatusBar *)parent).leadingAlpha > 0) {
				color = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"miscStatusBarColor"]];
			}
		}

		%orig;
	}

	%new
	-(void)magmaEvoColorize {
		[self setForegroundColor:UIColor.whiteColor];
	}
%end

%hook CCUIModularControlCenterOverlayViewController
	-(void)presentAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 {
		%orig;

		[self magmaEvoColorizeMain];
		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorizeMain) name:@"com.noisyflake.magmaevo/reload" object:nil];

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

	%new
	-(void)magmaEvoColorizeMain {
		UIView *view = self.overlayBackgroundView;
		if ([view safeValueForKey:@"_backdropView"]) view = [view safeValueForKey:@"_backdropView"];

		for (CAFilter *filter in view.layer.filters) {
			if (![filter.name isEqual:@"gaussianBlur"]) {
				filter.enabled = [settings valueForKey:@"miscMainBackground"] ? NO : YES;
			}
		}

		view.backgroundColor = [MagmaHelper colorForKey:@"miscMainBackground" withFallback:nil];
	}

%end

%hook CCUIContentModuleContentContainerView
	-(void)didMoveToWindow {
		%orig;

		[self magmaEvoColorize];
		[[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
	}

	%new
	-(void)magmaEvoColorize {
		NSString *preferenceKey = nil;

		UIViewController *controller = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).contentViewController;
		NSString *module = ((CCUIContentModuleContainerViewController *)self._viewControllerForAncestor).moduleIdentifier;

		MTMaterialView *matView = [self safeValueForKey:@"_moduleMaterialView"];

		if ([module isEqual:@"com.apple.control-center.ConnectivityModule"]) {

			preferenceKey = @"connectivityContainerBackground";

		} else if ([module isEqual:@"com.muirey03.powermodule"]) {

			preferenceKey = @"powerModuleContainerBackground";

		} else if ([controller isKindOfClass:%c(HACCModuleViewController)]) {

			preferenceKey = @"togglesContainerBackground";
			if (!matView) matView = controller.view.subviews[1]; // iOS 12

		} else if ([controller isKindOfClass:%c(TVRMContentViewController)]) {

			preferenceKey = @"togglesContainerBackground";
			if (!matView) matView = ((TVRMContentViewController *)controller).buttonModuleViewController.buttonView.subviews[0]; // iOS 12

		} else 	if ([controller isKindOfClass:%c(CCUIButtonModuleViewController)] ||
			[controller isKindOfClass:%c(HUCCModuleContentViewController)] ||
			[controller isKindOfClass:%c(AXCCTextSizeModuleViewController)] ||
			[controller isKindOfClass:%c(WSUIModuleContentViewController)] ||
			[module isEqual:@"com.apple.accessibility.controlcenter.hearingdevices"]
		) {

			preferenceKey = @"togglesContainerBackground";

		} else if ([controller isKindOfClass:%c(BCIWeatherContentViewController)]) {

			preferenceKey = @"betterCCXIContainerBackground";

		} else if ([controller isKindOfClass:%c(CCUIDisplayModuleViewController)] ||
			[controller isKindOfClass:%c(CCUIAudioModuleViewController)] ||
			[controller isKindOfClass:%c(CCRingerModuleContentViewController)]) {

			preferenceKey = @"slidersContainerBackground";
		}


		if (preferenceKey) {
			[MagmaHelper colorizeMaterialView:matView forSetting:preferenceKey];
		}
	}
%end

%hook UIRootSceneWindow
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	%orig;

	if (self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
		[settings loadPresetForStyle:self.traitCollection.userInterfaceStyle];
	}

}
%end

%hook NCTToggleModule
-(void)setSelected:(BOOL)arg1 {
	%orig;

	[settings loadPresetForStyle:arg1 ? 2 : 1];
}
%end

%ctor {
	settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {

		// Load Noctis12 so we can use the hook for it
		NSFileManager *fileManager= [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:@"/Library/ControlCenter/Bundles/NoctisToggle.bundle/"]) {
			[[NSBundle bundleWithPath:@"/Library/ControlCenter/Bundles/NoctisToggle.bundle/"] load];
		}

		%init;
	}
}
