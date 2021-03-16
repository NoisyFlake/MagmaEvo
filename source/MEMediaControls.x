#import "MagmaEvo.h"

// iOS 13
%hook MediaControlsMaterialView
  -(id)initWithFrame:(CGRect)arg1 {
    MediaControlsMaterialView *orig = %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];

    return orig;
  }

  %new
  -(void)magmaEvoColorize {
    [MagmaHelper colorizeMaterialView:[self safeValueForKey:@"_backgroundView"] forSetting:@"mediaControlsContainerBackground"];
  }
%end

// iOS 14
%hook MRUNowPlayingView
  -(void)didMoveToWindow {
    %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(MRUCoverSheetViewController)] || [controller isKindOfClass:%c(QRTMediaModuleViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    [MagmaHelper colorizeMaterialView:self.superview.subviews[0] forSetting:@"mediaControlsContainerBackground"];
  }
%end

%hook MRUNowPlayingRoutingButton
-(void)layoutSubviews {
  %orig;

  [self magmaEvoColorize];
  [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
}

%new
-(void)magmaEvoColorize {

  // In iOS 14, we need to actually trigger the coloring here, no idea why though
  forceLayerUpdate(self.packageView.layer.sublayers);
}
%end

// iOS 13
%hook MediaControlsTransportStackView
  -(void)layoutSubviews {
    %orig;

    [self magmaEvoColorize];
  }

  -(void)didMoveToWindow {
    %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] || [controller isKindOfClass:%c(QRTMediaModuleViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    self.leftButton.imageView.image = [self.leftButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftButton.imageView.tintColor = [settings valueForKey:@"mediaControlsLeftButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsLeftButton"]] : [UIColor whiteColor];

    self.middleButton.imageView.image = [self.middleButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.middleButton.imageView.tintColor = [settings valueForKey:@"mediaControlsMiddleButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsMiddleButton"]] : [UIColor whiteColor];

    self.rightButton.imageView.image = [self.rightButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightButton.imageView.tintColor = [settings valueForKey:@"mediaControlsRightButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRightButton"]] : [UIColor whiteColor];

    if ([controller isKindOfClass:%c(MRPlatterViewController)]) {
      forceLayerUpdate(((MRPlatterViewController *)controller).routingCornerView.layer.sublayers);
    }
  }
%end

// iOS 14
%hook MRUNowPlayingTransportControlsView
  -(void)updateResponse {
    %orig;

    [self magmaEvoColorize];
  }

  -(void)didMoveToWindow {
    %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(MRUCoverSheetViewController)] || [controller isKindOfClass:%c(QRTMediaModuleViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    self.leftButton.imageView.image = [self.leftButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftButton.imageView.tintColor = [settings valueForKey:@"mediaControlsLeftButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsLeftButton"]] : [UIColor whiteColor];

    self.middleButton.imageView.image = [self.middleButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.middleButton.imageView.tintColor = [settings valueForKey:@"mediaControlsMiddleButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsMiddleButton"]] : [UIColor whiteColor];

    self.rightButton.imageView.image = [self.rightButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rightButton.imageView.tintColor = [settings valueForKey:@"mediaControlsRightButton"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRightButton"]] : [UIColor whiteColor];

    if ([controller isKindOfClass:%c(MRPlatterViewController)]) {
      forceLayerUpdate(((MRPlatterViewController *)controller).routingCornerView.layer.sublayers);
    }
  }
%end

// iOS 13
%hook MediaControlsTimeControl
  -(void)setStyle:(long long)arg1 {
    %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
  }

  %new
  -(void)magmaEvoColorize {
     UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    self.elapsedTrack.backgroundColor = [settings valueForKey:@"mediaControlsSlider"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSlider"]] : UIColor.whiteColor;
  }
%end

// iOS 14
%hook MRUNowPlayingTimeControlsView
  -(void)updateVisualStyling {
    %orig;

    [self magmaEvoColorize];
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(magmaEvoColorize) name:@"com.noisyflake.magmaevo/reload" object:nil];
  }

  %new
  -(void)magmaEvoColorize {
     UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(MRUCoverSheetViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    self.elapsedTrack.backgroundColor = [settings valueForKey:@"mediaControlsSlider"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSlider"]] : UIColor.whiteColor;
  }
%end

%hook NextUpMediaHeaderView
  -(void)_updateStyle {
    %orig;

    [self magmaEvoColorize];
  }
%end

// iOS 13
%hook MediaControlsHeaderView
  -(void)_updateStyle {
    %orig;

    [self magmaEvoColorize];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen or the AirPlay view under the expanded View
    if ((([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] ||
          [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] ||
          ([controller isKindOfClass:%c(NextUpViewController)] && !((NextUpViewController *)controller).controlCenter)
          ) && ![settings boolForKey:@"mediaControlsColorLockscreen"])) return;

    self.primaryLabel.textColor = [settings valueForKey:@"mediaControlsPrimaryLabel"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsPrimaryLabel"]] : [UIColor whiteColor];

    self.secondaryLabel.textColor = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSecondaryLabel"]] : [UIColor whiteColor];
    self.secondaryLabel.layer.filters = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? nil : self.secondaryLabel.layer.filters;
  }
%end

// iOS 14
%hook MRUNowPlayingLabelView
  -(void)updateVisualStyling {
    %orig;

    [self magmaEvoColorize];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen or the AirPlay view under the expanded View
    if ((([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] ||
          [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)] ||
          [controller.parentViewController isKindOfClass:%c(MRUCoverSheetViewController)] ||
          ([controller isKindOfClass:%c(NextUpViewController)] && !((NextUpViewController *)controller).controlCenter)
          ) && ![settings boolForKey:@"mediaControlsColorLockscreen"])) return;

    self.titleLabel.textColor = [settings valueForKey:@"mediaControlsPrimaryLabel"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsPrimaryLabel"]] : [UIColor whiteColor];

    self.subtitleLabel.textColor = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSecondaryLabel"]] : [UIColor whiteColor];
    self.subtitleLabel.layer.filters = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? nil : self.subtitleLabel.layer.filters;

    self.placeholderLabel.textColor = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSecondaryLabel"]] : [UIColor whiteColor];
    self.placeholderLabel.layer.filters = [settings valueForKey:@"mediaControlsSecondaryLabel"] ? nil : self.subtitleLabel.layer.filters;
  }
%end

%ctor {
  settings = [MagmaPrefs sharedInstance];

	if ([settings boolForKey:@"enabled"]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/NextUp.dylib"]) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/NextUp.dylib", RTLD_LAZY);
		}

		%init;
	}
}
