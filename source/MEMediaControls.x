#import "MagmaEvo.h"

%hook MediaControlsMaterialView
  -(id)initWithFrame:(CGRect)arg1 {
    MediaControlsMaterialView *orig = %orig;
    if ([settings boolForKey:@"mediaControlsHideContainer"]) orig.alpha = 0;
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
      MediaControlsTransportButton *leftButton = self.leftButton;
      leftButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsLeftButton"]] CGColor];
    }

    if ([settings valueForKey:@"mediaControlsMiddleButton"] != nil) {
      MediaControlsTransportButton *middleButton = self.middleButton;
      middleButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsMiddleButton"]] CGColor];
    }

    if ([settings valueForKey:@"mediaControlsRightButton"] != nil) {
      MediaControlsTransportButton *rightButton = self.rightButton;
      rightButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor evoRGBAColorFromHexString:[settings valueForKey:@"mediaControlsRightButton"]] CGColor];
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
    if ((([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) && ![settings boolForKey:@"mediaControlsColorLockscreen"])) return;

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
		%init;
	}
}
