#import "MagmaEvo.h"

%hook MediaControlsMaterialView
  -(id)initWithFrame:(CGRect)arg1 {
    MediaControlsMaterialView *orig = %orig;
    if (prefBool(@"mediaControlsHideContainer")) orig.alpha = 0;
    return orig;
  }
%end

%hook MediaControlsTransportStackView
  -(void)layoutSubviews {
    %orig;

    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen
    if (([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) && !prefBool(@"mediaControlsColorLockscreen")) return;

    if (prefValue(@"mediaControlsLeftButton") != nil) {
      MediaControlsTransportButton *leftButton = self.leftButton;
      leftButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor RGBAColorFromHexString:prefValue(@"mediaControlsLeftButton")] CGColor];
    }

    if (prefValue(@"mediaControlsMiddleButton") != nil) {
      MediaControlsTransportButton *middleButton = self.middleButton;
      middleButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor RGBAColorFromHexString:prefValue(@"mediaControlsMiddleButton")] CGColor];
    }

    if (prefValue(@"mediaControlsRightButton") != nil) {
      MediaControlsTransportButton *rightButton = self.rightButton;
      rightButton.layer.sublayers[0].contentsMultiplyColor = [[UIColor RGBAColorFromHexString:prefValue(@"mediaControlsRightButton")] CGColor];
    }

  }
%end

%hook MediaControlsHeaderView
  -(void)_updateStyle {
    %orig;

    UIViewController *controller = self._viewControllerForAncestor;

    // Don't color controls on the lockscreen or the AirPlay view under the expanded View
    if ((([controller.parentViewController isKindOfClass:%c(CSMediaControlsViewController)] || [controller.parentViewController isKindOfClass:%c(SBDashBoardMediaControlsViewController)]) && !prefBool(@"mediaControlsColorLockscreen")) || self.buttonType == 0) return;

    if (prefValue(@"mediaControlsPrimaryLabel") != nil) {
      self.primaryLabel.textColor = [UIColor RGBAColorFromHexString:prefValue(@"mediaControlsPrimaryLabel")];
    }

    if (prefValue(@"mediaControlsSecondaryLabel") != nil) {
      self.secondaryLabel.textColor = [UIColor RGBAColorFromHexString:prefValue(@"mediaControlsSecondaryLabel")];
      self.secondaryLabel.layer.filters = nil;
    }

  }
%end

%ctor {
	if (prefBool(@"enabled")) {
		%init;
	}
}
