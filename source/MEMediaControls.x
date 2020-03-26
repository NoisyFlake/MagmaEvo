#import "MagmaEvo.h"

%hook MediaControlsMaterialView
  -(id)initWithFrame:(CGRect)arg1 {
    MediaControlsMaterialView *orig = %orig;

    if ([settings valueForKey:@"mediaControlsContainerBackground"]) {
			UIView *view = [self safeValueForKey:@"_backgroundView"];

			if ([view respondsToSelector:@selector(configuration)]) {
				((MTMaterialView *)view).configuration = 1;
			} else {
				view = [view safeValueForKey:@"_backdropView"];
				((_MTBackdropView *)view).colorAddColor = nil;
				((_MTBackdropView *)view).brightness = 0;
			}

			view.backgroundColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsContainerBackground"]];
		}

    return orig;
  }
%end

%hook MediaControlsTransportStackView
  -(void)layoutSubviews {
    %orig;

    [self magmaEvoColorize];
  }

  -(void)didMoveToWindow {
    %orig;

    [self magmaEvoColorize];
  }

  %new
  -(void)magmaEvoColorize {
    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"]) return;

    if ([settings valueForKey:@"mediaControlsLeftButton"] != nil) {
      self.leftButton.imageView.image = [self.leftButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      self.leftButton.imageView.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsLeftButton"]];
    }

    if ([settings valueForKey:@"mediaControlsMiddleButton"] != nil) {
      self.middleButton.imageView.image = [self.middleButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      self.middleButton.imageView.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsMiddleButton"]];
    }

    if ([settings valueForKey:@"mediaControlsRightButton"] != nil) {
      self.rightButton.imageView.image = [self.rightButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
      self.rightButton.imageView.tintColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRightButton"]];
    }

    if ([settings valueForKey:@"mediaControlsRoutingButton"] != nil && [controller isKindOfClass:%c(MRPlatterViewController)]) {
      forceLayerUpdate(((MRPlatterViewController *)controller).routingCornerView.layer.sublayers);
    }
  }
%end

%hook NextUpMediaHeaderView
  -(void)_updateStyle {
    %orig;

    [self magmaEvoColorize];
  }
%end

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

    if ([settings valueForKey:@"mediaControlsPrimaryLabel"] != nil) {
      self.primaryLabel.textColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsPrimaryLabel"]];
    }

    if ([settings valueForKey:@"mediaControlsSecondaryLabel"] != nil) {
      self.secondaryLabel.textColor = [UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsSecondaryLabel"]];
      self.secondaryLabel.layer.filters = nil;
    }
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
